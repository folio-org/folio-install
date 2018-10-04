FOLIO STRIPES Docker Image Build
===============================

This repository is used to build the FOLIO strips docker image. The docker image depends on github repository [folio-org/platform-complete](https://github.com/folio-org/platform-complete/tree/master).

### Docker Build

1. Check stripes.config.js for any additional modules.

    * DO NOT adjust this section of stripes.config.js. This section is required when deploying container using Environmental Variables (See Below for Deploy Options)

            okapi: { 'url':'DOCKER_OKAPI_SCHEME://DOCKER_OKAPI_HOSTPORT', 'tenant':'DOCKER_OKAPI_TENANT' },

2. Stripes Tag Variable
    * `stripestag` is set with --build-arg
    * This tag represents the branch or tag within [folio-org/platform-complete](https://github.com/folio-org/platform-complete/tree/master)

3. Build docker image

        $ docker build --build-arg stripestag=q3-2018 -t foliocli/folio-stripes .


### Deploy Options

#### Environmental Variables

1. OKAPI_HOSTPORT (default: localhost:9130)
2. OKAPI_TENANT (default: diku)
3. OKAPI_SCHEME (default: http)

#### Docker Run

1. Default options - See above for default okapi variables

        docker run -d -p 3000:80  foliocli/folio-stripes

2. Custom stripes okapi setup (Example: okapi:{ 'url':'https://culibraries.colorado.edu:9999','tenant':'folio'})

        docker run -d -p 3000:80 \
            -e "OKAPI_HOSTPORT=culibraries.colorado.edu:9999" \
            -e "OKAPI_SCHEME=https" \
            -e "OKAPI_TENANT=folio" \
            foliocli/folio-stripes    

Open browser to [http://localhost:3000](http://localhost:3000)
