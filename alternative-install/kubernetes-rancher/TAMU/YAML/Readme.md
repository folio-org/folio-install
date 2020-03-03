## YAML for deploying Folio Q4 2019 back-end modules and clustered Okapi on Kubernetes/Rancher 2.x

All YAML assumes you are deploying in a namespace called `folio-q4`

### Secrets needed for configuring edge modules, Okapi and database connections:

`connect-db`<br/>
`db-connect-okapi`<br/>
`edge-securestore-props`<br/>
`sip2-certs`

### Before you import!!!

-Edit the folio-q4-clustered-okapi.yaml file, and set your Docker registry to pull Okapi from, here:<br/>

`image: <your_registry_IP_FQDN>/folio/okapi:q4-2019`<br/>

-In the same folio-q4-clustered-okapi.yaml file, edit to point to the Registry Resource Secret in your Rancher environment, here:<br/>
```
imagePullSecrets:
 - name: <your_registry_secret>
```
### Importing folio-q4-clustered-okapi.yaml into the folio-q4 namespace does the following:

-Creates a secret called `db-connect-okapi` in the namespace you import to.<br/>
-Creates a ClusterRoleBinding service account named `hazelcast-rb-q4-2019` for K8s Hazelcast plug-in in the `folio-q4` namespace.<br/>
-Deploys a StatefulSet of 3 clustered Okapis in the namespace you import to.<br/>
-Once imported, you can edit the default values in the `db-connect-okapi` Secret to match your environment.

### Importing folio-q4-2019-workloads.yaml into the folio-q4 namespace does the following:

-Deploys 50 Workloads representing the Folio Q4 back-end Docker modules.<br/>
-Those Workloads that connect to storage will be deployed as StatefulSets.<br/>
-The edge-sip2 Workload gets deployed as a DaemonSet, one on every K8s worker node. It alse exposes hostport on 1024.<br/>
-All other Workloads are deployed as scaleable Deployments.
