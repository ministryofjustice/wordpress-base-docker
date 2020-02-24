#!/bin/sh

# create publicly accessible security.txt file
# copies the entire text from the working file; vulnerability-disclosure-security.txt
if [ -d "/bedrock" ]
then
  if [ ! -d "/bedrock/web/.well-known" ]
  then
    mkdir /bedrock/web/.well-known
  fi

  curl -s https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt -o /bedrock/web/.well-known/security.txt
fi
