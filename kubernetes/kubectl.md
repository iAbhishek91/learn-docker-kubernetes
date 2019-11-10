# commands

## kubectl create

This cretes a pod/replicaset/ replica controller/deployment/services based on the `kind` attribute in the kubernetes object(the yml file): **kubectl create -f pod-definition.yaml**

## kubectl run hello-minikube

basic run command syntax **kubectl run `<podname>` --image `<container-name>`**

## kubectl cluster info

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

get info about replica set: **kubectl get replicaset**

get info about deployment: **kubectl get deployments**

get info about services: **kubectl get services**

## kubectl describe

get detail information about pods **kubectl describe pods**

## kubectl delete

delete already running deployment **kubectl delete deployment nginx**

## kubectl cluster-info

displays the description of cluster. **kubectl cluster-info --help**, **kubectl cluster-info dump**, **kubectl cluster-info --help**

## JSON path

[kubernetes](https://kubernetes.io/docs/reference/kubectl/jsonpath/) this is to extract information from the json input.

Written by me to find pod and containers inside a kubernetes cluster

```sh
kubectl get pods --all-namespaces -o jsonpath="{range.items[*]}[{.metadata.name},{.spec.containers[*].image}]" | tr -s '][' '\n' | tr -s ',' '\t\t\t' | sort
```
