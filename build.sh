#!/bin/sh

nix build unstable.coq_8_8 -o nix-builds/coq-8-8
nix build nixpkgs.coq_8_7 -o nix-builds/coq-8-7
nix build nixpkgs.coq_8_6 -o nix-builds/coq-8-6
nix build nixpkgs.coq_8_5 -o nix-builds/coq-8-5
nix build nixpkgs.coq_8_4 -o nix-builds/coq-8-4
nix build -f pykinea.nix -o nix-builds/pykinea
