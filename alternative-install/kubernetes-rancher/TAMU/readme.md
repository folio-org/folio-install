# Folio on Kubernetes/Rancher 2.0

## License

Copyright (C) 2016-2019 The Open Library Foundation

This software is distributed under the terms of the Apache License, Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

A collection of Dockerfiles and YAML for FOLIO Q4 installation on Kubernetes/Rancher 2.0.<br/>
Latest deployment procedure here: https://wiki.folio.org/pages/viewpage.action?pageId=14458600

## Contents

* [Minikube deployment notes](Folio_MiniKube_Notes.md)
* [Module Metadata notes](module_metadata.md)
* [Okapi Dockerfile Readme](okapi/Readme.md)
* [Stripes Dockerfile Readme](stripes-diku/Readme.md)
* [bootstrap-superuser Dockerfile Readme](deploy-jobs/bootstrap-superuser/Readme.md)
* [create-database Dockerfile Readme](deploy-jobs/create-database/Readme.md)
* [create-deploy Dockerfile Readme](deploy-jobs/create-deploy/Readme.md)
* [create-refdata Dockerfile Readme](deploy-jobs/create-refdata/Readme.md)
* [create-tenant Dockerfile Readme](deploy-jobs/create-tenant/Readme.md)
* [create-sampdata Dockerfile Readme](deploy-jobs/tenants/diku/create-sampdata/Readme.md)
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

#### Run/Install Rancher Manager:

```docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher```



## Prerequisites for Kubernetes Hosts

#### VM specs:

2 core CPU<br/>
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

1) Rancher 2.0 UI - Global View
2) Click upper right-hand corner drop-down - select Node Templates
3) Click Add Template
4) Click vSphere
5) Use these config suggestions:

```
Name:
RancherOS-XXX
     
Account Access:
vcenter or ESXi Server: your.vsphere.org
vcenterPort: Usually 443
username/Password: Your vSphere login or service account
     
Instance options:
cpuCount: 4
diskSize: 40000
memorySize: 16384
     
OS ISO URL:
https://releases.rancher.com/os/latest/rancheros-vmware.iso
     
Guestinfo settings:
guestinfo.hostname=kubenodeXXX
guestinfo.interface.0.route.0.gateway=XXX.XXX.XXX.X
guestinfo.dns.server.0=XXX.XXX.XXX.X
guestinfo.dns.server.1=XXX.XXX.XXX.X
guestinfo.dns.domain.0=your.domain.org
guestinfo.interface.0.ip.0.address=XXX.XXX.XXX.X/23
guestinfo.interface.0.dhcp={"no"}
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


1) Add a Cluster -> select vSphere -> enter a cluster name (rancheros-cluster) -> Next
2) Set these cluster options:<br/>
  a) Kubernetes Version - v1.11.5-rancher1-1<br/>
  b) Network Provider - Canal<br/>
  c) Project Network Isolation - Disabled<br/>
  d) Nginx Ingress - Enabled<br/>
  e) Metrics Server Monitoring - Enabled<br/>
  f) Pod Security Policy Support - Enabled<br/>
  g) Docker version on nodes - Allow unsupported versions<br/>
  h) Docker Root Directory - /var/lib/docker<br/>
  i) Default Pod Security Policy - unrestricted (You can change this later for the cluster as well as the Namespaces once Pod Security Policies have been established)<br/>
  j) Cloud Provider - None
3) Click Edit as YAML button and add this code to the very bottom under Services section:
```
services:
  etcd:
    extra_args:
      election-timeout: "5000"
      heartbeat-interval: "500"
    snapshot: false
  kube-api:
    pod_security_policy: true
  kube-controller:
    extra_args:
      node-monitor-grace-period: "30s"
      node-monitor-period: "10s"
      pod-eviction-timeout: "30s"
  kubelet:
    extra_args:
      node-status-update-frequency: "5s"
    fail_swap_on: false
