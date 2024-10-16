## Build Docker image

`docker build -t create-config .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-config -h create-config -e TENANT_ID=mytenant -e EMAIL_FROM=noreply@folio.org -e EMAIL_PASSWORD="password" -e EMAIL_SMTP_HOST=localhost -e EMAIL_SMTP_PORT=502 -e EMAIL_USERNAME=login -e OKAPI_URL=http://localhost:9130 create-config`

## Environment variables

When you deploy the `create-config` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

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

### SERVICE_POINT

UUID of the service point in FOLIO you wish to set for SIP2.

### SELF_CHECKOUT_CONFIG

Java config for configuring SIP2 self-checkout settings. An example might look like this:

`{\"timeoutPeriod\": 5,\"retriesAllowed\": 3,\"terminalDelimeter\" : \"\\r\",\"fieldDelimeter\" : \"|\",\"errorDetectionEnabled\" : true,\"charset\" : \"UTF8\",\"SCtimeZone\" : \"EDT\",\"checkinOk\": true,\"checkoutOk\": true,\"acsRenewalPolicy\": false,\"maxPrintWidth\" : 200,\"libraryName\": \"DI\",\"terminalLocation\": \"<SERVICE_POINT UUID>\"}`

### ACS_TENANT_CONFIG

Java config for configuring SIP2 message support. An example might look like this:

`{\"supportedMessages\": [{\"messageName\": \"REQUEST_SC_ACS_RESEND\",\"isSupported\": \"Y\"},{\"messageName\": \"PATRON_STATUS_REQUEST\",\"isSupported\": \"N\"},{\"messageName\": \"CHECKOUT\",\"isSupported\": \"Y\"},{\"messageName\": \"CHECKIN\",\"isSupported\": \"Y\"},{\"messageName\": \"BLOCK_PATRON\",\"isSupported\": \"N\"},{\"messageName\": \"SC_ACS_STATUS\",\"isSupported\": \"Y\"},{\"messageName\": \"LOGIN\",\"isSupported\": \"Y\"},{\"messageName\": \"PATRON_INFORMATION\",\"isSupported\": \"Y\"},{\"messageName\": \"END_PATRON_SESSION\",\"isSupported\": \"Y\"},{\"messageName\": \"FEE_PAID\",\"isSupported\": \"N\"},{\"messageName\": \"ITEM_INFORMATION\",\"isSupported\": \"N\"},{\"messageName\": \"ITEM_STATUS_UPDATE\",\"isSupported\": \"N\"},{\"messageName\": \"PATRON_ENABLE\",\"isSupported\": \"N\"},{\"messageName\": \"HOLD\",\"isSupported\": \"N\"},{\"messageName\": \"RENEW\",\"isSupported\": \"N\"},{\"messageName\": \"RENEW_ALL\",\"isSupported\": \"N\"}],\"statusUpdateOk\": false,\"offlineOk\": false,\"currencyType\" : \"USD\",\"language\" : \"en\",\"patronPasswordVerificationRequired\" : false}`

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### X_OKAPI_TOKEN

Okapi Token for your tenant. Defaults to `foo`.

### FOLIO_HOST

FOLIO URL for your tenant. Defaults to `http://localhost:3000`.
