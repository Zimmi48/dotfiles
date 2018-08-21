#!/bin/sh

nix build -f coq.nix coq-master -o nix-builds/coq-master
nix build -f coq.nix coq-v8-8 -o nix-builds/coq-v8.8
nix build -f '<unstable>' coq_8_8 -o nix-builds/coq-8-8
nix build -f '<nixpkgs>' coq_8_7 -o nix-builds/coq-8-7
nix build -f '<nixpkgs>' coq_8_6 -o nix-builds/coq-8-6
nix build -f '<nixpkgs>' coq_8_5 -o nix-builds/coq-8-5
nix build -f '<nixpkgs>' coq_8_4 -o nix-builds/coq-8-4
nix build -f pykinea.nix -o nix-builds/pykinea

nix-env -iA cachix -f "<unstable>"
export CACHIX_SIGNING_KEY=$(pass tech/Cachix/theozim/CACHIX_SIGNING_KEY)
cd nix-builds
cachix push theozim pykinea
