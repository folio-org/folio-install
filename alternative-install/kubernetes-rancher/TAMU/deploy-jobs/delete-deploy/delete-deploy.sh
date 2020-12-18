#!/bin/sh

# POST the list of Stripes modules to disable for a tenant

echo POSTing the list of Stripes modules to disable for a tenant...

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @disable/stripes-disable.json \
  $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?preRelease=false

# POST the list of backend modules to disable for a tenant

echo POSTing the list of backend modules to disable for a tenant, and purging data if set to true...

# If you get an "HTTP/1.1 500 Internal Server Error" here, your module has an issue

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @disable/okapi-disable.json \
  $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?deploy=false\&preRelease=false\&purge=$PURGE_DATA

echo Done!