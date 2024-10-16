# Setup FOLIO on Rancher 2.x/Kubernetes

## Readme Contents

* [Workload YAML Readme](YAML/Readme.md)
* [Module Metadata notes](module_metadata.md)
* [Okapi Dockerfile Readme](okapi/Readme.md)
* [Stripes Dockerfile Readme](stripes-tamu/Readme.md)
* [bootstrap-superuser Dockerfile Readme](deploy-jobs/bootstrap-superuser/Readme.md)
* [alter-database Dockerfile Readme](deploy-jobs/alter-database/Readme.md)
* [create-deploy Dockerfile Readme](deploy-jobs/create-deploy/Readme.md)
* [create-tenant Dockerfile Readme](deploy-jobs/create-tenant/Readme.md)
* [create-email Dockerfile Readme](deploy-jobs/create-email/Readme.md)
* [secure-okapi Dockerfile Readme](deploy-jobs/secure-okapi/Readme.md)
* [mod-circulation-notimers Readme](mod-circulation-notimers/Readme.md)

### FOLIO deployment overview:
Our Rancher-exported YAML can be looked at under the YAML folder. After creating the cluster via Rancher 2.x...<br/>

1) Create a FOLIO Project in Rancher 2.x UI.
2) Add *folio-prod* namespace for your FOLIO Project under *Namespaces* in Rancher 2.x UI.
3) Add Dockerhub and your private Docker registries to the FOLIO Project.
4) Add Persistent Volumes on the cluster and Persistent Volume Claims for the FOLIO Project (We are using vSphere Storage Class).<br/>

The rest of these steps are from within the FOLIO Project in Rancher 2.x...<br/>

5) Create the following Secrets in Rancher under the FOLIO Project for the *folio-prod* namespace:<br/>
```
data-export-aws-config
db-connect
db-connect-ldp
db-connect-okapi
db-config-ldp
db-config-modules
db-config-okapi
edge-securestore-props
ldp-conf
mod-graphql
mod-pubsub
mod-search
mod-z3950
postgres-setup-sql
postgres-setup-sql-ldp
secured-okapi
tamu-tenant-config
x-okapi-token
```
6) If you are using an external database host, ignore this step. Otherwise deploy two crunchy-postgres *Stateful set* Workloads to the *folio-prod* namespace. Name one *pg-okapi* for Okapi's *okapi* database, and the other *pg-folio* for FOLIO's *okapi_modules* database. Edit each of these Workloads to set environment variables - clicking *Add From Source* to choose the corresponding db-config-okapi and db-config-modules Secrets. Configure your persistent volumes, any resource reservations and limits, as well as the Postgres UID and GID (26) at this time.
7) Install Apache Kafka and Apache ZooKeeper through a Helm Chart under your FOLIO Project - Apps - Launch. Currently using the Bitnami Kafka app.
8) Install Elasticsearch through a Helm Chart under your FOLIO Project - Apps - Launch. Currently using the Bitnami Elasticsearch app.
9) Deploy Okapi Workload *Scalable deployment* of 1 and InitDB environment variable set to true - built from our custom Docker container - with db-connect-okapi Secret. Once it is running, edit the Okapi Workload and set InitDB environment variable to *false*, it will redeploy.
10) Deploy FOLIO module Workloads as *Scalable deployment* between 1 and 3 (one Workload per FOLIO module) - with db-connect Secret for those modules that need a connection to the database. Import the folio-<release>-workloads.yaml file in Rancher for this step.
11) Deploy Stripes Workload as *Run one pod on each node* – built from our custom Docker container.
12) Deploy create-tenant Workload as *Job* – built from our custom Docker container with scripts - with tamu-tenant-config Secret.
13) Deploy create-deploy Workload as *Job*, to enable modules for `/proxy/modules`, `/discovery/modules`, and tenants – built from our custom Docker container with scripts - with tamu-tenant-config Secret.
14) Deploy bootstrap-superuser Workload as *Job* – built from our custom Docker container with scripts - with tamu-tenant-config Secret.
15) Deploy create-email Workload as *Job* – built from our custom Docker container with scripts - with tamu-tenant-config Secret.
16) Scale up Okapi pods to 3 (for HA) using Rancher 2.x + button.
17) Add Ingresses and their Nginx annotations under Load Balancing for Okapi and Stripes using your URLs for `/` and `/_/` paths.
18) FOLIO post-install tenant configuration regarding the edge user, permissions, patron groups for system and tenant admin users, timezone and plugin selection, and securing Okapi.
19) Set up the LDP and configure it for FOLIO UI access.


### Cluster Service Accounts Notes
Run the following in the Rancher GUI - cluster Dashboard using the *Launch kubectl* button:<br/>

-When using Hazelcast discovery Kubernetes plugin for Okapi, you need to execute these commands on the cluster for the service account:<br/>

1) ```touch rbac.yaml```<br/>
2) ```vi rbac.yaml```<br/>

