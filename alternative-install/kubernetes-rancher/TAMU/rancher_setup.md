# Setup Rancher 2.x/Kubernetes Cluster

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
# 
# Cluster Config
# 
default_pod_security_policy_template_id: unrestricted
docker_root_dir: /var/lib/docker
enable_cluster_alerting: true
enable_cluster_monitoring: true
enable_network_policy: true
local_cluster_auth_endpoint:
  enabled: false
# 
# Rancher Config
# 
rancher_kubernetes_engine_config:
  addon_job_timeout: 30
  addons: |-
    ---
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: vsphere-datastore
    provisioner: kubernetes.io/vsphere-volume
    reclaimPolicy: Delete
    parameters:
      diskformat: thin
      datastore: kube
      fstype: xfs
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: admin-user
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: admin-user
      namespace: kubernetes-dashboard
  addons_include:
    - >-
      https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
  authentication:
    strategy: x509
  cloud_provider:
    name: vsphere
    vsphere_cloud_provider:
      global:
        datacenters: 'DC1, DC2'
        insecure-flag: true
        soap-roundtrip-count: 0
        user: 'rancher'
        password: 'password'
      virtual_center:
        vsphere.org:
          datacenters: 'DC1, DC2'
          soap-roundtrip-count: 0
      workspace:
        datacenter: DC1
        default-datastore: kube
        folder: /DC1/vms/Linux
        server: vsphere.org
  ignore_docker_version: true
# 
# # Currently only nginx ingress provider is supported.
# # To disable ingress controller, set `provider: none`
# # To enable ingress on specific nodes, use the node_selector, eg:
#    provider: nginx
#    node_selector:
#      app: ingress
# 
  ingress:
    http_port: 0
    https_port: 0
    options:
      compute-full-forwarded-for: 'true'
      hsts-include-subdomains: 'false'
      hsts-max-age: '31536000'
      use-forwarded-headers: 'true'
    provider: nginx
  kubernetes_version: v1.18.20-rancher1-1
  monitoring:
    provider: metrics-server
    replicas: 1
# 
#   If you are using calico on AWS
# 
#    network:
#      plugin: calico
#      calico_network_provider:
#        cloud_provider: aws
# 
# # To specify flannel interface
# 
#    network:
#      plugin: flannel
#      flannel_network_provider:
#      iface: eth1
# 
# # To specify flannel interface for canal plugin
# 
#    network:
#      plugin: canal
#      canal_network_provider:
#        iface: eth1
# 
  network:
    mtu: 0
    options:
      flannel_backend_type: vxlan
    plugin: canal
# 
#    services:
#      kube-api:
#        service_cluster_ip_range: 10.43.0.0/16
#      kube-controller:
#        cluster_cidr: 10.42.0.0/16
#        service_cluster_ip_range: 10.43.0.0/16
#      kubelet:
#        cluster_domain: cluster.local
#        cluster_dns_server: 10.43.0.10
# 
  services:
    etcd:
      backup_config:
        enabled: true
        interval_hours: 12
        retention: 14
        safe_timestamp: false
        timeout: 300
      creation: 12h
      extra_args:
        election-timeout: '5000'
        heartbeat-interval: '500'
      gid: 0
      retention: 72h
      snapshot: false
      uid: 0
    kube_api:
      always_pull_images: false
      extra_args:
        default-not-ready-toleration-seconds: '60'
        default-unreachable-toleration-seconds: '120'
      pod_security_policy: true
      service_node_port_range: 30000-32767
    kube_controller:
      extra_args:
        node-monitor-grace-period: 60s
        node-monitor-period: 10s
        v: '3'
    kubelet:
      extra_args:
        node-status-update-frequency: 5s
      fail_swap_on: false
      generate_serving_certificate: false
  ssh_agent_auth: false
  upgrade_strategy:
    drain: false
    max_unavailable_controlplane: '1'
    max_unavailable_worker: 10%
    node_drain_input:
      delete_local_data: false
      force: false
      grace_period: -1
      ignore_daemon_sets: true
      timeout: 120
scheduled_cluster_scan:
  enabled: true
  scan_config:
    cis_scan_config:
      debug_master: false
      debug_worker: false
      override_benchmark_version: rke-cis-1.5
      profile: permissive
  schedule_config:
    cron_schedule: 0 19 * * *
    retention: 7
windows_prefered_cluster: false
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

#### To get a token for use against the cluster to authenticate with (Run this in Rancher using Launch kubectl):

```kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')```

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

