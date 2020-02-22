# commands

## kubectl create

This cretes a pod/replicaset/ replica controller/deployment/services based on the `kind` attribute in the kubernetes object(the yml file): **kubectl create -f pod-definition.yaml**

## kubectl run hello-minikube

basic run command syntax **kubectl run `<podname>` --image `<container-name>`**

## kubectl cluster info

```sh
kubectl cluster-info

# OUTPUT
# Kubernetes master is running at https://192.168.1.248:8443
# KubeDNS is running at https://192.168.1.248:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## kubectl get

get info about everything: **kubectl get all**

get info about pods :

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

> Important Note: When you delete a pod using the above command, automatically immediately a pod is created by Kubernetes scheduler. Hence you really cant delete a pod. use the below command for that

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

## kubectl cluster-info

displays the description of cluster. **kubectl cluster-info --help**, **kubectl cluster-info dump**, **kubectl cluster-info --help**

## JSON path

[kubernetes](https://kubernetes.io/docs/reference/kubectl/jsonpath/) this is to extract information from the json input.

Written by me to find pod and containers inside a kubernetes cluster

```sh
kubectl get pods --all-namespaces -o jsonpath="{range.items[*]}[{.metadata.name},{.spec.containers[*].image}]" | tr -s '][' '\n' | tr -s ',' '\t\t\t' | sort
```
