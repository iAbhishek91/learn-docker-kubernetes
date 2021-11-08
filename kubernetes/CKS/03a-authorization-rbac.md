# Authorization

Authorization is performed by API-server it self after *authentication* phase.

Like,authentication, authorization phases consist of different plugins, k8s admin can enable multiple way to authorize by providing this in the k8s API-server configuration - **--authorization-mode=AlwaysAllow**

Multiple option can be defined by providing comma separated value, the corresponding plugins are then used in order they are specified:
**--authorization-mode=Node,RBAC,Webhook**

>NOTE: to authorize we need to be allowed by only one plugin, next one are skipped.

Common Authorization modes: AlwaysAllow(default option), AlwaysDeny, Node, ABAC, RBAC webhook

## Role and ClusterRole

Each role have rules, and each rules have following section:

- rules contains: **apiGroups**, **resources**, **verb**. NOTE for core group leave the apiGroup blank, for other specify the group name.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "get", "create", "update", describe"]
  resourceNames: ["blue", "green", "yellow"]# this also restrict which user can access what type of pods, uncommon config majorly not used
- apiGroups: [""]
  resources: ["ConfigMap"]
  verbs: ["create"]
```

## RoleBinding and ClusterRoleBinding

connects user/sa/group with a role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devuser-developer-binding
subjects: # use details goes here
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef: # roles are bound, note we can only use only role per roleBinding
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

## Validate RBAC

```sh
# SYNTAX: k auth can-i <action> resource
k auth can-i create po
k auth can-i get nodes
k auth can-i delete sa

# impersonate any user
k auth can-i create deployments --as dev-user
k auth can-i create pods --as dev-user

# impersonate in a namespace
k auth can-i create po --as dev-user -n application-1
```
