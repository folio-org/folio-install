# Folio on Kubernetes/Rancher 2.x

## License

Copyright (C) 2016-2021 The Open Library Foundation

This software is distributed under the terms of the Apache License, Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

A collection of Dockerfiles and YAML for Folio Q3 2020 installation on Kubernetes/Rancher 2.x.<br/>
Latest deployment procedure here: https://wiki.folio.org/pages/viewpage.action?pageId=14458600

## Contents

* [Minikube deployment notes](Folio_MiniKube_Notes.md)
* [Module Metadata notes](module_metadata.md)
* [Okapi Dockerfile Readme](okapi/Readme.md)
* [Stripes Dockerfile Readme](stripes-diku/Readme.md)
* [bootstrap-superuser Dockerfile Readme](deploy-jobs/bootstrap-superuser/Readme.md)
* [alter-database Dockerfile Readme](deploy-jobs/alter-database/Readme.md)
* [create-deploy Dockerfile Readme](deploy-jobs/create-deploy/Readme.md)
* [create-tenant Dockerfile Readme](deploy-jobs/create-tenant/Readme.md)
* [secure-okapi Dockerfile Readme](deploy-jobs/secure-okapi)

## Prerequisites for Rancher Server

#### In Oracle Linux, install correct version of Docker:

```yum install yum-utils```

```yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo```

```yum install --setopt=obsoletes=0 docker-ce-17.03.2.ce-1.el7.centos.x86_64```

```systemctl start docker.service && systemctl enable docker.service```

#### Add insecure Docker Registry:

``cat > /etc/docker/daemon.json <<END
{
  "insecure-registries" : ["Your Docker private registry IP or FQDN"],
  "storage-driver": "devicemapper"
}
END``

#### Restart Docker after amending Docker Registry:

```systemctl restart docker```

#### Run/Install Rancher Server:
(We are using our own certs, signed by a recognized CA)

```docker run -d --restart=unless-stopped -p 80:80 -p 443:443 -v /etc/ssl/certs/my-cert.pem:/etc/rancher/ssl/cert.pem -v /etc/ssl/certs/my-key.pem:/etc/rancher/ssl/key.pem rancher/rancher:stable --no-cacerts```



## Prerequisites for Kubernetes Hosts

#### VM specs:

8 core CPU<br/>
16GB of memory<br/>
40GB disk<br/>

#### In Oracle Linux, install correct version of Docker:

```yum install yum-utils```

```yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo```

```yum install --setopt=obsoletes=0 docker-ce-17.03.2.ce-1.el7.centos.x86_64```

```systemctl start docker.service && systemctl enable docker.service```

#### Add insecure Docker Registry:

``cat > /etc/docker/daemon.json <<END
{
  "insecure-registries" : ["Your Docker private registry IP or FQDN"],
  "storage-driver": "devicemapper"
}
END``

#### Restart Docker after amending Docker Registry:

```systemctl restart docker```

#### Setup Kubernetes Cluster (From within Rancher GUI):

1) Add a Cluster -> select Custom -> enter a cluster name (folio-cluster) -> Next
2) From Node Role, select all the roles: etcd, Control, and Worker.
3) Optional: Rancher auto-detects the IP addresses used for Rancher communication and cluster communication.
   You can override these using Public Address and Internal Address in the Node Address section.
4) Skip the Labels stuff. It's not important for now.
5) Copy the command displayed on screen to your clipboard.
6) Log in to your first Kubernetes Linux host using your preferred shell, such as PuTTy or a remote Terminal connection. Run the command copied to your clipboard. Repeat this for each additional node you wish to add.
7) When you finish running the command on all of your Kubernetes Linux hosts, click Done inside of Rancher GUI.

# OR

### Create vSphere Node template:

1) Rancher 2.x UI - Global View
2) Click upper right-hand corner drop-down - select Node Templates
3) Click Add Template
4) Click vSphere
5) Use these config suggestions:

```
Name:
k8s-role-datacenter
     
Account Access:
vcenter or ESXi Server: your.vsphere.org
vcenterPort: Usually 443
username/Password: Your vSphere login or service account
     
Instance options:
cpuCount: 8
diskSize: 40000
memorySize: 16384
     
OS ISO URL:
https://releases.rancher.com/os/latest/rancheros-vmware.iso
     
Guestinfo settings:
guestinfo.hostname=kubenodeXXX
guestinfo.interface.0.dhcp={"yes"}
guestinfo.interface.0.name=eth0
guestinfo.interface.0.role={"public"}
disk.enableUUID=TRUE
     
Scheduling:
datacenter: Your vSphere datacenter name
network: Your vSphere network name
datastore: Your vSphere datastore name
folder: /Path/to/VMs
     
Storage driver:
overlay2
     
Insecure registry settings:
XXX.XXX.XXX.X
XXX.XXX.XXX.X
     
Registry Mirrors:
https://your.private.registry.org
```


### Setup Kubernetes cluster using Node Templates on vSphere (From within Rancher GUI):


1) Add a Cluster -> select vSphere -> enter a cluster name (folio-dev-cluster) -> Next
2) Set these cluster options:<br/>
  a) Kubernetes Version - v1.18.10-rancher1-2<br/>
  b) Network Provider - Canal<br/>
  c) Project Network Isolation - Enabled<br/>
  d) Nginx Ingress - Enabled<br/>
  e) Metrics Server Monitoring - Enabled<br/>
  f) Pod Security Policy Support - Enabled<br/>
  g) Docker version on nodes - Allow unsupported versions<br/>
  h) Docker Root Directory - /var/lib/docker<br/>
  i) Default Pod Security Policy - unrestricted (You can change this later for the cluster as well as the namespaces once Pod Security Policies have been established)<br/>
  j) Cloud Provider - Custom<br/>
  k) Private Registries - Disabled<br/>
  l) etcd Snapshot Backup Target - local<br/>
  m) Recurring etcd Snapshot Enabled - Yes<br/>
  n) Recurring etcd Snapshot Creation Period - 12<br/>
  o) Recurring etcd Snapshot Retention Count - 6<br/>
3) Click Edit as YAML button and add this code to the very bottom under Services section:
```
addon_job_timeout: 30
authentication:
  strategy: "x509"
bastion_host:
  ssh_agent_auth: false
cloud_provider:
  name: "vsphere"
  vsphereCloudProvider:
    global:
      datacenters: "DC1, DC2"
      insecure-flag: true
      soap-roundtrip-count: 0
      user: "username"
      password: "password"
    virtual_center:
      vsphere.org:
        datacenters: "DC1, DC2"
        soap-roundtrip-count: 0
    workspace:
      datacenter: "DC1"
      default-datastore: "kube"
      folder: "kubevols"
      server: "vsphere.org"
ignore_docker_version: true
#
#   # Currently only nginx ingress provider is supported.
#   # To disable ingress controller, set `provider: none`
#   # To enable ingress on specific nodes, use the node_selector, eg:
#      provider: nginx
#      node_selector:
#        app: ingress
#
ingress:
  provider: "nginx"
kubernetes_version: "v1.18.10-rancher1-2"
monitoring:
  provider: "metrics-server"
#
#   # If you are using calico on AWS
#
#      network:
#        plugin: calico
#        calico_network_provider:
#          cloud_provider: aws
#
#   # To specify flannel interface
#
#      network:
#        plugin: flannel
#        flannel_network_provider:
#          iface: eth1
#
#   # To specify flannel interface for canal plugin
#
#      network:
#        plugin: canal
#        canal_network_provider:
#          iface: eth1
#
network: 
  options: 
    flannel_backend_type: "vxlan"
  plugin: "canal"
restore: 
  restore: false
#
#      services:
#        kube_api:
#          service_cluster_ip_range: 10.43.0.0/16
#        kube_controller:
#          cluster_cidr: 10.42.0.0/16
#          service_cluster_ip_range: 10.43.0.0/16
#        kubelet:
#          cluster_domain: cluster.local
#          cluster_dns_server: 10.43.0.10
#
services: 
  etcd: 
    backup_config: 
      enabled: true
      interval_hours: 12
      retention: 6
    creation: "12h"
    extra_args: 
      election-timeout: "5000"
      heartbeat-interval: "1000"
    retention: "72h"
    snapshot: false
  kube-api: 
    always_pull_images: false
    pod_security_policy: true
    service_node_port_range: "30000-32767"
  kube-controller: 
    extra_args: 
      node-monitor-grace-period: "60s"
      node-monitor-period: "10s"
      pod-eviction-timeout: "120s"
  kubelet: 
    extra_args: 
      node-status-update-frequency: "5s"
    fail_swap_on: false
ssh_agent_auth: false
default_pod_security_policy_template_id: "unrestricted"
description: "Cluster for Folio deployments in the development environment."
# 
#   # Rancher Config
# 
docker_root_dir: "/var/lib/docker"
enable_cluster_alerting: true
enable_cluster_monitoring: true
enable_network_policy: true
local_cluster_auth_endpoint: 
  enabled: false
name: "folio-dev-cluster"
```
4) Add Node Pools.
5) For the Node Pool name Prefix, type kubenode# (0-10), select the corresponding Node Template, and check which roles you want for each node.
6) Click Create

