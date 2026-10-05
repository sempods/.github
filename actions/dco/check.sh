#!/usr/bin/env bash
# DCO check shared by the sempods repositories (see README.md next to it).
#
# Every commit of a pull request needs a Signed-off-by line matching its
# author, as CONTRIBUTING.md asks. The DCO is an attestation, not
# authentication: author fields and trailers are free text. This check reminds
# honest contributors and records their certification; it is not an access
# control against someone determined to misrepresent authorship.
#
# It reads commit authors and messages from the GitHub API as data and executes
# nothing from the pull request.
#
# Environment: GH_TOKEN, REPO, PR_NUMBER, PR_AUTHOR, PR_AUTHOR_TYPE.
set -euo pipefail

if [[ -z "${PR_NUMBER:-}" ]]; then
  echo "The DCO check runs on pull_request events only." >&2
  exit 2
fi

# Exempt only commits of the authenticated bot that opened this pull request
# (for example Dependabot): its account type, its exact name and a GitHub
# noreply address. A bot cannot sign and has nothing to certify; the maintainer
# who merges its pull request takes responsibility. Look-alike author fields in
# anyone else's pull request are checked like every other commit.
is_bot_commit() { # name email pr-author pr-author-type
  [[ "$4" == "Bot" && "$1" == "$3" ]] || return 1
  case "$2" in *"[bot]@users.noreply.github.com") return 0 ;; esac
  return 1
}
failed=""
expect() {
  local want="$1" got="check"
  is_bot_commit "$2" "$3" "$4" "$5" && got="skip"
  [[ "$got" == "$want" ]] || {
    echo "self-test: '$2' <$3> in a PR by $4 ($5) = $got, want $want" >&2
    failed=1
  }
}
dependabot="49699333+dependabot[bot]@users.noreply.github.com"
expect skip "dependabot[bot]" "$dependabot" "dependabot[bot]" "Bot"
expect check "dependabot[bot]" "$dependabot" "mallory" "User"
expect check "dependabot[bot]" "$dependabot" "renovate[bot]" "Bot"
expect check "Ada Lovelace" "1234+ada@users.noreply.github.com" "dependabot[bot]" "Bot"
expect check "dependabot[bot]" "someone@example.org" "dependabot[bot]" "Bot"
[[ -z "$failed" ]] || exit 3

# The API lists at most 250 commits of a pull request; refuse rather than
# check a partial range.
commits="$(gh api --paginate "repos/$REPO/pulls/$PR_NUMBER/commits?per_page=100" --jq '.[]' | jq -s '.')"
count="$(jq 'length' <<<"$commits")"
if ((count >= 250)); then
  echo "This pull request has $count or more commits; split it to check every sign-off." >&2
  exit 1
fi

is_github_web_merge() { # commit-json
  [[ "$(jq -r '[(.parents | length) > 1, .commit.committer.name == "GitHub",
    .commit.committer.email == "noreply@github.com",
    .commit.verification.verified == true] | all' <<<"$1")" == "true" ]]
}

missing=""
for i in $(seq 0 $((count - 1))); do
  commit="$(jq -c ".[$i]" <<<"$commits")"
  sha="$(jq -r '.sha' <<<"$commit")"
  name="$(jq -r '.commit.author.name' <<<"$commit")"
  email="$(jq -r '.commit.author.email' <<<"$commit")"
  is_bot_commit "$name" "$email" "$PR_AUTHOR" "$PR_AUTHOR_TYPE" && continue
  # Merge commits are checked too: a merge can carry conflict resolutions or
  # other changes of its own. The exception is a merge that GitHub itself
  # created for a signed-in user ("Update branch" in a pull request): GitHub
  # adds no sign-off there. GitHub is then the committer and its own signature
  # is reported as verified; a self-signed look-alike with that committer
  # address cannot be verified for it.
  is_github_web_merge "$commit" && continue
  #
  # Only the author's own sign-off counts; another person cannot certify on
  # their behalf. Addresses are collected first (grep -q in a pipeline would
  # stop reading early and, with pipefail, a SIGPIPE upstream would reject a
  # valid commit), compared as fixed strings passed with -e (`+`, `.` and a
  # leading `-` are never syntax), and an empty address or an empty sign-off
  # set never counts as signed (an empty pattern matches every line).
  signoffs="$(jq -r '.commit.message' <<<"$commit" |
    sed -n 's/^[Ss]igned-off-by:[[:space:]]*.*<\(.*\)>[[:space:]]*$/\1/p')"
  if [[ -n "$email" && -n "$signoffs" ]] &&
    grep -qixF -e "$email" <<<"$signoffs"; then
    continue
  fi
  subject="$(jq -r '.commit.message | split("\n")[0]' <<<"$commit")"
  missing+="  ${sha:0:12}  $subject (author: $email)"$'\n'
done

if [[ -n "$missing" ]]; then
  echo "These commits carry no Signed-off-by line matching their author:"
  echo "$missing"
  echo "Add it with: git rebase --signoff <base> && git push --force-with-lease"
  echo "New commits: git commit -s (merges: git merge --signoff, or rebase)"
  exit 1
fi
echo "All $count commits signed off."
