# commands

**k exec** /resources/docs/03_services.md
**k expose** /resources/docs/03_services.md
**k run** /resources/docs/01_pod.md
**k logs** /resources/docs/01_pod.md
**k port-forward** /resources/docs/01_pod.md
**k rollout** /resource/docs/06_deployment.md

---

Defined in this page

**k completion**,
**k version**,
**k option**,
**k api-resources**,
**k api-version**,
**k config**,
**k explain**,
**k cluster-info**,
**k create**,
**k edit**,
**k apply**,
**k replace**,
**k get**,
**k describe**,
**k delete**,
**k coredon**,
**k uncoredon**,

## k completion

```sh
#auto completion of kubectl command in bash or zsh
source <(kubectl completion bash | sed s/kubectl/k/g)
```

## k version

display the version of kubernetes running on client and server **k version** or **k version --client**
> Note its not version of kubernetes.

## k option

display global options that can be passed to any *k* commands.

## k api-resources

Lists all resources of **k api-resources** **k api-resources --sort-by=name**.

Important to note some common thing about k8s resources:

- some resources falls under a names space, some do not. Pods are, but certificatesigningrequests are not.
- All resources end with "s" (plural) and are in small letter. eg pods, services, certificatesigningrequests.

## k api-version

lists all the api-version available in group/version version.

**k api-version**.

## k config

TBD

## k explain

Explains the fields in supported resources.

```sh
# explain all the fields of pod resource
k explain po
# explain resource of older version
k explain po --api-version='v1'
# explains fields of field recursively (currently only one level deep)
k explain po --recursive
# explain certain section of resource
k explain po.spec
```

## k cluster info

displays the description of cluster. **k cluster-info dump**, **k cluster-info**

```sh
k cluster-info

# OUTPUT
# Kubernetes master is running at https://192.168.1.248:8443
# KubeDNS is running at https://192.168.1.248:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

dump will give massive details about the cluster.

## k create

This creates a resource based on the `kind` attribute in the kubernetes object(the yml or json file):

**POST call**, where as apply makes a **PUT call**(PUT is idempotent) to the API server.  

its always better to --validate && --dry-run && -o yaml

```sh
# create a resource from a file
k create -f pod-definition.yaml
# create a resource from a stdin
cat pod.json | k create -f -
# dry run and don't create the resource
k create -f pod-def.yaml --dry-run='client'
#  validate before running, by default its set to true
k create -f pod-def.yml --validate
# create clusterrole --dryrun
k create clusterrole system:kube-apiserver-to-kubelet --dry-run=true --verb="*" --resource=node/proxy,nodes/stats,node/log,nodes/spec,node/metrices --validate=true -o yaml > generated_clusterrole.yml
# create a clusterrolebinding using the above cluster role
k create clusterrolebinding system:kube-apiserver --dry-run=true --validate=true --clusterrole=system:kube-apiserver-to-kubelet --user=kubenetes -o yaml
# create config map
k create configmap my-config-map --from-literal=firstname=abhishek --from-file=/path/to/the/file/or/dir
# create a secret: its similar to config map, but secret type is to be mentioned
k create secret generic my-secret --from...... same as above

```

> k create do nor provide generator is not available for pod. use k run my-pod --image=abdas81/k8s-metadata

## k edit

It all will update the resource in  a open window, and then automatically it will delete and create the pod again.

```sh
k edit po standalone-pod
```

## k apply

**PUT call**(PUT is idempotent), where as create makes a **POST call** to the API server.

Apply will not work if dynamic update of the filed is not allowed, this is mainly because, apply do not delete the existing deployment.

Almost same syntax like create

```sh
k apply -f pod.yml --dry-run=client --validate -o yaml
```

## k replace

same edit the file and the do replace

```sh
k replace -f rs.yaml
```

## k get

help of any k8s option **k get -h**

Display one or many resources.

Watch event for a specific node

```sh
k get all
k get events --watch -n jenkins
```

get info about everything: **k get all --all-namespaces| -A**

```sh
# OUTPUT: all k8s resources running for all namespaces.
NAMESPACE              NAME                                             READY   STATUS             RESTARTS   AGE
default                pod/abdas81-8h922                                1/1     Running            3          7d8h
default                pod/abdas81-vslms                                1/1     Running            3          7d6h
kube-system            pod/coredns-6955765f44-fws8c                     0/1     Running            3          8d
kube-system            pod/coredns-6955765f44-rwxbh                     0/1     Running            1          14h
kube-system            pod/coredns-7f85fdfc6b-vhtfv                     0/1     CrashLoopBackOff   181        14h
kube-system            pod/etcd-osboxes                                 1/1     Running            3          8d
kube-system            pod/kube-apiserver-osboxes                       1/1     Running            3          8d
kube-system            pod/kube-controller-manager-osboxes              1/1     Running            3          8d
kube-system            pod/kube-proxy-sswhj                             1/1     Running            3          8d
kube-system            pod/kube-scheduler-osboxes                       1/1     Running            3          8d
kube-system            pod/storage-provisioner                          1/1     Running            5          8d
kubernetes-dashboard   pod/dashboard-metrics-scraper-7b64584c5c-9dz8v   1/1     Running            3          8d
kubernetes-dashboard   pod/kubernetes-dashboard-79d9cd965-xfk6w         0/1     CrashLoopBackOff   776        8d

