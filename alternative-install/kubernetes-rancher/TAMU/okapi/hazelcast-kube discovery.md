#Perform these commands in Rancher via Launch kubectl

#Run:

``touch rbac.yaml
vi rbac.yaml``

#Copy:

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hazelcast-rb-q32-2019
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: default
  namespace: folio-q32-2019

#Run:

``kubectl apply -f rbac.yaml``
