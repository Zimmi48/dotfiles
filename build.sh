#!/bin/sh

nix-build -E "with import ./unstable {}; coq_8_6" -o ~/nix-builds/coq-8-6
nix-build -E "with import ./unstable {}; coq_8_5" -o ~/nix-builds/coq-8-5
nix-build -E "with import ./unstable {}; coq_8_4" -o ~/nix-builds/coq-8-4
nix-build coq-dev.nix -o ~/nix-builds/coq-dev
