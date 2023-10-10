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

# Are there any changes to commit?
DIFF=$((git diff --exit-code > /dev/null 2>&1; echo $?) || echo $?)

# Tagging the new configuration
# (silently skip if there are no changes to commit)
if [ "$DIFF" -eq 1 ]; then
       echo
       echo "Current tags:"
       cat ./nixos-tags.nix
       echo "Do you want to set new tags for this configuration? (Y/n)"
       read -r answer
       if [ "$answer" != "${answer#[Nn]}" ]; then
              echo "Skipping the tagging of the new configuration..."
       else
              echo "What are the (space-separated) tags for the new configuration? (They will be reorded alphabetically.)"
              read -r -a tags
              echo "{ system.nixos.tags = [ $(printf '"%s" ' "${tags[@]}")]; }" > ./nixos-tags.nix
       fi
fi

# Build the NixOS configuration for this machine.
# Generate a unique result symlink filename containing the date and time.
# This allows to keep roots of previous builds for a while.
result="$HOSTNAME-$(date +%Y-%m-%d-%Hh%M)"
echo
echo "Building $HOSTNAME configuration..."
nix build .#nixosConfigurations."$HOSTNAME".config.system.build.toplevel --no-warn-dirty --out-link ./nix-builds/$result --experimental-features 'nix-command flakes' #--no-substitute (useful when offline)
echo "Build completed."
echo
echo "Closure differences:"
nix store diff-closures /nix/var/nix/profiles/system ./nix-builds/$result --experimental-features 'nix-command flakes'
echo
echo "Result symlink: nix-builds/$result"

echo
echo "Do you want to test (t), switch to (s) or boot (b) the new configuration?"
read -r answer
# If the user answer equals "t" or "T", then test the new configuration.
if [ "$answer" = "t" ] || [ "$answer" = "T" ]; then
       echo "Testing the new configuration..."
       pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
       su -c "./nix-builds/$result/bin/switch-to-configuration test"
elif [ "$answer" = "s" ] || [ "$answer" = "S" ] || [ "$answer" = "b" ] || [ "$answer" = "B" ]; then
       if [ "$DIFF" -eq 1 ]; then
              echo "Do you want to commit the new configuration? (Y/n)"
              read -r commit_answer
              if [ "$commit_answer" != "${commit_answer#[Nn]}" ]; then
                     echo "Skipping the commit of the new configuration..."
              else
                     echo "Committing the new configuration..."
                     git commit -am "$(cat ./nix-builds/$result/nixos-version)" -m "$(nix store diff-closures /nix/var/nix/profiles/system ./nix-builds/$result)" --edit -S
              fi
       fi
       # If the user answer equals "B" or "b", then boot the new configuration.
       if [ "$answer" = "b" ] || [ "$answer" = "B" ]; then
              echo "Booting the new configuration..."
              pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
              su -c "nix-env -p /nix/var/nix/profiles/system --set ./nix-builds/$result &&
                     ./nix-builds/$result/bin/switch-to-configuration boot"
       # If the user answer equals "S" or "s", then switch to the new configuration.
       elif [ "$answer" = "s" ] || [ "$answer" = "S" ]; then
              echo "Switching to the new configuration..."
              pass -c tech/$(echo $HOSTNAME | cut -d- -f1-2)/rootpass
              su -c "nix-env -p /nix/var/nix/profiles/system --set ./nix-builds/$result &&
                     ./nix-builds/$result/bin/switch-to-configuration switch"
       fi
fi

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
