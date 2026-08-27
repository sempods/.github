# Contributing to sempods

This is the default contributing guide for the [sempods](https://github.com/sempods)
organisation. It carries the terms that hold everywhere — licensing, sign-off,
AI-assisted work. Anything about *building* a particular thing lives in that
repository's own `CONTRIBUTING.md`, which supersedes this file where both exist;
[sempods-kotlin](https://github.com/sempods/sempods-kotlin/blob/main/CONTRIBUTING.md)
is the fullest of them.

sempods is early and currently has one maintainer. Open an issue before a large
change — a rejected pull request after two weeks of work is a bad experience for
both sides, and avoidable.

## No CLA

Contributions are accepted under the **Developer Certificate of Origin** (below).
There is no Contributor License Agreement, and there will not be one.

The reason is worth stating plainly: a CLA exists so that one party can relicense
the project — usually to sell it under different terms. That is not where this
project is going. Everyone, including the maintainer, works under the same
licence.

## What contributions are licensed under

* Code — Apache License 2.0
* Documentation and specification text — CC BY 4.0
* Vocabulary terms — CC BY 4.0 (see
  [`NAMESPACE.md`](https://github.com/sempods/sempods-kotlin/blob/main/NAMESPACE.md))

By contributing, you agree your contribution is licensed under the same terms as
the file it lands in.

## Developer Certificate of Origin

Every commit must carry a `Signed-off-by` line matching the author:

```
git commit -s
```

which appends:

```
Signed-off-by: Your Name <your.email@example.com>
```

By signing off you certify the following (Developer Certificate of Origin 1.1,
Copyright (C) 2004, 2006 The Linux Foundation and its contributors, verbatim):

```
Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

If you contribute on behalf of an employer, make sure you are entitled to — that
is what clause (a) is about.

Automated commits are the one exception, and the checks know it. A dependency
bump opened by Dependabot carries no sign-off, because a bot has no way to add
one and nothing to certify with it — raising a version string is not authorship.
The maintainer who merges the bump is the one taking responsibility for it.

## AI-assisted contributions

sempods is built with AI assistance, and contributions that used it are welcome.
The bar does not change; what matters is responsibility, not which tool typed the
characters.

**You are the author of what you submit.** The `Signed-off-by` line certifies you
have the right to submit the change under the file's licence and that you stand
behind it — a model cannot certify that, which is why the sign-off is yours and
the commit is under your name. If you could not defend the change in review, it
is not ready, whatever drafted it.

**Attribution is honest, not hidden.** When a model did substantial work on a
commit, name it — a `Co-Authored-By:` trailer is the usual way. That adds to your
sign-off; it never stands in for it.

**Provenance is the one risk that review does not catch by reading.** A model can
reproduce code it was trained on, and that code may carry an incompatible licence.
Do not paste large verbatim blocks whose origin you cannot vouch for; keep
contributions small enough to reason about.

**Tested and understood, or not at all.** An unreviewed, untested,
machine-generated pull request costs more to triage than to write, and it will be
closed. Review is the scarce resource on a one-maintainer project.

## Where a change belongs

* **Specification changes** move slower than implementation changes and need a
  written rationale, because other implementations depend on them.
* **Implementation changes** need tests, preferably at the protocol level, since
  that is where the contract lives.
* **Deployment-specific behaviour** is expected to live behind a seam rather than
  in a fork. If the seam you need does not exist yet, say so in an issue.

## Security

Security issues do **not** go in public issues. See
[`SECURITY.md`](https://github.com/sempods/.github/blob/main/SECURITY.md).

### If push protection blocks your push

Push protection scans what you are pushing and refuses commits that carry something
shaped like a credential. The refusal is the system working: the secret has not reached
GitHub.

**Deleting the line and committing again does not clear it.** The earlier commit is still
part of the push and still contains the secret, so the next attempt fails for the same
reason. Rewrite the history instead — `git commit --amend` if it was the last commit, an
interactive rebase if it was further back.

**If the credential was real, rotate it.** It has existed in a working tree, possibly on a
shared machine, possibly in a backup. Taking it out of the history does not un-know it.

**If it is a false positive** — a test fixture, an example key, a public identifier that
merely looks secret — the block message links to a form for saying so. Name which of those
it is; the bypass is recorded either way, and "it's fine" is not a reason.

None of this needs reporting as a vulnerability. The moment it does, because a real
credential did reach a public branch, the channel above is the one to use.

## Code of conduct

Participation is governed by
[`CODE_OF_CONDUCT.md`](https://github.com/sempods/.github/blob/main/CODE_OF_CONDUCT.md).
