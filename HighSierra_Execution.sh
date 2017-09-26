#!/bin/sh
# High Sierra Execution Script 

##### PREFLIGHT PATCHING AND MAINTAINENCE
# Install DEPNotify and use that for this process, because why not? It's awesome and a great tool for this... no, this won't end badly at all
if -d /var/cvt/; then
	echo "directory found"
else
	mkdir /var/cvt
fi
dep_log="/var/tmp/depnotify.log"
curl -s http://www.cvent.com/en/brand-guide/images/download/cvent-logo.png > /var/cvt/cvent.png
jamf policy -trigger depnotify
echo "Command: Image: /var/cvt/cvent.png" >> $dep_log
echo "Command: WindowTitle: High Sierra Upgrade in process" >> $dep_log
echo "Command: Determinate 6" >> $dep_log
echo "Command: MainText: Your machine is currently getting ready for the upgrade to High Sierra. Please do not turn off or restart your computer." >> $dep_log
echo "Command: NotificationOn:" >> $dep_log
open "/var/cvt/DEPNotify.app/"


# Create Security User
jamf policy -trigger secuser

# Rename the mac for the actual end user
echo "Status: Updating machine record..." >> $dep_log
jamf policy -trigger rename_mac


# Update Chrome
echo "Status: Updating Google Chrome..." >> $dep_log
killall Google\ Chrome
jamf policy -trigger update_chrome_nr

# Update MSOffice
echo "Status: Updating Microsoft Office..." >> $dep_log
jamf policy -trigger ms_office_highsierra_install_cached


# Update Firefox
if -d /Applications/Mozilla\ Firefox.app/; then
	echo "Status: Updating Mozilla Firefox..." >> $dep_log
	jamf policy -trigger update_firefox
fi

echo "Status: Patching and prep-work complete. Preparing upgrade package..." >> $dep_log
killall DEPNotify
rm -rfv $dep_log

####### END PREFLIGHT CHECKS

##Title to be used for userDialog (only applies to Utility Window)
title="macOS High Sierra Upgrade"
##Heading to be used for userDialog
heading="Please wait as we prepare your computer for macOS High Sierra..."

##Title to be used for userDialog
description="
This process will take approximately 5-10 minutes. 
Once completed your computer will reboot and begin the upgrade."

##Icon to be used for userDialog
##Default is macOS Sierra Installer logo which is included in the staged installer package
icon=/Users/Shared/Install\ macOS\ High\ Sierra.app/Contents/Resources/InstallAssistant.icns

/bin/mkdir -p /usr/local/jamfps
/bin/echo "#!/bin/bash
## First Run Script to remove the installer.
## Clean up files
/bin/rm -fdr /Users/Shared/Install\ macOS\ High\ Sierra.app
/bin/sleep 2
/usr/local/jamf/bin/jamf policy -trigger hs_new_fv2_key
/bin/sleep 10
/usr/local/jamf/bin/jamf recon

## Remove LaunchDaemon
/bin/launchctl unload -w /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist
/bin/rm -f /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist

exit 0" > /usr/local/jamfps/finishOSInstall.sh

/usr/sbin/chown root:admin /usr/local/jamfps/finishOSInstall.sh
/bin/chmod 755 /usr/local/jamfps/finishOSInstall.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# LAUNCH DAEMON
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

/bin/echo "<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
    <key>Label</key> 
    <string>com.jamfps.cleanupOSInstall</string> 
    <key>ProgramArguments</key> 
    <array> 
        <string>/usr/local/jamfps/finishOSInstall.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict> 
</plist>" > /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist

##Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist
/bin/chmod 644 /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist

/bin/echo "Launching jamfHelper as FullScreen..."
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -title "" -icon "$icon" -heading "$heading" -description "$description" &
jamfHelperPID=$(echo $!)
/bin/echo "Launching startosinstall..."
/Users/Shared/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --applicationpath /Users/Shared/Install\ macOS\ High\ Sierra.app --agreetolicense --pidtosignal $jamfHelperPID &
/bin/sleep 3