## Perform these commands in Rancher via Launch kubectl

### Run:

```touch rbac.yaml```

```vi rbac.yaml```

### Copy into rbac.yaml:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hazelcast-rb-prod
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: default
  namespace: folio-prod
```

### Run:

```kubectl apply -f rbac.yaml```
