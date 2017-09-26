#!/bin/sh

# Cvent Mac hardening script

# Borrows liberally from CIS Hardening Guidelines/script by Kris Payne

### Mac App Store (MAS)
# Enable MAS Autocheck and Autodownload
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool TRUE
# Enable MAS Autoupdate
/usr/bin/defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool TRUE

### SoftwareUpdate
# Enable Configuration Data Installs
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool TRUE
# Enable Critical Software Update Installs
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE
# Enable macOS Autoupdates
/usr/bin/defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool TRUE

### Machine Configuration
# Set Network time and set timeserver
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver time.apple.com
# Disable Remote Apple Events
/usr/sbin/systemsetup -setremoteappleevents off
# Retain system, firewall, and security logs
/usr/bin/sed -i.bak 's/^>\ system\.log.*/>\ system\.log\ mode=640\ format=bsd\ rotate=seq\ ttl=90/' /etc/asl.conf
/usr/bin/sed -i.bak 's/^\?\ \[=\ Facility\ com.apple.alf.logging\]\ .*/\?\ \[=\ Facility\ com.apple.alf.logging\]\ file\ appfirewall.log\ rotate=seq\ ttl=90/' /etc/asl.conf
/usr/bin/sed -i.bak 's/^\*\ file\ \/var\/log\/authd\.log.*/\*\ file\ \/var\/log\/authd\.log\ mode=640\ format=bsd\ rotate=seq\ ttl=90/' /etc/asl/com.apple.authd
# Disable wake on network access
/usr/bin/pmset -a womp 0
# Enable Security Auditing
/bin/launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist

### User Environment
# Disable Guest access
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
/usr/bin/defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool no
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool no
# Disable password hint
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
# Set Loginwindow text
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "This system is reserved for authorized Cvent use only. The use of this system may be monitored."