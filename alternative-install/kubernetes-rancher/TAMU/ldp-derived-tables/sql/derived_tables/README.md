FOLIO Reporting Derived Tables
==============================

These queries create "derived tables" which are helper tables to
simplify writing ad hoc queries.

The tables are created in the schema `folio_reporting`.  For security
reasons, we suggest creating a separate database user, for example
`ldpreport`, and granting permissions for that user to create tables
only in the schema `folio_reporting`.

Before running the queries for the first time, the schema should be
created:

```sql
CREATE SCHEMA IF NOT EXISTS folio_reporting;

ALTER SCHEMA folio_reporting OWNER TO ldpadmin;

GRANT CREATE, USAGE ON SCHEMA folio_reporting TO ldpreport;

GRANT USAGE ON SCHEMA folio_reporting TO ldp;

GRANT USAGE ON SCHEMA public TO ldpreport;
```

There are various ways the queries can be executed.  One method is:

```shell
cd folio-analytics/sql/derived_tables
git checkout 0.9-release
git pull
psql ldp -U ldpadmin -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ldpreport;"
echo > logfile
for f in $( cat runlist.txt ); do
    echo >> logfile
    echo "======== $f ========" >> logfile
    echo >> logfile
    cat $f > tmpfile
    echo "GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ldp;" >> tmpfile
    psql ldp -U ldpreport -a -f tmpfile >> logfile 2>&1
done
```

Note that the provided file `runlist.txt` lists all of the query files
in the order they should be run.  The order is significant because
some of the queries depend on the result of other queries.  The file
`deps.txt` lists specific dependencies in the form *r1*: *r2* *r3* ...
where *r1* depends on *r2*, *r3*, ...

The queries should be rerun every night after the LDP full update
completes, so that the derived tables will be recreated with the
latest data.

After all database updates and derived table queries have completed,
it is recommended to run vacuum and analyze as superuser:

```shell
VACUUM;

ANALYZE;
```

