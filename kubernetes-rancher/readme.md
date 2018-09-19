# Folio on Kubernetes/Rancher 2.0

## License

Copyright (C) 2016-2018 The Open Library Foundation

This software is distributed under the terms of the Apache License, Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

A collection of Dockerfiles and YAML for FOLIO Q2 installation on Kubernetes/Rancher 2.0.

## Contents

* [Minikube deployment notes](Folio_MiniKube_Notes.md)
* [Okapi Dockerfile Readme](https://github.com/folio-org/folio-install/blob/kube-rancher/kubernetes-rancher/okapi/Readme.md)



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

#### In Oralce Linux, install correct version of Docker:

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



## FOLIO in Kubernetes



### Set-up order overview (Our Rancher-exported YAML can be looked at under the YAML folder):

1) Create cluster via Rancher 2.0 with one or more nodes, using Canal network plugin. We are using VMware to provision Oracle Linux VMs at the moment
2) Create Folio-Project in Rancher 2.0 UI
3) Add folio-q2 Namespace for Folio-Project under Namespaces in Rancher 2.0 UI
4) Add Dockerhub and your private Docker registries to the Folio-Project
5) Add Persistent Volume on the cluster and Persistent Volume Claim for Folio-Project (We are using an NFS Share)
(The rest of these steps are from within the Folio-Project in Rancher 2.0)
6) Deploy crunchy-postgres Workload *Stateful set* via Helm Package, edit the Workload to tweak environment variables for use with Folio
7) Add Record under Service Discovery, named pg-folio, as type *Selector* with Label/Value: *statefulset.kubernetes.io/pod-name = pgset-0*
8) Deploy create-db Workload *Job* - our custom Docker container with DB init scripts
9) Deploy Okapi Workload *Scalable deployment* of 1 - our custom Docker container
10) Deploy Folio module Workloads *Scalable deployment* of 3 (one Workload per Folio module)
11) Deploy Stripes Workload *Run one pod on each node* – our custom Docker container
12) Deploy create-tenant/create-deploy Workload *Job* – our custom Docker container with scripts
13) Edit Okapi Workload, set InitDB environment variable to false
14) Scale up Okapi pods to 3 using Rancher 2.0 + button
15) Add Ingress under Load Balancing for Okapi and Stripes using URLs for `/` and `/_/`

### Okapi Notes:

-Running in "clustered mode", but is not currently clustering.<br/>
-Workload running as 3 pods that share database.<br/>
-Initially spin up one Okapi pod, do the deployment jobs, then can scale out Okapi's pods and they will each pick up the tenants/discovery/proxy services.<br/>
-After single Okapi pod has been initialized, set Workload environment variable for InitDB to false for future pod scalability.<br/>
-Running Okapi with 'ClusterIP' type of port mapping, and Clusterhost IP environment variable set to the assigned 'ClusterIP' of the service as given by Kubernetes/Rancher.<br/>

#### Okapi Workload environment variables:
	
PG_HOST	= pg-folio<br/>
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

-Currently testing out crunchy-postgres HA Kubernetes solution.<br/>
-Running as a Kubernetes 'Stateful Set', with one primary and two replica pods. Replica pods are read-only.<br/>
-For Postgres 'Service Discovery', created a 'Selector' type called ‘pg-folio’ that targets the master pgset-0 Postgres pod via a label.<br/>
-Using a 'Persistent Volume Claim' for Rancher Folio Project, which is a 10GB NFS share on our Netapp filer.<br/>
-Not sure if we would run like this in Production yet, as we haven't load tested it. It is a possibility for those looking for a complete Kubernetes/Container solution and being actively developed out more.<br/>

#### Persistent Volume NFS share mount options:

sync<br/>
hard<br/>
lookupcache=none<br/>

#### Crunchy-postgres Workload environment variables:

WORK_MEM = 4<br/>
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
MAX_CONNECTIONS = 200<br/>
ARCHIVE_MODE = off<br/>
CRUNCHY_DEBUG = FALSE<br/>

#### Modules that require a database Workload environment variables:

db.username = folio_admin<br/>
db.port = 5432<br/>
db.password = folio_admin<br/>
db.host = pg-folio<br/>
db.database = okapi_modules<br/>

#### mod-authtoken Workload environment variable:

JAVA_OPTIONS = -Djwt.signing.key=CorrectBatteryHorseStaple


### Ingress Notes:

-Have two URLs as A Records for the three Kube nodes.<br/>
-One URL is for proxying front-end and the other is for proxying Okapi traffic.<br/>
-The Okapi traffic URL is the URL used when building Stripes.<br/>
-When setting up Load Balancing/Ingress, target the Service name instead of Workload name if you have specific ports you have set in the Workload.<br/>
-To have default Rancher 2.0 nginx ingress be a little more smart about DNS round-robin, add annotations in Rancher 2.0 GUI Service Discovery for Okapi and Stripes:

nginx.ingress.kubernetes.io/upstream-fail-timeout = 1<br/>
nginx.ingress.kubernetes.io/upstream-max-fails = 2


## Pro Tips


#### Config and launch Kubernetes Cluster Dashboard from your workstation (Save files and token on iMac in /Users/UserName/.kube/):

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

#### When spinning up containers from Dockerhub, be sure the Workload `Advanced Option - Command` *Auto Restart* setting is set to *Always*

#### When creating Workloads, set min to 0 if you wish to scale your deployments to 0 - in Kubernetes Dashboard

#### When using crunchy-postgres, need to execute this command on the Kubernetes cluster for the pgset-sa service account:

```kubectl create clusterrolebinding pgset-sa --clusterrole=admin --serviceaccount=folio-q2:pgset-sa --namespace=folio-q2```

#### To find out which orphaned Replicasets need deleting that have 0 pods (Run this in Rancher using Launch kubectl):

```kubectl get --all-namespaces rs -o json|jq -r '.items[] | select(.spec.replicas | contains(0)) | "kubectl delete rs --namespace=\(.metadata.namespace) \(.metadata.name)"'```

#### Set `.spec.revisionHistoryLimit` in the Kubernetes Deployment to the number of old Replicasets you want to retain.