### Setup Kubernetes cluster Storage Class (From within Rancher GUI):

1) From cluster view - under the Storage drop-down, click Storage Classes
2) Click Add Class
3) Name your storage class, click Provisioner: VMWare vSphere Volume
4) For Parameters select:<br/>

Thin<br/>
Datastore: kube<br/>
Filesystem Type: xfs<br/>

5) Click Save

## FOLIO in Rancher/Kubernetes

### Folio deployment overview (Our Rancher-exported YAML can be looked at under the YAML folder):

After creating the cluster as above via Rancher 2.x...<br/>

1) Create Folio-Project in Rancher 2.x UI.
2) Add *folio-q3* namespace for Folio-Project under *Namespaces* in Rancher 2.x UI.
3) Add Dockerhub and your private Docker registries to the Folio-Project.
4) Add Persistent Volume on the cluster and Persistent Volume Claim for Folio-Project (We are using vSphere Storage Class).<br/>

(The rest of these steps are from within the Folio-Project in Rancher 2.x)<br/>

5) Create the following Secrets in Rancher under the Folio-Project for the *folio-q3* namespace:<br/>

db-connect<br/>
db-connect-okapi<br/>
db-config-modules<br/>
db-config-okapi<br/>
diku-tenant-config<br/>
edge-securestore-props<br/>
postgres-setup-sql<br/>
x-okapi-token<br/>

