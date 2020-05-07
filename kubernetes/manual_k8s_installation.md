## install the below packages

The below are all binaries:

- keep it under /usr/lib/bin
- provide +x access

wget -q --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"

## config

API server:

no kubeconfig for API server.

## Test the server daily

```sh
#below are required to define in ~/.bashrc
# for kubectl
export KUBECONFIG=/home/rancher/admin.kubeconfig
```

```sh
# kubectl
k get componentstatuses
curl -i http://127.0.0.1:8080/healthz
```

> For etcd refer: ./etcd directory

## How kubelet and api-server connect with each other

Kubelet is the one which informs k8s as nodes. The node which do not have kubelet installed will not be shown up in command `k get nodes`
