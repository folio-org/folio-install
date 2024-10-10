# Library Data Platform Notes

# Contents
* [Useful Links](#useful-links)
* [Deployment on Infrastructure](#deployment-on-infrastructure)
* [LDP Process Flow](#ldp-process-flow)
* [Troubleshooting the LDP](#troubleshooting-the-ldp)
* [Tips for Creating Faster Queries in LDP Databases](LDP_Faster_Queries.pdf)

# Useful Links

#### About the Library Data Platform (LDP)
* https://docs.folio.org/docs/reporting/
* https://github.com/library-data-platform/ldp/blob/main/doc/User_Guide.md
* https://github.com/library-data-platform/ldp/blob/main/doc/Admin_Guide.md
* https://github.com/library-data-platform/ldpmarc
* https://github.com/folio-org/folio-analytics

#### Rancher Folio Clusters
1) https://rancher-dev.tamu.org
* folio-dev-cluster (*folio-dev*/*folio-test* namespaces)
* folio-pre-cluster (*folio-pre* namespace)
2) https://rancher.tamu.org
* folio-prod-cluster (*folio-prod* namespace)

# Deployment on Infrastructure

### Each LDP instance consists of the following pieces:
*The four Folio environments (Dev/Test/Pre/Prod) run their own LDP instance with dedicated K8s Secrets*
* LDP Postgres database (containerized K8s Workload or vSphere VM)
* Three time-ordered K8s cron jobs for the nightly sync and rebuild
* LDP "Server" K8s Workload
* Folio mod-ldp backend module
* Folio LDP UI App
* Github repo containing SQL code for the derived tables, and Folio UI LDP saved queries

### Breakdown of the Pieces:

#### Kubernetes Secrets needed for configuring the LDP:
`db-connect-ldp` (Deprecated in Nolana)<br/>
```
DB_CHARSET=UTF-8
DB_DATABASE=ldp
DB_HOST=pg-ldp
DB_MAXPOOLSIZE=10
DB_PASSWORD=<PASSWORD>
DB_PORT=5432
DB_QUERYTIMEOUT=120000
DB_USERNAME=ldpadmin
```
`db-config-ldp`<br/>
```
DB_HOST=pg-ldp
LDP_CONFIG_PASSWORD=<PASSWORD>
LDP_CONFIG_USER=ldpconfig
LDP_REPORT_PASSWORD=<PASSWORD>
LDP_REPORT_USER=ldpreport
LDP_USER=ldp
LDP_USER_PASSWORD=<PASSWORD>
PG_DATABASE=ldp
PG_PASSWORD=<PASSWORD>
PG_ROOT_PASSWORD=<PASSWORD>
PG_USER=ldpadmin
```
`ldp-conf`<br/>
```
ldpconf.json = {
    "anonymize": false,
    "deployment_environment": "staging",
    "ldp_database": {
        "database_name": "ldp",
        "database_host": "pg-ldp",
        "database_port": 5432,
        "database_user": "ldpadmin",
        "database_password": "<PASSWORD>",
        "database_sslmode": "disable"
    },
    "enable_sources": ["tamu_library"],
    "sources": {
        "tamu_library": {
            "okapi_url": "http://okapi:9130",
            "okapi_tenant": "tamu",
            "okapi_user": "tamu_admin",
            "okapi_password": "<PASSWORD>",
            "direct_tables": [
                "inventory_holdings",
                "inventory_instances",
                "inventory_items",
                "srs_marc",
                "srs_records"
            ],
            "direct_database_name": "okapi_modules",
            "direct_database_host": "pg-folio",
            "direct_database_port": 5432,
            "direct_database_user": "folio_admin",
            "direct_database_password": "<PASSWORD>"
        }
    }
}
```
`postgres-setup-sql-ldp`<br/>
<details>
<summary>Click Me for SQL</summary>
/*<br/>
 * Copyright 2016 - 2020 Crunchy Data Solutions, Inc.<br/>
 * Licensed under the Apache License, Version 2.0 (the "License");<br/>
 * you may not use this file except in compliance with the License.<br/>
 * You may obtain a copy of the License at<br/>
 *<br/>
 * http://www.apache.org/licenses/LICENSE-2.0<br/>
 *<br/>
 * Unless required by applicable law or agreed to in writing, software<br/>
 * distributed under the License is distributed on an "AS IS" BASIS,<br/>
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.<br/>
 * See the License for the specific language governing permissions and<br/>
 * limitations under the License.<br/>
 */<br/>
<br/>
--- System Setup<br/>
SET application_name="container_setup";<br/>
<br/>
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;<br/>
<br/>
ALTER USER postgres PASSWORD 'PG_ROOT_PASSWORD';<br/>
<br/>
CREATE USER "PG_PRIMARY_USER" WITH REPLICATION;<br/>
ALTER USER "PG_PRIMARY_USER" PASSWORD 'PG_PRIMARY_PASSWORD';<br/>
<br/>
CREATE USER "PG_USER" LOGIN;<br/>
ALTER USER "PG_USER" PASSWORD 'PG_PASSWORD';<br/>
<br/>
CREATE DATABASE "PG_DATABASE";<br/>
ALTER DATABASE "PG_DATABASE" SET search_path TO public;<br/>
GRANT ALL PRIVILEGES ON DATABASE "PG_DATABASE" TO "PG_USER";<br/>
<br/>
CREATE TABLE IF NOT EXISTS primarytable (key varchar(20), value varchar(20));<br/>
GRANT ALL ON primarytable TO "PG_PRIMARY_USER";<br/>
<br/>
--- PG_DATABASE Setup<br/>
<br/>
\c "PG_DATABASE"<br/>
<br/>
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;<br/>
<br/>
\c postgres postgres<br/>
<br/>
\set ldp_user `echo "$LDP_USER"`<br/>
\set ldp_config_user `echo "$LDP_CONFIG_USER"`<br/>
\set ldp_report_user `echo "$LDP_REPORT_USER"`<br/>
\set ldp_ro_user `echo "$LDP_RO_USER"`<br/>
<br/>
ALTER DATABASE "PG_DATABASE" OWNER TO "PG_USER";<br/>
CREATE USER :ldp_config_user LOGIN;<br/>
ALTER USER :ldp_config_user PASSWORD '<PASSWORD>';<br/>
CREATE USER :ldp_user LOGIN;<br/>
ALTER USER :ldp_user PASSWORD '<PASSWORD>';<br/>
CREATE USER :ldp_report_user LOGIN;<br/>
ALTER USER :ldp_report_user PASSWORD '<PASSWORD>';<br/>
CREATE USER :ldp_ro_user LOGIN;<br/>
ALTER USER :ldp_ro_user PASSWORD '<PASSWORD>';<br/>
<br/>
\c "PG_DATABASE" postgres<br/>
<br/>
CREATE SCHEMA IF NOT EXISTS folio_reporting;<br/>
ALTER SCHEMA folio_reporting OWNER TO ldpadmin;<br/>
GRANT CREATE, USAGE ON SCHEMA folio_reporting TO ldp;<br/>
GRANT USAGE ON SCHEMA folio_reporting TO ldp;<br/>
GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ldp;<br/>
ALTER DEFAULT PRIVILEGES IN SCHEMA folio_reporting GRANT SELECT ON TABLES TO ldp;<br/>
GRANT CREATE, USAGE ON SCHEMA folio_reporting TO ldpreport;<br/>
GRANT USAGE ON SCHEMA public TO ldpreport;<br/>
CREATE SCHEMA mis AUTHORIZATION ldpadmin;<br/>
GRANT USAGE ON SCHEMA mis TO ldp;<br/>
GRANT USAGE ON SCHEMA mis TO ldpadmin;<br/>
ALTER DEFAULT PRIVILEGES IN SCHEMA mis GRANT ALL PRIVILEGES ON TABLES TO ldp;<br/>
ALTER DEFAULT PRIVILEGES IN SCHEMA mis GRANT ALL PRIVILEGES ON TABLES TO ldpadmin;<br/>
CREATE TABLE mis.coral_extract (<br/>
coralid int2 NOT NULL,<br/>
contributor varchar(256) NULL,<br/>
title varchar(256) NULL,<br/>
publisher varchar(256) NULL,<br/>
summary varchar(4000) NULL,<br/>
natureofcontentterm varchar(200) NULL,<br/>
electronicaccess varchar(2000) NULL,<br/>
status varchar(8) NULL,<br/>
CONSTRAINT coral_extract_pkey PRIMARY KEY (coralid)<br/>
);<br/>
CREATE TABLE mis.coral_instances (<br/>
coralid int2 NOT NULL,<br/>
instanceid varchar(36) NULL,<br/>
CONSTRAINT coral_instances_pkey PRIMARY KEY (coralid)<br/>
);<br/>
CREATE TABLE mis.item_history (<br/>
item_id varchar(36) NOT NULL,<br/>
hist_charges int2 NULL,<br/>
hist_browses int2 NULL,<br/>
last_transaction date NULL,<br/>
CONSTRAINT item_history_pkey PRIMARY KEY (item_id)<br/>
);<br/>
CREATE EXTENSION pg_trgm;<br/>
<br/>
\c "PG_DATABASE" "PG_USER";<br/>
<br/>
REVOKE ALL ON SCHEMA public FROM public;<br/>
GRANT ALL ON SCHEMA public TO "PG_USER";<br/>
GRANT USAGE ON SCHEMA public TO :ldp_config_user;<br/>
GRANT USAGE ON SCHEMA public TO :ldp_user;<br/>
</details><br/>

#### LDP Postgres database
1) Folio Dev
* Containerized DB Workload *pg-ldp* in *folio-dev* K8s namespace
* CNAME URL: folio-ldp-dev.tamu.org
* Setup SQL K8s Secret *postgres-setup-sql-ldp*
2) Folio Test
* Containerized DB Workload *pg-ldp* in *folio-test* K8s namespace
* CNAME URL: folio-ldp-test.tamu.org
* Setup SQL K8s Secret *postgres-setup-sql-ldp*
3) Folio Pre
* Containerized DB Workload *pg-ldp* in *folio-pre* K8s namespace
* CNAME URL: folio-ldp-pre.tamu.org
* Setup SQL K8s Secret *postgres-setup-sql-ldp*
4) Folio Prod
* vSphere VM srv-pgsql-ldp
* Symlink'd via K8s Service Discovery *pg-ldp* record
* URL: ldp.tamu.org / CNAME URL: prod-ldp.tamu.org
* Setup SQL a part of Ansible Playbook

