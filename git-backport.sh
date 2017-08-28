#!/usr/bin/env bash

# Usage: git-backport <PR number>

set -e

PRNUM=$1
# Fails if PR does not exist:
git log master --grep "Merge PR #${PRNUM}" | grep "." > /dev/null

BRANCH=backport-pr-${PRNUM}
RANGE=$(git log master --grep "Merge PR #${PRNUM}" --format="%P" | sed 's/ /../')
MESSAGE=$(git log master --grep "Merge PR #${PRNUM}" --format="%s" | sed 's/Merge/Backport/')

git checkout -b ${BRANCH}
git cherry-pick -x ${RANGE}
git checkout -
git merge -S ${BRANCH} --no-ff -m "${MESSAGE}"
git branch -d ${BRANCH}
