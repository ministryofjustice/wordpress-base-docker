#!/bin/sh

echo "allow 127.0.0.1;" > /etc/nginx/conf.d/whitelist.conf;

for IP in $(echo $IP_WHITELIST | tr "," "\n")
do
  echo "allow ${IP};" >> /etc/nginx/conf.d/whitelist.conf;
done
