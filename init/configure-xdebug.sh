#!/bin/sh

# Enable XDebug if XDEBUG_CONFIG environment variable exists

if [ ! -z "$XDEBUG_CONFIG" ]
then
	phpenmod xdebug
fi
