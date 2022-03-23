## YAML for deploying Folio R1 2021 back-end modules and clustered Okapi on Kubernetes/Rancher 2.x

All YAML assumes you are deploying in a namespace called `folio-r2`

### Kubernetes Secrets needed for configuring edge modules, Kafka, Elasticsearch, Okapi and database connections:

`db-connect`<br/>
`db-connect-okapi`<br/>
`edge-securestore-props`<br/>
`data-export-aws-config`<br/>
`mod-graphql`<br/>
`mod-pubsub`<br/>
`mod-search`<br/>

### Kubernetes ConfigMaps needed for configuring SIP2 modules:

`sip2-conf`<br/>
`sip2-tenants-conf`

### Kubernetes PV/PVCs needed for configuring mod-data-import/export modules to share cache space:

`storage-files-import`<br/>
`storage-files`

### Before you import!!!

-Edit the folio-r2-clustered-okapi.yaml file, and set your Docker registry, repo and image tag to pull Okapi from, here:<br/>

`image: <your_registry_IP_FQDN>/<repo>/okapi:<image_tag>`<br/>

-Edit the folio-r2-stripes.yaml file, and set your Docker registry, repo and image tag to pull Stripes from, here:<br/>

`image: <your_registry_IP_FQDN>/<repo>/stripes:<image_tag>`<br/>

-In the same folio-r2-clustered-okapi.yaml and folio-r2-stripes.yaml files, edit to point to the Registry Resource Secret in your Rancher environment, here:<br/>
```
imagePullSecrets:
 - name: <your_registry_secret>
```
### Importing folio-r2-clustered-okapi.yaml into the folio-r2 namespace does the following:

-Creates a secret called `db-connect-okapi` in the namespace you import to.<br/>
-Creates a ClusterRoleBinding service account named `hazelcast-rb-r2-2021` for K8s Hazelcast plug-in in the `folio-r2` namespace.<br/>
-Deploys a StatefulSet of 3 clustered Okapi pods in the namespace you import to.<br/>
-Once imported, you can edit the default values in the `db-connect-okapi` Secret to match your environment.

### Importing folio-r2-2021-workloads.yaml into the folio-r2 namespace does the following:

-Deploys 71 Workloads representing the folio q3 back-end, pulls the folioorg Docker containers for each.<br/>
-Creates the 71 Workload's Service Discovery/DNS Records.<br/>
-Those Workloads that connect to storage will be deployed as StatefulSets, one pod each.<br/>
-The edge-sip2 Workload gets deployed as a DaemonSet, one pod on every K8s worker node. It also exposes hostport on 7052.<br/>
-The mod-z3950 Workload gets deployed as a DaemonSet, one pod on every K8s worker node. It also exposes hostport on 7090.<br/>
-All other Workloads are deployed as scaleable Deployments, one pod each.
