#!/usr/bin/env nix-shell
#!nix-shell -i bash -p android-tools
# (nix-shell shebang to get adb)

# Obtained using adb shell ls storage
sd_UUID="3338-3039"

# Define an exclusion list of packages that should not be moved
exclusion_list=(
    "com.bforbank.androidapp" # BforBank
    "com.bose.bosemusic" # Bose Music
    "com.communauto.reservauto" # Communauto
    "com.fortuneo.android" # Fortuneo
    "com.google.android.inputmethod.latin" # Gboard
    "com.revolut.revolut" # Revolut
    "com.simplemobiletools.calendar.pro" # Simple Calendar Pro
    "com.sncf.fusion" # SNCF Assistant
    "com.vsct.vsc.mobile.horaireetresa.android" # SNCF Connect
    "fr.bnpp.digitalbanking" # Hello Bank
    "fr.neamar.kiss" # KISS Launcher
    "org.thosp.yourlocalweather" # Your Local Weather
    "xyz.klinker.messenger" # Pulse SMS
)

# Get a list of installed third-party apps (including Google apps that can be moved to the SD card like Google Calendar, Docs, Sheets)
apps=$(adb shell pm list packages -3)

# Loop through the apps and move them to the SD card if they're not in the exclusion list
for app in $apps; do
    app=$(echo "$app" | sed 's/package://')
    if ! [[ "${exclusion_list[@]}" =~ "${app}" ]]; then
        # Test if the app is already on the SD card
        if ! (adb shell pm path "$app" | grep "^package:/mnt/" > /dev/null); then
            echo "Moving $app to SD card..."
            adb shell pm move-package "$app" "$sd_UUID"
        fi
    fi
done

echo "Done!"
