# WordPress Base for Docker

A base docker image for running 12 factor WordPress applications.

## Intended Use

This docker image is intended to be used as a base that's extended from when creating  WordPress applications that follow the [Twelve-Factor App](http://12factor.net/) philosophy.

Within MOJ Digital, we are using this as part of our Publishing Platform. It is just one piece of a larger puzzle, and so it's not particularly useful on its own.

## Environment Variables

This image expects the following environment variables to be declared:

| Environment Variable  | Description |
| --------------------- | ----------- |
| `SERVER_NAME`  | The FQDN of the WordPress application which this image is serving.  |
| `AWS_ACCESS_KEY_ID` <br/> `AWS_SECRET_ACCESS_KEY` | AWS access key credentials – requires CRUD permissions on the specified S3 bucket.  |
| `AWS_S3_BUCKET` | Name of the AWS S3 bucket to be used for storage of items uploaded to the WordPress media library. |
| `SMTP_HOST` <br/> `SMTP_PORT`&nbsp;*(optional)* <br/> `SMTP_USER` <br/> `SMTP_PASS` <br/> `SMTP_USE_STARTTLS`&nbsp;*(optional)* <br/> `SMTP_USE_SSL`&nbsp;*(optional)* | SMTP settings to use for outgoing emails. <br/><br/> If not supplied, `SMTP_PORT` will default to 25. <br/><br/> `SMTP_USE_STARTTLS` and `SMTP_USE_SSL` are optional but mutually exclusive. <br/> It's highly recommended that you use one! *(You weren't planning on sending those credentials in plain text, now, were you?)* |
| `WHITELIST_IPS` | A comma-separated list of IP addresses which should be granted access to the WordPress login page (`/wp/wp-login.php`) |

### Example env file

```ini
SERVER_NAME=example.com

#The IP range of the load balancers. Used for setting the real client IP.
LB_IP_RANGE=192.168.1.0/24

# AWS access keys
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_S3_BUCKET=example-bucket

# SMTP relay
SMTP_HOST=smtp.example.com
SMTP_USER=username
SMTP_PASS=secret
SMTP_USE_STARTTLS=true

WHITELIST_IPS=192.168.99.1,93.184.216.34
```