#### Three time-ordered K8s cron jobs for the nightly sync and rebuild
1) ldp-data-update
* Syncs data from Folio using a combo of the Folio API and direct-to-database connection
* Sync configuration stored as a K8s Secret *ldp-conf*, mounted as a Volume
* Scratch K8s Volume Claim attached for data cache operations
* Uses Index Data provided container from *ghcr.io/library-data-platform*
* When running, the Workload run-time command is `update -D /var/lib/ldp --direct-extraction-no-ssl --trace`
2) ldp-marc-data-update
* Syncs data from Folio using a combo of the Folio API and direct-to-database connection
* Sync configuration stored as a K8s Secret *ldp-conf*, mounted as a Volume
* Scratch K8s Volume Claim attached for data cache operations
* Uses Index Data provided container from *ghcr.io/library-data-platform*
* When running, the Workload run-time command is `-D /var/lib/ldp -u ldpadmin`
3) ldp-derived-tables
* Transforms data from Folio sync cron jobs above into relational tables using Bash and Perl scripts
* Connection configuration K8s Secret *db-config-ldp*
* Uses custom Harbor container image and SQL built from `../ldp-derived-tables` repo folder

#### LDP "Server" K8s Workload
* Updates LDP database schema on a planned LDP version upgrade
* Uses Index Data provided container from *ghcr.io/library-data-platform*
* Exists in the Folio namespace as *ldp-server* Workload
* Normally does not run (0 pods) unless a schema update is required
* When scaled to 1 pod, the Workload run-time command is `upgrade-database -D /var/lib/ldp --direct-extraction-no-ssl --trace`
* Sync configuration stored as a K8s Secret *ldp-conf*, mounted as a Volume
* Scratch K8s Volume Claim attached for data cache operations

