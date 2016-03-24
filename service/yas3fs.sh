#!/bin/sh
# Mount the WordPress uploads directory to S3 using yas3fs
exec /usr/local/bin/yas3fs --foreground --no-metadata --nonempty s3://$AWS_S3_BUCKET/uploads /bedrock/web/app/uploads --topic $SNS_TOPIC --queue $SQS_QUEUE
