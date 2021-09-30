#!/bin/sh

# Set postgres password environment variable
export PGPASSWORD=$PG_PASSWORD

# Alter schema for ldpreport user
psql -U $PG_USER -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ldpreport;" &&\
psql -U $PG_USER -h $DB_HOST -d $PG_DATABASE -w --command "ALTER SCHEMA folio_reporting OWNER TO ldpadmin;"

# Change directories to run derived table code
cd /usr/local/bin/ldp/sql/derived_tables

# Queries can now be executed
echo > logfile
for f in $( cat runlist.txt ); do
    echo >> logfile
    echo "======== $f ========" >> logfile
    echo >> logfile
    cat $f > tmpfile
    echo "GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ldp;" >> tmpfile
    psql -U $PG_USER -h $DB_HOST -d $PG_DATABASE -a -f tmpfile >> logfile 2>&1
done

# Set postgres password environment variable for postgres
export PGPASSWORD=$PG_ROOT_PASSWORD

# After all database updates and derived table queries have completed, it is recommended to run vacuum and analyze as superuser
psql -U postgres -h $DB_HOST -d $PG_DATABASE -w --command "VACUUM;" &&\
psql -U postgres -h $DB_HOST -d $PG_DATABASE -w --command "ANALYZE;"
