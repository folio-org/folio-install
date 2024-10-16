## YAML for deploying FOLIO back-end modules, clustered Okapi, and Stripes on Kubernetes/Rancher 2.x

All YAML assumes you are deploying in a namespace called `folio-prod`, Okapi is reachable at `http://okapi:9130` and Kafka is reachable at `http://kafka-prod`. Please find-and-replace these values for your environment if they are different.

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

-Edit the folio-prod-clustered-okapi.yaml file, and set your Docker registry, repo and image tag to pull Okapi from, here:<br/>

`image: <your_registry_IP_FQDN>/<repo>/okapi:<image_tag>`<br/>

-Edit the folio-prod-stripes.yaml file, and set your Docker registry, repo and image tag to pull Stripes from, here:<br/>

`image: <your_registry_IP_FQDN>/<repo>/stripes:<image_tag>`<br/>

-In the same folio-prod-clustered-okapi.yaml and folio-prod-stripes.yaml files, edit to point to the Registry Resource Secret in your Rancher environment, here:<br/>
```
imagePullSecrets:
 - name: <your_registry_secret>
```
### Importing folio-prod-clustered-okapi.yaml into the folio-prod namespace does the following:

-Creates a secret called `db-connect-okapi` in the namespace you import to.<br/>
-Creates a ClusterRoleBinding service account named `hazelcast-rb-prod` for K8s Hazelcast plug-in in the `folio-prod` namespace.<br/>
-Deploys a StatefulSet of 3 clustered Okapi pods in the namespace you import to.<br/>
-Once imported, you can edit the default values in the `db-connect-okapi` Secret to match your environment.

### Importing folio-prod-workloads.yaml into the folio-prod namespace does the following:

-Deploys 71 Workloads representing the FOLIO back-end, pulls the FOLIO org's Docker containers for each.<br/>
-Creates the 71 Workload's Service Discovery/DNS Records for Rancher to use.<br/>
-Those Workloads that connect to storage will be deployed as StatefulSets, one pod each.<br/>
-The edge-sip2 Workload gets deployed as a DaemonSet, one pod on every K8s worker node. It also exposes hostport on 7052.<br/>
-The mod-z3950 Workload gets deployed as a DaemonSet, one pod on every K8s worker node. It also exposes hostport on 7090.<br/>
-All other Workloads are deployed as scaleable Deployments, one pod each.
