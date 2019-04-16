#!/bin/sh

export OKAPI_URL_PY=$OKAPI_URL
export REGISTRY_URL_PY=$REGISTRY_URL

# Pull module descriptors from central registry (this will take a while)

echo Pulling in module descriptors from Index Data module registry...

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @install/okapi-pull.json \
  $OKAPI_URL/_/proxy/pull/modules

# Generate deployment descriptors, POST to /_/discovery/modules

echo Generating deployment descriptors for these backend modules...

python ./create-deploy-desc.py

# POST the list of backend modules to enable for a tenant

echo POSTing the list of backend modules to install for a tenant, and importing data if set to true...

# If you get an "HTTP/1.1 500 Internal Server Error" here, your module needs to be able connect to the database

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @install/okapi-install.json \
  $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3D$SAMPLE_DATA%2CloadReference%3D$REF_DATA

# POST the list of Stripes modules to enable for a tenant

echo POSTing the list of Stripes modules to install for a tenant...

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
  -d @install/stripes-install.json \
  $OKAPI_URL/_/proxy/tenants/$TENANT_ID/install?preRelease=false

echo Done!