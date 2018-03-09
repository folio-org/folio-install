# Migrating from one PostgreSQL server to another
You may find at some point that you need to migrate a FOLIO database from one PostgreSQL server to another. In my case, I had to migrate a database from RDS to a standalone server. This example assumes that all module data is in a single database. Here are the steps I had to take (for future reference):

1. On the target PostgreSQL server, create the database and superuser database role (used by RMB storage modules).
```
CREATE ROLE <username> PASSWORD <password> LOGIN SUPERUSER;
CREATE DATABASE <database> WITH OWNER <username>;
```

2. On the source server, list all the database roles, using the command `\du`. Output should look something like:
```
 diku_mod_circulation_storage |                                                            | {}
 diku_mod_configuration       |                                                            | {}
 diku_mod_inventory_storage   |                                                            | {}
 diku_mod_login               |                                                            | {}
 diku_mod_notes               |                                                            | {}
 diku_mod_notify              |                                                            | {}
 diku_mod_permissions         |                                                            | {}
 diku_mod_users               |                                                            | {}
 folioperf                    | Create role, Create DB                                    +| {rds_superuser,diku_mod_permissions,diku_mod_login,diku_mod_users,diku_mod_configuration,diku_mod_inventory_storage,diku_mod_circulation_storage,diku_mod_notify,diku_mod_notes}
```

3. On the target server, create each of the `<tenant>_<module>` roles, with password `<tenant>`. For example:
```
CREATE ROLE diku_mod_circulation_storage WITH PASSWORD 'diku' INHERIT LOGIN;
```

4. Dump the database from the source instance using `pg_dump`. I chose to use the "directory" dump format in this example, and use 4 processor threads to speed it up:
```
pg_dump --create --format=d --file=<backup directory> --jobs=4 --verbose -U <database user> -h <database host> <database name>
```

5. Load the database into the target instance using `pg_restore`.
```
pg_restore -U <username> -h <database host> --dbname=<database name> --jobs=4 --verbose --clean <backup_directory>
```

6. On the target server, connect to the target database, and `GRANT USAGE` to the public schema to each of the `<tenant>_<module>` roles:
```
GRANT USAGE ON SCHEMA public TO diku_mod_circulation_storage
```

7. Update the database connection information on the Okapi `/_/env` endpoint, and restart Okapi (assuming modules have been deployed to the `/_/discovery` endpoint for deployment persistance).
