## Build Docker image

`docker build -t create-deploy .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-deploy -h create-deploy -e TENANT_ID=mytenant -e OKAPI_URL=http://localhost:9130 -e REGISTRY_URL=http://localhost:9130/_/proxy/modules -e SAMPLE_DATA=false -e REF_DATA=false create-deploy`

### What to deploy

Update the included install/stripes-install.json and install/okapi-install.json files with the modules you wish to deploy to your Folio system's Okapi `/_/proxy/tenants/<tenant_id>/install` endpoint. The initial deploy will take some time, as all of the module descriptors are brought into your Okapi's `/_/proxy/modules` endpoint. You can change what registry you pull the module descriptors from, in the /install/okapi-pull.json file.

## Environment variables

When you deploy the `create-deploy` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant. Defaults to `mytenant`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### REGISTRY_URL

Module registry URL to use for YOUR Okapi. Defaults to `http://localhost:9130/_/proxy/modules`.

### SAMPLE_DATA

Load module sample data. Defaults to `false`.

### REF_DATA

Load module reference data. Defaults to `false`.