Paste in this code:<br/>

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hazelcast-rb-r2-2021
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: default
  namespace: folio-prod
  ```

3) Save and exit
4) Run: ```kubectl apply -f rbac.yaml```

### Kafka and Elasticsearch Helm Chart Notes
 1) In the Rancher GUI Global view, add the bitnami Helm v3 catalog under Tools - Catalogs: `https://charts.bitnami.com/bitnami`
 2) Paste the following in when deploying the Helm charts<br/>

#### Kafka Helm Chart Values Yaml:
```
---
  autoCreateTopicsEnable: true
  defaultReplicationFactor: "3"
  auth: 
    clientProtocol: "plaintext"
    interBrokerProtocol: "tls"
    tls: 
      autoGenerated: true
      type: "pem"
  externalAccess: 
    enabled: false
  extraEnvVars:
  - name: ES_JAVA_OPTS
    value: "-Dlog4j2.formatMsgNoLookups=true"
  global: 
    storageClass: "vsphere-datastore"
  heapOpts: "-Xmx2048m -Xms2048m"
  logFlushIntervalMs: "3600000"
  logRetentionHours: "24"
  numIoThreads: "8"
  numNetworkThreads: "5"
  numPartitions: "1"
  persistence: 
    accessMode: "ReadWriteOnce"
    enabled: true
    size: "300Gi"
    storageClass: "vsphere-datastore"
  replicaCount: "3"
  socketReceiveBufferBytes: "102400"
  socketRequestMaxBytes: "104857600"
  socketSendBufferBytes: "102400"
  zookeeper: 
    enabled: true
    allowAnonymousLogin: false
    auth:
      enabled: true
      serverUsers: "zookeeper_admin"
      serverPasswords: "password"
      clientUser: "zookeeper_user"
      clientPassword: "password"
    replicaCount: "3"
    persistence: 
      enabled: true
      size: "50Gi"
      dataLogDir:
        size: "20Gi"
  zookeeperConnectionTimeoutMs: "60000"
```

#### Elasticsearch Helm Chart key-value pairs:
```
coordinating.heapsize = 256m      
coordinating.livenessProbe.enabled = false      
coordinating.readinessProbe.enabled = false       
coordinating.replicas = 2       
coordinating.securityContext.enabled = true       
coordinating.securityContext.fsGroup = 1001       
coordinating.securityContext.runAsUser = 1001       
coordinating.service.port = 9200      
coordinating.serviceAccount.create = true       
coordinating.startupProbe.enabled = false       
data.heapSize = 2048m       
data.livenessProbe.enabled = false      
data.persistence.enabled = true       
data.persistence.size = 200Gi       
data.readinessProbe.enabled = false       
data.replicas = 2       
data.securityContext.enabled = true       
data.securityContext.fsGroup = 1001       
data.securityContext.runAsUser = 1001       
data.serviceAccount.create = true       
data.startupProbe.enabled = false       
global.coordinating.name = es-conn      
global.kibanaEnabled = true       
global.storageClass = "vsphere-datastore"       
image.debug = false       
ingest.service.port = 9300      
ingest.service.type = ClusterIP       
kibana.elasticsearch.hosts = {elasticsearch-r2-es-conn}      
kibana.elasticsearch.port = 9200      
master.heapSize = 512m      
master.livenessProbe.enabled = false      
master.persistence.enabled = true       
master.persistence.size = 20Gi      
master.readinessProbe.enabled = false       
master.replicas = 3       
master.securityContext.enabled = true       
master.securityContext.fsGroup = 1001       
master.securityContext.runAsUser = 1001       
master.service.port = 9300      
master.service.type = ClusterIP       
master.serviceAccount.create = true       
master.startupProbe.enabled = false       
plugins = analysis-icu,analysis-kuromoji,analysis-smartcn,analysis-nori,analysis-phonetic
```

### Rancher Secrets Notes:

-In production, unique Secrets should only be available to a single namespace for security and separation. If you choose, Secrets can be made available to all namespaces for testing and development.<br/>
-The Secrets below are to be created in the *folio-prod* namespace, and are being used for Tamu's specific deployment of FOLIO, MinIO, Kafka, Elasticsearch, migration tooling and the LDP. They are included here as a reference.

#### data-export-aws-config Secret key-value pairs:

AWS_ACCESS_KEY_ID = key<br/>
AWS_BUCKET = folio-data-export<br/>
AWS_REGION = us-east-1<br/>
AWS_SECRET_ACCESS_KEY = secret<br/>
AWS_URL = minio.tamu.org<br/>
config = 
```
[default]
aws_access_key_id = key
aws_secret_access_key = secret
region = us-east-1
```

#### db-connect Secret key-value pairs:

DB_CHARSET = UTF-8<br/>
DB_DATABASE = okapi_modules<br/>
DB_HOST = pg-folio<br/>
DB_MAXPOOLSIZE = 20<br/>
DB_PASSWORD = password<br/>
DB_PORT = 5432<br/>
DB_QUERYTIMEOUT = 120000<br/>
DB_USERNAME = folio_admin

#### db-connect-migration Secret key-value pairs:

