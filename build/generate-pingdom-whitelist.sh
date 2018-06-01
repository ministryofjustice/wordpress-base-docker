#!/bin/bash
set -e

PINGDOM_IPS_URL="https://my.pingdom.com/probes/ipv4"
OUTPUT_FILE="$1"

echo "Generating Pingdom IP address whitelist"

echo "# List of Pingdom IP addresses" > $OUTPUT_FILE
echo "# Correct as of: `date`" >> $OUTPUT_FILE
echo "# For the current list see: $PINGDOM_IPS_URL" >> $OUTPUT_FILE

for IP in `curl -sf $PINGDOM_IPS_URL`; do
	echo "allow $IP;" >> $OUTPUT_FILE
done

echo "Whitelist generated and saved to $OUTPUT_FILE"
