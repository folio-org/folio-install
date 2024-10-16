# Contents
* [Useful Links](#useful-links)
* [Dump and Restore FOLIO Prod to Pre Notes](#dump-and-restore-folio-prod-to-pre-notes)
* [Upgrade FOLIO Notes](#upgrade-folio-notes)
* [Roll-back FOLIO Notes](#roll-back-folio-notes)
* [Other Notes](#other-notes)
* [Troubleshooting FOLIO](#troubleshooting-folio)

# Useful Links

* [FOLIO API Documentation](https://dev.folio.org/reference/api/)
* [FOLIO Community Module Registry](http://folio-registry.aws.indexdata.com/_/proxy/modules)
* [FOLIO Docs](https://docs.folio.org/docs/)
* [FOLIO Install Guide on Github](https://github.com/folio-org/folio-install)
* [FOLIO Jira](https://folio-org.atlassian.net/jira)
* [FOLIO Modules on Dockerhub](https://hub.docker.com/u/folioorg/)
* [FOLIO Platform Complete on Github](https://github.com/folio-org/platform-complete)
* [FOLIO Vagrant](https://app.vagrantup.com/folio)
* [Okapi API Gateway on Github](https://github.com/folio-org/okapi/blob/master/README.md)

# Dump and Restore FOLIO Prod to Pre Notes

## Prepare a Crunchy Patroni Prod database cluster Replica for the Database Dump
(ssh to Prod cpg replica host)
#### Remove replica member from the Patroni cluster as root user:
```systemctl stop patroni@crunchy.service```

#### Start Postgres service, while keeping replica member removed from Crunchy Patroni Prod database cluster as Postgres user:
```/usr/pgsql-12/bin/pg_ctl -D /data/pg_data -l logfile start```

#### Start dump process after 5 minutes as Postgres user, inside Postgres /data/pg_data folder:
```pg_dump -v -U postgres -Fc okapi_modules > okapi_modules.dmp```

#### Once completed copy the dump file to /mnt/nfstmp/folio_db_dmp and then restart the Crunchy Patroni Prod database cluster replica VM

*Before a large data import, restore or data change it is generally a good idea to pause the cluster and disable replication.*

## Prepare FOLIO Pre Environment for the Database Restore
(ssh to Pre cpg leader host)
#### Scale down FOLIO backend on the folio-pre K8s cluster:
(Replace `<NAMESPACE>` with the corresponding K8s FOLIO namespace)<br/>
```kubectl get deploy -n <NAMESPACE> -o name | xargs -I % kubectl scale % --replicas=0 -n <NAMESPACE>```<br/>
```kubectl get statefulsets -n <NAMESPACE> -o name | xargs -I % kubectl scale % --replicas=0 -n <NAMESPACE>```

#### Pause the Crunchy Patroni Pre database cluster:
`patronictl -c /etc/patroni/crunchy.yml pause`

#### Drop database schemas on Crunchy Patroni Pre database cluster Leader BEFORE pg_restore:
```
DROP SCHEMA tamu_mod_authtoken CASCADE;
DROP SCHEMA tamu_mod_agreements CASCADE;
DROP SCHEMA tamu_mod_calendar CASCADE;
DROP SCHEMA tamu_mod_circulation_storage CASCADE;
DROP SCHEMA tamu_mod_configuration CASCADE;
DROP SCHEMA tamu_mod_courses CASCADE;
DROP SCHEMA tamu_mod_data_export CASCADE;
DROP SCHEMA tamu_mod_data_export_worker CASCADE;
DROP SCHEMA tamu_mod_data_import_converter_storage CASCADE;
DROP SCHEMA tamu_mod_email CASCADE;
DROP SCHEMA tamu_mod_erm_usage CASCADE;
DROP SCHEMA tamu_mod_erm_usage_harvester CASCADE;
DROP SCHEMA tamu_mod_eusage_reports CASCADE;
DROP SCHEMA tamu_mod_event_config CASCADE;
DROP SCHEMA tamu_mod_feesfines CASCADE;
DROP SCHEMA tamu_mod_finance_storage CASCADE;
DROP SCHEMA tamu_mod_inn_reach CASCADE;
DROP SCHEMA tamu_mod_inventory CASCADE;
DROP SCHEMA tamu_mod_inventory_storage CASCADE;
DROP SCHEMA tamu_mod_invoice_storage CASCADE;
DROP SCHEMA tamu_mod_kb_ebsco_java CASCADE;
DROP SCHEMA tamu_mod_licenses CASCADE;
DROP SCHEMA tamu_mod_login CASCADE;
DROP SCHEMA tamu_mod_notes CASCADE;
DROP SCHEMA tamu_mod_notify CASCADE;
DROP SCHEMA tamu_mod_oai_pmh CASCADE;
DROP SCHEMA tamu_mod_orders_storage CASCADE;
DROP SCHEMA tamu_mod_organizations_storage CASCADE;
DROP SCHEMA tamu_mod_password_validator CASCADE;
DROP SCHEMA tamu_mod_patron_blocks CASCADE;
DROP SCHEMA tamu_mod_permissions CASCADE;
DROP SCHEMA tamu_mod_pubsub CASCADE;
DROP SCHEMA tamu_mod_service_interaction CASCADE;
DROP SCHEMA tamu_mod_source_record_manager CASCADE;
DROP SCHEMA tamu_mod_source_record_storage CASCADE;
DROP SCHEMA tamu_mod_tags CASCADE;
DROP SCHEMA tamu_mod_template_engine CASCADE;
DROP SCHEMA tamu_mod_users CASCADE;
DROP SCHEMA tamu_mod_data_import CASCADE;
DROP SCHEMA tamu_mod_audit CASCADE;
DROP SCHEMA tamu_mod_copycat CASCADE;
DROP SCHEMA tamu_mod_data_export_spring CASCADE;
DROP SCHEMA tamu_mod_quick_marc CASCADE;
DROP SCHEMA tamu_mod_remote_storage CASCADE;
DROP SCHEMA tamu_mod_search CASCADE;
DROP SCHEMA folio_admin CASCADE;
DROP SCHEMA mod_agreements__system CASCADE;
DROP SCHEMA pubsub_config CASCADE;
DROP SCHEMA supertenant_mod_authtoken CASCADE;
DROP SCHEMA supertenant_mod_login CASCADE;
DROP SCHEMA supertenant_mod_permissions CASCADE;
DROP SCHEMA supertenant_mod_users CASCADE;
```

#### Once completed copy the dump file from /mnt/nfstmp/folio_db_dmp to the /data/pg_data folder on the Crunchy Patroni Pre database cluster Leader

#### Restore database dump to Crunchy Patroni Pre database cluster Leader from /data/pg_data folder:
```pg_restore -d okapi_modules --clean --if-exists okapi_modules.dmp```

#### Remove E-mails from Patrons to avoid sending circulation notices - in the database as Postgres user:
```
UPDATE tamu_mod_users.users
SET jsonb = Jsonb_set(jsonb, '{personal, email}', '"folio_user@tamu.org"')
WHERE jsonb -> 'personal' ->> 'email' != 'folio_user@tamu.org';
 ```

#### Scale up FOLIO backend on the folio-pre K8s cluster:
(Replace `<NAMESPACE>` with the corresponding K8s FOLIO namespace)<br/>
```kubectl get deploy -n <NAMESPACE> -o name | xargs -I % kubectl scale % --replicas=1 -n <NAMESPACE>```<br/>
```kubectl get statefulsets -n <NAMESPACE> -o name | xargs -I % kubectl scale % --replicas=1 -n <NAMESPACE>```

#### Update FOLIO Pre database role passwords, FOLIO Pre System/Admin user passwords - See the list below.

#### Update E-mail URL and void SMTP-RELAY settings for FOLIO Pre tenant:
(I perform the following exec'd into the Okapi container on the K8s cluster of the FOLIO Pre instance)<br/>
`touch folio_host.json`<br/>
`vi folio_host.json`

##### Paste in:
```
{
 "module": "USERSBL",
 "configName": "resetPassword",
 "code": "FOLIO_HOST",
 "description": "Folio UI application host",
 "default": true,
 "enabled": true,
 "value": "https://folio.tamu.org"
}
```

`touch email_smtp_host.json`<br/>
`vi email_smtp_host.json`

##### Paste in:
```
{
    "id" : "<TAMU_UUID>",
    "host" : "tamu.org",
    "port" : 25,
    "username" : "login",
    "password" : "password",
    "ssl" : false,
    "trustAll" : true,
    "loginOption" : "DISABLED",
    "startTlsOptions" : "OPTIONAL",
    "authMethods" : "",
    "from" : "folio_admin@tamu.org",
    "emailHeaders" : [ ]
}
```

#### Get UUIDs of FOLIO Pre configs to compare and match:
```
curl -i -w '\n' -X GET "$OKAPI_URL/configurations/entries?limit=100" \
-H "X-Okapi-Tenant: tamu" \
-H "X-Okapi-Token: <OKAPI_TOKEN>"
```
```
curl -i -w '\n' -X GET "$OKAPI_URL/smtp-configuration?limit=100" \
-H "X-Okapi-Tenant: tamu" \
-H "X-Okapi-Token: <OKAPI_TOKEN>"
```

#### Post the configs to FOLIO Pre with tamu_admin UI session token:
(Replace `<OKAPI_TOKEN>` with the tamu_admin user token from FOLIO Pre UI *Settings - Developer - Set token*)<br/>
```
curl -i -w '\n' -X PUT $OKAPI_URL/configurations/entries/<TAMU_UUID> \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: tamu" \
-H "X-Okapi-Token: <OKAPI_TOKEN>" \
-d @folio_host.json
```
```
curl -i -w '\n' -X PUT $OKAPI_URL/smtp-configuration/<TAMU_UUID> \
-H "Content-type: application/json" \
-H "X-Okapi-Tenant: tamu" \
-H "X-Okapi-Token: <OKAPI_TOKEN>" \
-d @email_smtp_host.json
```

#### Reindex Elasticsearch for FOLIO Pre:
```
curl -w '\n' -D - -X POST $OKAPI_URL/search/index/inventory/reindex -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{"recreateIndex": true}'
```

#### Post LDP Pre application config:
(Replace `<PASSWORD>` with the FOLIO Pre ldp user's database password)<br/>
```
curl -w '\n' -D - -X PUT $OKAPI_URL/ldp/config/dbinfo -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{
  "key":"dbinfo",
  "tenant":"tamu",
  "value":"{ \"user\" : \"ldp\", \"url\" : \"jdbc:postgresql:\/\/pg-ldp:5432\/ldp\", \"pass\" : \"<PASSWORD>\" }"  
}'
```

#### Update Settings in FOLIO UI
* The target FOLIO instance *Settings - Tenant - SSO settings - Identity Provider URL* configuration may need to be updated if the environment you're cloning to is for staging/testing.<br/>
Testing IDP URL: `https://tamu.org/shibboleth-test`<br/>
Pre/Prod IDP URL: `https://tamu.org/shibboleth`
* The target FOLIO instance *Settings - OAI-PMH - General - Base URL* configuration will need to be updated to reflect the edge URL for that instance.<br/>
Dev/Test/Pre URL: `https://folio-edge-<dev/test/pre>.tamu.org/oai`<br/>
Prod URL: `https://folio-edge.tamu.org/oai`

#### Re-create Crunchy Postgres Patroni Pre cluster replicas from the Leader Postgres host:

1) Start backup on Leader Postgres host as Postgres user:<br/>
`psql -c "select pg_start_backup('initial_backup');"`

2) Stop backup on Leader Postgres host as Postgres user:<br/>
`psql -c "select pg_stop_backup();"`

3) Reinit replica Postgres hosts:<BR>
`patronictl -c /etc/patroni/crunchy.yml reinit crunchy <member>`

4) Initiate a stanza backup on srv-pgbackrest# for replica sync as postgres user:<BR>
`pgbackrest --stanza=crunchy --type=full --log-level-console=info backup`

#### These DB roles need their passwords updated after restoring a dump:

role "alpha_owner"<br/>
role "ccp_monitoring"<br/>
role "folio_admin"<br/>
role "okapi"<br/>
role "pgbouncer"<br/>
role "postgres"<br/>
role "replicator"<br/>
role "spring_folio_admin"

#### These FOLIO System Accounts need their passwords updated after restoring a dump:
(In the FOLIO UI)<br/>
backup_admin<br/>
data-export-system-user<br/>
ebsco_services<br/>
edgeuser<br/>
folio-scripts<br/>
mod-search<br/>
pub-sub<br/>
system-user<br/>
tamu_admin<br/>
vufind

# Upgrade FOLIO Notes

Be sure to read over the FOLIO Flower release notes here: [https://folio-org.atlassian.net/wiki/spaces/REL/overview](https://folio-org.atlassian.net/wiki/spaces/REL/overview)<br/>
Pay very close attention to the *Important upgrade considerations* and *Changes and required actions* sections of each release.<br/>
New FOLIO back-end modules may need to be added to the deployment namespace; and existing FOLIO module configs, environment variables, and/or database configs may need to change.<br/>

**Prerequisites**
* Always be sure to back up your database before performing any upgrades!
* In the FOLIO UI logged in as the tamu_admin user, add the **Okapi All** permission set to the tamu_admin user before the upgrade in the Users app by editing it. When the upgrade is verified as successful, remove this permission set from the tamu_admin user.
* After the **Okapi All** permission set is added to the tamu_admin user, log out of FOLIO and back in with it. In *Settings - Developer - Set token*, copy out this token. You will need it later for disabling mod-authtoken for the supertenant.
* On the Nginx Plus load balancer dashboard on Manager22, edit and mark the appropriate HTTP upstream FOLIO cluster nodes as Down so it is not accessible from the outside while performing an upgrade.
* Scale the Okapi Workload to 1 pod in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* Suspend LDP ldp-data-update, ldp-marc-data-update and ldp-derived-tables K8s cron jobs in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* Scale down the mod-camunda, mod-data-mig, mod-spine-o-matic, and mod-workflow Workloads in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* Disable mod-authtoken for the supertenant before upgrading. See notes on how at the bottom of this Readme.

#### Check FOLIO okapi_modules database schema for duplicate barcodes from Postgres:
```
SET search_path TO tamu_mod_inventory_storage;
SELECT lower(jsonb->>'barcode')
FROM item
GROUP BY 1
HAVING count(*) > 1;

SET search_path TO tamu_mod_inventory_storage;
UPDATE item SET jsonb = jsonb - 'barcode'
WHERE lower(jsonb->>'barcode') in (
  SELECT lower(jsonb->>'barcode')
  FROM item
  GROUP BY 1
  HAVING count(*) > 1);
```

#### Check FOLIO okapi_modules database schema for duplicate external IDs from Postgres:
```
SET search_path TO tamu_mod_users;
SELECT left(lower(f_unaccent( jsonb->>'externalSystemId')), 600)
FROM users
GROUP BY 1
HAVING count(*) > 1;
```
*If any duplicates are found, the appropriate Librarian over that data's functional area will need to be consulted, along with a developer to mitigate the bad data.*

### Upgrading the FOLIO instance:

1) Grab the following files from the desired FOLIO org's platform-complete release branch at https://github.com/folio-org/platform-complete:
* install.json
* okapi-install.json
* package.json
* stripes.config.js
* yarn.lock

2) Git Clone the appropriate TAMU FOLIO release repo or branch from here as a baseline: https://github.com/TAMULib/folio

3) Copy in the install.json and okapi-install.json files from the 1st step above to the `../deploy-jobs/create-deploy/install` folder of the cloned TAMU FOLIO release repo.

4) Copy in the package.json and yarn.lock files from the 1st step above to the `../stripes-tamu` folder of the cloned TAMU FOLIO release repo.

5) Merge the configs of the new stripes.config.js from https://github.com/folio-org/platform-complete with the existing file at `../stripes-tamu`<br/>
(Rename the *tenant*, *welcomeMessage* and *platformName* texts per the environment)<br/>
The sections to generally keep the same are:
```module.exports = {
  okapi: { 'url':'http://localhost:9130', 'tenant':'tamu' },
  config: {
    logCategories: 'core,path,action,xhr',
    logPrefix: '--',
    maxUnpagedResourceCount: 2000,
    welcomeMessage: 'Welcome to FOLIO Pre!',
    platformName: 'FOLIO Pre',
    showPerms: false
  },
```
and:<br/>
(Rename the *alt* text, and update the logo per the environment)
```
branding: {
    logo: {
      src: './tenant-assets/logo.png',
      alt: 'TAMU Libraries',
    },
    favicon: {
      src: './tenant-assets/favicon.png',
    },
  }
};
```

6) Build and push the create-deploy Docker container in `../deploy-jobs/create-deploy` to the Harbor container registry with tag: rX-202X-hX (*release-year-hotfix*).

Docker command examples below:<br/>
`docker build -t harbor.tamu.org/folio/create-deploy:rX-202X .`<br/>
`docker push harbor.tamu.org/folio/create-deploy:rX-202X`

7) Build and push the stripes-tamu Docker container in `../stripes-tamu` to the Harbor container registry with tag: rX-202X-hX-tenantX (*release-year-hotfix-tenantid*).

Docker command examples below:<br/>
`docker build -t harbor.tamu.org/folio/stripes:rX-202X-hX-tenantX .`<br/>
`docker push harbor.tamu.org/folio/stripes:rX-202X-hX-tenantX`

8) Update the Okapi Dockerfile tag at `RUN git clone -b "vX.X.X"` in `../okapi/Dockerfile` of the cloned TAMU FOLIO release repo, corresponding to what is present in the new platform-complete's install.json file from step #1. Build and push the Okapi Docker container to the Harbor container registry with tag: rX-202X-hX (*release-year-hotfix*).

Docker command examples below:<br/>
`docker build -t harbor.tamu.org/folio/okapi:rX-202X-hX .`<br/>
`docker push harbor.tamu.org/folio/okapi:rX-202X-hX`

9) In Rancher, in the appropriate FOLIO cluster and namespace - scale the "okapi" Workload down to 0 pods, update the tag to the newly pushed version that was built in step 8, and scale up to 1 pod.

10) Update the folio-rX-202X-workloads.yaml in `../YAML` of the cloned TAMU FOLIO release repo
* Replace the version numbers of the image tags as well as the workloadselector/name fields with the new version numbers in the install.json from step 1.
* Update any config changes in this YAML and/or Rancher's Secrets/ConfigMaps of the FOLIO namespace in this step.
* In Rancher, import the updated YAML to the appropriate FOLIO namespace.
* *This will take a while...*

11) In Rancher, in the appropriate FOLIO cluster and namespace - update the tag for the "stripes-tamu-XXXX" Workload to the newly pushed version that was built in step 7. The pods will auto-redeploy via K8s.

12) In Rancher, in the appropriate FOLIO cluster and namespace - deploy the “create-deploy” K8s Job using the tamu-tenant-config secret and tagged rX-202X-hX image mentioned in step 6.
* For the Job Configuration settings set *Completions*, *Parallelism* and *Back Off Limit* to 1.
* Set a long Active Deadline Seconds for the Job (I use 50000).
* *This will take a while...*

*If any of it fails, get the logs from Rancher containers themselves and record them. This includes the create-deploy Job container for the upgrade, the Okapi containers, as well as the backend FOLIO module containers related to the error messages that come from the create-deploy Job container. FOLIO Jira Issues will need to be filed if there is not an apparent mis-configuration after some investigation.*

13) Restart all FOLIO back-end modules once the upgrade is complete.

14) Reindex Elasticsearch by posting to Okapi (either from inside the Okapi container in the environment or externally using the FQDN Okapi URL):
```
curl -w '\n' -D - -X POST http://okapi:9130/search/index/inventory/reindex -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{"recreateIndex": true}'
```

