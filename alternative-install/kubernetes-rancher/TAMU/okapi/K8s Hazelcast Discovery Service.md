## Perform these commands in Rancher via Launch kubectl

### Run:

```touch rbac.yaml```

```vi rbac.yaml```

### Copy into rbac.yaml:

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
  namespace: folio-q3-2020
```

### Run:

```kubectl apply -f rbac.yaml```
