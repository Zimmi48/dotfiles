#!/bin/sh

# Build the NixOS configuration for this machine.
# Generate a unique result symlink filename containing the date and time.
# This allows to keep roots of previous builds for a while.
result="$HOSTNAME-$(date +%Y-%m-%d-%Hh%M)"
echo "Building $HOSTNAME configuration..."
nixos-rebuild build --flake .
mv result "nix-builds/$result"
echo "Result symlink: nix-builds/$result"

# Old Coq releases
echo
echo "Do you want to build old Coq releases? (y/n)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
       echo "Building old Coq releases..."

       nix-build nixpkgs -A coqPackages_8_16.coqide -o nix-builds/coq-8-16
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
else
       echo "Skipping old Coq releases..."
fi

# Dev version of Coq
echo
echo "Do you want to build the dev version of Coq? (y/n)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
       echo "Building dev version of Coq..."

       nix-build -E '(import ./nixpkgs {}).coq.override { version = "dev"; buildIde = true; }' -o nix-builds/coq-dev
else
       echo "Skipping dev version of Coq..."
fi

echo
echo "Build completed."
echo
echo "Now run:"
echo "pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
su -c \"nix-env -p /nix/var/nix/profiles/system --set ./nix-builds/$result &&
       ./nix-builds/$result/bin/switch-to-configuration switch\""

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
