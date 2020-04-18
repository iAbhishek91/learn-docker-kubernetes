# commands

## kubectl api-resources

Lists all resources of **kubectl api-resources**.

Important to note some common thing about k8s resources:

- some resources falls under a names space, some do not. Pods are, but certificatesigningrequests are not.
- All resources end with "s" (plural) and are in small letter. eg pods, services, certificatesigningrequests.

## kubectl cluster info

displays the description of cluster. **kubectl cluster-info dump**, **kubectl cluster-info --help**

```sh
kubectl cluster-info

# OUTPUT
# Kubernetes master is running at https://192.168.1.248:8443
# KubeDNS is running at https://192.168.1.248:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## kubectl create

This cretes a resource based on the `kind` attribute in the kubernetes object(the yml or json file): **kubectl create -f pod-definition.yaml**

## kubectl run

Create and run a particular image.

basic run command syntax **kubectl run `<podname>` --image `<container-name>`**

## kubectl get

read **kubectl get --help**

get info about everything: **kubectl get all --all-namespaces**

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

- **kubectl get pods** this may not show any resources.
- **kubectl get pods --all-namespaces** make sure kube-dns service is running.
- **kubectl get pods -o wide** similar to `get pods` command, but it give IP and node info as well.
- **kubectl get pods --all-namespace -o jsonpath="{...image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c** to get the list of images running on the k8s cluster.

> Note: there are several way to access info about pods please refer [github](https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/)

get info about namespace: **kubectl get ns**
get info about nodes: **kubectl get nodes**

get info about replication controller: **kubectl get replicationcontroller**

```sh
kubectl get replicationcontroller -o wide

# OUTPUT
# NAME    DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES        SELECTOR
# kubia   1         1         0       53m   kubia        luska/kubia   run=kubia
```

get info about replica set: **kubectl get replicaset**

get info about deployment: **kubectl get deployments**

get info about services: **kubectl get services**

## kubectl describe

get detail information about pods **kubectl describe pods**

## kubectl delete

delete already running deployment **kubectl delete deployment nginx**

```sh
kubectl delete pod kubia-7hzsz

# pod "kubia-7hzsz" deleted
```

> Important Note: When you delete a pod using the above command, automatically immediately a pod is created by Kubernetes scheduler. Hence you really cant delete a pod (if not created manually)

```sh
kubectl get nodes # get the node name

# OUTPUT
# NAME      STATUS   ROLES    AGE    VERSION
# osboxes   Ready    master   176m   v1.17.2
kubectl get pods -o wide | grep <nodename> # get all the pods from a specific node, check the pod that you want to delete

# OUTPUT
# kubia-6bvfx   0/1     ImagePullBackOff   0          11m   172.17.0.6   osboxes   <none>           <none>
kubectl cordon <node-name> # set the node to be unschedulable

# OUTPUT
# node/osboxes cordoned
```

## JSON path

[kubernetes](https://kubernetes.io/docs/reference/kubectl/jsonpath/) this is to extract information from the json input.

Written by me to find pod and containers inside a kubernetes cluster

```sh
kubectl get pods --all-namespaces -o jsonpath="{range.items[*]}[{.metadata.name},{.spec.containers[*].image}]" | tr -s '][' '\n' | tr -s ',' '\t\t\t' | sort
```