OKAPI_PASSWORD = password<br/>
OKAPI_USERNAME = tamu_admin<br/>
SPRING_DATASOURCE_PASSWORD = password<br/>
SPRING_DATASOURCE_USERNAME = spring_folio_admin<br/>
TENANT_DEFAULT_TENANT = tamu<br/>
SPRING_APPLICATION_JSON =
```
{
  "okapi": {
    "url": "http://okapi:9130",
    "credentials": {
      "username": "tamu_admin",
      "password": "password"
    },
    "modules": {
      "database": {
        "url": "jdbc:postgresql://pg-folio/okapi_modules",
        "username": "folio_admin",
        "password": "password",
        "driverClassName": "org.postgresql.Driver"
      }
    }
  }
}
```
#### db-config-migration Secret key-value pairs:

PG_DATABASE = migration_modules<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = spring_folio_admin

#### db-config-ldp Secret key-value pairs:

DB_HOST = pg-ldp<br/>
LDP_CONFIG_PASSWORD = password<br/>
LDP_CONFIG_USER = ldpconfig<br/>
LDP_REPORT_PASSWORD = password<br/>
LDP_REPORT_USER = ldpreport<br/>
LDP_RO_PASSWORD = password<br/>
LDP_RO_USER = ro_ldp_user<br/>
LDP_USER = ldp<br/>
LDP_USER_PASSWORD = password<br/>
PG_DATABASE = ldp<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = ldpadmin

#### db-connect-ldp Secret key-value pairs:

DB_CHARSET = UTF-8<br/>
DB_DATABASE = ldp<br/>
DB_HOST = pg-ldp<br/>
DB_MAXPOOLSIZE = 20<br/>
DB_PASSWORD = password<br/>
DB_PORT = 5432<br/>
DB_QUERYTIMEOUT = 120000<br/>
DB_USERNAME = ldpadmin

#### db-connect-okapi Secret key-value pairs:

DB_MAXPOOLSIZE = 10<br/>
PG_DATABASE = okapi<br/>
PG_HOST = pg-okapi<br/>
PG_PASSWORD = password<br/>
PG_PORT = 5432<br/>
PG_USERNAME = okapi

#### db-config-modules Secret key-value pairs:

PG_DATABASE = okapi_modules<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = folio_admin

#### db-config-okapi Secret key-value pairs:

PG_DATABASE = okapi<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = okapi

#### edge-securestore-props Secret key-value pairs:

edge-ephemeral.properties =
```
secureStore.type=Ephemeral
# a comma separated list of tenants
tenants=tamu
#######################################################
# For each tenant, the institutional user password...
#
# Note: this is intended for development purposes only
#######################################################
# format: tenant=username,password
tamu=edgeuser,password
```

#### ldp-conf Secret key-value pairs:

ldpconf.json =
```
{
    "anonymize": false,
    "deployment_environment": "staging",
    "ldp_database": {
        "database_name": "ldp",
        "database_host": "pg-ldp",
        "database_port": 5432,
        "database_user": "ldpadmin",
        "database_password": "password",
        "database_sslmode": "disable"
    },
    "enable_sources": ["tamu_library"],
    "sources": {
        "tamu_library": {
            "okapi_url": "http://okapi:9130",
            "okapi_tenant": "tamu",
            "okapi_user": "tamu_admin",
            "okapi_password": "password",
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
            "direct_database_password": "password"
        }
    }
}
```

#### mod-graphql Secret key-value pairs:

CONSOLE_TRACE = 1<br/>
GRAPHQL_OPTIONS = <br/>
LOGGING_CATEGORIES = <br/>
NODE_OPTIONS = --no-deprecation<br/>
OKAPI_TENANT = tamu<br/>
OKAPI_TOKEN = token<br/>
OKAPI_URL = `http://okapi:9130`<br/>
PROXY_OKAPI_URL = `https://folio-okapi.tamu.org`<br/>
RAML_DIR = <br/>
RAML_EXCLUDE = <br/>
RAML_MATCH = <br/>
RAML_SKIP =

#### mod-pubsub Secret key-value pairs:

ELASTICSEARCH_PASSWORD = <br/>
ELASTICSEARCH_USERNAME = <br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
KAFKA_HOST = `http://kafka-r2`<br/>
KAFKA_PORT = 9092<br/>
OKAPI_URL = `http://okapi:9130`<br/>
SYSTEM_USER_NAME = pub-sub<br/>
SYSTEM_USER_PASSWORD = password

#### mod-search Secret key-value pairs:

