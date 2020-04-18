# kubeadm

## Node configuration

After minikube this is the second cluster we are setting up. Note that in minikube we only had one node. However, in this scenario we have one master and multiple worker node.

Everything in minikube node configuration remains same. Apart from those configuration multi node cluster requires few more settings:

1. Make sure *MAC address is unique* for all the nodes. Mostly in VMs we face this issue.
2. Make sure your *VMs are direct clone*, and not linked cloned.
3. Make sure */sys/class/dmi/id/product_uuid is unique*. MAC address and product_uuid is used by k8s to distinguish different node.
4. *Adding kubernetes yum repo* at /etc/yum.repo.d/kubernetes.repo. Content of this file can be taken from kubernetes.io.
5. *br_netfilter should be active*. verify using `lsmod | grep br_netfilter`. Enable it `modprobe br_netfilter`.
6. Network configuration to make sure Kubernetes service is working properly

```sh
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

> Note for all the above step refer Kubernetes in action -Appendix B.

## Component to be installed

```sh
yum install -y docker kubelet kubectl kubeadm kubernetes-cni
```

> NOTE: Reason of installing all the above packages are detailed in Appendix-B of kubernetes in action.

## kubeadm init

```sh
[root@master osboxes]# kubeadm init
W0416 19:09:20.897590    2619 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.2
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master.k8s kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.158]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master.k8s localhost] and IPs [192.168.1.158 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master.k8s localhost] and IPs [192.168.1.158 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0416 19:09:49.109601    2619 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0416 19:09:49.110441    2619 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 22.503256 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master.k8s as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master.k8s as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: ugbltx.ukgawau0c5209b95
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.158:6443 --token ugbltx.ukgawau0c5209b95 \
    --discovery-token-ca-cert-hash sha256:6951e7437c5bac9828d1b771057795d172778cc7eb6bab44c29463e48c8a601f
```

## /etc/kubernetes/manifest

**Before** kubeadm init

```sh
[root@master osboxes]# ll -ats /etc/kubernetes/manifests/
total 0
```

**After** kubeadm init

```sh
[root@master osboxes]# ll -ats /etc/kubernetes/manifests/
total 24
4 drwxr-xr-x. 2 root root 4096 Apr 16 19:09 .
4 -rw-------. 1 root root 1858 Apr 16 19:09 etcd.yaml
4 -rw-------. 1 root root 2420 Apr 16 19:09 kube-controller-manager.yaml
4 -rw-------. 1 root root 1120 Apr 16 19:09 kube-scheduler.yaml
4 -rw-------. 1 root root 2709 Apr 16 19:09 kube-apiserver.yaml
4 drwxr-xr-x. 4 root root 4096 Apr 16 19:09 ..
```

## Kubectl config and list pods and nodes

```sh
[root@master osboxes]# echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
[root@master osboxes]# echo "alias k='kubectl'" >> ~/.bashrc
[root@master osboxes]# source ~/.bashrc
[root@master osboxes]# k get pods --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-5vmqm             0/1     Pending   0          7h
kube-system   coredns-66bff467f8-9nvns             0/1     Pending   0          7h
kube-system   etcd-master.k8s                      1/1     Running   1          7h
kube-system   kube-apiserver-master.k8s            1/1     Running   1          7h
kube-system   kube-controller-manager-master.k8s   1/1     Running   1          7h
kube-system   kube-proxy-rw2zp                     1/1     Running   1          7h
kube-system   kube-scheduler-master.k8s            1/1     Running   1          7h
[root@master osboxes]# k get nodes
NAME         STATUS     ROLES    AGE    VERSION
master.k8s   NotReady   master   7h3m   v1.18.1
```

## Worker node

kubeadm join on both the worker nodes.

```sh
[root@node1 osboxes]# kubeadm join 192.168.1.158:6443 --token ugbltx.ukgawau0c5209b95 \
>     --discovery-token-ca-cert-hash sha256:6951e7437c5bac9828d1b771057795d172778cc7eb6bab44c29463e48c8a601f
W0417 02:24:27.289064   12074 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
[root@node2 osboxes]# kubeadm join 192.168.1.158:6443 --token ugbltx.ukgawau0c5209b95 \
>     --discovery-token-ca-cert-hash sha256:6951e7437c5bac9828d1b771057795d172778cc7eb6bab44c29463e48c8a601f
W0417 02:25:57.972958   12165 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
[root@master osboxes]# k get nodes
NAME         STATUS     ROLES    AGE     VERSION
master.k8s   NotReady   master   7h17m   v1.18.1
node1.k8s    NotReady   <none>   3m22s   v1.18.1
node2.k8s    NotReady   <none>   118s    v1.18.1
```

### Nodes are not ready

In the above section we saw the none of the nodes are ready.

```sh
[root@master osboxes]# k describe nodes node1.k8s 
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Fri, 17 Apr 2020 02:45:12 -0400   Fri, 17 Apr 2020 02:24:41 -0400   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Fri, 17 Apr 2020 02:45:12 -0400   Fri, 17 Apr 2020 02:24:41 -0400   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Fri, 17 Apr 2020 02:45:12 -0400   Fri, 17 Apr 2020 02:24:41 -0400   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            False   Fri, 17 Apr 2020 02:45:12 -0400   Fri, 17 Apr 2020 02:24:41 -0400   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

This is because K8s CNI plugin is not deployed yet.

## Deploying kubernetes CNI plugin

> NOTE we need to install kubernetes-cni which we have already done on all the nodes.

```sh
[root@master osboxes]# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
```