15) Perform post-upgrade tasks in the following order
* Scale Okapi to 3 pods.
* Scale all other back-end modules out to 1, 2, 5 pods accordingly (Use existing folio-pre/folio-prod instance as a reference).
* Upgrade the modules for the supertenant, notes below.
* Re-enable mod-authtoken for the supertenant.
* Resume LDP ldp-data-update, ldp-marc-data-update and ldp-derived-tables K8s cron jobs in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* Scale up to 1 pod each the mod-camunda, mod-data-mig, mod-spine-o-matic, and mod-workflow Workloads in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* Delete old/unused FOLIO back-end modules in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.
* On the Nginx Plus load balancer dashboard on Manager22, edit and mark the appropriate HTTP upstream FOLIO cluster nodes as back Up so it is accessible from the outside once an upgrade is completed.

16) Try logging in to the FOLIO instance on the web
* Check the FOLIO UI *Settings - Software versions* for any yellow or red.
* Click around on the Apps at the top bar and drop-down to check for responsiveness and data feed.
* In the FOLIO UI logged in as the tamu_admin user, remove the **Okapi All** permission set from the tamu_admin user.

# Roll-back FOLIO Notes

1) Shut down the FOLIO Okapi API gateway and Postgres databases<br/>
* In Rancher, spin down the Okapi container in the appropriate namespace to 0 pods.
* If using a Postgres container: In Rancher, spin down the Postgres Okapi database container (pg-okapi) and Postgres FOLIO modules database container (pg-folio) in their corresponding namespaces.
* If using a Crunchy Postgres VM: Pause the Patroni cluster using the command `patronictl -c /etc/patroni/crunchy.yml pause` and shut down the primary VM in vSphere.

