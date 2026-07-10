#!/usr/bin/env bash

set -e

if ping -q -c1 8.8.8.8 &> /dev/null; then
       OFFLINE_FLAGS=()
       # Update phase
       echo "Do you want to update the input flakes? (y/N)"
       read -r answer
       if [ "$answer" != "${answer#[Yy]}" ]; then
              echo "Updating the input flakes..."
              nix flake update
       else
              echo "Skipping the update of the input flakes..."
       fi
else
       OFFLINE_FLAGS=("--no-substitute")
       echo "Skipping the update of the input flakes because we are offline..."
fi

# If a temporary commit was created, undo it on Ctrl+C or command failure.
TMP_COMMITTED=false
_cleanup() {
       if $TMP_COMMITTED; then
              TMP_COMMITTED=false
              echo "Interrupted; undoing temporary commit..."
              jj undo
       fi
}
trap '_cleanup; exit 130' INT
trap '_cleanup' ERR

# Check whether the JJ working copy has any changes.
if [ -n "$(jj diff --summary)" ]; then
       WC_CHANGED=true
else
       WC_CHANGED=false
fi

# If there are changes: set tags first, then create a temporary commit so that
# the flake is evaluated from a clean state (a dirty flake bypasses the eval cache).
if $WC_CHANGED; then
       echo
       echo "Current tags:"
       cat ./nixos-tags.nix
       echo "Do you want to set new tags for this configuration? (Y/n)"
       read -r tags_answer
       if [ "$tags_answer" != "${tags_answer#[Nn]}" ]; then
              echo "Skipping the tagging of the new configuration..."
       else
              echo "What are the (space-separated) tags for the new configuration? (They will be reordered alphabetically.)"
              read -r -a tags
              if [ ${#tags[@]} -eq 0 ]; then
                     echo "{ system.nixos.tags = []; }" > ./nixos-tags.nix
              else
                     echo "{ system.nixos.tags = [ $(printf '"%s" ' "${tags[@]}")]; }" > ./nixos-tags.nix
              fi
       fi
       echo "Creating temporary commit..."
       jj commit -m "tmp: $HOSTNAME"
       TMP_COMMITTED=true
fi

# Build the NixOS configuration for this machine.
# Generate a unique result symlink filename containing the date and time.
# This allows to keep roots of previous builds for a while.
result="$HOSTNAME-$(date +%Y-%m-%d-%Hh%M)"
echo
echo "Building $HOSTNAME configuration..."
nix build ".#nixosConfigurations.$HOSTNAME.config.system.build.toplevel" \
       --out-link "./nix-builds/$result" \
       --experimental-features 'nix-command flakes' \
       "${OFFLINE_FLAGS[@]}"
echo "Build completed."
echo
echo "Closure differences:"
nix store diff-closures /nix/var/nix/profiles/system "./nix-builds/$result" \
       --experimental-features 'nix-command flakes'
echo
echo "Result symlink: nix-builds/$result"

echo
echo "Do you want to test (t), switch to (s) or boot (b) the new configuration?"
read -r answer
# If the user answer equals "t" or "T", then test the new configuration.
if [ "$answer" = "t" ] || [ "$answer" = "T" ]; then
       echo "Testing the new configuration..."
       sudo -A "./nix-builds/$result/bin/switch-to-configuration" test
elif [ "$answer" = "s" ] || [ "$answer" = "S" ] || [ "$answer" = "b" ] || [ "$answer" = "B" ]; then
       if $WC_CHANGED; then
              # Squash the temporary commit: pre-fill the description with the NixOS
              # version and closure diff, then open the editor for final editing.
              (cat "./nix-builds/$result/nixos-version" \
                     && printf '\n\n' \
                     && nix store diff-closures /nix/var/nix/profiles/system "./nix-builds/$result" \
                            --experimental-features 'nix-command flakes') \
                     | jj describe @- --stdin
              jj describe @-
       fi
       TMP_COMMITTED=false
       # If the user answer equals "B" or "b", then boot the new configuration.
       if [ "$answer" = "b" ] || [ "$answer" = "B" ]; then
              echo "Booting the new configuration..."
              sudo -A nix-env -p "/nix/var/nix/profiles/system" --set "./nix-builds/$result"
              sudo -A "./nix-builds/$result/bin/switch-to-configuration" boot
       # If the user answer equals "S" or "s", then switch to the new configuration.
       elif [ "$answer" = "s" ] || [ "$answer" = "S" ]; then
              echo "Switching to the new configuration..."
              sudo -A nix-env -p "/nix/var/nix/profiles/system" --set "./nix-builds/$result"
              sudo -A "./nix-builds/$result/bin/switch-to-configuration" switch
       fi
elif $WC_CHANGED; then
       # User bailed without switching; undo the temporary commit to restore the
       # working copy.
       TMP_COMMITTED=false
       echo "Undoing temporary commit..."
       jj undo
fi

# Reference: http://www.haskellforall.com/2018/08/nixos-in-production.html