ELASTICSEARCH_PASSWORD = <br/>
ELASTICSEARCH_USERNAME = <br/>
ELASTICSEARCH_URL = `http://elasticsearch-r2-es-conn:9200`<br/>
ENV = folio-prod<br/>
INITIAL_LANGUAGES = eng,spa,fre,ger<br/>
JAVA_OPTIONS = -XX:MaxRAMPercentage=66.0<br/>
KAFKA_EVENTS_CONSUMER_PATTERN = `(folio-prod\.)(.*\.)inventory\.(instance|holdings-record|item)`<br/>
KAFKA_HOST = `http://kafka-r2`<br/>
KAFKA_PORT = 9092<br/>
KAFKA_SECURITY_PROTOCOL = PLAINTEXT<br/>
KAFKA_SSL_KEYSTORE_LOCATION = <br/>
KAFKA_SSL_KEYSTORE_PASSWORD = <br/>
KAFKA_SSL_TRUSTSTORE_LOCATION = <br/>
KAFKA_SSL_TRUSTSTORE_PASSWORD = <br/>
OKAPI_URL = `http://okapi:9130`<br/>
SYSTEM_USER_PASSWORD = password

#### mod-z3950 Secret key-value pairs:

config.Default.json =
```
{
  "okapi": {
    "url": "http://okapi:9130",
    "tenant": "tamu"
  },
  "login": {
    "username": "edgeuser",
    "password": "password"
  },
  "indexMap": {
    "1": "author",
    "7": "identifiers/@value/@identifierTypeId=\"8261054f-be78-422d-bd51-4ed9f33c3422\"",
    "4": "title",
    "12": {
      "cql": "hrid",
      "relation": "==",
      "omitSortIndexModifiers": ["missing", "case"]
    },
    "21": "subject",
    "1016": "author,title,hrid,subject"
  },
  "queryFilter": "source==marc NOT discoverySuppress==true",
  "graphqlQuery": "instances.graphql-query",
  "chunkSize": 5,
  "marcHoldings": {
    "restrictToItem": 0,
    "field": "952",
    "indicators": [" ", " "],
    "holdingsElements": {
      "t": "copyNumber"
    },
    "itemElements": {
      "b": "itemId",
      "k": "_callNumberPrefix",
      "h": "_callNumber",
      "m": "_callNumberSuffix",
      "v": "_volume",
      "e": "_enumeration",
      "y": "_yearCaption",
      "c": "_chronology"
    }
  },
  "postProcessing": {
    "marc": {
      "008": {
        "op": "regsub",
        "pattern": "([13579])",
        "replacement": "[$1]",
        "flags": "g"
      },
      "245$a": [{
          "op": "stripDiacritics"
        },
        {
          "op": "regsub",
          "pattern": "[abc]",
          "replacement": "*",
          "flags": "g"
        }
      ]
    }
  }
}
```

config.tamu.json =
```
{
  "okapi": {
    "url": "http://okapi:9130",
    "tenant": "tamu"
  },
  "login": {
    "username": "edgeuser",
    "password": "password"
  },
  "indexMap": {
    "1": "author",
    "7": "identifiers/@value/@identifierTypeId=\"8261054f-be78-422d-bd51-4ed9f33c3422\"",
    "4": "title",
    "12": {
      "cql": "hrid",
      "relation": "==",
      "omitSortIndexModifiers": ["missing", "case"]
    },
    "21": "subject",
    "1016": "author,title,hrid,subject"
  },
  "queryFilter": "source==marc NOT discoverySuppress==true",
  "graphqlQuery": "instances.graphql-query",
  "chunkSize": 5,
  "marcHoldings": {
    "restrictToItem": 0,
    "field": "952",
    "indicators": [" ", " "],
    "holdingsElements": {
      "t": "copyNumber"
    },
    "itemElements": {
      "b": "itemId",
      "k": "_callNumberPrefix",
      "h": "_callNumber",
      "m": "_callNumberSuffix",
      "v": "_volume",
      "e": "_enumeration",
      "y": "_yearCaption",
      "c": "_chronology"
    }
  },
  "postProcessing": {
    "marc": {
      "008": {
        "op": "regsub",
        "pattern": "([13579])",
        "replacement": "[$1]",
        "flags": "g"
      },
      "245$a": [{
          "op": "stripDiacritics"
        },
        {
          "op": "regsub",
          "pattern": "[abc]",
          "replacement": "*",
          "flags": "g"
        }
      ]
    }
  }
}
```

#### postgres-setup-sql Secret key-value pairs:

setup.sql =
```
--- System Setup
SET application_name="container_setup";

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

ALTER USER postgres PASSWORD 'PG_ROOT_PASSWORD';

CREATE USER "PG_PRIMARY_USER" WITH REPLICATION;
ALTER USER "PG_PRIMARY_USER" PASSWORD 'PG_PRIMARY_PASSWORD';

CREATE USER "PG_USER" LOGIN;
ALTER USER "PG_USER" PASSWORD 'PG_PASSWORD';

CREATE DATABASE "PG_DATABASE";
GRANT ALL PRIVILEGES ON DATABASE "PG_DATABASE" TO "PG_USER";

CREATE TABLE IF NOT EXISTS primarytable (key varchar(20), value varchar(20));
GRANT ALL ON primarytable TO "PG_PRIMARY_USER";

--- PG_DATABASE Setup

\c "PG_DATABASE"

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

--- Verify permissions via PG_USER

\c "PG_DATABASE" "PG_USER";

CREATE SCHEMA IF NOT EXISTS "PG_USER";

\c postgres postgres

ALTER USER "PG_USER" with SUPERUSER;
ALTER ROLE "PG_USER" CREATEDB;
ALTER DATABASE "PG_DATABASE" OWNER TO "PG_USER";
CREATE EXTENSION pg_trgm;
ALTER EXTENSION pg_trgm SET SCHEMA public;
```