2) Restore the Postgres data
* If using a Postgres container: In vSphere the container volumes were snapshot the night before. You can find the container volume names and which *Kube* vSphere volume they live in for the container databases under the Volumes tab in Rancher - FOLIO Project.
* If using a Crunchy Postgres VM: The VMs and their volumes will need to be restored via the Netapp Plugin for vCenter snapshots/backups in vSphere.

3) In Rancher, spin back up the two database containers (pg-okapi and pg-folio) to 1 pod each, then the Okapi container to 1 pod. If restoring the Crunchy VM, be sure it is powered back on and ready in vSphere. You may need to run the `patronictl -c /etc/patroni/crunchy.yml restart crunchy <node>` command for the Leader node after the VM is up.

4) Redeploy the Bitnami Kafka Helm chart
* Take care to save the Answer file config before deleting the Helm Chart!
* Delete the Kafka and Zookeeper Rancher volumes in Rancher after the Helm chart is finished being deleted.
* Redeploy the Bitnami Kafka Helm Chart from the Catalog in Rancher, choosing the appropriate FOLIO namespace, and pasting in the contents of the Answer file as YAML.

5) Restart all of the FOLIO mod-XXXX back-end modules in Rancher

6) Reindex Elasticsearch if you intend to keep this state of the FOLIO system by posting to Okapi (either from inside the Okapi container in the environment or externally using the FQDN Okapi URL):
```
curl -w '\n' -D - -X POST http://okapi:9130/search/index/inventory/reindex -H "X-Okapi-Tenant: tamu" -H "Content-Type: application/json" -H "X-Okapi-Token: <OKAPI_TOKEN>" -d '{"recreateIndex": true}'
```