6) If you are using an external database host, ignore this step. Otherwise deploy two crunchy-postgres *Stateful set* Workloads to the *folio-q3* namespace. Name one *pg-okapi* for Okapi's *okapi* database, and the other *pg-folio* for Folio's *okapi_modules* database. Edit each of these Workloads to set environment variables - clicking *Add From Source* to choose the corresponding db-config-okapi and db-config-modules Secrets. Configure your persistent volumes, any resource reservations and limits, as well as the Postgres UID and GID (26) at this time.
7) Deploy Okapi Workload *Scalable deployment* of 1 and InitDB environment variable set to true - built from our custom Docker container - with db-connect-okapi Secret. Once it is running, edit the Okapi Workload and set InitDB environment variable to *false*, it will redeploy.
8) Deploy Folio module Workloads as *Scalable deployment* between 1 and 3 (one Workload per Folio module) - with db-connect Secret for those modules that need a connection to the database. Import the folio-q3-2020-workloads.yaml file in Rancher for this step.
9) Deploy Stripes Workload as *Run one pod on each node* – built from our custom Docker container.
10) Deploy create-tenant Workload as *Job* – built from our custom Docker container with scripts - with diku-tenant-config Secret.
11) Deploy create-deploy Workload as *Job*, to enable modules for `/proxy/modules`, `/discovery/modules`, and tenants – built from our custom Docker container with scripts - diku-tenant-config Secret.
12) Deploy bootstrap-superuser Workload as *Job* – built from our custom Docker container with scripts - with diku-tenant-config Secret.
13) Scale up Okapi pods to 3 (for HA) using Rancher 2.x + button.
14) Add Ingresses under Load Balancing for Okapi and Stripes using URLs for `/` and `/_/`.

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
  name: hazelcast-rb-q3-2020
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: default
  namespace: folio-q3
  ```

3) Save and exit
4) Run: ```kubectl apply -f rbac.yaml```


### Rancher Secrets Notes:

-In production, unique Secrets should only be available to a single namespace for security and separation. If you choose, Secrets can be made available to all namespaces for testing and development.<br/>

-The Secrets below to be created in the *folio-q3* namespace:<br/>

#### db-connect Secret key-value pairs:

DB_CHARSET = UTF-8<br/>
DB_DATABASE = okapi_modules<br/>
DB_HOST = pg-folio<br/>
DB_MAXPOOLSIZE = 20<br/>
DB_PASSWORD = password<br/>
DB_PORT = 5432<br/>
DB_QUERYTIMEOUT = 120000<br/>
DB_USERNAME = folio_admin

#### db-connect-okapi Secret key-value pairs:

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

#### diku-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = diku_admin<br/>
IGNORE_ERRORS = true<br/>
OKAPI_URL = http://okapi:9130<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = true<br/>
TENANT_DESC = Danish Library Technology Institute<br/>
TENANT_ID = diku<br/>
TENANT_NAME = Datalogisk Institut

#### edge-securestore-props Secret key-value pairs:

edge-ephemeral.properties =
```
secureStore.type=Ephemeral
# a comma separated list of tenants
tenants=diku
#######################################################
# For each tenant, the institutional user password...
#
# Note: this is intended for development purposes only
#######################################################
# format: tenant=username,password
diku=edgeuser,password
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

#### x-okapi-token Secret Key-Value pairs:
NOTE: You won’t need this until after the Folio system is up, but before you secure Okapi. Log in to the Folio System via the GUI, go to *Settings - Developer - Set Token* and copy it out from there.<br/>

X_OKAPI_TOKEN = *Authentication token from Okapi*


### The Secrets below are being used for Tamu's specific Folio deployment, migration tooling and the LDP deployment. They are included here as a reference.

#### tamu-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = tamu_admin<br/>
IGNORE_ERRORS = true<br/>
OKAPI_URL = http://okapi:9130<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = false<br/>
TENANT_DESC = Texas A&M University Libraries<br/>
TENANT_ID = tamu<br/>
TENANT_NAME = TAMU Libraries

#### ldp-conf Secret key-value pairs:

ldpconf.json =  ```{
    "deployment_environment": "development",
    "ldp_database": {
        "odbc_database": "ldp"
    },
    "enable_sources": ["my_library"],
    "sources": {
        "my_library": {
            "okapi_url": "http://okapi:9130",
            "okapi_tenant": "tamu",
            "okapi_user": "tamu_admin",
            "okapi_password": "password",
            "direct_tables": [
                "inventory_holdings",
                "inventory_instances",
                "inventory_items"
            ],
            "direct_database_name": "okapi_modules",
            "direct_database_host": "pg-folio",
            "direct_database_port": 5432,
            "direct_database_user": "folio_admin",
            "direct_database_password": "password"
        }
    }
}```

#### db-connect-migration Secret key-value pairs:

CAMUNDA_BPM_ADMIN_USER_ID = admin<br/>
CAMUNDA_BPM_ADMIN_USER_PASSWORD = password<br/>
EXTRACTION_DATASOURCE_PASSWORD = password<br/>
EXTRACTION_DATASOURCE_USERNAME = db<br/>
OKAPI_PASSWORD = password<br/>
OKAPI_USERNAME = tamu_admin<br/>
SPRING_DATASOURCE_PASSWORD = password<br/>
SPRING_DATASOURCE_USERNAME = spring_folio_admin<br/>
TENANT_DEFAULT_TENANT = tamu

#### db-config-migration Secret key-value pairs:

PG_DATABASE = mod_data_migration<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = spring_folio_admin

#### db-config-ldp Secret key-value pairs:

LDP_CONFIG_PASSWORD = password<br/>
LDP_CONFIG_USER = ldpconfig<br/>
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

### Okapi Notes:

