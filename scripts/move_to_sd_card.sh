#!/usr/bin/env nix-shell
#!nix-shell -i bash -p android-tools
# (nix-shell shebang to get adb)

# Obtained using adb shell ls storage
sd_UUID="3338-3039"

# Define an exclusion list of packages that should not be moved
exclusion_list=(
    # DAVx⁵
    "at.bitfire.davdroid"
    # Alan
    "com.alanmobile"
    # BforBank
    "com.bforbank.androidapp"
    # Bose Music
    "com.bose.bosemusic"
    # Communauto
    "com.communauto.reservauto"
    # Fortuneo
    "com.fortuneo.android"
    # Gboard
    "com.google.android.inputmethod.latin"
    # Revolut
    "com.revolut.revolut"
    # Simple Calendar Pro
    "com.simplemobiletools.calendar.pro"
    # SNCF Assistant
    "com.sncf.fusion"
    # SNCF Connect
    "com.vsct.vsc.mobile.horaireetresa.android"
    # WhatsApp
    "com.whatsapp"
    # Hello Bank
    "fr.bnpp.digitalbanking"
    # KISS Launcher
    "fr.neamar.kiss"
    # Tasks.org
    "org.tasks"
    # Your Local Weather
    "org.thosp.yourlocalweather"
    # Signal
    "org.thoughtcrime.securesms"
    # Etar Calendar
    "ws.xsoh.etar"
    # Pulse SMS
    "xyz.klinker.messenger"
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
