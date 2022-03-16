# So You're A Developer At Eaze...

## Why This Fork Exists

This fork is primarily motivated by wanting support for SQL Server's `GO`
statement, as
[implemented in this upstream pull request](https://github.com/golang-migrate/migrate/pull/666)
without waiting for the maintainers to accept the changes. It additionally
[allows the SQL Server tests to be run on an M1 Mac](https://github.com/golang-migrate/migrate/pull/714).
In general, we may use this branch for floating *any* patches which are slow
to merge upstream.

## What's In This Fork (i.e., The Changelog)

Currently, this fork floats the following patches:

- GitHub Action updates to support releasing builds of the fork ([commit](https://github.com/eaze/migrate/commit/d01de3edf981218e098eef51effefb7c915388a4))
- Scripts to support a fork maintenance workflow ([commit](https://github.com/eaze/migrate/commit/be1e44ce894fd57bac6a7e3e8727bfb420617c12))
- Arm-Mac-compatible testing with [Azure SQL Edge](https://hub.docker.com/_/microsoft-azure-sql-edge) ([commit](https://github.com/eaze/migrate/commit/5a7c7f44997891a593e66b6f7e35560d2de2394c))
- GO statement support ([commit](https://github.com/eaze/migrate/commit/5de18cf6e4b83dc1e9e2fe61d168ff27e37ed5ee))
- A reduced testing step which only covers postgresql and mssql ([commit](https://github.com/eaze/migrate/commit/c5cbaabdff3bfbfb16b6801cccf2ca3ac384f4c7))
- This Document!

## How to Float a New Patch

### Step 1: Clone The Repository

Note that go has *very* strong opinions about where repositories should live,
relative to an environment variable called `GOPATH`, which defaults to `~/go`.

Assuming you're using that default, you should be able to get everything in
order by running:

```bash
mkdir -p ~/go/src/github.com/golang-migrate
cd ~/go/src/github.com/golang-migrate
git clone git@github.com:eaze/migrate.git
```

### Step 1: Create A Feature Branch

Nothing special here - while on the `latest` branch, run
`git checkout -b {your branch name}`..

### Step 2: Sync Changes with Upstream

There's a non-zero chance that upstream has merged pull requests since the
last time we applied patches. They push to a `master` branch, while we use
`latest` as our trunk branch. To sync changes, we fetch upstream's master
branch and merge it into the feature branch.

The script at `bin/sync-upstream.sh` can assist with this. TL;DR: You should
be able to run `./bin/sync-upstream.sh` in the project root on your new
feature branch and - if there are any changes to speak of - end up with a
merge commit containing the new changes.

### Step 3: Make Your Changes

From here you should be able to make changes as normal.

Because we're floating patches against an upstream branch, it is **much more
important than usual** that commits are self-contained. Don't be (too) afraid
to do an interactive rebase before going to review!

### Step 4: Run Tests, Formatting And Linting

These are for the most part documented by upstream, but here's the TL;DR:

1. `make test-short` to run tests. We've disabled tests for all databases except
   PostgreSQL and SQL Server, so they should be snappier than the full upstream
   suite.
2. `go fmt ./path/to/file.go` will do formatting. Note that go's idiomatic
   formatting uses tabs instead of spaces - this will clean all of that up!
3. `golangci-lint run` to run linting. You can install this tool with
   `brew install golangci-lint` if you're on MacOS.

### Step 5: Update This Document

Add a short description of the change you're making to the changelog in this
document. The commits should be more or less 1:1 with the items in the
changelog.

### Step 6: Make A Pull Request Against `eaze` and `latest`

**BE CAREFUL:** The default pull request UI will make a pull request against
**upstream**, NOT our fork. The UI should allow you to make the pull request
against `eaze/migrate` and the `latest` branch, but if you forget to do this
it will make a PR upstream! As far as can be told, this is *not* configurable
on GitHub's end. **Sorry for the error-prone busywork!**

Don't worry too much about making pull requests to the upstream project - it's
likely that your changes will build on top of other patches in this fork. That
said, if you're so inclined, you may fetch and check out the upstream `master`
branch, attempt a `cherry-pick`, and send another PR. But again: don't worry
too much about it.

### Step 7: Watch The Tests Pass In CI

The `CI` GitHub action will run the same tests and linting as documented in
step 4. Critically, this includes the change where we only test PostgreSQL and
SQL Server, with the same benefits and caveats.

### Step 8: Merge Your PR

If everything looks good on your PR, go ahead and merge it. If we keep commits
well-contained up to this point any strategy should be fine, but if you haven't
been careful then a *SQUASH* will be your best friend.

### Step 9: Tag A Release

This project uses [goreleaser](https://goreleaser.com/) to do release builds.
It does cross-platform builds and automatically uploads artifacts to GitHub
Releases. It's slick! However, it *does* constrain us to using tags for
releases - nightly builds require the paid version.

This is further complicated by the fact that fetching from upstream will
populate our repo with their tags. This is good in that it allows us to easily
see what was released at which version upstream, but it also means we need to
get a little creative with our patched version.

Our general strategy is to take the version in the most recent release tag
and add `.beta-1` to it. This gives us a cheap way to create a distinct
version which matches with the one we're patching, while also remaining
consistent with [go's opinions on version numbers](https://go.dev/doc/modules/version-numbers).

There's a script which handles most cases at `bin/tag-release.sh`. To use it,
check out `latest`, make sure it's up-to-date (with your recently merged
changes), and then run `./bin/tag-release.sh`. It will print which git command
it's running; if git complains, you should be able to understand why. If it's
due to the latest version *being* a beta release, try finding a beta version
one higher than the one published upstream. Don't worry about getting this
perfect - it's a messy situation!

### Step 10: Watch The Release Get Created

The release step is run against any tag which passes tests and linting.

### Step 11: Receive Bacon

If everything worked up to this point, you should see your shiny new release
here:

<https://github.com/eaze/migrate/releases>

In particular, under the "Assets" drop-down, you'll find builds for a bunch of
different architectures, operating systems and package managers. Practically
speaking, you will probably want to snag the URL to the `amd64` .deb package
and paste it into the relevant Ansible script in our infrastructure repo.
Sadly, using tags makes that difficult to automate. C'est la vie!