# Other Notes

* If any new module versions need deploying temporarily - Copy the existing older version of the Workload in Rancher, and update the name and tag. You can update the "workloads.yaml" provided in the appropriate FOLIO Git repo for Libraries under the YAML folder later...<br/>
* I tend to only deploy one instance of new Okapi version and one pod each of the new back-end FOLIO modules when I upgrade. Then I scale them out after a successful upgrade. This makes log chasing and diagnosing issues easier...

**Disable mod-authtoken for the supertenant**<br/>
Exec into the Okapi pod in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace and touch a file as **dt.json**. Edit and Save this file as:
```
[
  {
    "id": "mod-authtoken-X.X.X",
    "action": "disable"
  }
]
```
Using the token you copied out of FOLIO earlier under **Prerequisites**, issue this command while Exec'd into the Okapi pod:
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
-H "X-Okapi-Token: <OKAPI_TOKEN>" \
-d @dt.json \
$OKAPI_URL/_/proxy/tenants/supertenant/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3Dfalse%2CloadReference%3Dfalse
```
To re-enable mod-authtoken for the supertenant, perform the same steps above but edit the **dt.json** file and set `"action": "enable"`

**Upgrade the back-end modules for the supertenant**<br/>
The supertenant can only be logged in to via the command line, there is no FOLIO UI interface for interacting with it. Because of this, the steps are very similar to upgrading FOLIO - A list of modules in a json file is posted to the supertenant Okapi install endpoint. Perform these steps exec'd into an Okapi Workload pod in the appropriate Rancher UI - FOLIO Cluster - FOLIO Namespace.<br/>
These modules are:
* mod-login
* mod-permissions
* mod-users
* mod-authtoken<br/>

Okapi install endpoint curl command:
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
-d @install/okapi-install.json \
$OKAPI_URL/_/proxy/tenants/supertenant/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3Dfalse%2CloadReference%3Dfalse
```
Where the contents of `okapi-install.json` are:<br/>
*(Replace X.X.X with the appropriate version of the module for the release of FOLIO you are upgrading to)*
```
[
  {
    "id": "mod-permissions-X.X.X",
    "action": "enable"
  },
  {
    "id": "mod-users-X.X.X",
    "action": "enable"
  },
  {
    "id": "mod-login-X.X.X",
    "action": "enable"
  },
  {
    "id": "mod-authtoken-X.X.X",
    "action": "enable"
  }
]
```