-Running in *clustered* mode.<br/>
-Hazelcast in Kubernetes requires editing the hazelcast.xml file included with the Okapi repo before you build the Docker container, and setting your Folio namespace and service-name under:
```
<kubernetes enabled="true">
                <namespace>folio-q3</namespace>
                <service-name>okapi</service-name>
                <!--
                <service-label-name>MY-SERVICE-LABEL-NAME</service-label-name>
                <service-label-value>MY-SERVICE-LABEL-VALUE</service-label-value>
                -->
            </kubernetes>
```
-After a single Okapi pod has been initialized, edit and set Okapi's Workload environment variable for InitDB to false, and it will respin up for future pod scalability with data persistence.<br/>
-After initially spinning up one Okapi pod, then doing the InitDB variable switch above, execute the deployment K8s Jobs to deploy the Folio tenants and modules.<br/>
-Scale out Okapi's pods for clustering after finishing your tenant setup, they will each get and manage the shared data of your Folio deployment.<br/>
-Use *ClusterIP* port mapping for Okapi port 9130, and the Hazelcast ports (5701 - 5704, 54327). Also add a *NodePort* port map for 9130 when exposing Okapi via a Load Balancing/Ingress entry.<br/>

#### Configuration and observations for containerized Okapi:

-Built using Tamu's Dockerfile vs the Folioorg Dockerhub artifact, as it provides us with a bit more flexibility when running (defined environment variables easily allow ability to pass hazelcast config, and to initialize the database or not on startup).<br/>
-For minimal HA we run as a single cluster of 3 containers per Folio instance, at an odd number of members so a quorum is established (3, 5, 7, etc). You can run as a single node cluster, but you lose the benefits of multiple Okapis providing redundancy and the overhead that allows you for handling multiple, simultaneous and large requests<br/>
-The Okapi cluster is spawned from a single Workload as a K8s statefulset deployment, then scaled out. This is done to allow Okapi nodes to have consistent names, to handle upgrading members on-the-fly, and to facilitate scaling up and down with more consistency and stability.<br/>
-As stated above, we define in the hazelcast.xml config file a unique group name, namespace, and the service name of the deployment in K8s.<br/>
-Hazelcast overhead seems low. Members and their config are stored in a memory map in each Okapi node from my understanding.<br/>
-I have seen performance drawbacks with large numbers of Okapi. This appears to stem from the Timers function.<br/>
-In K8s networking, the Okapi pods are round-robin load-balanced so not a single member gets overwhelmed. This does have a benefit in our testing: Loading data through the APIs doesn’t overload any single K8s node where an Okapi pod instance may be running. This also means that other tenants, where heavy requests may be taking place, do not see as much of a performance impact of the system when multiple tenants are being accessed and used within the same instance of Folio.<br/>
-It has been our experience that running a separate *okapi* database host for Okapi, and not combining it with the Folio *okapi_modules* database improves performance for us.<br/>

#### Okapi Workload environment variables:

OKAPI_URL = http://okapi:9130<br/>
OKAPI_STORAGE = postgres<br/>
OKAPI_PORT = 9130<br/>
OKAPI_LOGLEVEL = INFO<br/>
OKAPI_HOST = okapi<br/>
OKAPI_COMMAND = cluster<br/>
OKAPI_CLUSTERHOST = $(OKAPI_SERVICE_HOST)<br/>
INITDB = false<br/>
HAZELCAST_VERTX_PORT = 5702<br/>
HAZELCAST_PORT = 5701<br/>
HAZELCAST_IP = $(OKAPI_SERVICE_HOST)<br/>

### HA Postgres in Kubernetes/Rancher Notes:

-Currently testing out crunchy-postgres Kubernetes solution.<br/>
-Running as a Kubernetes *Stateful Set*, with one primary and two replica pods. Replica pods are read-only.<br/>
-Using a *Persistent Volume Claim* for Rancher Folio-Project, provisioned with vSphere Storage Class.<br/>
-Not sure if we would run like this in Production yet, as we haven't load tested it. It is a possibility for those looking for a complete Rancher/Kubernetes/Container solution, and being actively developed.<br/>

