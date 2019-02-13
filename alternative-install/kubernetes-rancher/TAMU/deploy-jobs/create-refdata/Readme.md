## Build Docker image

`docker build -t create-refdata .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-refdata -h create-refdata -e TENANT_ID=mytenant -e ADMIN_USER=tenant_admin -e ADMIN_PASSWORD=password -e OKAPI_URL=http://localhost:9130 create-refdata`

## Environment variables

When you deploy the `create-refdata` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### TENANT_ID

The short name of the Tenant. Defaults to `mytenant`.

### ADMIN_USER

Name of the superuser for Folio. Defaults to `tenant_admin`.

### ADMIN_PASSWORD

Password of the superuser. Defaults to `password`.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.
