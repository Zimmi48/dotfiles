#!/bin/sh

# This script assumes that ./nixos and ./nixpkgs are two worktrees
# of the same git repository

set -e

( cd nixpkgs && git fetch upstream && git checkout upstream/nixpkgs-unstable )
( cd nixos && git checkout "upstream/nixos-$(nixos-version | cut -c -5)" )

./build.sh
