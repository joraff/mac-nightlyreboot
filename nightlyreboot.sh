#!/usr/bin/env bash
user=`ls -l /dev/console | awk '{ print $3 }'`
if [ $user = "root" ]; then
    echo "No one logged in. Rebooting to windows.";
    bless --device /dev/disk0s3 --setBoot --nextonly --legacy
    reboot
else
    echo "$user is currently logged in. Not rebooting yet."
    exit 1
fi

