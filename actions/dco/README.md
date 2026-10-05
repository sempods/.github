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
      - uses: sempods/.github/actions/dco@<commit-sha> # main
```

Keep the job id `check`: the repository rulesets require a status check of that
name. A `github-actions` entry in the repository's Dependabot configuration
keeps the pin current.

## What it checks

- Every commit, including merge commits, needs a `Signed-off-by` whose address
  equals the commit author's address (case-insensitive, compared as a fixed
  string). Another person's sign-off does not count; an empty address never does.
- Commits of a bot are exempt only in a pull request that this bot account
  opened (for example Dependabot). GitHub authenticates the pull request's
  author; commit author fields are free text.
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
