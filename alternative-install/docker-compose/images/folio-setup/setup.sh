#!/usr/bin/env bash

sleep 60;

if [ "$INITDB" = "true" ]; then
    # set git repo to the correct branch or tag
    (cd platform-complete  && git checkout "$PLATFORM_COMPLETE_TAG");
    (cd folio-install  && git checkout "$FOLIO_INSTALL_TAG");

    #Pull module descriptors from central repository (this will take a while)
    #curl -w '\n' -X POST -H "Content-type: application/json" -d '{"urls":["http://folio-registry.aws.indexdata.com"]}' "$OKAPI_URL/_/proxy/pull/modules";

    ./setup.py
    #sleep within python script(180s)

    #Create FOLIO Superuser
    perl folio-install/bootstrap-superuser.pl --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "$OKAPI_URL";
fi

if [ "$LOAD_SAMPLEDATA" = "true" ] && [ "$INITDB" = "true" ]; then
    # Load Ref data
    perl folio-install/load-data.pl --sort location-units/institutions,location-units/campuses,location-units/libraries,locations --custom-method loan-rules-storage=PUT --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "$OKAPI_URL" folio-install/reference-data;

    # Sample Data
    perl folio-install/load-data.pl --sort fiscal_year,ledger,fund,budget,instance-storage/instances,instance-storage/instance-relationships,holdings-storage,item-storage,users,authn,perms,service-points-users --custom-method --custom-method "instances/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/"=PUT --tenant "$OKAPI_TENANT" --user "$FOLIO_USER" --password "$FOLIO_PASSWORD" --okapi "$OKAPI_URL" folio-install/sample-data;

    # Inventory data
    reqtoken=$(curl -w '\n' -D - -X POST -H "Content-type: application/json" -H "Accept: application/json" -H "X-Okapi-Tenant: $OKAPI_TENANT" -d '{"username":"'"$FOLIO_USER"'","password":"'"$FOLIO_PASSWORD"'"}'   "$OKAPI_URL/authn/login");
    token=$(echo $reqtoken | awk '{print $14}');
    # post the files in sample-data/mod-inventory
    for i in folio-install/sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: $OKAPI_TENANT" -H "X-Okapi-Token: $token" -F upload=@${i} "$OKAPI_URL/inventory/ingest/mods"; done

fi
sleep 240;
