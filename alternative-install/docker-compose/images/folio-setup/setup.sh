#!/bin/sh

sleep 90;

#Pull module descriptors from central repository (this will take a while)
curl -w '\n' -X POST -H "Content-type: application/json" -d '{"urls":["http://folio-registry.aws.indexdata.com"]}' "http://$OKAPI_NODENAME:$OKAPI_PORT/_/proxy/pull/modules";

#Create Tenant
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d '{"id":"'"$OKAPI_TENANT"'","name":"'"$TENANT_NAME"'","description":"'"$TENANT_DESCRIPTION"'"}' "http://$OKAPI_NODENAME:$OKAPI_PORT/_/proxy/tenants";

#Okapi internal module for the tenant
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"id":"okapi"}' "http://$OKAPI_NODENAME:$OKAPI_PORT/_/proxy/tenants/$OKAPI_TENANT/modules";

(cd platform-complete  && git checkout "$PLATFORM_COMPLETE_TAG");
# Post the list of backend modules to deploy and enable
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @platform-complete/okapi-install.json "http://$OKAPI_NODENAME:$OKAPI_PORT/_/proxy/tenants/$OKAPI_TENANT/install?deploy=true&preRelease=false";

# Post the list of Stripes modules to enable
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @platform-complete/stripes-install.json "http://$OKAPI_NODENAME:$OKAPI_PORT/_/proxy/tenants/$OKAPI_TENANT/install?preRelease=false";

#Create FOLIO Superuser
perl folio-install/bootstrap-superuser.pl --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "http://$OKAPI_NODENAME:$OKAPI_PORT";


if [ $LOAD_SAMPLEDATA = 'true' ]; then
    # Load Ref data
    perl folio-install/load-data.pl --sort location-units/institutions,location-units/campuses,location-units/libraries,locations --custom-method loan-rules-storage=PUT --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "http://$OKAPI_NODENAME:$OKAPI_PORT" folio-install/reference-data;

    # Sample Data
    perl folio-install/load-data.pl --sort fiscal_year,ledger,fund,budget,instance-storage/instances,instance-storage/instance-relationships,holdings-storage,item-storage,users,authn,perms,service-points-users --custom-method --custom-method "instances/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/"=PUT --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "http://$OKAPI_NODENAME:$OKAPI_PORT" folio-install/sample-data;

    # Inventory data
    reqtoken=$(curl -w '\n' -D - -X POST -H "Content-type: application/json" -H "Accept: application/json" -H "X-Okapi-Tenant: $OKAPI_TENANT" -d '{"username":"'"$FOLIO_USER"'","password":"'"$FOLIO_PASSWORD"'"}'   "http://$OKAPI_NODENAME:$OKAPI_PORT/authn/login");
    token=$(echo $reqtoken | awk '{print $14}');
    # post the files in sample-data/mod-inventory
    for i in folio-install/sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: $OKAPI_TENANT" -H "X-Okapi-Token: $token" -F upload=@${i} "http://$OKAPI_NODENAME:$OKAPI_PORT/inventory/ingest/mods"; done

fi
