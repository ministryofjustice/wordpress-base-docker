#!/bin/sh

##
# Generate the whitelist configuration for nginx
# This is generated at runtime based on environment variables
#
# Define which IPs you want whitelisted in the WHITELIST_IPS environment varable.
# Separate multiple IP addresses with commas.
#   e.g. WHITELIST_IPS=xxx.xxx.xxx.xxx,yyy.yyy.yyy.yyy,zzz.zzz.zzz.zzz
#
# Whitelist config file location:
#   /etc/nginx/whitelist.conf
##

# Whitelist localhost
if [ ! -z "$LB_IP_RANGE" ]
then
	echo "#Set trusted sources that can set the RealIP e.g loadbalancer"
	echo "set_real_ip_from ${LB_IP_RANGE};" > /etc/nginx/whitelist.conf
	echo "real_ip_header X-Forwarded-For;" >> /etc/nginx/whitelist.conf
	echo "real_ip_recursive on;" >> /etc/nginx/whitelist.conf
fi

echo "allow 127.0.0.1;" >> /etc/nginx/whitelist.conf;

# Whitelist Pingdom
echo "include /etc/nginx/whitelists/pingdom.conf;" >> /etc/nginx/whitelist.conf


# Whitelist IPs from the environment
if [ ! -z "$WHITELIST_IPS" ]
then
	echo "# This file was generated dynamically from the WHITELIST_IPS environment variable." > /etc/nginx/whitelists/environment.conf
	for IP in $(echo $WHITELIST_IPS | tr "," "\n")
	do
		echo "allow ${IP};" >> /etc/nginx/whitelists/environment.conf
	done

	echo "include /etc/nginx/whitelists/environment.conf;" >> /etc/nginx/whitelist.conf
fi

# Deny access to everyone else
echo "deny all;" >> /etc/nginx/whitelist.conf;
