#!/bin/sh

# Set postgres password environment variable
export PGPASSWORD=$PG_PASSWORD

echo Setting schema access for reporting user.

# Alter schema for ldpreport user
psql -U $PG_USER -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ldpreport;" &&\
psql -U $PG_USER -h $DB_HOST -d $PG_DATABASE -w --command "ALTER SCHEMA folio_reporting OWNER TO ldpadmin;"

# Change directories to run derived table code
cd /usr/local/bin/ldp/sql/derived_tables

echo Generating derived tables...

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

echo Setting schema access for all other users.

# After all database updates and derived table queries have completed, correct schema access and roles
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA mis TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA folio_reporting TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA public TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA history TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA mis TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA history TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "ALTER DEFAULT PRIVILEGES IN SCHEMA mis GRANT SELECT ON TABLES TO ro_ldp_user;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA mis TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA folio_reporting TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA public TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA history TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA mis TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA history TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "ALTER DEFAULT PRIVILEGES IN SCHEMA mis GRANT SELECT ON TABLES TO ldpreport;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT USAGE ON SCHEMA public TO ldp;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ldp;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ldp;"

echo Running item history update...

# Change directories to run item history update perl script
cd /usr/local/bin/ldp
perl ./item_history_update.pl

# After all database updates and derived table queries have completed, it is recommended to run vacuum and analyze as superuser
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "VACUUM;" &&\
psql -U ldpadmin -h $DB_HOST -d $PG_DATABASE -w --command "ANALYZE;"

echo Done!
