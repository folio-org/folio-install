#!/bin/sh

#Set postgres password environment variable
export PGPASSWORD=$PG_PASSWORD

#Create folio_admin user and set password
psql -U postgres -h $DB_HOST -w --command "CREATE USER $DB_USERNAME WITH SUPERUSER PASSWORD '"$DB_PASSWORD"';"

#Set okapi DB's owner that was created at pgset runtime and create roles
    psql -U postgres -h $DB_HOST -w --command "ALTER DATABASE $PG_DATABASE OWNER TO $PG_USER;" &&\
    psql -U postgres -h $DB_HOST -w --command "ALTER ROLE $PG_USER CREATEDB;" &&\
    psql -U postgres -h $DB_HOST -w --command "ALTER USER $PG_USER with SUPERUSER;" &&\
    psql -U postgres -h $DB_HOST -w --command "CREATE DATABASE $DB_DATABASE WITH OWNER=$DB_USERNAME ENCODING 'UTF8' LC_CTYPE 'en_US.UTF-8' LC_COLLATE 'en_US.UTF-8' TEMPLATE 'template0';"

