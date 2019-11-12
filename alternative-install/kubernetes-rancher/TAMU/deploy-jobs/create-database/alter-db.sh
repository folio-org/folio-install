#!/bin/sh

#Set postgres password environment variable
export PGPASSWORD=$PG_PASSWORD

#Set DB owner that was created at pgset runtime and create roles
psql -U postgres -h $DB_HOST -w --command "ALTER USER $PG_USER with SUPERUSER;" &&\
psql -U postgres -h $DB_HOST -w --command "ALTER ROLE $PG_USER CREATEDB;" &&\
psql -U postgres -h $DB_HOST -w --command "ALTER DATABASE $PG_DATABASE OWNER TO $PG_USER;" &&\
psql -U postgres -h $DB_HOST -d $PG_DATABASE -w --command "CREATE EXTENSION pg_trgm;" &&\
psql -U postgres -h $DB_HOST -d $PG_DATABASE -w --command "ALTER EXTENSION pg_trgm SET SCHEMA pg_catalog;"