ssh_agent_auth: false
```
4) Add Node Pools. Currently no DHCP pool for CIDR - only one node per node pool per template is supported.
5) For the Node Pool name Prefix, type kubenode# (0-10), select the corresponding template, and check which roles you want for each node.
6) Copy the command displayed on screen to your clipboard.
7) Click Create


## FOLIO in Rancher/Kubernetes

### Set-up order overview (Our Rancher-exported YAML can be looked at under the YAML folder):

1) Create cluster via Rancher 2.0 with one or more nodes, using Canal network plugin. We are using VMware to provision Oracle Linux VMs at the moment
2) Create Folio-Project in Rancher 2.0 UI
3) Add folio-q4 Namespace for Folio-Project under Namespaces in Rancher 2.0 UI
4) Add Dockerhub and your private Docker registries to the Folio-Project
5) Add Persistent Volume on the cluster and Persistent Volume Claim for Folio-Project (We are using an NFS Share)<br/>

(The rest of these steps are from within the Folio-Project in Rancher 2.0)<br/>

6) Create db-config and db-connect Rancher Secrets under Folio-Project Resources - Secrets
7) Deploy crunchy-postgres Workload *Stateful set* via Helm Package, edit the Workload to tweak environment variables for use with Folio - with db-config Secret
8) Add Record under Service Discovery, named pg-folio, as type *Selector* with Label/Value: *statefulset.kubernetes.io/pod-name = pgset-0*
9) Deploy create-db Workload *Job* - built from our custom Docker container with DB init scripts - with db-connect Secret
10) Deploy Okapi Workload *Scalable deployment* of 1 and InitDB environment variable set to true - built from our custom Docker container
11) Deploy Folio module Workloads *Scalable deployment* between 1 and 3 (one Workload per Folio module) - with db-connect Secret for those modules that need a connection to the database
12) Deploy Stripes Workload *Run one pod on each node* – built from our custom Docker container
13) Create diku-tenant-config and x-okapi-token Rancher Secrets under Folio-Project - Resources - Secrets
14) Deploy create-tenant Workload *Job* – built from our custom Docker container with scripts - with diku-tenant-config Secret
15) Deploy create-deploy Workload *Job*, to enable modules for `/proxy/modules`, `/discovery/modules`, and diku tenant – built from our custom Docker container with scripts - with diku-tenant-config Secret
16) Deploy bootstrap-superuser Workload *Job* – built from our custom Docker container with scripts - with diku-tenant-config Secret
17) Deploy create-refdata Workload *Job* – built from our custom Docker container with scripts - with diku-tenant-config Secret
18) Deploy create-sampdata Workload *Job* – built from our custom Docker container with scripts - with x-okapi-token Secret
19) Edit Okapi Workload, set InitDB environment variable to false
20) Scale up Okapi pods to 3 using Rancher 2.0 + button
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
  name: hazelcast-rb-q4
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

-Each Rancher Secret should only be available to a single Namespace for security and separation. The Secrets below were made available to the folio-q4 Namespace.<br/>

#### db-config Secret key-value pairs:

PG_DATABASE = okapi<br/>
PG_PASSWORD = okapi25<br/>
PG_PRIMARY_PASSWORD = password<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_ROOT_PASSWORD = password<br/>
PG_USER = okapi

#### db-connect Secret key-value pairs:

DB_DATABASE = okapi_modules<br/>
DB_HOST = pg-folio<br/>
DB_MAXPOOLSIZE = 20<br/>
DB_PASSWORD = password<br/>
DB_PORT = 5432<br/>
DB_USERNAME = folio_admin<br/>
PG_DATABASE = okapi<br/>
PG_PASSWORD = password<br/>
PG_USER = okapi

#### diku-tenant-config Secret key-value pairs:

ADMIN_PASSWORD = admin<br/>
ADMIN_USER = diku_admin<br/>
OKAPI_URL = http://okapi:9130<br/>
TENANT_DESC = Danish Library Technology Institute<br/>
TENANT_ID = diku<br/>
TENANT_NAME = Datalogisk Institut

#### x-okapi-token Secret Key-Value pairs:

X_OKAPI_TOKEN = *Authentication token from Okapi*


### Okapi Notes:

-Running in *clustered* mode.<br/>
-Workload running as 3 pods that share database (Run as uneven numbers for quorum).<br/>
-Initially spin up one Okapi pod, do the deployment jobs, then can scale out Okapi's pods for clustering and they will each pick up the tenants/discovery/proxy services.<br/>
-After single Okapi pod has been initialized, set Workload environment variable for InitDB to false for future pod scalability.<br/>
-*ClusterIP* port mapping for Okapi port 9130, Hazelcast ports (5701 - 5704) and OKAPI_CLUSTERHOST environment variable set to the *ClusterIP* Rancher/K8s assigns in Service Discovery.<br/>

#### Okapi Workload environment variables:
  
PG_HOST = pg-folio<br/>
OKAPI_URL = http://okapi:9130<br/>
OKAPI_PORT = 9130<br/>
OKAPI_NODENAME = okapi1<br/>
OKAPI_LOGLEVEL = INFO<br/>
OKAPI_HOST = okapi<br/>
OKAPI_CLUSTERHOST = xx.xx.x.xxx (Insert ClusterIP Kubernetes assigns the service)<br/>
INITDB = false<br/>
HAZELCAST_VERTX_PORT = 5703<br/>
HAZELCAST_PORT = 5701<br/>
HAZELCAST_IP = xx.xx.x.xxx (Insert ClusterIP Kubernetes assigns the service)<br/>


### HA Postgres in Kubernetes/Rancher Notes:

-Currently testing out crunchy-postgres Helm Chart HA Kubernetes solution.<br/>
-Running as a Kubernetes *Stateful Set*, with one primary and two replica pods. Replica pods are read-only.<br/>
-For Postgres *Service Discovery*, created a *Selector* type called *pg-folio* that targets the master pgset-0 Postgres pod via a label.<br/>
-Using a *Persistent Volume Claim* for Rancher Folio-Project, which is a 10GB NFS share on our Netapp filer.<br/>
-Not sure if we would run like this in Production yet, as we haven't load tested it. It is a possibility for those looking for a complete Rancher/Kubernetes/Container solution, and being actively developed.<br/>

#### Persistent Volume NFS share mount options:

sync<br/>
hard<br/>
noac<br/>
fg<br/>
suid<br/>
rsize=8192<br/>
wsize=8192<br/>

#### Crunchy-postgres Workload environment variables:

WORK_MEM = 4MB<br/>
PGHOST = /tmp<br/>
PGDATA_PATH_OVERRIDE = folio-data<br/>
PG_USER = okapi<br/>
PG_ROOT_PASSWORD = postgres<br/>
PG_REPLICA_HOST = pgset-replica<br/>
PG_PRIMARY_USER = primaryuser<br/>
PG_PRIMARY_PORT = 5432<br/>
PG_PRIMARY_PASSWORD = Primaryuser-set-password<br/>
PG_PRIMARY_HOST = pgset-primary<br/>
PG_PASSWORD = okapi25<br/>
PG_MODE = set<br/>
PG_LOCALE = en_US.UTF-8<br/>
PG_DATABASE = okapi<br/>
MAX_CONNECTIONS = 500<br/>
ARCHIVE_MODE = off<br/>
CRUNCHY_DEBUG = FALSE<br/>
TEMP_BUFFERS = 16MB<br/>
SHARED_BUFFERS = 128MB<br/>
MAX_WAL_SENDERS = 2<br/>


### Workload Notes

#### Modules that require a database Workload environment variables:

DB_USERNAME = folio_admin<br/>
DB_PORT = 5432<br/>
DB_PASSWORD = folio_admin<br/>
DB_HOST = pg-folio<br/>
DB_DATABASE = okapi_modules<br/>
DB_MAXPOOLSIZE = 20<br/>

#### mod-authtoken Workload environment variable:

JAVA_OPTIONS = -Djwt.signing.key=CorrectBatteryHorseStaple

#### mod-inventory Workload environment variable:

JAVA_OPTIONS = -Dorg.folio.metadata.inventory.storage.type=okapi

#### mod-kb-ebsco Workload environment variable:

EBSCO_RMAPI_BASE_URL = https://sandbox.ebsco.io

#### Module Java heap Workload environment variables:

JAVA_OPTIONS = -Xmx256m<br/>

Set for: *mod-authtoken, mod-login, mod-configuration, mod-users-bl, mod-login-saml, mod-user-import, mod-inventory, mod-circulation-storage, mod-circulation, mod-notify, mod-notes, mod-codex-inventory, mod-codex-ekb, mod-codex-mux, mod-vendors, mod-calendar, mod-finance, mod-feesfines, mod-tags, mod-orders-storage, mod-rtac*<br/>

JAVA_OPTIONS = -Xmx512m<br/>

Set for: *mod-permissions*, *mod-inventory-storage*<br/>

JAVA_OPTIONS = -Xmx384m<br/>

Set for: *mod-users*


### Ingress Notes:

-Have two URLs as A Records for the six worker Kubenodes.<br/>
-One URL is for proxying front-end Stripes and the other is for proxying Okapi traffic.<br/>
-The Okapi traffic URL is the URL used when building Stripes.<br/>
-When setting up Load Balancing/Ingress, target the Service name instead of Workload name if you have specific ports you have set in the Workload.<br/>
-For Okapi HA ingress, I have Okapi Service as the target at port 9130, with root path, `/` and `/_/` for the hostname folio-okapiq4.org<br/>

-To have default Rancher 2.0 Nginx ingress be a little smarter about DNS RR, add annotations in Rancher 2.0 GUI Service Discovery:<br/>

nginx.ingress.kubernetes.io/upstream-fail-timeout = 5<br/>
nginx.ingress.kubernetes.io/upstream-max-fails = 2<br/>
nginx.ingress.kubernetes.io/proxy-connect-timeout = 2<br/>

-To allow larger chunks of data, add annotations in Rancher 2.0 GUI Service Discovery:<br/>

nginx.ingress.kubernetes.io/client-body-buffer-size = 2M<br/>
nginx.ingress.kubernetes.io/proxy-body-size = 1g



## Pro Tips

#### Config and launch Kubernetes Cluster Dashboard from your workstation (On OSX: Save files and token in /Users/UserName/.kube/):

Run instructions from here: https://gist.github.com/superseb/3a9c0d2e4a60afa3689badb1297e2a44

#### Build, tag and push docker images from within their respective folders:

```docker build -t docker-private-registry/folio-project/containername:v1 .```<br/>
```docker push docker-private-registry/folio-project/containername:v1```<br/>

#### To clean existing Kubernetes cluster node for re-deployment run:

```docker stop $(docker ps -aq)```<br/>
```docker rm $(docker ps -aq)```<br/>
```docker rmi $(docker images -q)```<br/>
```docker volume prune```<br/>
```docker system prune```<br/>
```sudo rm -rf /var/lib/etcd /etc/kubernetes/ssl /etc/cni /opt/cni /var/lib/cni /var/run/calico /etc/kubernetes/.tmp/```<br/>
```systemctl restart docker```<br/>

#### To remove dangling images from nodes that have failed:

```docker rmi $(docker images -aq --filter dangling=true)```

#### To find out which orphaned Replicasets need deleting that have 0 pods (Run this in Rancher using Launch kubectl):

```kubectl get --all-namespaces rs -o json|jq -r '.items[] | select(.spec.replicas | contains(0)) | "kubectl delete rs --namespace=\(.metadata.namespace) \(.metadata.name)"'```

#### Enabling Recurring etcd Snapshots on the cluster:

RKE takes a snapshot of etcd running on each etcd node. The file is saved to /opt/rke/etcd-snapshots

#### When spinning up containers from Dockerhub, be sure the Workload `Advanced Option - Command` *Auto Restart* setting is set to *Always*

#### When creating Workloads, set min to 0 if you wish to scale your deployments to 0 - in Kubernetes Dashboard

#### Set `.spec.revisionHistoryLimit` in the Kubernetes Deployment to the number of old Replicasets you want to retain.

#### To avoid overloading your cluster, in case of node failure or Workload deployment - set resource limits! Do this under Workload - Show advanced options - Security & Host Config

