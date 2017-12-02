#!/bin/sh

nix-build '<unstable>' -A coq_8_7 -o nix-builds/coq-8-7
nix-build '<unstable>' -A coqPackages_8_7.mathcomp -o nix-builds/coq-8-7-mathcomp
nix-build '<nixpkgs>' -A coq_8_6 -o nix-builds/coq-8-6
nix-build '<nixpkgs>' -A coq_8_5 -o nix-builds/coq-8-5
nix-build '<nixpkgs>' -A coq_8_4 -o nix-builds/coq-8-4
# nix-build serapi-dev.nix --arg pkgs "import <unstable> {}" -o nix-builds/serapi-dev
nix-build pykinea.nix --arg pkgs "import <unstable> {}" -o nix-builds/pykinea
