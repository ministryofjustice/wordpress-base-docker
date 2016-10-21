#!/bin/sh

# Mount the WordPress uploads directory to S3 using yas3fs

if [ ! -z "$AWS_DEFAULT_REGION" ]
then
	# Default to eu-west-1 if a default region hasn't been set
	AWS_DEFAULT_REGION="eu-west-1"
fi

if [ ! -z "$SNS_TOPIC" ]
then
	# If we were given a SNS topic, tell yas3fs to use it.
	exec /usr/local/bin/yas3fs --topic $SNS_TOPIC --new-queue-with-hostname --foreground --no-metadata --nonempty s3://$AWS_S3_BUCKET/uploads /bedrock/web/app/uploads --region $AWS_DEFAULT_REGION
else
	# Else, don't.
	exec /usr/local/bin/yas3fs --foreground --no-metadata --nonempty s3://$AWS_S3_BUCKET/uploads /bedrock/web/app/uploads --region $AWS_DEFAULT_REGION
fi
