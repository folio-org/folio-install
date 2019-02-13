## Build Docker image

`docker build -t create-db .`

### Linux console run command

`docker run --rm -d --network folio-network --name create-db -h create-db -e PG_PASSWORD=password -e DB_USERNAME=folio_admin -e DB_PASSWORD=password -e PG_DATABASE=okapi -e PG_USER=okapi -e DB_DATABASE=okapi_modules create-db`

## Environment variables

When you deploy the `create-db` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### PG_DATABASE

Name of your Okapi database inside of Postgres. Defaults to `okapi`. (This database should be created in advance in Postgres)

### PG_USER

Name of the okapi User/Role for the Okapi database. Defaults to `okapi`. (This User and Role should be created in advance in Postgres)

### PG_PASSWORD

Password of the Postgres database superuser. Defaults to `password`. (This Password should have been created and set when Postgres was set up)

### DB_HOST

IP address or URL of where Postgres is hosted. Defaults to `pghost`.

### DB_DATABASE

Name of the Folio module database to be created. Defaults to `okapi_modules`.

### DB_USERNAME

Name of the Folio module database superuser to be created. Defaults to `folio_admin`.

### DB_PASSWORD

Password to set for the Folio module database superuser. Defaults to `password`.
