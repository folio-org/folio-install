#!/bin/sh

#Load Reference Data
perl ./load-data.pl \
--tenant $TENANT_ID --user $ADMIN_USER --password $ADMIN_PASSWORD --okapi $OKAPI_URL --sort fiscal_year,ledger,fund,budget,instance-storage/instances,instance-storage/instance-relationships,holdings-storage,item-storage,users,authn,perms,service-points-users \
--custom-method "instances/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/"=PUT \
/sample-data

for i in /sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $X_OKAPI_TOKEN" -F upload=@${i} http://okapi:9130/inventory/ingest/mods; done