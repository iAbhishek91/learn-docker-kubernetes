# Kube-bench

- Its a open source tool from **aqua-security**.
- Perform automated checks in Kubernetes cluster to verify cluster is deployed as per security best practices
- It matches the CIS benchmarks

## Installation

- as Docker container
- as POD in a cluster
- as binary
- compile from source code

## Lab

```sh
## download kube bench
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.4.0/kube-bench_0.4.0_linux_amd64.tar.gz -o kube-bench_0.4.0_linux_amd64.tar.gz
tar -xvf kube-bench_0.4.0_linux_amd64.tar.gz

## run kube-bench
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml 

## Few remediation(important for on-prem clusters, for cloud managed clusters these managed and taken care by cloud)
# Edit the Controller Manager pod specification file /etc/kubernetes/manifests/kube-controller-manager.yaml
# on the master node and set the --terminated-pod-gc-threshold to an appropriate threshold,
# for example:
# --terminated-pod-gc-threshold=10


# 1.3.6 Edit the Controller Manager pod specification file /etc/kubernetes/manifests/kube-controller-manager.yaml
# on the master node and set the --feature-gates parameter to include RotateKubeletServerCertificate=true.
# --feature-gates=RotateKubeletServerCertificate=true

# Edit the Scheduler pod specification file /etc/kubernetes/manifests/kube-scheduler.yaml file
# on the master node and set the below parameter.
# --profiling=false
```
