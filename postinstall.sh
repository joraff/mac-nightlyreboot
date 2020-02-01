#!/usr/bin/env bash

# Post-install script for NightlyReboot.pkg that loads the newly installed launchdaemon

launchctl load /Library/LaunchDaemons/edu.tamu.oal.nightlyreboot.plist