#### Folio mod-ldp backend module
* Exists in the Folio namespace as *mod-ldp-X-X-X* Workload running 1 pod
* Connects to Folio okapi_modules database using K8s Secret *db-connect*
* Deployed with Folio platform-complete or during a Folio upgrade
* Independent of the LDP itself

#### Folio LDP UI App
* Allows in-app query building
* Available in Folio UI as LDP on top bar, or drop-down
* Configuration settings in UI under Settings - LDP
* Deployed with Folio platform-complete or during a Folio upgrade
* Independent of the LDP itself

#### Github repo
* Located in `../ldp-derived-tables` folder
* K8s *ldp-derived-tables* cron job container built using this repo, executes *create-derived-tables.sh* SQL and *item_history_update* Perl scripts
* SQL and execution logic under `../sql/derived_tables` subfolder
* Folio UI saved queries at `../queries` folder

# LDP Process Flow

### Nightly LDP Rebuild
1) *ldp-data-update* K8s cron job kicks off at 23:00 UTC (6:00 P.M.)<br/>
Cron settings:
* Completions: 1
* Parallelism: 1
* Back Off Limit: 0
* Active Deadline Seconds: 40000
* History Limits: 7 jobs
2) *ldp-marc-data-update* K8s cron job kicks off at 07:00 UTC (2:00 A.M.)<br/>
Cron settings:
* Completions: 1
* Parallelism: 1
* Back Off Limit: 0
* Active Deadline Seconds: 40000
* History Limits: 7 jobs
3) *ldp-derived-tables* K8s cron job kicks off at 09:00 UTC (4:00 A.M.)<br/>
Cron settings:
* Completions: 1
* Parallelism: 1
* Back Off Limit: 0
* Active Deadline Seconds: 50000
* History Limits: 7 jobs