#### postgres-setup-sql-ldp Secret key-value pairs:

setup.sql =
```
/*
 * Copyright 2016 - 2020 Crunchy Data Solutions, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

--- System Setup
SET application_name="container_setup";

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

ALTER USER postgres PASSWORD 'PG_ROOT_PASSWORD';

CREATE USER "PG_PRIMARY_USER" WITH REPLICATION;
ALTER USER "PG_PRIMARY_USER" PASSWORD 'PG_PRIMARY_PASSWORD';

CREATE USER "PG_USER" LOGIN;
ALTER USER "PG_USER" PASSWORD 'PG_PASSWORD';

CREATE DATABASE "PG_DATABASE";
ALTER DATABASE "PG_DATABASE" SET search_path TO public;
GRANT ALL PRIVILEGES ON DATABASE "PG_DATABASE" TO "PG_USER";

CREATE TABLE IF NOT EXISTS primarytable (key varchar(20), value varchar(20));
GRANT ALL ON primarytable TO "PG_PRIMARY_USER";

--- PG_DATABASE Setup

\c "PG_DATABASE"

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

\c postgres postgres

\set ldp_user `echo "$LDP_USER"`
\set ldp_config_user `echo "$LDP_CONFIG_USER"`
\set ldp_report_user `echo "$LDP_REPORT_USER"`
\set ldp_ro_user `echo "$LDP_RO_USER"`

ALTER DATABASE "PG_DATABASE" OWNER TO "PG_USER";
CREATE USER :ldp_config_user LOGIN;
ALTER USER :ldp_config_user PASSWORD 'password';
CREATE USER :ldp_user LOGIN;
ALTER USER :ldp_user PASSWORD 'password';
CREATE USER :ldp_report_user LOGIN;
ALTER USER :ldp_report_user PASSWORD 'password';
CREATE USER :ldp_ro_user LOGIN;
ALTER USER :ldp_ro_user PASSWORD 'password';

\c "PG_DATABASE" postgres

CREATE SCHEMA IF NOT EXISTS folio_reporting;
ALTER SCHEMA folio_reporting OWNER TO ldpadmin;
GRANT CREATE, USAGE ON SCHEMA folio_reporting TO ldp;
GRANT USAGE ON SCHEMA folio_reporting TO ldp;
GRANT SELECT ON ALL TABLES IN SCHEMA folio_reporting TO ldp;
ALTER DEFAULT PRIVILEGES IN SCHEMA folio_reporting GRANT SELECT ON TABLES TO ldp;
GRANT CREATE, USAGE ON SCHEMA folio_reporting TO ldpreport;
GRANT USAGE ON SCHEMA public TO ldpreport;
CREATE EXTENSION pg_trgm;

\c "PG_DATABASE" "PG_USER";

REVOKE ALL ON SCHEMA public FROM public;
GRANT ALL ON SCHEMA public TO "PG_USER";
GRANT USAGE ON SCHEMA public TO :ldp_config_user;
GRANT USAGE ON SCHEMA public TO :ldp_user;
```

#### secured-okapi Secret key-value pairs:

OKAPI_URL = http://okapi:9130<br/>
REF_DATA = true<br/>
SAMPLE_DATA = false<br/>
SUPER_PSSWD = password<br/>
SUPER_USR = superuser<br/>
TENANT_ID = supertenant

#### tamu-tenant-config Secret key-value pairs:

ACS_TENANT_CONFIG =
```
{\"supportedMessages\": [{\"messageName\": \"REQUEST_SC_ACS_RESEND\",\"isSupported\": \"Y\"},{\"messageName\": \"PATRON_STATUS_REQUEST\",\"isSupported\": \"N\"},{\"messageName\": \"CHECKOUT\",\"isSupported\": \"Y\"},{\"messageName\": \"CHECKIN\",\"isSupported\": \"Y\"},{\"messageName\": \"BLOCK_PATRON\",\"isSupported\": \"N\"},{\"messageName\": \"SC_ACS_STATUS\",\"isSupported\": \"Y\"},{\"messageName\": \"LOGIN\",\"isSupported\": \"Y\"},{\"messageName\": \"PATRON_INFORMATION\",\"isSupported\": \"Y\"},{\"messageName\": \"END_PATRON_SESSION\",\"isSupported\": \"Y\"},{\"messageName\": \"FEE_PAID\",\"isSupported\": \"N\"},{\"messageName\": \"ITEM_INFORMATION\",\"isSupported\": \"N\"},{\"messageName\": \"ITEM_STATUS_UPDATE\",\"isSupported\": \"N\"},{\"messageName\": \"PATRON_ENABLE\",\"isSupported\": \"N\"},{\"messageName\": \"HOLD\",\"isSupported\": \"N\"},{\"messageName\": \"RENEW\",\"isSupported\": \"N\"},{\"messageName\": \"RENEW_ALL\",\"isSupported\": \"N\"}],\"statusUpdateOk\": false,\"offlineOk\": false,\"currencyType\" : \"USD\",\"language\" : \"en\",\"patronPasswordVerificationRequired\" : false}
```
ADMIN_PASSWORD = admin<br/>
ADMIN_USER = tamu_admin<br/>
EMAIL_FROM = `folio_admin@tamu.org`<br/>
EMAIL_PASSWORD = password<br/>
EMAIL_SMTP_HOST = tamu.org<br/>
EMAIL_SMTP_LOGIN_OPTION = DISABLED<br/>
EMAIL_SMTP_PORT = 25<br/>
EMAIL_SMTP_SSL = false<br/>
EMAIL_START_TLS_OPTIONS = OPTIONAL<br/>
EMAIL_TRUST_ALL = true<br/>
EMAIL_USERNAME = login_user<br/>
FOLIO_HOST = `https://folio.tamu.org`<br/>
IGNORE_ERRORS = false<br/>
OKAPI_URL = `http://okapi:9130`<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = false<br/>
SELF_CHECKOUT_CONFIG =
```
{\"timeoutPeriod\": 30,\"retriesAllowed\": 3,\"terminalDelimeter\" : \"\\r\",\"fieldDelimeter\" : \"|\",\"errorDetectionEnabled\" : true,\"charset\" : \"UTF8\",\"SCtimeZone\" : \"EDT\",\"checkinOk\": true,\"checkoutOk\": true,\"acsRenewalPolicy\": false,\"maxPrintWidth\" : 200,\"libraryName\": \"evans\",\"terminalLocation\": \"3b80cfdf-438b-48c1-aadc-57965a0d7680\"}
```
SERVICE_POINT = 3b80cfdf-438b-48c1-aadc-57965a0d7680<br/>
TENANT_DESC = Texas A&M University Libraries<br/>
TENANT_ID = tamu<br/>
TENANT_NAME = TAMU Libraries<br/>
X_OKAPI_TOKEN = token

#### x-okapi-token Secret Key-Value pairs:
NOTE: You won’t need this until after the FOLIO system is up, but before you secure Okapi. Log in to the FOLIO system via the UI, go to *Settings - Developer - Set Token* and copy it out from there.<br/>

X_OKAPI_TOKEN = `<Authentication token from Okapi>`

### Okapi Notes:

-Running in *clustered* mode.<br/>
-Hazelcast in Kubernetes requires editing the hazelcast.xml file included with the Okapi repo before you build the Docker container, and setting your Folio namespace and service-name under:
```
<kubernetes enabled="true">
                <namespace>folio-prod</namespace>
                <service-name>okapi</service-name>
                <!--
                <service-label-name>MY-SERVICE-LABEL-NAME</service-label-name>
                <service-label-value>MY-SERVICE-LABEL-VALUE</service-label-value>
                -->
            </kubernetes>
```
-After a single Okapi pod has been initialized, edit and set Okapi's Workload environment variable for InitDB to false, and it will respin up for future pod scalability with data persistence.<br/>
-After initially spinning up one Okapi pod, then doing the InitDB variable switch above, execute the deployment K8s Jobs to deploy the FOLIO tenants and modules.<br/>
-Scale out Okapi's pods for clustering after finishing your tenant setup, they will each get and manage the shared data of your FOLIO deployment.<br/>
-Use *ClusterIP* port mapping for Okapi port 9130, and the Hazelcast ports (5701 - 5704, 54327). Also add a *NodePort* port map for 9130 when exposing Okapi via a Load Balancing/Ingress entry.<br/>

#### Configuration and observations for containerized Okapi:

-Built using Tamu's Dockerfile vs the FOLIO-org Dockerhub artifact, as it provides us with a bit more flexibility when running (defined environment variables easily allow ability to pass hazelcast config, and to initialize the database or not on startup).<br/>
-For minimal HA we run as a single cluster of 3 containers per FOLIO instance, at an odd number of members so a quorum is established (3, 5, 7, etc). You can run as a single node cluster, but you lose the benefits of multiple Okapis providing redundancy and the overhead that allows you for handling multiple, simultaneous and large requests<br/>
-The Okapi cluster is spawned from a single Workload as a K8s statefulset deployment, then scaled out. This is done to allow Okapi nodes to have consistent names, to handle upgrading members on-the-fly, and to facilitate scaling up and down with more consistency and stability.<br/>
-As stated above, we define in the hazelcast.xml config file a unique group name, namespace, and the service name of the deployment in K8s.<br/>
-Hazelcast overhead seems low. Members and their config are stored in a memory map in each Okapi node from my understanding.<br/>
-I have seen performance drawbacks with large numbers of Okapi. This appears to stem from the Timers function.<br/>
-In K8s networking, the Okapi pods are round-robin load-balanced so not a single member gets overwhelmed. This does have a benefit in our testing: Loading data through the APIs doesn’t overload any single K8s node where an Okapi pod instance may be running. This also means that other tenants, where heavy requests may be taking place, do not see as much of a performance impact of the system when multiple tenants are being accessed and used within the same instance of FOLIO.<br/>
-It has been our experience that running a separate *okapi* database host for Okapi, and not combining it with the FOLIO *okapi_modules* database improves performance for us.<br/>

