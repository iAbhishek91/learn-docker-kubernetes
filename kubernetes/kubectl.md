# commands

## kubectl create

This cretes a pod/replicaset/ replica controller/deployment/services based on the `kind` attribute in the kubernetes object(the yml file): **kubectl create -f pod-definition.yaml**

## kubectl run hello-minikube

basic run command syntax **kubectl run `<podname>` --image `<container-name>`**

## kubectl cluster info

## kubectl get

get info about everything: **kubectl get all**

get info about pods :

- **kubectl get pods**
- **kubectl get pods --all-namespaces** make sure kube-dns service is running.
- **kubectl get pods -o wide** similar to `get pods` command, but it give IP and node info as well.

get info about nodes: **kubectl get nodes**

get info about replication contoller: **kubectl get replicationcontroller**

get info about replica set: **kubectl get replicaset**

get info about deployment: **kubectl get deployments**

get info about services: **kubectl get services**

## kubectl describe

get detail information about pods **kubectl describe pods**

## kubectl delete

delete already running deployment **kubectl delete deployment nginx**
