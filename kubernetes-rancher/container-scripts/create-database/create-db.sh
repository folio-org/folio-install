#!/bin/sh

#Set postgres password environment variable
export PGPASSWORD=$PG_PASSWORD

#Create folio_admin user and set password
psql -U postgres -h pg-folio -w --command "CREATE USER folio_admin WITH SUPERUSER PASSWORD 'folio_admin';"

#Set okapi DB's owner that was created at pgset runtime and create roles
psql -U postgres -h pg-folio -w --command "ALTER DATABASE okapi OWNER TO okapi;" &&\
    psql -U postgres -h pg-folio -w --command "ALTER ROLE okapi CREATEDB;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_calendar PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_circulation_storage PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_configuration PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_inventory_storage PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_login PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_notes PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_notify PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_permissions PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_users PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE ROLE diku_mod_vendors PASSWORD 'diku' NOSUPERUSER NOCREATEDB INHERIT LOGIN;" &&\
    psql -U postgres -h pg-folio -w --command "CREATE DATABASE okapi_modules WITH OWNER=folio_admin ENCODING 'UTF8' LC_CTYPE 'en_US.UTF-8' LC_COLLATE 'en_US.UTF-8' TEMPLATE 'template0';"

#Copy in dump of latest Okapi modules
psql -U postgres -h pg-folio -w okapi_modules < /usr/local/bin/folio/okapi_modules.dmp