#### Okapi Workload environment variables:

OKAPI_URL = `http://okapi:9130`<br/>
OKAPI_STORAGE = postgres<br/>
OKAPI_PORT = 9130<br/>
OKAPI_LOGLEVEL = WARN<br/>
OKAPI_HOST = okapi<br/>
OKAPI_COMMAND = cluster<br/>
OKAPI_CLUSTERHOST = $(OKAPI_SERVICE_HOST)<br/>
INITDB = false<br/>
HAZELCAST_VERTX_PORT = 5702<br/>
HAZELCAST_PORT = 5701<br/>
HAZELCAST_IP = $(OKAPI_SERVICE_HOST)<br/>
HAZELCAST_FILE = /hazelcast/hazelcast.xml<br/>

### Crunchy-Postgres in Kubernetes/Rancher Notes:

-Currently testing out crunchy-postgres Kubernetes solution.<br/>
-Running as a Kubernetes *Stateful Set*, with one primary and two replica pods. Replica pods are read-only.<br/>
-Using *Persistent Volume Claims* for Rancher FOLIO Project, provisioned with vSphere Storage Class.<br/>
-Not sure if we would run like this in Production yet, as we haven't load tested it. It is a possibility for those looking for a complete Rancher/Kubernetes/Container solution, and being actively developed.<br/>
-Volumes for persistent data as well as SQL execution need to be added to the pg-folio and pg-okapi *statefulset* Workloads:<br/>

Volume Name: pgdata<br/>
Persistent Volume Claim: folio-prod:pgdata-pvc<br/>
Mount Point: /pgdata<br/>

Volume Name: backrestrepo<br/>
Persistent Volume Claim: folio-prod:backrestrepo-pvc<br/>
Mount Point: /backrestrepo<br/>

Volume Name: recover<br/>
Persistent Volume Claim: folio-prod:recover-pvc<br/>
Mount Point: /recover<br/>

Volume Name: pgwal<br/>
Persistent Volume Claim: folio-prod:pgwal-pvc<br/>
Mount Point: /pgwal<br/>

Volume Name: pgconf<br/>
Default Mode: 755<br/>
Secret: postgres-setup-sql<br/>
Mount Point: /pgconf<br/>

#### Crunchy-postgres Workload environment variables:

WORK_MEM = 128MB<br/>
PGHOST = /tmp<br/>
PG_REPLICA_HOST = pgset-replica<br/>
PG_PRIMARY_HOST = pgset-primary<br/>
PG_MODE = set<br/>
PG_LOCALE = en_US.UTF-8<br/>
PG_DATABASE = okapi_modules<br/>
MAX_CONNECTIONS = 1000<br/>
ARCHIVE_MODE = on<br/>
ARCHIVE_TIMEOUT = 60<br/>
CRUNCHY_DEBUG = FALSE<br/>
TEMP_BUFFERS = 128MB<br/>
SHARED_BUFFERS = 4096MB<br/>
MAX_WAL_SENDERS = 3<br/>


### Workload Notes

-Please see this document for the required back-end module environment variables, database connection stipulation, Java heap memory setting, and port to start the module Workload:<br/>

* [Module Metadata notes](module_metadata.md)

#### Modules that require the db-connect Secret:

*mod-agreements, mod-aes, mod-audit, mod-calendar, mod-circulation-storage, mod-configuration, mod-copycat, mod-courses, mod-data-export, mod-data-export-spring, mod-data-export-worker, mod-data-import, mod-data-import-converter-storage, mod-ebsconet, mod-email, mod-erm-usage, mod-erm-usage-harvester, mod-event-config, mod-feesfines, mod-finance-storage, mod-inventory-storage, mod-invoice-storage, mod-kb-ebsco-java, mod-licenses, mod-login, mod-notes, mod-notify, mod-oai-pmh, mod-orders-storage, mod-organizations-storage, mod-password-validator, mod-patron-blocks, mod-permissions, mod-pubsub, mod-quick-marc, mod-remote-storage, mod-search, mod-sender, mod-service-interaction, mod-source-record-manager, mod-source-record-storage, mod-tags, mod-template-engine, mod-users*


### Ingress Notes:

-Have two URLs as CNAME Records for external NginX Plus load balancer - which set upstream as K8s cluster worker nodes via their DNS names.<br/>
-One URL is for proxying front-end Stripes and the other is for proxying Okapi traffic.<br/>
-The Okapi traffic URL is the URL used when building Stripes.<br/>
-When setting up Load Balancing/Ingress, target the Service name instead of Workload name if you have specific ports you have set in the Workload.<br/>
-For Okapi HA ingress, I have Okapi Service as the target at port 9130, with root path, `/` and `/_/` for the hostname folio-okapi.org<br/>

