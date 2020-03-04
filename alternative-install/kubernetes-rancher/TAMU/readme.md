# Folio on Kubernetes/Rancher 2.x

## License

Copyright (C) 2016-2019 The Open Library Foundation

This software is distributed under the terms of the Apache License, Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

A collection of Dockerfiles and YAML for Folio Q3.2 installation on Kubernetes/Rancher 2.x.<br/>
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
  a) Kubernetes Version - v1.13.10-rancher1-2<br/>
  b) Network Provider - Canal<br/>
  c) Project Network Isolation - Enabled<br/>
  d) Nginx Ingress - Enabled<br/>
  e) Metrics Server Monitoring - Enabled<br/>
  f) Pod Security Policy Support - Enabled<br/>
  g) Docker version on nodes - Allow unsupported versions<br/>
  h) Docker Root Directory - /var/lib/docker<br/>
  i) Default Pod Security Policy - unrestricted (You can change this later for the cluster as well as the Namespaces once Pod Security Policies have been established)<br/>
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
kubernetes_version: "v1.13.10-rancher1-2"
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

4) Click Save

## FOLIO in Rancher/Kubernetes

### Set-up order overview (Our Rancher-exported YAML can be looked at under the YAML folder):

1) Create cluster via Rancher 2.x with one or more nodes, using Canal network plugin. We are using VMware to provision Oracle Linux VMs at the moment
2) Create Folio-Project in Rancher 2.x UI
3) Add folio-q4, postgres-modules-q4, and postgres-okapi-q4 Namespaces for Folio-Project under Namespaces in Rancher 2.x UI
4) Add Dockerhub and your private Docker registries to the Folio-Project
5) Add Persistent Volume on the cluster and Persistent Volume Claim for Folio-Project (We are using vSphere Storage Class)<br/>

(The rest of these steps are from within the Folio-Project in Rancher 2.x)<br/>

6) Create the following Rancher Secrets under Folio-Project:<br/>

db-connect (folio-q4/postgres-modules-q4/postgres-okapi-q4 namespaces)<br/>
db-connect-okapi (folio-q4 namespace)<br/>
db-config-modules (postgres-modules-q4 namespace)<br/>
db-config-okapi (postgres-okapi-q4 namespace)<br/>

7) Deploy crunchy-postgres Workload *Stateful set* via Helm Package, edit the Workload to tweak environment variables for use with Folio - with db-config Secret
8) Add Record under Service Discovery, named pg-folio, as type *Selector* with Label/Value: *statefulset.kubernetes.io/pod-name = pgset-0*
9) Deploy create-db Workload *Job* - built from our custom Docker container with DB init scripts - with db-connect Secret
10) Deploy Okapi Workload *Scalable deployment* of 1 and InitDB environment variable set to true - built from our custom Docker container - with db-connect-okapi Secret
11) Deploy Folio module Workloads *Scalable deployment* between 1 and 3 (one Workload per Folio module) - with db-connect Secret for those modules that need a connection to the database
12) Deploy Stripes Workload *Run one pod on each node* – built from our custom Docker container
13) Create tamu-tenant-config, diku-tenant-config and x-okapi-token Rancher Secrets under Folio-Project - Resources - Secrets
14) Deploy create-tenant Workload *Job* – built from our custom Docker container with scripts - with tamu-tenant-config/diku-tenant-config Secret
15) Deploy create-deploy Workload *Job*, to enable modules for `/proxy/modules`, `/discovery/modules`, and tenants – built from our custom Docker container with scripts - with tamu-tenant-config/diku-tenant-config Secret
16) Deploy bootstrap-superuser Workload *Job* – built from our custom Docker container with scripts - with tamu-tenant-config/diku-tenant-config Secret
17) Deploy create-refdata Workload *Job* – built from our custom Docker container with scripts - with tamu-tenant-config/diku-tenant-config Secret
18) Deploy create-sampdata Workload *Job* – built from our custom Docker container with scripts - with x-okapi-token Secret AND diku-tenant-config Secret
19) Edit Okapi Workload, set InitDB environment variable to false
20) Scale up Okapi pods to 3 using Rancher 2.x + button
21) Add Ingress under Load Balancing for Okapi and Stripes using URLs for `/` and `/_/`

### Cluster Service Accounts Notes
Run the following in the Rancher GUI - cluster Dashboard using the *Launch kubectl* button:<br/>

-When using crunchy-postgres, need to execute this command on the cluster for the pgset-sa service account:<br/>

```kubectl create clusterrolebinding pgset-sa --clusterrole=admin --serviceaccount=folio-q4:pgset-sa --namespace=folio-q4```<br/>

-When using Hazelcast discovery Kubernetes plugin for Okapi, need to execute these commands on the cluster for the service account:<br/>

1) ```touch rbac.yaml```<br/>
2) ```vi rbac.yaml```<br/>

