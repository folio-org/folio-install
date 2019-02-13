#!/bin/sh

#Load Reference Data
perl ./load-data.pl --tenant $TENANT_ID --user $ADMIN_USER --password $ADMIN_PASSWORD --okapi $OKAPI_URL --sort location-units/institutions,location-units/campuses,location-units/libraries,locations,statistical-code-types --custom-method loan-rules-storage=PUT /reference-data