-To have default Rancher 2.x Nginx ingress be a little smarter about DNS round-robin, and larger chunks of data, add annotations in Rancher GUI under Service Discovery:<br/>

nginx.ingress.kubernetes.io/client-body-buffer-size = 512M<br/>
nginx.ingress.kubernetes.io/proxy-body-size = 8192M<br/>
nginx.ingress.kubernetes.io/upstream-fail-timeout = 120<br/>
nginx.ingress.kubernetes.io/upstream-max-fails = 2<br/>
nginx.ingress.kubernetes.io/proxy-connect-timeout = 600<br/>
nginx.ingress.kubernetes.io/proxy-read-timeout = 600<br/>
nginx.ingress.kubernetes.io/proxy-send-timeout = 600<br/>


## FOLIO Pro Tips

#### Disable module for tenant:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/proxy/tenants/tamu/modules/<module-id>```

#### Delete proxy/module registration:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/proxy/modules/<Id>```

#### Delete discovery/module registration:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/discovery/modules/<srvcId>/<instId>```

#### List tenants:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/tenants```

#### List registered modules:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/modules```

#### List modules enabled for a specific tenant:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/tenants/tamu/modules```

#### List of discovered/deployed modules:
```curl -i -w '\n' -X GET http://okapi:9130/_/discovery/modules```

#### Tenant login:
```
curl -i -w '\n' -X POST -H "X-Okapi-Tenant:tamu" -d '{"username": "tamu_admin", "password": "admin"}' \
http://okapi:9130/authn/login
```

#### Pull all Okapi registration files from url to your Okapi:
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"urls":["http://folio-registry.aws.indexdata.com"]}' http://okapi:9130/_/proxy/pull/modules
```

#### Simulate an install:
```
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @enable-docker.json http://okapi:9130/_/proxy/tenants/tamu/install?simulate=true
```

#### Re-index Elasticsearch with Okapi request:
```
curl -w '\n' -D - -X POST $OKAPI_URL/search/index/inventory/reindex -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{"recreateIndex": true}'
```

#### Get an Elasticsearch job ID with Okapi request:
```
curl -w '\n' -D - -X GET -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" $OKAPI_URL/search/index/inventory/reindex
```

#### Monitor an Elasticsearch job with Okapi request:
```
curl -w '\n' -D - -X GET -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" $OKAPI_URL/instance-storage/reindex/<REINDEX_JOB_ID>
```

#### Patch a timer job with Okapi request:
```
curl -XPATCH -d'{"delay":"24"}' -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" http://okapi:9130/_/proxy/tenants/tamu/timers/mod-data-export_1
```

#### Get the user summary to check for patron blocks:
```
curl -w '\n' -D - -X GET -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" http://okapi:9130/user-summary/<USER_UUID>
```

#### Get a list of FOLIO configuration entries:
```
curl -i -w '\n' -X GET "http://okapi:9130/configurations/entries?limit=100" -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>"
```

#### Put an updated configuration entry:
```
curl -i -w '\n' -X PUT http://okapi:9130/configurations/entries/<CONFIG_ID> -H "Content-type: application/json" -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d @UPDATED_CONFIG.json
```

#### Purge deprecated permissions from FOLIO:
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" http://okapi:9130/perms/purge-deprecated
```

#### Query mod-email logs in FOLIO:
```
curl -i -w '\n' -X GET -H "X-Okapi-Tenant: tamu" -H "X-Okapi-Token: <OKAPI_TOKEN>" http://okapi:9130/email?limit=1000
```

#### Front-end FOLIO-CI repo:
https://repository.folio.org/#browse/welcome

#### Indexdata Okapi module registry:
http://folio-registry.aws.indexdata.com/_/proxy/modules

#### Database export example:
```psql -U postgres -h pg-folio -w -d okapi_modules --command "SELECT * FROM tamu_mod_inventory_storage.item;" > /pgdata/folio-prod/items```

#### Database number of module connections:
```SELECT count(*) FROM pg_stat_activity WHERE usename = 'tenantId_mod_whatever';```

#### Database number of Okapi connections:
```SELECT count(*) FROM pg_stat_activity WHERE usename = 'okapi';```

#### Database commands to remove conditions causing Patron block, and the block itself:
```DELETE FROM tamu_mod_circulation_storage.audit_loan WHERE jsonb -> 'loan' ->> 'userId' = '<USER_UUID>' AND jsonb -> 'loan' -> 'status' ->> 'name' = 'Open' and id NOT IN (SELECT id from tamu_mod_circulation_storage.loan where jsonb -> 'status' ->> 'name' = 'Open' and jsonb ->> 'userId' = '<USER_UUID>');```

```DELETE FROM tamu_mod_patron_blocks.user_summary WHERE jsonb ->> 'userId' = '<USER_UUID>';```