*Normally the whole rebuild takes until about 7:00-8:00 A.M. the next morning.*

### Update the LDP Deployment
1) Replace the image tag of the *ldp-data-update* K8s cron job in Rancher with the corresponding version of the desired LDP "Server" release here: https://github.com/library-data-platform/ldp/pkgs/container/ldp
2) Replace the image tag of the *ldp-marc-data-update* K8s cron job in Rancher with the corresponding version of the desired LDP marc release here: https://github.com/library-data-platform/ldpmarc/pkgs/container/ldpmarc
3) Download the desired branch of SQL for the derived-tables using this matrix: [folio-analytics Readme](https://github.com/folio-org/folio-analytics/blob/main/README.md)
4) Merge and update TAMU's existing derived-tables queries in use under the `../ldp-derived-tables` folder, with the new queries. This will take the efforts of the data analyst and a developer and/or a database administrator.
5) Build, tag and push to Harbor the new ldp-derived-tables container, from the working directory of your local machine where the Git repos have been pulled in.
* Readme: [Nolana derived-tables](/ldp-derived-tables/Readme.md)
* Edit the *item_history_update.pl* file, and set your LDP database FQDN and ldpadmin user password by replacing **<LDP_DB_FQDN>** and **<ldp_db_password>** with the appropriate values before you build<br/>
Docker command examples below:<br/>
`docker build -t harbor.tamu.org/folio/ldp-derived-tables:envX-folioX-vX .`<br/>
`docker push harbor.tamu.org/folio/ldp-derived-tables:envX-folioX-vX`
6) Upgrade the Postgres version if applicable.
* If upgrading the Postgres VM in Prod - this will require an in-place upgrade of Postgres using Ansible Playbooks
* If upgrading the Postgres *pg-ldp* container Workload in Dev/Test/Pre - it is better delete and re-create the Rancher K8s data volume PV/PVC, update the tag of the Workload to the desired version, and let the LDP rebuild

# Troubleshooting the LDP
* Check the Rancher K8s cron jobs for any red/failed jobs. The pod logs can be viewed in Rancher, but they clear every afternoon
* Check the LDP database (VM or pg-ldp container Workload) for any stuck queries
* Large LDP data changes/updates may make the K8s cron job take longer to complete, it could be killed by K8s as a result. You may need to extend the K8s cron Job Configuration *Active Deadline Seconds* setting by editing the LDP cron job Workloads in Rancher