#### Crunchy-postgres Workload environment variables:

WORK_MEM = 64MB<br/>
PGHOST = /tmp<br/>
PG_REPLICA_HOST = pgset-replica<br/>
PG_PRIMARY_HOST = pgset-primary<br/>
PG_MODE = set<br/>
PG_LOCALE = en_US.UTF-8<br/>
PG_DATABASE = okapi<br/>
MAX_CONNECTIONS = 1000<br/>
ARCHIVE_MODE = on<br/>
ARCHIVE_TIMEOUT = 60<br/>
CRUNCHY_DEBUG = FALSE<br/>
TEMP_BUFFERS = 64MB<br/>
SHARED_BUFFERS = 2048MB<br/>
MAX_WAL_SENDERS = 3<br/>


### Workload Notes

-Please see this document for the required back-end module environment variables, database connection stipulation, Java heap memory setting, and port to start the module Workload:<br/>

* [Module Metadata notes](module_metadata.md)

#### Modules that require the db-connect Secret:

*mod-agreements, mod-audit, mod-audit-filter, mod-calendar, mod-circulation-storage, mod-configuration, mod-data-import, mod-email, mod-erm-usage, mod-erm-usage-harvester, mod-event-config, mod-feesfines, mod-finance-storage, mod-inventory-storage, mod-kb-ebsco-java, mod-licenses, mod-login, mod-notes, mod-notify, mod-oai-pmh, mod-orders-storage, mod-organizations-storage, mod-password-validator, mod-permissions, mod-sender, mod-source-record-manager, mod-source-record-storage, mod-tags, mod-template-engine, mod-users*


### Ingress Notes:

-Have two URLs as CNAME Records for external NginX Plus load balancer - which set upstream as K8s cluster worker nodes via their DNS names.<br/>
-One URL is for proxying front-end Stripes and the other is for proxying Okapi traffic.<br/>
-The Okapi traffic URL is the URL used when building Stripes.<br/>
-When setting up Load Balancing/Ingress, target the Service name instead of Workload name if you have specific ports you have set in the Workload.<br/>
-For Okapi HA ingress, I have Okapi Service as the target at port 9130, with root path, `/` and `/_/` for the hostname folio-okapi-q3.org<br/>

-To have default Rancher 2.x Nginx ingress be a little smarter about DNS round-robin, add annotations in Rancher GUI under Service Discovery:<br/>

nginx.ingress.kubernetes.io/upstream-fail-timeout = 30<br/>
nginx.ingress.kubernetes.io/upstream-max-fails = 1<br/>
nginx.ingress.kubernetes.io/proxy-connect-timeout = 60<br/>
nginx.ingress.kubernetes.io/proxy-read-timeout = 600<br/>
nginx.ingress.kubernetes.io/proxy-send-timeout = 600<br/>

-To allow larger chunks of data, add annotations in Rancher 2.x GUI Service Discovery:<br/>

nginx.ingress.kubernetes.io/client-body-buffer-size = 512M<br/>
nginx.ingress.kubernetes.io/proxy-body-size = 2048M



## Kubernetes Pro Tips

#### Config and launch Kubernetes Cluster Dashboard from your workstation (On OSX: Save files and token in /Users/UserName/.kube/):

Run instructions from here: https://gist.github.com/superseb/3a9c0d2e4a60afa3689badb1297e2a44

#### If running Kubernetes node VMs in VMWare, follow these instructions to reconfigure the VMTools:

Run instructions from here: https://itq.nl/veeam-tenants-dockerkubernetes-aware/

1) Open the tools.conf file in the /etc/vmware-tools directory with a text editor. (If this file does not exist, just create one)<br/>
2) Append the following lines:<br/>
```
[vmbackup]
enableSyncDriver = false
```
3) Restart the VMTools service.

#### To clean existing Kubernetes cluster node for re-deployment run:

```docker stop $(docker ps -aq)```<br/>
```docker rm $(docker ps -aq)```<br/>
```docker rmi $(docker images -q)```<br/>
```docker volume prune```<br/>
```docker system prune```<br/>
```sudo rm -rf /var/lib/etcd /etc/kubernetes/ssl /etc/cni /opt/cni /var/lib/cni /var/run/calico /etc/kubernetes /etc/ceph /opt/rke /run/secrets/kubernetes.io /run/calico /run/flannel /var/lib/calico /var/lib/kubelet /var/lib/rancher/rke/log /var/log/containers /var/log/pods /var/run/calico```<br/>
```systemctl restart docker```<br/>

#### To remove dangling images from nodes that have failed:

```docker rmi $(docker images -aq --filter dangling=true)```

#### To find out which orphaned Replicasets need deleting that have 0 pods (Run this in Rancher using Launch kubectl):

```kubectl get --all-namespaces rs -o json|jq -r '.items[] | select(.spec.replicas | contains(0)) | "kubectl delete rs --namespace=\(.metadata.namespace) \(.metadata.name)"'```

#### To scale all deployments to 0 in a namespace (Run this in Rancher using Launch kubectl):

```kubectl get deploy -n <namespace> -o name | xargs -I % kubectl scale % --replicas=0 -n <namespace>```

#### To scale all statefulsets to 0 in a namespace (Run this in Rancher using Launch kubectl):

```kubectl get statefulsets -n <namespace> -o name | xargs -I % kubectl scale % --replicas=0 -n <namespace>```

#### Enable Recurring etcd Snapshots on the cluster:

You can enable this option when you create or edit the cluster. RKE takes a snapshot of etcd running on each etcd node. The file is saved to /opt/rke/etcd-snapshots.

#### When spinning up containers from Dockerhub, be sure the Workload `Advanced Option - Command` *Auto Restart* setting is set to *Always*

#### When creating Workloads, set min to 0 if you wish to scale your deployments to 0 - in Kubernetes Dashboard

#### Set `.spec.revisionHistoryLimit` in the Kubernetes Deployment to the number of old Replicasets you want to retain.

#### To avoid overloading your cluster, in case of node failure or Workload deployment - set resource limits! Do this under Workload - Show advanced options - Security & Host Config



## Docker Pro Tips

#### Build, tag and push docker images from within their respective folders:

```docker build -t docker-private-registry/folio-project/containername:v1 .```<br/>
```docker push docker-private-registry/folio-project/containername:v1```<br/>

#### Logs:
```docker logs -f <container name>```

#### Run command on container:
```docker exec -it <container name> <command>```



## Folio Pro Tips

#### Disable module for tenant:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/proxy/tenants/diku/modules/<module-id>```

#### Delete proxy/module registration:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/proxy/modules/<Id>```

#### Delete discovery/module registration:
```curl -i -w '\n' -X DELETE http://okapi:9130/_/discovery/modules/<srvcId>/<instId>```

#### List tenants:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/tenants```

#### List registered modules:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/modules```

#### List modules enabled for a specific tenant:
```curl -i -w '\n' -X GET http://okapi:9130/_/proxy/tenants/diku/modules```

#### List of discovered/deployed modules:
```curl -i -w '\n' -X GET http://okapi:9130/_/discovery/modules```

#### Tenant login:
```
curl -i -w '\n' -X POST -H "X-Okapi-Tenant:diku" -d '{"username": "diku_admin", "password": "admin"}' \
http://okapi:9130/authn/login
```

#### Pull all Okapi registration files from url to your Okapi:
```
curl -w '\n' -D - -X POST -H "Content-type: application/json" -d '{"urls":["http://folio-registry.aws.indexdata.com"]}' http://okapi:9130/_/proxy/pull/modules
```

#### Simulate an install:
```
curl -w '\n' -X POST -D - -H "Content-type: application/json" -d @enable-docker.json http://okapi:9130/_/proxy/tenants/diku/install?simulate=true
```

#### Front-end folioci repo:
https://repository.folio.org/#browse/welcome

#### Indexdata Okapi module registry:
http://folio-registry.aws.indexdata.com/_/proxy/modules

#### Database export example:
```psql -U postgres -h pg-folio -w -d okapi_modules --command "SELECT * FROM diku_mod_inventory_storage.item;" > /pgdata/folio-q3/items```
