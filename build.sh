#!/bin/sh

nix-build '<unstable>' -A coq_8_6 -o nix-builds/coq-8-6
nix-build '<unstable>' -A coqPackages_8_6.mathcomp -o nix-builds/coq-8-6-mathcomp
nix-build '<nixpkgs>' -A coq_8_5 -o nix-builds/coq-8-5
nix-build '<nixpkgs>' -A coq_8_4 -o nix-builds/coq-8-4
nix-build coq-dev.nix -o nix-builds/coq-dev
nix-build serapi-dev.nix -o nix-builds/serapi-dev
nix-build pykinea.nix -o nix-builds/pykinea
