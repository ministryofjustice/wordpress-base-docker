#!/bin/bash

# First start nullmailer via its /etc/init.d script
# This feels a bit hacky, but what we want nullmailer to create its required trigger files
# We don't want it running as a daemon, so we'll kill it as soon as it starts
/etc/init.d/nullmailer start
/etc/init.d/nullmailer stop

# Then run it in the foreground
exec /sbin/setuser mail /usr/sbin/nullmailer-send -s
