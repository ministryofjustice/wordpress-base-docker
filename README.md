# WordPress Base for Docker

A base docker image for running 12 factor WordPress applications.

## Intended Usage

This docker image is intended to be used as a base that's extended from when creating  WordPress applications that follow the [Twelve-Factor App](http://12factor.net/) philosophy.

Within MOJ Digital, we are using this as part of our Publishing Platform. It is just one piece of a larger puzzle, and so it's not particularly useful on its own.

This image expects that you're using [Bedrock](https://roots.io/bedrock/) to structure your application. The base directory for application files is `/bedrock`, meaning the webroot should be located at `/bedrock/web`, and the themes directory at `/bedrock/web/app/themes`. WordPress core should be installed using `composer` and located in `/bedrock/web/wp`.

## Environment Variables

This image accepts the following environment variables. All are optional unless otherwise stated.

**Note:** The WordPress application that extends this image will require additional environment variables. Those documented below are just required by this base image.

### Server configuration

| Name            | Required | Description |
| --------------- | -------- | ----------- |
| `SERVER_NAME`   | Yes      | Name of the website. This will be available in PHP as `$_SERVER['SERVER_NAME']`, and should usually be the hostname of the website – e.g. `www.example.com` |
| `XDEBUG_CONFIG` |          | XDebug will be enabled if this is set. It should be a string of config settings that will be used by XDebug. Usually you'll only need to set the remote host for debugging – since this is docker, you'll need to use the IP address of your host machine (`localhost` will not work!). [Refer to the documentation](https://xdebug.org/docs/all_settings) for more settings. Example: `remote_host=172.22.5.156` |

### AWS file storage

Configuration for storage of file uploads in the WordPress media library.

| Name                    | Required | Description |
| ----------------------- | -------- | ----------- |
| `AWS_S3_BUCKET`         |          | Name of the S3 bucket to use for file uploads. If not set, S3 will not be mounted. |
| `AWS_ACCESS_KEY_ID`     |          | AWS access key ID. Must have permission to read/write to the specified S3 bucket, and optionally pub/sub to SNS and SQS. |
| `AWS_SECRET_ACCESS_KEY` |          | AWS secret access key |
| `AWS_DEFAULT_REGION`    |          | Default region when creating resources. Used by yas3fs when creating SQS queues. |
| `S3_UPLOADS_BASE_URL`   |          | URL to the `uploads` directory in the S3 bucket, without a trailing slash – e.g. `https://s3-eu-west-1.amazonaws.com/example-bucket/uploads` |
| `SNS_TOPIC`             |          | ARN for SNS topic – e.g. `arn:aws:sns:eu-west-1:123456789012:topic-name`. If not set, SNS/SQS will not be used. |

### Mail configuration

SMTP settings to use for outgoing emails.

| Name                | Required | Description |
| ------------------- | -------- | ----------- |
| `SMTP_HOST`         | Yes      | SMTP server hostname – e.g. `smtp.gmail.com` |
| `SMTP_PORT`         |          | SMTP port. Defaults to port `25`. |
| `SMTP_USER`         |          | SMTP username |
| `SMTP_PASS`         |          | SMTP password |
| `SMTP_USE_STARTTLS` |          | Set to `true` to connect using STARTTLS. |
| `SMTP_USE_SSL`      |          | Set to `true` to connect using SSL. <br/> **Top Tip:** When using SSL, you'll probably want to set `SMTP_PORT` to `465`. |

### IP whitelisting

| Name                  | Required | Description |
| --------------------- | -------- | ----------- |
| `LB_IP_RANGE`         |          | The IP range of the load balancers. Used by [nginx real-ip module](https://nginx.org/en/docs/http/ngx_http_realip_module.html) for setting the real client IP, to allow whitelists to work correctly. <br/> **Important:** Only set this when the docker container is running behind a load balancer! |
| `LOGIN_WHITELIST_IPS` |          | A comma-separated list of IP addresses that should be allowed to access the WordPress login page (`/wp/wp-login.php`) |
| `SITE_WHITELIST_IPS`  |          | A comma-separated list of IP addresses to whitelist the entire website. Disabled by default – i.e. the website will be publicly accessible. |

### Example env file

```ini
# Server configuration
SERVER_NAME=example.com

# AWS file storage
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_DEFAULT_REGION=eu-west-1
AWS_S3_BUCKET=example-bucket
S3_UPLOADS_BASE_URL=https://s3-eu-west-1.amazonaws.com/example-bucket/uploads
SNS_TOPIC=arn:aws:sns:eu-west-1:123456789012:example-topic

# Mail configuration
SMTP_HOST=smtp.example.com
SMTP_USER=username
SMTP_PASS=secret
SMTP_USE_STARTTLS=true

# IP whitelisting
LB_IP_RANGE=192.168.1.0/24
LOGIN_WHITELIST_IPS=192.168.99.1,93.184.216.34
```
