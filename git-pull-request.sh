#!/usr/bin/env bash

# Usage: git-pull-request <PR number> [remote]

set -e

dir="`git rev-parse --show-toplevel`-pr-$1"
remote=${2:-$(git remote | grep ^upstream || echo origin)}
branch="pr/$1"
ref="refs/pull/$1/merge"

git fetch ${remote} ${ref}
git branch ${branch} FETCH_HEAD
git config branch.${branch}.remote ${remote}
git config branch.${branch}.merge ${ref}
git worktree add ${dir} ${branch}
cd ${dir}
bash # Let the user do their tests
cd - > /dev/null
read -p "Remove the worktree and the branch? [y/N] " resp
if [[ "$resp" = "y" || "$resp" = "Y" ]]; then
  rm -rf ${dir}
  git worktree prune
  git branch -D ${branch}
fi