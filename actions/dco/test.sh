#!/usr/bin/env bash
# Regression cases for check.sh: a fake `gh` returns fixture commits, so no
# network or token is needed. Run: actions/dco/test.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mkdir "$work/bin"
cat >"$work/bin/gh" <<'GH'
#!/usr/bin/env bash
cat "$FIXTURE"
GH
chmod +x "$work/bin/gh"

# commit sha parents-json author-name author-email message
commit() {
  jq -cn --arg sha "$1" --argjson p "$2" --arg n "$3" --arg e "$4" --arg m "$5" \
    '{sha: $sha, parents: $p, commit: {author: {name: $n, email: $e}, message: $m}}'
}
# web-commit sha parents-json committer-name committer-email verified message:
# shaped like the merge GitHub creates for "Update branch".
web_commit() {
  jq -cn --arg sha "$1" --argjson p "$2" --arg cn "$3" --arg ce "$4" --argjson v "$5" --arg m "$6" \
    '{sha: $sha, parents: $p, commit: {author: {name: "Danilo Stein", email: "danilo@example.org"},
      committer: {name: $cn, email: $ce}, verification: {verified: $v, reason: (if $v then "valid" else "unsigned" end)},
      message: $m}}'
}
dependabot="49699333+dependabot[bot]@users.noreply.github.com"
ada="1234+ada@users.noreply.github.com"
signed() { printf '%s\n\nSigned-off-by: %s <%s>' "$1" "$2" "$3"; }

failures=0
# case name want-exit pr-author pr-author-type fixture-lines...
case_() {
  local name="$1" want="$2" author="$3" type="$4"
  shift 4
  printf '%s\n' "$@" >"$work/fixture.json"
  # A broken fixture must fail the case, never pass as "zero commits".
  if [[ "$(jq -s 'length' "$work/fixture.json" 2>/dev/null)" != "$#" ]]; then
    echo "FAIL  $name: invalid fixture"
    failures=$((failures + 1))
    return
  fi
  local got=0
  PATH="$work/bin:$PATH" FIXTURE="$work/fixture.json" GH_TOKEN=x REPO=o/r PR_NUMBER=1 \
    PR_AUTHOR="$author" PR_AUTHOR_TYPE="$type" "$here/check.sh" >/dev/null 2>&1 || got=$?
  if [[ "$got" == "$want" ]]; then
    echo "ok    $name"
  else
    echo "FAIL  $name: exit $got, want $want"
    failures=$((failures + 1))
  fi
}

case_ "signed commit with a noreply + address" 0 ada User \
  "$(commit a1 '[{}]' Ada "$ada" "$(signed fix Ada "$ada")")"
case_ "unsigned commit" 1 ada User \
  "$(commit a2 '[{}]' Ada "$ada" "fix")"
case_ "sign-off by someone other than the author" 1 bob User \
  "$(commit a3 '[{}]' Bob bob@example.org "$(signed fix Alice alice@example.org)")"
case_ "author address --help is a pattern, not an option" 1 eve User \
  "$(commit a4 '[{}]' Eve --help "$(signed fix Eve x@example.org)")"
case_ "empty author address never counts as signed" 1 eve User \
  "$(commit a5 '[{}]' Eve "" "fix")"
case_ "Dependabot commit in a pull request opened by Dependabot" 0 'dependabot[bot]' Bot \
  "$(commit a6 '[{}]' 'dependabot[bot]' "$dependabot" "bump")"
case_ "bot look-alike in a user's pull request" 1 mallory User \
  "$(commit a7 '[{}]' 'dependabot[bot]' "$dependabot" "bump")"
case_ "bot look-alike in another bot's pull request" 1 'renovate[bot]' Bot \
  "$(commit a8 '[{}]' 'dependabot[bot]' "$dependabot" "bump")"
case_ "unsigned merge commit" 1 ada User \
  "$(commit a9 '[{}]' Ada "$ada" "$(signed fix Ada "$ada")")" \
  "$(commit b1 '[{},{}]' Ada "$ada" "Merge branch main")"
case_ "signed-off merge commit" 0 ada User \
  "$(commit b2 '[{},{}]' Ada "$ada" "$(signed 'Merge branch main' Ada "$ada")")"
case_ "GitHub's own Update-branch merge, signed by GitHub" 0 ada User \
  "$(commit c1 '[{}]' Ada "$ada" "$(signed fix Ada "$ada")")" \
  "$(web_commit c2 '[{},{}]' GitHub noreply@github.com true "Merge branch 'main' into topic")"
case_ "Update-branch look-alike without GitHub's verified signature" 1 ada User \
  "$(web_commit c3 '[{},{}]' GitHub noreply@github.com false "Merge branch 'main' into topic")"
case_ "GitHub-committed change that is not a merge" 1 ada User \
  "$(web_commit c4 '[{}]' GitHub noreply@github.com true "Edit file")"
case_ "merge committed as GitHub with another address" 1 ada User \
  "$(web_commit c5 '[{},{}]' GitHub github@example.org true "Merge branch 'main' into topic")"
case_ "Update-branch merge in a Dependabot pull request" 0 'dependabot[bot]' Bot \
  "$(commit c6 '[{}]' 'dependabot[bot]' "$dependabot" "bump")" \
  "$(web_commit c7 '[{},{}]' GitHub noreply@github.com true "Merge branch 'main' into dependabot/x")"
# Too large for a command-line argument, so the message comes from a file.
{
  signed 'large squash' Ada "$ada"
  for n in $(seq 1 3000); do
    printf '\nSigned-off-by: Contributor %s With A Long Name <contributor-%s-with-a-long-address@example.org>' "$n" "$n"
  done
} >"$work/message"
case_ "valid sign-off followed by 3000 more" 0 ada User \
  "$(jq -cn --arg e "$ada" --rawfile m "$work/message" \
    '{sha: "b3", parents: [{}], commit: {author: {name: "Ada", email: $e}, message: $m}}')"

got=0
PATH="$work/bin:$PATH" FIXTURE=/dev/null GH_TOKEN=x REPO=o/r PR_NUMBER='' PR_AUTHOR=x PR_AUTHOR_TYPE=User \
  "$here/check.sh" >/dev/null 2>&1 || got=$?
if [[ "$got" == 2 ]]; then echo "ok    refuses to run outside a pull request"; else
  echo "FAIL  outside a pull request: exit $got, want 2"
  failures=$((failures + 1))
fi

if ((failures > 0)); then
  echo "$failures case(s) failed."
  exit 1
fi
echo "All DCO cases passed."
