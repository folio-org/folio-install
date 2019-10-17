## Build Docker image

`docker build -t create-email-config .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-email-config -h create-email-config -e TENANT_ID=mytenant -e EMAIL_FROM="noreply@folio.org" -e EMAIL_PASSWORD="password" -e EMAIL_SMTP_HOST="localhost" -e EMAIL_SMTP_PORT="502" -e EMAIL_USERNAME="login" -e OKAPI_URL=http://localhost:9130 create-email-config`

## Environment variables

When you deploy the `create-email-config` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant to use. Defaults to `mytenant`.

### EMAIL_FROM

The 'from' property of the email. Defaults to `noreply@folio.org`.

### EMAIL_PASSWORD

The password for the login. Defaults to `password`.

### EMAIL_SMTP_HOST

The hostname of the smtp server. Defaults to `localhost`.

### EMAIL_SMTP_PORT

The port of the smtp server. Defaults to `502`.

### EMAIL_USERNAME

The username for the login. Defaults to `login`.

### EMAIL_SMTP_LOGIN_OPTION

The login mode for the connection. Examples are `DISABLED`, `OPTIONAL` or `REQUIRED` Defaults to `DISABLED`.

### EMAIL_TRUST_ALL

Trust all certificates on ssl connect. Examples are `true` or `false` Defaults to `true`.

### EMAIL_SMTP_SSL

sslOnConnect mode for the connection. Examples are `true` or `false` Defaults to `false`.

### EMAIL_START_TLS_OPTIONS

TLS security mode for the connection. Examples are `NONE`, `OPTIONAL` or `REQUIRED` Defaults to `NONE`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### X_OKAPI_TOKEN

Okapi Token for your tenant. Defaults to `foo`.

### FOLIO_HOST

Folio URL for your tenant. Defaults to `http://localhost:3000`.
