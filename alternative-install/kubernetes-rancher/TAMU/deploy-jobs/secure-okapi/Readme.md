## Build Docker image

`docker build -t secure-okapi .`

### Linux console run command

`docker run --rm -d --network folio-network --name secure-okapi -h secure-okapi -e SUPER_USR=superuser -e SUPER_PSSWD=password -e OKAPI_URL=http://localhost:9130 secure-okapi`

## Environment variables

When you deploy the `secure-okapi` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### OKAPI_URL

Internal OKAPI URL to use. Defaults to `http://localhost:9130`.

### SUPER_USR

Name of the Okapi superuser to create. Defaults to `superuser`.

### SUPER_PSSWD

Password to set for the Okapi superuser. Defaults to `password`.

### TENANT_ID

The short name of the Tenant to create. Defaults to `supertenant`.

### SAMPLE_DATA

Load module sample data. Defaults to `false`.

### REF_DATA

Load module reference data. Defaults to `true`.
