#!/bin/bash

# Create the nullmailer trigger file if it doesn't already exist
# Nullmailer will not start without this
# Taken from the `start` sequence in /etc/init.d/nullmailer

if [ ! -p /var/spool/nullmailer/trigger ]; then
    rm -f /var/spool/nullmailer/trigger
    mkfifo /var/spool/nullmailer/trigger
fi

chown mail:root /var/spool/nullmailer/trigger
chmod 0622 /var/spool/nullmailer/trigger

# Then run it in the foreground
exec /sbin/setuser mail /usr/sbin/nullmailer-send
