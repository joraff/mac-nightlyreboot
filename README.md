Script that is called by a launchDaemon at a scheduled time with the intention of rebooting a dual-boot Macintosh into its 
Windows partition. Obviously we don't want to reboot if a user is currently logged in at the console level, so we check that. 
If a user is logged in, we exit with a status of 1 to tell launchd that it needs to run us again. This process will continue 
until no one is logged in any longer (indicated by a user of root). At that time we change the startup disk and restart the 
computer immediately.