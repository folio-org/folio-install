## Build Docker image

`docker build -t alter-db .`

### Linux console run command

`docker run --rm -d --network folio-network --name alter-db -h alter-db -e PG_PASSWORD=password -e PG_DATABASE=okapi -e PG_USER=okapi -e DB_DHOST=pg-host create-db`

## Environment variables

When you deploy the `alter-db` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### PG_DATABASE

Name of your database inside of Postgres. Defaults to `okapi`. (This database should be created in advance in Postgres)

### PG_USER

Name of the User/Role for the database. Defaults to `okapi`. (This User and Role should be created in advance in Postgres)

### PG_PASSWORD

Password of the Postgres database superuser. Defaults to `password`. (This Password should have been created and set when Postgres was set up)

### DB_HOST

IP address or URL of where Postgres is hosted. Defaults to `pg-host`.
