# Cloning a FOLIO Tenant

It turns out that as long as the module database FOLIO admin role and the tenant IDs are the same, it's fairly trivial to clone a tenant from one FOLIO instance to another using `pg_dump` and `pg_restore`. This procedure can also be used for backup/restore.

## Procedure

1. Create the tenant on the target cluster using the same tenant ID as the source cluster. Install the same set of modules for the tenant (without `loadReference` or `loadSample`). This will ensure that the database is initialized for all modules by creating the required roles for the tenant and defining any required functions that are outside of module schema namespaces.

2. Back up the custom CAST definitions.

```
psql -U $SRC_DB_ADMIN -h $SRC_PG_HOSTNAME -AtF $'\t' $SRC_DATABASE <<EOF | awk -F '\t' '{ create_cast="CREATE CAST (" $1 " AS " $2 ")"; if ($5="i") { func_clause="WITH INOUT" } else if ($5="b") { func_clause="WITHOUT FUNCTION" } else { func_clause="WITH FUNCTION " $3 }; if ($4="i") { assign="AS IMPLICIT" } else if ($4="a") { assign="AS ASSIGNMENT" } else { assign="" }; print create_cast " " func_clause " " assign ";" }' > ${TENANT_ID}-casts.sql
SELECT castsource::regtype, casttarget::regtype, castfunc::regproc,  castcontext, castmethod
  FROM pg_catalog.pg_cast
WHERE (casttarget::regtype)::varchar like '${TENANT_ID}%';
EOF
```

3. Use `pg_dump` to create a backup of the source tenant schemas. It is safest if the client version of `pg_dump` matches the server version of PostgreSQL.

```
pg_dump -U $SRC_DB_ADMIN -h $SRC_PG_HOSTNAME -d $SRC_DATABASE --format=c --blobs --serializable-deferrable --file=$DUMP_FILE --schema="${TENANT_ID}_*"
```

4. Drop all the target schemas from the target database. This shouldn't be strictly necessary, but some schemas (mod-quick-marc and mod-data-export-spring, looking at you) seem to pose a problem and won't be updated without this step.

```
psql -U $TARGET_DB_ADMIN -h $TARGET_DB_HOST $TARGET_DATABASE <<EOF
DO \$\$ DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE '${TENANT_ID}_%') LOOP
    EXECUTE 'DROP SCHEMA IF EXISTS ' || quote_ident(r.schema_name) || ' CASCADE';
  END LOOP;
END \$\$;
EOF
```

5. Use `pg_restore` to load the data into the target database. Note that you must use the same version of `pg_restore` and `pg_dump`.

```
pg_restore -U $TARGET_DB_ADMIN -h $TARGET_DB_HOST -d $TARGET_DATABASE --clean --if-exists $DUMP_FILE
```

6. Restore the custom CAST definitions

```
psql -U $TARGET_DB_ADMIN -h $TARGET_DB_HOST -f ${TENANT_ID}-casts.sql $TARGET_DATABASE
```

7. Restart all the backend modules in the target environment

```
for i in $(kubectl -n <TARGET_NAMESPACE> get pods -l workload=folio_module -o jsonpath={.items..metadata.name}); do kubectl -n <TARGET_NAMESPACE> delete pod/$i; done
```

8. Run `VACUUM ANALYZE` in the target database

```
psql -U $TARGET_DB_ADMIN -h $TARGET_DB_HOST -c 'VACUUM ANALYZE' $TARGET_DATABASE
```

9. Recreate the inventory search index. POST to `/search/index/inventory/reindex`:

```
curl -w '\n' -D - -X POST http://okapi:9130/search/index/inventory/reindex -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{"recreateIndex": true}'
```

## Notes and caveats

* Both environments should have a running FOLIO environment with all the same module versions

* The following modules have system users and passwords that must be aligned with deployment environment variables. You may need to delete/recreate credentials if updated, do a `rollout restart` of the deployments.
    * mod-data-export-spring: username `data-export-system-user`, password from `SYSTEM_USER_PASSWORD`
    * mod-entities-links: username `mod-entities-links`, password from `SYSTEM_USER_PASSWORD`
    * mod-pubsub: username from `SYSTEM_USER_NAME`, password from `SYSTEM_USER_PASSWORD`
    * mod-remote-storage: username `system-user` password from `SYSTEM_USER_PASSWORD`
    * mod-search: username `mod-search`, password from `SYSTEM_USER_PASSWORD`

* Cloning the mod-data-export-spring schema seems to corrupt the data in the schema so that circulation log exports no longer work. Unfortunately, the only solution is to disable the module with `purge=true` and then reenable it and do a `rollout restart` of both mod-data-export-spring and mod-data-export-worker. This has the side effect of emptying out the "Export manager" log.

* mod-ldp stores data in a single table in the `public` schema. Manual extraction and insertion is probably the best option, unfortunately.

* The target FOLIO instance *Settings - Tenant - SSO settings - Identity Provider UR*L configuration may need to be updated if the environment you're cloning to is for staging/testing.

* The target FOLIO instance *Settings - OAI-PMH - General - Base URL* configuration will need to be updated to reflect the edge URL for that instance.
