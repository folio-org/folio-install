## Build Docker image

`docker build -t create-tenant .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-tenant -h create-tenant -e TENANT_ID=mytenant -e TENANT_NAME="full_tenant_name" -e TENANT_DESC="tenant_description" -e OKAPI_URL=http://localhost:9130 create-tenant`

## Environment variables

When you deploy the `create-tenant` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant to create. Defaults to `mytenant`.

### TENANT_NAME

Full name of the Tenant to create. Defaults to `full_tenant_name`.

### TENANT_DESC

Description of the Tenant to create. Defaults to `tenant_description`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.
