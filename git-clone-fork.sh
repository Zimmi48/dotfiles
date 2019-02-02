#!/bin/sh

set -e

if [ "$#" -ne 4 ]; then
  echo "USAGE: git clone-fork <base-url> <upstream-username> <origin-username> <repo-name>"
  exit 1
fi
base=$1
upstream=$2
origin=$3
repo=$4

git clone "${base}${upstream}/${repo}" -o upstream
cd "$repo"
git remote add origin "${base}${origin}/${repo}"
git remote -v
