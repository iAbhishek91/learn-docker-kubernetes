# DNS

Name resolution service of k8s

Before Kubernetes version 1.11, the Kubernetes DNS service was based on kube-dns. Version 1.11 introduced CoreDNS to address some security and stability concerns with kube-dns.

Regardless of the software handling the actual DNS records, both implementations work in a similar manner:

A service named kube-dns and one or more pods are created.
The kube-dns service listens for service and endpoint events from the Kubernetes API and updates its DNS records as needed. These events are triggered when you create, update or delete Kubernetes services and their associated pods.
kubelet sets each new pod’s /etc/resolv.conf nameserver option to the cluster IP of the kube-dns service, with appropriate search options to allow for shorter hostnames to be used:

resolv.conf
nameserver 10.32.0.10
search namespace.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
Applications running in containers can then resolve hostnames such as example-service.namespace into the correct cluster IP addresses.

https://www.digitalocean.com/community/tutorials/an-introduction-to-the-kubernetes-dns-service