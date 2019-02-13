#!/bin/sh

#Create Tenant file for script based on your environment
cat > tenant.json <<END
{
  "id" : "$TENANT_ID",
  "name" : "$TENANT_NAME",
  "description" : "$TENANT_DESC"
}
END

#Send created Tenant to Okapi
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant.json $OKAPI_URL/_/proxy/tenants

#Okapi internal module for the Tenant
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"id":"okapi"}' $OKAPI_URL/_/proxy/tenants/$TENANT_ID/modules
