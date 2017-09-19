#!/usr/bin/env bash

# Usage: git-backport <PR number>

set -e

PRNUM=$1

if ! git log master --grep "Merge PR #${PRNUM}" | grep "." > /dev/null; then
    echo "PR #${PRNUM} does not exist."
    exit 1
fi

BRANCH=backport-pr-${PRNUM}
RANGE=$(git log master --grep "Merge PR #${PRNUM}" --format="%P" | sed 's/ /../')
MESSAGE=$(git log master --grep "Merge PR #${PRNUM}" --format="%s" | sed 's/Merge/Backport/')

if git checkout -b ${BRANCH}; then

    if ! git cherry-pick -x ${RANGE}; then
        echo "Please fix the conflicts, then exit."
        bash
        while ! git cherry-pick --continue; do
            echo "Please fix the conflicts, then exit."
            bash
        done
    fi
    git checkout -

else

    echo
    read -p "Skip directly to merging phase? [y/N] " resp
    if ! [[ "$resp" = "y" || "$resp" = "Y" ]]; then
        exit
    fi

fi

git merge -S ${BRANCH} --no-ff -m "${MESSAGE}"
git branch -d ${BRANCH}
