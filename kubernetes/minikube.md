# minikube

This allows to run K8s cluster on one host.

## Below are the warning messages

minikube start --vm-driver=none

1. [WARNING Firewalld]: firewalld is active, please ensure ports [8443 10250] are open or your cluster may not function correctly
2. [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
3. [WARNING Swap]: running with swap on is not supported. Please disable swap
4. [WARNING FileExisting-socat]: socat not found in system path
5. [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
6. [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1

**No Action for 1**: firewalld service runs in one system. verify, `firewall-cmd --list-all` this command will give if 8443 and 10250 is blocked. Incase its blocked open the firewall rules.

Also once minikube starts you can verify `netstat -tulp` that all the service of kubernetes is running or not. For me, I can see below processes after minikube starts:

tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1494/master
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      1260/kubelet
tcp        0      0 127.0.0.1:44328         0.0.0.0:*               LISTEN      1260/kubelet
tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN      1582/kube-proxy
tcp        0      0 127.0.0.1:10257         0.0.0.0:*               LISTEN      876/kube-controller
tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN      923/kube-scheduler
tcp6       0      0 ::1:25                  :::*                    LISTEN      1494/master
tcp6       0      0 :::8443                 :::*                    LISTEN      921/kube-apiserver  
tcp6       0      0 :::10250                :::*                    LISTEN      1260/kubelet
tcp6       0      0 :::10251                :::*                    LISTEN      923/kube-scheduler
tcp6       0      0 :::10252                :::*                    LISTEN      876/kube-controller
tcp6       0      0 :::10256                :::*                    LISTEN      1582/kube-proxy

**Optional Action for 2**

When systemd is chosen as the init system for a Linux distribution, the init process generates and consumes a root control group (cgroup) and acts as a cgroup manager. Systemd has a tight integration with cgroups and will allocate cgroups per process. cgroupfs is the default cgroup manager for docker. It’s possible to configure your container runtime and the kubelet to use cgroupfs. Using cgroupfs alongside systemd means that there will then be two different cgroup managers.

Since cgroup are used to restrict resources per process, one cgroup manager will simplify the resource management.

Across the cluster cgroup manager should be consistent (kubelet, docker and other processes)

To set this. For each container solution configuration is different. For docker, please go through https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker 

**Optional Action for 3**

Swap is not handled by kubernetes. Kubelet isn't designed to handle swap situations and the Kubernetes team aren't planning to implement this as the goal is that pods should fit within the memory of the host.

Swap device and files `cat /proc/swaps`.

`swapoff -av`

**Optional Action for 4**

socat stands for socket concatenation. This ia a utilities used to create two for bi-directional byte stream and transfer data between them.

`yum install -y socat`

**Optional Action for 5**

`systemctl status kubelet.service`

Enable using `systemctl enable kubelet.service`

OUTPUT: `Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.`

**Action for 6**: echo 1 >proc/sys/net/bridge/bridge-nf-call-iptables - Note this a temporary change and do not impact

### minikube start --vm-driver=none

#### OUTPUT

minikube v1.7.2 on Centos 7.7.1908
✨  Using the none driver based on user configuration
⌛  Reconfiguring existing host ...
🔄  Starting existing none VM for "minikube" ...
ℹ️   OS release is CentOS Linux 7 (Core)
🐳  Preparing Kubernetes v1.17.2 on Docker 19.03.6 ...
🚀  Launching Kubernetes ... 
🌟  Enabling addons: default-storageclass, storage-provisioner
🤹  Configuring local host environment ...

⚠️  The 'none' driver provides limited isolation and may reduce system security and reliability.
⚠️  For more information, see:
👉  https://minikube.sigs.k8s.io/docs/reference/drivers/none/

⚠️  kubectl and minikube configuration will be stored in /root
⚠️  To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:

    ▪ sudo mv /root/.kube /root/.minikube $HOME
    ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube

💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
🏄  Done! kubectl is now configured to use "minikube"

#### Notes

Once the kubernetes cluster is created using minikube, `minikube start` command creates  a kubectl context called minikube. This context contains the configuration to communicate with your Minikube cluster.

### Running application in minikube

before starting, ensure kubernetes cluster is running properly

```sh
kubectl cluster-info

# OUTPUT
# Kubernetes master is running at https://192.168.1.248:8443
# KubeDNS is running at https://192.168.1.248:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Deploying a node.js app

```sh
kubectl run abdas81 --image=abdas81/temperature-service --port=1313 --generator=run/v1 # use run-pod/v1 now to run a pod manually

# OUTPUT
# replicationcontroller/abdas81 created
```

List the pods that were created

```sh
kubectl get pods

# OUTPUT (image is not available will give below errors ErrImagePull or ImagePullBackOff)
# NAME          READY   STATUS         RESTARTS   AGE
# kubia-7hzsz   0/1     ErrImagePull   0          2m

# NAME          READY   STATUS             RESTARTS   AGE
# kubia-7hzsz   0/1     ImagePullBackOff   0          23m
```

#### Notes

name space analysis when k8s is running.

Nproc is number of processing units available.

```sh
lsns

# OUTPUT
# master (etcd(conf key value store), api server, scheduler, controller-manager(function on the cluster))
# NAMESPACE TYPE    NPROCS PID USER     COMMAND
#4026532211 mnt        1   876 root     kube-controller-manager --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=
#4026532212 pid        1   876 root     kube-controller-manager --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=
#4026532213 mnt        1   920 root     etcd --advertise-client-urls=https://192.168.1.248:2379 --cert-file=/var/lib/minikube/certs/etcd/server.crt --client-ce
#4026532214 pid        1   920 root     etcd --advertise-client-urls=https://192.168.1.248:2379 --cert-file=/var/lib/minikube/certs/etcd/server.crt --client-ce
#4026532215 mnt        1   921 root     kube-apiserver --advertise-address=192.168.1.248 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-fil
#4026532216 pid        1   921 root     kube-apiserver --advertise-address=192.168.1.248 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-fil
#4026532217 mnt        1   923 root     kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.conf --authorization-kubeconfig=/etc/kubernetes/sc
#4026532218 pid        1   923 root     kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.conf --authorization-kubeconfig=/etc/kubernetes/sc

# Kube proxy()
#4026532223 mnt        1  1582 root     /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/config.conf --hostname-override=osboxes
#4026532224 pid        1  1582 root     /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/config.conf --hostname-override=osboxes

# This is for container running (abdas81/temperature-service)
#4026532747 mnt        1 13193 root     node dist/server/
#4026532748 uts        1 13193 root     node dist/server/
#4026532749 pid        1 13193 root     node dist/server/
```

```sh
netstat -p

# OUTPUT
#tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1494/master
#tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      1260/kubelet
#tcp        0      0 127.0.0.1:44328         0.0.0.0:*               LISTEN      1260/kubelet
#tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN      1582/kube-proxy
#tcp        0      0 192.168.1.248:2379      0.0.0.0:*               LISTEN      920/etcd
#tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      920/etcd
#tcp        0      0 192.168.1.248:2380      0.0.0.0:*               LISTEN      920/etcd
#tcp        0      0 127.0.0.1:2381          0.0.0.0:*               LISTEN      920/etcd
#tcp        0      0 127.0.0.1:10257         0.0.0.0:*               LISTEN      876/kube-controller
#tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN      923/kube-scheduler
#tcp6       0      0 ::1:25                  :::*                    LISTEN      1494/master
#tcp6       0      0 :::8443                 :::*                    LISTEN      921/kube-apiserver
#tcp6       0      0 :::10250                :::*                    LISTEN      1260/kubelet
#tcp6       0      0 :::10251                :::*                    LISTEN      923/kube-scheduler
#tcp6       0      0 :::10252                :::*                    LISTEN      876/kube-controller
#tcp6       0      0 :::10256                :::*                    LISTEN      1582/kube-proxy
```

```sh
kubectl get pods -o wide

# OUTPUT
#NAME            READY   STATUS    RESTARTS   AGE     IP           NODE      NOMINATED NODE   READINESS GATES
#abdas81-gg6nt   1/1     Running   0          5h20m   172.17.0.6   osboxes   <none>           <none>
```

Couple of things to note from the above command's o/p:

- that 172.17.x.x network is not exposed on host system from netstat (where pod is running), this is internal network and hence cant be accessed from outside.
- also, PID 13193, is not listed in netstat, hence there is no active TCP network connection available.
- all the k8s component is running in local host as we are running with minikube and vm-option is none.

```sh
kubectl expose rc abdas81 --type=LoadBalancer --name abdas81-http # this command will create the service, however since minikube do not support load balancer external IP will be expose, see next step

# very important to note, why a service is required?
# POD run your application and exposes that to a port. However pod are shifted from one node to another. Also it may be recreated by replication controller. Also there may be a situation where you have multiple replicas of a pod each having multiple ip. So IP is never constants. Hence service is required, which provide a static IP to a user and internally connects to replication contoller to connect to the pod(s).


kubectl get services

# OUTPUT
# NAME           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# abdas81-http   LoadBalancer   10.100.67.165   <pending>     1313:31712/TCP   17m
# kubernetes     ClusterIP      10.96.0.1       <none>        443/TCP          16h

minikube service abdas81-http

# OUTPUT
# |-----------|--------------|-------------|----------------------------|
# | NAMESPACE |     NAME     | TARGET PORT |            URL             |
# |-----------|--------------|-------------|----------------------------|
# | default   | abdas81-http |             | http://192.168.1.248:31712 |
# |-----------|--------------|-------------|----------------------------|
# 🎉  Opening service default/abdas81-http in default browser...
# START /usr/bin/firefox "http://192.168.1.248:31712"
# Failed to open connection to "session" message bus: Unable to autolaunch a dbus-daemon without a $DISPLAY for X11
# Running without a11y support!
# Running Firefox as root in a regular user's session is not supported.  ($XDG_RUNTIME_DIR is /run/user/1001 which is owned by abhishek.)
# xdg-open: no method available for opening 'http://192.168.1.248:31712'
#
# 💣  open url failed: http://192.168.1.248:31712: exit status 3
#
# 😿  minikube is exiting due to an error. If the above message is not useful, open an issue:
# 👉  https://github.com/kubernetes/minikube/issues/new/choose

# this will throw error as minikube try to open the service in the pod in a web browser, and in many VM mozilla maynot be installed
# However, take the IP from the service.

curl 192.168.1.248:31712/api/v1/weather -H "longitude: 90" -H "latitude:50"

# OUTPUT
# {"temperature":5,"humidity":6}
```

Now we can scale an application very easily.

```sh
kubectl scale rc abdas81 --replicas=3
```