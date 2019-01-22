## Build Docker image

`docker build --build-arg STRIPES_PLATFORM=https://github.com/folio-org/platform-complete --build-arg STRIPES_BRANCH=q4-2018 --build-arg TENANT_ID=mytenant --build-arg OKAPI_URL=http://localhost:9130 -t stripes .`

### Linux console run command ###

`docker run --rm -d --network folio-network -p 3000:80 --name stripes stripes`

## Environment variables

When you build the `stripes` image, you can adjust the configuration by passing one or more Docker ARGs on the `docker build` command line. Running this Dockerfile assumes you have a Docker network 'folio-network' created.

### STRIPES_PLATFORM

What Stripes platform to clone from Git. Defaults to https://github.com/folio-org/platform-complete.

### STRIPES_BRANCH

What Stripes platform branch to checkout. Defaults to q4-2018.

### TENANT_ID

The short name of the Tenant. Defaults to mytenant.

### OKAPI_URL

URL to the Okapi back-end to use. Defaults to http://localhost:9130.
