#!/bin/sh

# Mount the WordPress uploads directory to S3 using yas3fs

if [ -z "$AWS_DEFAULT_REGION" ]
then
	# Default to eu-west-1 if a default region hasn't been set
	AWS_DEFAULT_REGION="eu-west-1"
fi

# Define the S3 endpoint URI
if [ "$AWS_DEFAULT_REGION" = "us-east-1" ]
then
	S3_ENDPOINT="s3.amazonaws.com"
else
	S3_ENDPOINT="s3-$AWS_DEFAULT_REGION.amazonaws.com"
fi

if [ ! -z "$SNS_TOPIC" ]
then
	# If we were given a SNS topic, tell yas3fs to use it.
	exec /usr/local/bin/yas3fs --topic "$SNS_TOPIC" --new-queue-with-hostname --foreground --no-metadata --nonempty "s3://$AWS_S3_BUCKET/uploads" /bedrock/web/app/uploads --region "$AWS_DEFAULT_REGION" --s3-use-sigv4 --s3-endpoint "$S3_ENDPOINT"
else
	# Else, don't.
	exec /usr/local/bin/yas3fs --foreground --no-metadata --nonempty "s3://$AWS_S3_BUCKET/uploads" /bedrock/web/app/uploads --region "$AWS_DEFAULT_REGION" --s3-use-sigv4 --s3-endpoint "$S3_ENDPOINT"
fi
