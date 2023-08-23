#!/bin/sh

# Update phase
echo "Do you want to update the input flakes? (y/N)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
       echo "Updating the input flakes..."
       nix flake update
else
       echo "Skipping the update of the input flakes..."
fi

# Build the NixOS configuration for this machine.
# Generate a unique result symlink filename containing the date and time.
# This allows to keep roots of previous builds for a while.
result="$HOSTNAME-$(date +%Y-%m-%d-%Hh%M)"
echo
echo "Building $HOSTNAME configuration..."
nixos-rebuild build --flake .
mv result "nix-builds/$result"
echo "Result symlink: nix-builds/$result"

echo
echo "Build completed."
echo
echo "Do you want to switch to the new configuration? (Y/n)"
read -r answer
if [ "$answer" != "${answer#[Nn]}" ] ;then
       echo "Skipping the switch to the new configuration..."
else
       echo "Switching to the new configuration..."
       pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
       su -c "nix-env -p /nix/var/nix/profiles/system --set ./nix-builds/$result &&
              ./nix-builds/$result/bin/switch-to-configuration switch"
fi

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
