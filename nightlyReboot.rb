#!/usr/bin/env ruby

=begin

nightlyReboot.rb
Copyright 2011 Texas A&M University
Joseph Rafferty
jrafferty@tamu.edu

Script that is called by a launchDaemon at a scheduled time with the intention of rebooting a dual-boot Macintosh into its 
Windows partition. Obviously we don't want to reboot if a user is currently logged in at the console level, so we check that. 
If a user is logged in, we exit with a status of 1 to tell launchd that it needs to run us again. This process will continue 
until no one is logged in any longer (indicated by a user of root). At that time we change the startup disk and restart the 
computer immediately.

=end


# Upon initial install, a postinstall script tells launchd to load the launchdaemon (so we dont have to wait for a reboot).
# This has the consequence of running this script upon load, and it very likely that the time since last boot criteria below will be met,
#  therefore causing the machine to reboot. 
# So, the postinstall script touches a file to indicate that this script was just installed, and that it should clean up and exit without rebooting.
if File.exists? "/tmp/skipReboot"
  puts "Detected a skip file. This run was triggered by the package installer postinstall script. Exiting."
  File.delete "/tmp/skipReboot"
  exit(0)
end


# Due to a limitation in launchd, we can't use the KeepAlive/SuccessfulExit and StartCalendarInterval keys together.
#  => Bug filed under apple radar #10111519
# A LaunchDaemon is loaded at startup, so we check the time since last boot. If it's recent, we're going to assume
# that the machine was just booted and that we shouldn't restart. Unfortunately, this means that if our scheduled
#  reboot time is 3:00, and the system was booted at 2:59 that we _would_ miss the reboot. There's only a small chance of this, 
#  so I won't try to address it.
bootTime = Time.at `sysctl kern.boottime | awk '{print $5}'`.chomp(",\n").to_i

if Time.now - bootTime > 120 # greater than 2 minutes ago
  user = `ls -l /dev/console | awk '{ print $3 }'`.strip
  # If our console user is root, it's safe to shutdown (most likely means we're at the loginwindow)
  if user == "root"
    puts "No one logged in. Rebooting to windows."
    `bless --device /dev/disk0s3 --setBoot --nextonly --legacy`
    `reboot`
  else
    puts "#{user} is currently logged in. Not rebooting yet."
    exit(1)
  end
else
  puts "This might be a launchd false-start run. Not doing anything"
  exit(0)
end
