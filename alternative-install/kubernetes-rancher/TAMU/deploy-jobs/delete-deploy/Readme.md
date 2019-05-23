## Build Docker image

`docker build -t delete-deploy .`

### Linux console run command

`docker run --rm -d --network folio-network --name delete-deploy -h delete-deploy -e TENANT_ID=mytenant -e OKAPI_URL=http://localhost:9130 -e PURGE_DATA=false delete-deploy`

### What to disable

Update the included disable/stripes-disable.json and disable/okapi-disable.json files with the modules and versions you wish to disable for your Folio system's Okapi `/_/proxy/tenants/<tenant_id>/install` endpoint. The disable will take some time if you set the PURGE_DATA environment variable to true, as all of the module data are removed from their databases for that tenant.

## Environment variables

When you deploy the `delete-deploy` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant. Defaults to `mytenant`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### PURGE_DATA

Purge all module data. Defaults to `false`.