NAMESPACE   NAME                            DESIRED   CURRENT   READY   AGE
default     replicationcontroller/abdas81   2         2         2       7d8h

NAMESPACE              NAME                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default                service/abdas81-http                LoadBalancer   10.100.67.165    <pending>     1313:31712/TCP           7d8h
default                service/kubernetes                  ClusterIP      10.96.0.1        <none>        443/TCP                  8d
kube-system            service/kube-dns                    ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   8d
kubernetes-dashboard   service/dashboard-metrics-scraper   ClusterIP      10.100.189.189   <none>        8000/TCP                 8d
kubernetes-dashboard   service/kubernetes-dashboard        ClusterIP      10.107.101.241   <none>        80/TCP                   8d

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           beta.kubernetes.io/os=linux   8d

NAMESPACE              NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
kube-system            deployment.apps/coredns                     0/2     2            0           8d
kubernetes-dashboard   deployment.apps/dashboard-metrics-scraper   1/1     1            1           8d
kubernetes-dashboard   deployment.apps/kubernetes-dashboard        0/1     1            0           8d

NAMESPACE              NAME                                                   DESIRED   CURRENT   READY   AGE
kube-system            replicaset.apps/coredns-6955765f44                     2         2         0       8d
kube-system            replicaset.apps/coredns-7f85fdfc6b                     1         1         0       14h
kubernetes-dashboard   replicaset.apps/dashboard-metrics-scraper-7b64584c5c   1         1         1       8d
kubernetes-dashboard   replicaset.apps/kubernetes-dashboard-79d9cd965         1         1         0       8d
```

get info about only pods :

- **k get pods** this may not show any resources.
- **k get pods --all-namespaces** make sure kube-dns service is running.
- **k get pods -o wide** similar to `get pods` command, but it give IP and node info as well.
- **k get pods --all-namespace -o jsonpath="{...image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c** to get the list of images running on the k8s cluster. valid -o format. json|yaml|wide|name|custom-columns=...|custom-columns-file=...|go-template=...|go-template-file=...|jsonpath=...|jsonpath-file=...

use the below flag to mention the labels
--selector='': Selector (label query) to filter on, supports '=', '==', and '!='.(e.g. -l key1=value1,key2=value2)
> Note: there are several way to access info about pods please refer [github](https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/)

get info about namespace: **k get ns**
get info about nodes: **k get nodes**

get info about replication controller: **k get replicationcontroller**

```sh
k get replicationcontroller -o wide

# OUTPUT
# NAME    DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES        SELECTOR
# kubia   1         1         0       53m   kubia        luska/kubia   run=kubia
```

get info about replica set: **k get replicaset**

get info about deployment: **k get deployments**

get info about services: **k get services**

## k describe

get detail information about pods **k describe pods**

## k delete

delete already running deployment **k delete deployment nginx**

```sh
k delete pod kubia-7hzsz
# pod "kubia-7hzsz" deleted

k delete po --all -n default
# delete all the pod from the namespace

k delete namespaces jenkins
# namespace "jenkins" deleted
```

> Important Note: When you delete a pod using the above command, automatically immediately a pod is created by Kubernetes scheduler. Hence you really cant delete a pod (if not created manually)

```sh
k get nodes # get the node name

# OUTPUT
# NAME      STATUS   ROLES    AGE    VERSION
# osboxes   Ready    master   176m   v1.17.2
k get pods -o wide | grep <nodename> # get all the pods from a specific node, check the pod that you want to delete
```

## k cordon

```sh
# OUTPUT
# kubia-6bvfx   0/1     ImagePullBackOff   0          11m   172.17.0.6   osboxes   <none>           <none>
k cordon <node-name> # set the node to be unschedulable

# OUTPUT
# node/osboxes cordoned
```

## JSON path

[kubernetes](https://kubernetes.io/docs/reference/k/jsonpath/) this is to extract information from the json input.

Written by me to find pod and containers inside a kubernetes cluster

```sh
k get pods --all-namespaces -o jsonpath="{range.items[*]}[{.metadata.name},{.spec.containers[*].image}]" | tr -s '][' '\n' | tr -s ',' '\t\t\t' | sort
```

## imp command

```sh
k run nginx --image=nginx --generator=run-pod/v1

k delete po --all

k delete rs replicaset-1 replicaset-2

k scale rs new-replica-set --replicas=5
k scale deploy deployment-1 --replicas=3

# FAIL: --replicas is not there in create command
k create deploy deployment-1 --image=busybox --replicas=3

# should be string
commands:
  - "sleep"
  - "5000"

k create secret generic db-secret --from-literal=DB-HOST=sql01

k set image deploy/frontend simple-webapp=kodekloud/webapp-color:v3
```

service at own namespace can be accessed with name of the service and port
service at diff namespace can be accessed with "servicename.svc.cluster.local"
