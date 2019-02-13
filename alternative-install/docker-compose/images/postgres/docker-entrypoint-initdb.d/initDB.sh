#!/bin/bash

set -e

psql -U postgres -d postgres  -c "CREATE ROLE ${PG_USERNAME} WITH PASSWORD '${PG_PASSWORD}' LOGIN CREATEDB";
psql -U postgres -d postgres  -c "CREATE DATABASE $PG_DATABASE WITH OWNER $PG_USERNAME";
psql -U postgres -d postgres  -c "CREATE ROLE $DB_USERNAME WITH PASSWORD '$DB_PASSWORD' LOGIN SUPERUSER";
psql -U postgres -d postgres  -c "CREATE DATABASE $DB_DATABASE WITH OWNER $DB_USERNAME";