# Monitoring and logging

## How do we find out breaches that have already been occurred

We use third party tools, is the simple answer. But if you want to know how it works, read below

- there are some suspicious activity like "cat /etc/shadow". or deleting something from access logs, or even accessing the shell of a pod "k exec -it"

Falco is one such example.

## Mutable and Immutable infrastructure

Infrastructure in which we can update of change software or packages. For example we can update nginx in a server(manual or automated). However, infrastructure where it cant be updated directly, we need to provision new infrastructure with update and delete the existing one is known as immutable infrastructure.

Why we are discussing this in Kubernetes? Mutable pods or containers are more exposed to attackers, we should make sure to minimize the attack surface.

**Few way to ensure immutability of containers**:

- Prevent: "k cp file_name pod_name:/file/path": make use of container level **securityContext.readOnlyRootFilesystem: true**, but this may break the application itself as application may need to write to certain into directory and this will make the pod to go in error state. To fix this please use mounted volume exactly where the pod writes. The volume type mostly can be EmptyDir as we don't want to persist the data. Now: all the commands which make use of filereadwrite wwould fail: "k exec -it nginx -- apt update", "k cp ..."
- Prevent running pods with **securityContext.privileged: true**. Even if we have readonly permission, we can still change some file system like proc: execute the command "k exec -it nginx -- bash -c "echo '75' > /proc/sys/vm/swappiness""
- Prevent pods to run as root user: "securityContext.runAsUser: 0"
- Prevent: "k exec -it nginx -- bash nginx:/etc/nginx"

## Auditing Kubernetes cluster

How to understand whats going on in the cluster? - how many resources are created, when it was created, who created etc, in which namespace it was created, ans where was this initiated from. etc

All these are known as events in Kubernetes. by default auditing is available but disabled(need to manually enable) and its managed by kube API server.

Manually enable auditing on "kube-apiServer", This is done by configuring backend where the audit will be written.

Two type of backend are supported as of 1.20 version: **file on controlplane node**, **webhook to some other system** - such as falco.(as part of CKS webhook are not included)

```sh
# in kubeadm based setup pass the below flag
-- audit-log-path=/var/log/k8-audit.log
-- audit-policy-file=/etc/kubernetes/audit-policy.yaml # policy is defined below
-- audit-log-maxage=10 # optional, if want to delete the audit log after few days (in this case its 10 days)
-- audit-log-maxbackup=5 # optional, number of audit files to be retained on the host
-- audit-log-maxsize=100 # optional, maximum size of each audit file, before its rotated.

# also need to add volume for the log-path and policy-file

```

There are **four stages** when an request is made to kube API server. They are as follow:

- RequestReceived
- ResponseStarted
- ResponseComplete
- Panic

This is too much information, our goal is to audit only request that are requeired by us only.

To achieve this we create a policyObject in kubernetes:

```yaml
# This policy is not applied (k create -f), rather passed to kubernetes API server.
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"] # request received stage autit is omitted
rules:
# FIRST RULE
- namespaces: ["prod-namespace"] # this is an optional field in rule block, if omitted then we it consider for all namespaces.
  verbs: ["delete"] # this is an optional field in rule block, if omitted then we consider all actions/operations
  resources:
  - groups: " " # mention the apiGroup that the resources belong to
    resources: ["pod"] # specific resources in the apigroup
    resourceName: ["webapp-prod"] # optional, if not defined, then all resources are selected
  ## Level of logging required if above event occur  
  # None - nothing is logged
  # Metadata: least verbose level, only the metadata is logged(timestamp, resources, namespace)
  # Request: logs both metadata and request body
  # RequestResponse: logs metadata, request and response
  level: None
# SECOND RULE
- resources:
  - group: " "
    resources: ["Secrets"]
  level: Metadata
```
