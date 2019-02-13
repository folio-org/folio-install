## Build Docker image

`docker build -t create-sampdata .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-sampdata -h create-sampdata -e TENANT_ID=diku -e ADMIN_USER=diku_admin -e ADMIN_PASSWORD=admin -e OKAPI_URL=http://localhost:9130 -e X_OKAPI_TOKENL=default create-sampdata`

## Environment variables

When you deploy the `create-sampdata` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant. Defaults to `diku`.

### ADMIN_USER

Name of the superuser for Folio. Defaults to `diku_admin`.

### ADMIN_PASSWORD

Password of the superuser. Defaults to `admin`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### X_OKAPI_TOKEN

The Token for the Folio system located in the UI under Settings - Developer - Set Token. Defaults to `default`.

## Additional Notes

This job is only meant to run in a Folio suystem with the Diku Tenant and reference data loaded. The sample data here is for the Diku tenant ONLY.
