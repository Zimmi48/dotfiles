#!/bin/sh

set -e

# Update phase
echo "Do you want to update the input flakes? (y/N)"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ]; then
       echo "Updating the input flakes..."
       nix flake update
else
       echo "Skipping the update of the input flakes..."
fi

# Tagging the new configuration
echo
echo "What are the (space-separated) tags for the new configuration? (They will be reorded alphabetically.)"
read -r -a tags
echo "{ system.nixos.tags = [ $(printf '"%s" ' "${tags[@]}")]; }" > ./nixos-tags.nix

# Build the NixOS configuration for this machine.
# Generate a unique result symlink filename containing the date and time.
# This allows to keep roots of previous builds for a while.
result="$HOSTNAME-$(date +%Y-%m-%d-%Hh%M)"
echo
echo "Building $HOSTNAME configuration..."
nix build .#nixosConfigurations."$HOSTNAME".config.system.build.toplevel --no-warn-dirty --out-link ./nix-builds/$result
echo "Build completed."
echo
echo "Closure differences:"
nix store diff-closures /run/current-system ./nix-builds/$result
echo
echo "Result symlink: nix-builds/$result"

echo
echo "Do you want to test (t) or switch to (s) the new configuration?"
read -r answer
# If the user answer equals "t" or "T", then test the new configuration.
if [ "$answer" = "t" ] || [ "$answer" = "T" ]; then
       echo "Testing the new configuration..."
       pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
       su -c "./nix-builds/$result/bin/switch-to-configuration test"
       exit 0
# If the user answer equals "S" or "s", then switch to the new configuration.
elif [ "$answer" = "s" ] || [ "$answer" = "S" ]; then
       echo "Committing the new configuration..."
       git commit -am "$(cat ./nix-builds/$result/nixos-version)" -m "$(nix store diff-closures /run/current-system ./nix-builds/$result)" --edit -S
       echo "Switching to the new configuration..."
       pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
       su -c "nix-env -p /nix/var/nix/profiles/system --set ./nix-builds/$result &&
              ./nix-builds/$result/bin/switch-to-configuration switch"
       exit 0
fi

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
