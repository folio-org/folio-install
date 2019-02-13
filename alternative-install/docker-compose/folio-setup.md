# Rancher and AWS EKS Cluster FOLIO Installation

### FOLIO Cluster Project and Namespace

1. Rancher Project Creation

        $ rancher project create folio

2. Rancher Context Switch

        $ rancher context switch
        NUMBER    CLUSTER NAME   PROJECT ID        PROJECT NAME   PROJECT DESCRIPTION
        1         libapps        c-67749:p-cqxp9   System         System  ...
        2         libapps        c-67749:p-v9rnk   folio
        3         libapps        c-67749:p-vb2c7   Default        Default ...
        Select a Project:2
        INFO[0222] Setting new context to project folio
        INFO[0222] Saving config to /Users/mast4541/.rancher/cli2.json

3. Rancher Create Namespace

        $ rancher namespace create q4-core --description "q4 2018 core"
        $ rancher namespace ls

        ID        NAME      STATE     PROJECT           DESCRIPTION
        q4-core   q4-core   active    c-67749:p-v9rnk   q4 2018 core

4. Documentation Project and Namespace
    * [Projects and Namespace](https://rancher.com/docs/rancher/v2.x/en/k8s-in-rancher/projects-and-namespaces/)

### FOLIO Installation

FOLIO installation will be deployed using the `libapps` cluster created within the [Rancher Setup Document]("rancher-setup.md"). The cluster has a `folio` project with `q4-core` namespace.

1. Automatic Generation of Kubernetes YAML files

        $ cd deployments/folio-backend

2. Check Config and Build Variable files
    * folio-variables.env
    * config folder

3. Github repository `folio-org/folio-ansible`
Navigate to `q4-2018` branch and click `group_vars`. Within this folder select the `release-core` YAML file. Copy the raw URL.  

        $ ./createK8sYaml "https://raw.githubusercontent.com/folio-org/folio-ansible/q4-2018/group_vars/release-core"

3. Docker Compose Build and Push

        $ cd folio-release/q4-2018/release-core
        $ docker-compose build
        $ docker-compose push

4. Double Check Rancher Project and Namespace

        $ rancher context current
        Cluster:libapps Project:folio

        $ rancher namespace ls
        ID        NAME      STATE     PROJECT           DESCRIPTION
        q4-core   q4-core   active    c-67749:p-v9rnk   q4 2018 core
        q4-full   q4-full   active    c-67749:p-v9rnk   q4 2018 full

5. Deploy Kubernetes Workload
    * Cluster Role-based access control(RBAC) for Okapi hazelcast

            $ rancher kubectl create -f rbac.yaml

    * Deploy FOLIO

            $ cd kompose/
            $ rancher kubectl create -f . -n q4-core

    * Update Configmap change HAZELCAST_IP and OKAPI_CLUSTERHOST

            $ cd ..
            $ chmod +x updateOkapiConfigmap
            $ ./updateOkapiConfigmap


rbac.yaml
kubectl get ClusterRoleBinding

kubectl scale deploy my-awesome-deployment --replicas=0

get IP
rancher kubectl get services -n q4-core | grep okapi| awk '{print $3}'
