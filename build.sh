#!/bin/sh

nix-build "$HOSTNAME.nix" -A system

# Old Coq releases
nix-build nixpkgs -A coqPackages_8_15.coqide -o nix-builds/coq-8-15
nix-build nixpkgs -A coqPackages_8_14.coqide -o nix-builds/coq-8-14
nix-build nixpkgs -A coq_8_13 -o nix-builds/coq-8-13
nix-build nixpkgs -A coq_8_12 -o nix-builds/coq-8-12
nix-build nixpkgs -A coq_8_11 -o nix-builds/coq-8-11
nix-build nixpkgs -A coq_8_10 -o nix-builds/coq-8-10
nix-build nixpkgs -A coq_8_9 -o nix-builds/coq-8-9
nix-build nixpkgs -A coq_8_8 -o nix-builds/coq-8-8
nix-build nixpkgs -A coq_8_7 -o nix-builds/coq-8-7
nix-build nixpkgs -A coq_8_6 -o nix-builds/coq-8-6

echo
echo "Build completed."
echo
echo "Now run:"
echo "pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
su -c \"nix-env -p /nix/var/nix/profiles/system --set ./result &&
       ./result/bin/switch-to-configuration switch\""

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
