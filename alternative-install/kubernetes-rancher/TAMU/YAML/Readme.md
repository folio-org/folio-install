## YAML for deploying Folio Q3 2020 back-end modules, Stripes webpack and clustered Okapi on Kubernetes/Rancher 2.x

All YAML assumes you are deploying in a namespace called `folio-q3`

### Secrets needed for configuring edge modules, Okapi and database connections:

`connect-db`<br/>
`db-connect-okapi`<br/>
`edge-securestore-props`<br/>
`sip2-certs`

### Before you import!!!

-Edit the folio-q3-2020-clustered-okapi.yaml and folio-q3-2020-stripes.yaml files to set your Docker registry, repo, image and image tag to pull Okapi and Stripes from, here:<br/>

`image: <your_registry_IP_FQDN>/<repo>/<image>:<image_tag>`<br/>

-In the same files, edit to point to the Registry Resource Secret in your Rancher environment, here:<br/>
```
imagePullSecrets:
 - name: <your_registry_secret>
```
### Importing folio-q3-2020-clustered-okapi.yaml into the namespace does the following:

-Creates a secret called `db-connect-okapi` in the namespace you import to.<br/>
-Creates a ClusterRoleBinding service account named `hazelcast-rb-q3-2020` for K8s Hazelcast plug-in in the `folio-q3` namespace.<br/>
-Deploys a StatefulSet of 3 clustered Okapi pods, on nodeport mapped to 9130, in the namespace you import to.<br/>
-Once imported, you can edit the default values in the `db-connect-okapi` Secret to match your environment.

### Importing folio-q3-2020-stripes.yaml into the namespace does the following:

-Deploys a DaemonSet, one pod on each worker node, on nodeport mapped to 3000, of the Stripes webpack on Nginx in the namespace you import to.<br/>

### Importing folio-q3-2020-workloads.yaml into the namespace does the following:

-Deploys 60+ Workloads representing the Folio Q3 2020 back-end, pulls the folioorg Docker containers for each.<br/>
-Creates the 50 Workload's Service Discovery/DNS Records.<br/>
-Those Workloads that connect to storage will be deployed as StatefulSets, one pod each.<br/>
-The edge-sip2 Workload gets deployed as a DaemonSet, one pod on every K8s worker node. It also exposes hostport on 1024.<br/>
-All other Workloads are deployed as scaleable Deployments, one pod each.
