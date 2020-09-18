#!/bin/sh

nix build -f "$HOSTNAME.nix" system

nix build -f coq.nix coq-master -o nix-builds/coq-master
nix build -f nixpkgs coq_8_11 -o nix-builds/coq-8-11
nix build -f nixpkgs coq_8_10 -o nix-builds/coq-8-10
nix build -f nixpkgs coq_8_9 -o nix-builds/coq-8-9
nix build -f nixpkgs coq_8_8 -o nix-builds/coq-8-8
nix build -f nixpkgs coq_8_7 -o nix-builds/coq-8-7
nix build -f nixpkgs coq_8_6 -o nix-builds/coq-8-6

echo
echo "Build completed."
echo
echo "Now run:"
#echo "export CACHIX_SIGNING_KEY=\$(pass tech/Cachix/theozim/CACHIX_SIGNING_KEY)"
#echo "nix run -f nixpkgs cachix -c cachix push theozim nix-builds/..."
#echo
#echo "And:"
echo "pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
su -c \"nix-env -p /nix/var/nix/profiles/system --set ./result &&
       ./result/bin/switch-to-configuration switch\""

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