# Troubleshooting FOLIO

* In Rancher if new FOLIO back-end modules are constantly restarting before you perform an upgrade - check their connection to the database, and the availability of the Okapi deployment.
* On occasion module changes may introduce a Kafka dependency or Elasticsearch dependency - and the module's environment variables or K8s Secret will need to be updated to connect to the Kafka or Elasticsearch instance in the namespace.
* On occasion an Okapi pod will crash and/or drop from the Okapi cluster due to a network issue and the Okapi cluster will fail to reform properly. In this scenario, the whole deployment must be scaled to 0 pods. Then scaled back up to 3 pods to re-form the Okapi cluster.
* If Data Import/Export stop functioning for Librarians - it may be necessary to re-deploy Kafka. After doing so, all back-end modules that connect to Kafka will have to be restarted.<br/>
**These are:** mod-circulation-storage, mod-data-export-spring, mod-data-export-worker, mod-data-import, mod-ebsconet, mod-source-record-manager, mod-source-record-storage, mod-inventory, mod-inventory-storage, mod-invoice, mod-pubsub, mod-quick-marc, mod-remote-storage, mod-search
* Data Import Troubleshooting links:<br/>
https://folio-org.atlassian.net/wiki/spaces/FOLIOtips/pages/5671929/Recommended+Maximum+File+Sizes+and+Configuration<br/><br/>
https://folio-org.atlassian.net/wiki/spaces/FOLIJET/pages/1385757/Settings+and+configuration+details+for+Data+Import+applicable+from+R1+2021+Iris+release+onwards
