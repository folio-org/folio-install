# Dockerfile for backend-modules

With this Dockerfile comes a shell script as `docker-entrypoint` which performs the registration and activation of modules depending on whether there exists a module-descriptor in the public folio-registry and existing okapi-installations.

simply adjust the environment variables below matching your installation parameters and start the container. a typical `docker-compose.yml` would look like this:
```yml
  mod-calendar-1.0.2:
    image: folioorg/mod-calendar:1.0.2
    environment:
      SERVICE_URL: http://mod-calendar-1.0.2:8081
      DB_DATABASE: okapi
      DB_USERNAME: okapi
      DB_PASSWORD: changeMe
      DB_HOST: okapi-db-2.22.0
      DB_PORT: "5432"
      OKAPI_URL: http://okapi-2.22.0:9130
      SERVICE_ID: mod-calendar-1.0.2
      INSTALL_ID: mod-calendar-1.0.2
      SELF_DEPLOY: "true"
    depends_on:
    - okapi-2.22.0
    - okapi-db-2.22.0
  ...
```

On first startup the module-container will look for *okapi* at the provided OKAPI_URL and perform the registration-process via *curl*. there are multiple retries built in the process to ensure okapi comes up and ready accepting connections.

If the module is registered successfully the JAR is started provided by the command in env var `START_CMD`

## Configuration variables

* `OKAPI_TRY_COUNT=120`: sets the try count for testing whether okapi is up and running
* `ENABLE_TRY_COUNT=120`: sets the try count for enabling the module in okapi
* `CURL_CONNECT_TIMEOUT=3`: sets the connect-timeout for curl-requests
* `SERVICE_ID=$MODULE-$TAG`: sets the `srvcId` used within the enable-descriptor
* `INSTALL_ID=$MODULE-$TAG`: sets the `instId` used within the enable-descriptor
* `SERVICE_URL=http://localhost:8081/`: sets the service-url where the module is reachable
* `FOLIO_REGISTRY='http://folio-registry.aws.indexdata.com/_/proxy/modules/'`: sets the registry where module-descriptors are retrieved from
* `SELF_DEPLOY=false`: enables auto-registering the module in okapi at startup (if not already registered)

## Error-Codes

* `0`: Everything worked fine
* `1`: Timeout wayting for okapi (`wait_for_okapi`)
* `2`: should never occur. this marks "module not found" and should trigger the deployment-process - if enabled. see above.
* `3`: unknown error while testing whether the module is registered (`module_already_registered`)
* `4`: unknown error while fetching module-descriptor from folio-registry (`fetch_module_descriptor`)
* `5`: unknown error while registering the module in okapi (`register_module`)
* `5`: unknown error while enabling the module in okapi (`enable_module`)