Paste in this code:<br/>

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hazelcast-rb-q4-2019
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: default
  namespace: folio-q4
  ```

3) Save
4) Run: ```kubectl apply -f rbac.yaml```


### Rancher Secrets Notes:

-Each Rancher Secret should only be available to a single Namespace for security and separation.<br/>

-The Secrets below were made available to the folio-q4 Namespace:<br/>

#### db-connect Secret key-value pairs:

DB_DATABASE = okapi_modules<br/>
DB_HOST = pg-folio<br/>
DB_MAXPOOLSIZE = 20<br/>
DB_PASSWORD = password<br/>
DB_PORT = 5432<br/>
DB_USERNAME = folio_admin<br/>

#### db-connect-okapi Secret key-value pairs:

PG_DATABASE = okapi<br/>
PG_HOST = pg-okapi<br/>
PG_PASSWORD = password<br/>
PG_PORT = 5432<br/>
PG_USERNAME = okapi

#### diku-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = diku_admin<br/>
OKAPI_URL = http://okapi:9130<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = true<br/>
TENANT_DESC = Danish Library Technology Institute<br/>
TENANT_ID = diku<br/>
TENANT_NAME = Datalogisk Institut

#### tamu-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = tamu_admin<br/>
OKAPI_URL = http://okapi:9130<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = false<br/>
TENANT_DESC = Texas A&M University Libraries<br/>
TENANT_ID = tamu<br/>
TENANT_NAME = TAMU Libraries

#### tern-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = tern_admin<br/>
OKAPI_URL = http://okapi:9130<br/>
PURGE_DATA = true<br/>
REF_DATA = true<br/>
REGISTRY_URL = `http://okapi:9130/_/proxy/modules`<br/>
SAMPLE_DATA = false<br/>
TENANT_DESC = Texas A&M University Libraries Development<br/>
TENANT_ID = tern<br/>
TENANT_NAME = TAMU Libraries Dev

#### ldp-conf Secret key-value pairs:

ldp.conf =  ```[folio]<br/>
            url = http://okapi:9130<br/>
            tenant = tamu<br/>
            user = tamu_admin<br/>
            password = password<br/>
            [default-database]<br/>
            dbtype = postgres<br/>
            host = pg-ldp<br/>
            port = 5432<br/>
            user = ldpadmin<br/>
            password = password<br/>
            dbname = ldp```

#### db-connect-migration Secret key-value pairs:

CAMUNDA_BPM_ADMIN_USER_ID = admin<br/>
CAMUNDA_BPM_ADMIN_USER_PASSWORD = password<br/>
EXTRACTION_DATASOURCE_PASSWORD = password<br/>
EXTRACTION_DATASOURCE_USERNAME = db<br/>
OKAPI_PASSWORD = admin<br/>
OKAPI_USERNAME = tern_admin<br/>
SPRING_DATASOURCE_PASSWORD = password<br/>
SPRING_DATASOURCE_USERNAME = spring_folio_admin<br/>
TENANT_DEFAULT_TENANT = tern

#### x-okapi-token Secret Key-Value pairs:
NOTE: You won’t need this until after the Folio system is up, but before you load sample data. Log in to the Folio System via the GUI, go to *Settings - Developer - Set Token* and copy it out from there.<br/>

X_OKAPI_TOKEN = *Authentication token from Okapi*

-The Secrets below were made available to the postgres-modules-q4 Namespace:<br/>

#### db-config-modules Secret key-value pairs:

PG_DATABASE = okapi_modules<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = folio_admin

#### db-connect Secret key-value pairs:

DB_HOST = pg-module-selector-q4<br/>
PG_DATABASE = okapi_modules<br/>
PG_PASSWORD = password<br/>
PG_USER = folio_admin

-The Secrets below were made available to the postgres-okapi-q4 Namespace:<br/>

#### db-config-okapi Secret key-value pairs:

PG_DATABASE = okapi<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = okapi

#### db-connect Secret key-value pairs:

DB_HOST = pg-okapi-selector-q4<br/>
PG_DATABASE = okapi<br/>
PG_PASSWORD = password<br/>
PG_USER = okapi

-The Secrets below were made available to the postgres-ldp Namespace:<br/>

#### db-config-ldp Secret key-value pairs:

DB_HOST = pg-ldp-selector<br/>
PG_DATABASE = ldp<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = ldp_admin

-The Secrets below were made available to the postgres-folio-migration Namespace:<br/>

#### db-config-migration-modules Secret key-value pairs:

DB_HOST = pg-folio-migration-selector<br/>
PG_DATABASE = migration_modules<br/>
PG_PASSWORD = password<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = spring_folio_admin


### Okapi Notes:

-Running in *clustered* mode.<br/>
-Hazelcast in Kubernetes requires editing the hazelcast.xml file included with the Okapi repo before you build the Docker container, and setting your Folio namespace under:
```
<kubernetes enabled="true">
                <namespace>folio-q4</namespace>
                <service-name>okapi</service-name>
                <!--
                <service-label-name>MY-SERVICE-LABEL-NAME</service-label-name>
                <service-label-value>MY-SERVICE-LABEL-VALUE</service-label-value>
                -->
            </kubernetes>
```
-Workload running as 3 pods that share database (Run as uneven numbers for quorum).<br/>
-Initially spin up one Okapi pod, do the deployment jobs, then can scale out Okapi's pods for clustering and they will each pick up the tenants/discovery/proxy services.<br/>
-After single Okapi pod has been initialized, set Workload environment variable for InitDB to false for future pod scalability.<br/>
-*ClusterIP* port mapping for Okapi port 9130, Hazelcast ports (5701 - 5704) and OKAPI_CLUSTERHOST environment variable set to the *ClusterIP* Rancher/K8s assigns in Service Discovery.<br/>

#### Okapi Workload environment variables:

OKAPI_URL = http://okapi:9130<br/>
OKAPI_STORAGE = postgres<br/>
OKAPI_PORT = 9130<br/>
OKAPI_NODENAME = okapi1<br/>
OKAPI_LOGLEVEL = INFO<br/>
OKAPI_HOST = okapi<br/>
OKAPI_COMMAND = cluster<br/>
OKAPI_CLUSTERHOST = $(OKAPI_SERVICE_HOST)<br/>
INITDB = false<br/>
HAZELCAST_VERTX_PORT = 5702<br/>
HAZELCAST_PORT = 5701<br/>
HAZELCAST_IP = $(OKAPI_SERVICE_HOST)<br/>

### HA Postgres in Kubernetes/Rancher Notes:

-Currently testing out crunchy-postgres Helm Chart HA Kubernetes solution.<br/>
-Running as a Kubernetes *Stateful Set*, with one primary and two replica pods. Replica pods are read-only.<br/>
-For Postgres *Service Discovery*, created a *Selector* type called *pg-folio* that targets the master pgset-0 Postgres pod via a label.<br/>
-Using a *Persistent Volume Claim* for Rancher Folio-Project, provisioned with vSphere Storage Class.<br/>
-Not sure if we would run like this in Production yet, as we haven't load tested it. It is a possibility for those looking for a complete Rancher/Kubernetes/Container solution, and being actively developed.<br/>

#### Crunchy-postgres Workload environment variables:

WORK_MEM = 4MB<br/>
PGHOST = /tmp<br/>
PG_REPLICA_HOST = pgset-replica<br/>
PG_PRIMARY_HOST = pgset-primary<br/>
PG_MODE = set<br/>
PG_LOCALE = en_US.UTF-8<br/>
PG_DATABASE = okapi<br/>
MAX_CONNECTIONS = 250<br/>
ARCHIVE_MODE = off<br/>
ARCHIVE_TIMEOUT = 60<br/>
CRUNCHY_DEBUG = FALSE<br/>
TEMP_BUFFERS = 16MB<br/>
SHARED_BUFFERS = 128MB<br/>
MAX_WAL_SENDERS = 2<br/>


### Workload Notes

-Please see this document for the required back-end module environment variables, database connection stipulation, Java heap memory setting, and port to start the module Workload:<br/>

* [Module Metadata notes](module_metadata.md)

#### Modules that require the db-connect Secret:

*mod-agreements, mod-audit, mod-audit-filter, mod-calendar, mod-circulation-storage, mod-configuration, mod-data-import, mod-email, mod-erm-usage, mod-erm-usage-harvester, mod-event-config, mod-feesfines, mod-finance-storage, mod-inventory-storage, mod-kb-ebsco-java, mod-licenses, mod-login, mod-notes, mod-notify, mod-orders-storage, mod-organizations-storage, mod-password-validator, mod-permissions, mod-sender, mod-source-record-manager, mod-source-record-storage, mod-tags, mod-template-engine, mod-users*


### Ingress Notes:

-Have two URLs as CNAME Records for external NginX Plus load balancer - which set upstream as K8s cluster worker nodes via their DNS names.<br/>
-One URL is for proxying front-end Stripes and the other is for proxying Okapi traffic.<br/>
-The Okapi traffic URL is the URL used when building Stripes.<br/>
-When setting up Load Balancing/Ingress, target the Service name instead of Workload name if you have specific ports you have set in the Workload.<br/>
-For Okapi HA ingress, I have Okapi Service as the target at port 9130, with root path, `/` and `/_/` for the hostname folio-okapi-q4.org<br/>

-To have default Rancher 2.x Nginx ingress be a little smarter about DNS RR, add annotations in Rancher 2.1 GUI Service Discovery:<br/>

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
```psql -U postgres -h pg-folio -w -d okapi_modules --command "SELECT * FROM diku_mod_inventory_storage.item;" > /pgdata/folio-q4/items```
