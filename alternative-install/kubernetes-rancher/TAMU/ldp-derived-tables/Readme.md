## Build Docker image

`docker build -t ldp-derived-tables .`


### Linux console run command ###

`docker run --rm -d --network folio-clustered --name ldp-derived-tables -h ldp-derived-tables -e PG_PASSWORD=ldp_db_password -e PG_USER=ldpadmin ldp-derived-tables`

## Environment variables

When you deploy the `ldp-derived-tables` image, you can adjust the configuration by passing one or more environment variables on the `docker run` command line. This assumes you have a Docker network `folio-network` created.

### PG_PASSWORD

Password for the LDP administrative user. Defaults to `ldp_db_password`.

### PG_ROOT_PASSWORD

Password for the Postgres administrative user. Defaults to `postgres_password`.

### PG_DATABASE

Name of the LDP database. Defaults to `ldp`.

### PG_USER

Name of the LDP administrative user. Defaults to `ldpadmin`.

### DB_HOST

Hostname or IP of the Postgres database host/server. Defaults to `pg-ldp`.

### PG_PRIMARY_PORT

Port that Postgres is running on for the database host/server. Defaults to `5432`.