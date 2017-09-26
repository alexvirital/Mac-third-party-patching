#!/bin/sh

# High Sierra Upgrade Preflight Check

# v0.1 for Cvent, Inc by Alex Merenyi

jamfHelper="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

##Check if Disk is encrypting
encryption=$( diskutil cs list | grep "Conversion " )
if [[ ${encryption} == *"Complete"* ]]; then
    encStatus="OK"
    /bin/echo "Encryption Check: OK - Not Encrypting"
else
    encStatus="ERROR"
    /bin/echo "Encryption Check: ERROR - Encryption In Process"
fi

##Check if device is on battery or ac power
pwrAdapter=$( /usr/bin/pmset -g ps )
if [[ ${pwrAdapter} == *"AC Power"* ]]; then
    pwrStatus="OK"
    /bin/echo "Power Check: OK - AC Power Detected"
else
    pwrStatus="ERROR"
    /bin/echo "Power Check: ERROR - No AC Power Detected"
fi

##Check if free space > 15GB
osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )
if [[ $osMinor -ge 12 ]]; then
    freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}' )
else
    freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}' )
fi

if [[ ${freeSpace%.*} -ge 15 ]]; then
    spaceStatus="OK"
    /bin/echo "Disk Check: OK - ${freeSpace%.*}GB Free Space Detected"
else
    spaceStatus="ERROR"
    /bin/echo "Disk Check: ERROR - ${freeSpace%.*}GB Free Space Detected"
fi

if [[ ${pwrStatus} == "OK" ]] && [[ ${spaceStatus} == "OK" ]] && [[ ${encStatus} == "OK" ]]; then
	jamf policy -trigger High_Sierra_Install
else
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -heading "Requirements Not Met" -description "We were unable to prepare your computer for macOS High Sierra. Please ensure you are connected to power and that you have at least 15GB of Free Space.
    
    Check to make sure your computer's power cable is connected and that you have over 15GB free space.

    Please try again by going to your Applications folder, open the Self Service app, and then click Install macOS High Sierra.

    If you continue to experience this issue, please contact ISHelp." -button1 "OK" -defaultButton 1
fi