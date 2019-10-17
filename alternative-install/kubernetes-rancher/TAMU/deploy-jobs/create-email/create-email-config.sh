#!/bin/sh

#Create config files for script based on your environment
cat > email_from.json <<END
{
    "module" : "SMTP_SERVER",
    "configName" : "email",
    "code" : "EMAIL_FROM",
    "description" : "smtp from",
    "default" : true,
    "enabled" : true,
    "value" : "$EMAIL_FROM"
}
END

cat > email_password.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_PASSWORD",
    "description": "smtp password",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_PASSWORD"
}
END

cat > email_smtp_host.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_SMTP_HOST",
    "description": "email smtp host",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_SMTP_HOST"
}
END

cat > email_smtp_port.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_SMTP_PORT",
    "description": "smtp port",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_SMTP_PORT"
}
END

cat > email_username.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_USERNAME",
    "description": "smtp username",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_USERNAME"
}
END

cat > email_smtp_login_option.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_SMTP_LOGIN_OPTION",
    "description": "login mode for the connection",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_SMTP_LOGIN_OPTION"
}
END

cat > email_trust_all.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_TRUST_ALL",
    "description": "trust all certificates on ssl connect",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_TRUST_ALL"
}
END

cat > email_smtp_ssl.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_SMTP_SSL",
    "description": "sslOnConnect for the connection",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_SMTP_SSL"
}
END

cat > email_start_tls_options.json <<END
{
    "module": "SMTP_SERVER",
    "configName": "email",
    "code": "EMAIL_START_TLS_OPTIONS",
    "description": "TLS security for the connection",
    "default": true,
    "enabled": true,
    "value": "$EMAIL_START_TLS_OPTIONS"
}
END

cat > folio_host.json <<END
{
 "module": "USERSBL",
 "configName": "resetPassword",
 "code": "FOLIO_HOST",
 "description": "Folio UI application host",
 "default": true,
 "enabled": true,
 "value": "$FOLIO_HOST"
}
END

#Send created config json files to Okapi tenant
curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_from.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_password.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_smtp_host.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_smtp_port.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_username.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_smtp_login_option.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_trust_all.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_smtp_ssl.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @email_start_tls_options.json

curl -i -w '\n' -X POST $OKAPI_URL/configurations/entries \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: $TENANT_ID" \
-H "X-Okapi-Token: $X_OKAPI_TOKEN" \
-d @folio_host.json

echo Done!

