## Build Docker image

`docker build -t bootstrap-superuser .`

### Linux console run command

`docker run --rm -d --network folio-network --name bootstrap-superuser -h bootstrap-superuser -e TENANT_ID=mytenant -e ADMIN_USER=tenant_admin -e ADMIN_PASSWORD=password -e OKAPI_URL=http://localhost:9130 bootstrap-superuser`

## Environment variables

When you deploy the `bootstrap-superuser` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network 'folio-network' created.

### TENANT_ID

The short name of the Tenant. Defaults to mytenant.

### ADMIN_USER

Name of the Folio superuser to create. Defaults to tenant_admin.

### ADMIN_PASSWORD

Password to set for the Folio superuser. Defaults to password.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to http://localhost:9130.