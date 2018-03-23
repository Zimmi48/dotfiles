#!/usr/bin/env bash

# Usage: git-pull-request <PR number> [remote]

set -e

dir="`git worktree list | head -1 | cut -f1 -d' '`-pr-$1"
branch="pr/$1"

if [[ "`git branch | grep ${branch}`" ]]; then
  cd ${dir}
  git pull --rebase
else
  remote=${2:-$(git remote | grep ^upstream || echo origin)}
  ref="refs/pull/$1/merge"
  git fetch ${remote} ${ref}
  git branch ${branch} FETCH_HEAD
  git config branch.${branch}.remote ${remote}
  git config branch.${branch}.merge ${ref}
  git worktree add ${dir} ${branch}
  cd ${dir}
fi
bash # Let the user do their tests
cd - > /dev/null
read -p "Remove the worktree and the branch? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf ${dir}
  git worktree prune
  git branch -D ${branch}
fi
