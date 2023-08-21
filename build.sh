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

       # from 8.6 to 8.16
       for i in {6..16}; do
              nix build .#coq_8_$i -o nix-builds/coq-8-$i
       done
else
       echo "Skipping old Coq releases..."
fi

# Dev version of Coq
echo
echo "Do you want to build the dev version of Coq? (y/n)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
       echo "Building dev version of Coq..."

       nix build .#coq-dev -o nix-builds/coq-dev
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
