# DCO check

Checks that every commit of a pull request carries a `Signed-off-by` line
matching its author, as [CONTRIBUTING.md](../../CONTRIBUTING.md) requires for
all sempods repositories. One implementation, tested here, used everywhere.

## Use it in a repository

In a new repository, choose **Actions → New workflow → DCO sign-off** (the
organisation's workflow template), or add `.github/workflows/dco.yml`, pinned to
a commit of this repository:

```yaml
name: DCO
on:
  pull_request:
permissions:
  contents: read
  pull-requests: read
jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: sempods/.github/actions/dco@<commit-sha> # v1.0.0
```

Pin the commit of a release tag and name the tag in the comment. Keep the job id
`check`: the repository rulesets require a status check of that name.

The `github-actions` entry of the repository's Dependabot configuration proposes
new release tags of this action. By default Dependabot waits three days after a
release (its cooldown). Our own reviewed releases need no waiting period, so
exclude them, while third-party actions keep the cooldown:

```yaml
- package-ecosystem: 'github-actions'
  # …
  cooldown:
    exclude:
      - 'sempods/.github/*'
```

## What it checks

- Every commit, including merge commits, needs a `Signed-off-by` whose address
  equals the commit author's address (case-insensitive, compared as a fixed
  string). Another person's sign-off does not count; an empty address never does.
- Commits of a bot are exempt only in a pull request that this bot account
  opened (for example Dependabot). GitHub authenticates the pull request's
  author; commit author fields are free text.
- A merge commit that GitHub itself created for a signed-in user (the
  **Update branch** button) is accepted without a sign-off, because GitHub adds
  none there. It is recognised by GitHub as committer and by GitHub's own
  signature being verified; a self-signed look-alike is not verified for that
  address. Merges made locally need `git merge --signoff`, or rebase instead.
- Commits are read from the GitHub API as data; nothing from the pull request is
  executed. Pull requests with 250 or more commits are refused rather than
  checked partially.

The DCO is an attestation, not authentication: anyone determined to
misrepresent authorship can write a matching sign-off. The check reminds honest
contributors and records their certification. A pull request can also edit its
own workflow file; such changes are visible in review and owned by the
maintainer through CODEOWNERS.

## Change it

Run `actions/dco/test.sh` (needs `bash` and `jq`). It covers signed and unsigned
commits, foreign sign-offs, unusual and empty addresses, bot exemptions and
look-alikes, merge commits and very long trailer lists. Pull requests here run
it on Linux with GNU tools, and check themselves with the changed action.

## Release a change

After a change to `actions/dco` is merged, tag `main` with the next semantic
version (`v1.0.1` for fixes, `v1.1.0` for new behaviour, `v2.0.0` when callers
must change) and move the pin in `workflow-templates/dco.yml` to that tag's
commit. Dependabot then proposes the new pin in every calling repository with
its next run. Run it early with *Insights → Dependency graph → Dependabot →
Check for updates*, or, for an urgent fix, move the pins by hand with one small
pull request per repository. A pull request whose check still runs an old pin
needs a new run: move the pin in that pull request, or, once the new pin is on
`main`, update the pull request's branch (rebase, or **Update branch**, which the
current version accepts). Re-running the old check does not help, because a
re-run keeps the original commit and therefore the old pin.
