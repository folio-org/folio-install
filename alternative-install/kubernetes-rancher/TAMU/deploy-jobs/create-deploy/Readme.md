## Build Docker image

`docker build -t create-deploy .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-deploy -h create-deploy -e TENANT_ID=mytenant -e OKAPI_URL=http://localhost:9130 create-deploy`

## Environment variables

When you deploy the `create-deploy` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network 'folio-network' created.

### TENANT_ID

The short name of the Tenant. Defaults to mytenant.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to http://localhost:9130.