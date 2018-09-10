#!/bin/sh

#Create Tenant
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @tenant.json http://okapi:9130/_/proxy/tenants

#Okapi internal module for the tenant
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"id":"okapi"}' http://okapi:9130/_/proxy/tenants/diku/modules
