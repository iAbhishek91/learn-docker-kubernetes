# minicube

This allows to run K8s cluster on one host.

## Below are the warning messages

1. [WARNING Firewalld]: firewalld is active, please ensure ports [8443 10250] are open or your cluster may not function correctly
2. [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
3. [WARNING Swap]: running with swap on is not supported. Please disable swap
4. [WARNING FileExisting-socat]: socat not found in system path
5. [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
6. [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1

**No Action for 1**: firewalld service runs in one system. verify, `firewall-cmd --list-all` this command will give if 8443 and 10250 is blocked. Incase its blocked open the firewall rules.

Also once minicube starts you can verify `netstat -tulp` that all the service of kubernetes is running or not. For me, I can see below processes after minicube starts:

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

Since cggroup are used to restrict resources per process, one cggroup manager will simplify the resource management.

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

Once the kubernetes cluster is created using minicube, `minicube start` command creates  a kubectl context called minicube. This context contains the configuration to communicate with your Minikube cluster.