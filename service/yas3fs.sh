#!/bin/sh

# Mount the WordPress uploads directory to S3 using yas3fs

if [ ! -z "$SNS_TOPIC" ] && [ ! -z "$SQS_QUEUE" ]
then
	# If we were given a SNS topic and SQS queue, tell yas3fs to use them.
	exec /usr/local/bin/yas3fs --topic $SNS_TOPIC --queue $SQS_QUEUE --foreground --no-metadata --nonempty s3://$AWS_S3_BUCKET/uploads /bedrock/web/app/uploads --region eu-west-1
else
	# Else, don't.
	exec /usr/local/bin/yas3fs --foreground --no-metadata --nonempty s3://$AWS_S3_BUCKET/uploads /bedrock/web/app/uploads --region eu-west-1
fi
