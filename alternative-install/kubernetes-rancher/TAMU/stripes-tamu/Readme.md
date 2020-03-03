## Build Docker image

`docker build --build-arg TENANT_ID=tamu --build-arg OKAPI_URL=http://localhost:9130 -t stripes .`

### Linux console run command ###

`docker run --rm -d --network folio-network -p 3000:80 --name stripes stripes`

## Environment variables

When you build the `stripes` image, you can adjust the configuration by passing one or more Docker ARGs on the `docker build` command line. Running this Dockerfile assumes you have a Docker network `folio-network` created, with container port 3000 exposed to port 80 on your machine.

### TENANT_ID

The short name of the Tenant. Defaults to `tamu`.

### OKAPI_URL

URL to the Okapi back-end to use. Defaults to `http://localhost:9130`.
