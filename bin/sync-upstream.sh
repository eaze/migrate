#!/usr/bin/env bash

set -e

print_help() {
  cat >&2 <<EOF
sync-upstream.sh

Merge the master branch from upstream.

Arguments:

  --rebase    Rebase upstream instead of merging

Example use:

  $ sync-upstream.sh --help    # prints this message
  $ sync-upstream.sh           # merge upstream/master into the current branch
  # sync-upstream.sh --rebase  # rebase the current branch against upstream/master
EOF
}

REBASE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --rebase)
      REBASE=1
      shift
      ;;
    *)
      print_help
      exit 1
      ;;
  esac
done

echo "info: configuring the upstream remote ..."

git remote add upstream git@github.com:golang-migrate/migrate.git || git remote set-url upstream git@github.com:golang-migrate/migrate.git

echo "info: fetching upstream ..."

git fetch upstream

if [ -n "${REBASE}" ]; then
  echo "info: rebasing against the upstream branch ..."

  git rebase upstream/master
else 
  echo "info: merging the upstream branch ..."

  git merge upstream/master
fi
