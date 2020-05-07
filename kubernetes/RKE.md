# Rancher kubernetes Engine

RKE is a fast, versatile kubernetes installer that you can use to install kubernetes on your linux hosts.

Note: RKE is available for macOS, Linux (intel, AMD), Linux ARM 32 bit and 64 bit) Windows (32 and 64 bit).

## configuration

### Prerequisite on nodes

FOLLOW ALL THE BELOW SETTING IN VMs and FULL CLONE the VM. 3 MASTER NODE and 3 WORKER NODE.

**Step-1:** Create a *docker* user group and the user *rancher*.Add ssh user preferred *rancher* to be part of *docker* group.

```sh
groupadd docker
useradd rancher
usermod -aG docker rancher
```

> Name of the group should be docker. Docker daemon starts and creates Unix socker accessible by members of the docker group.
>Users added to the docker group are granted effective root permissions on the host by means of the Docker API. Only choose a user that is intended for this purpose and has its credentials and access properly secured.
> Also root user can't be ssh user in RHEL and Centos. This is because port forwarding is disabled when privilege separation is disabled. And for root user privilege separation is always disabled and hence root user can't perform port forward. refer: https://bugzilla.redhat.com/show_bug.cgi?id=1527565

V.V.Imp: Read this docker docs, as RKE installes docker and non-root user. https://docs.docker.com/engine/install/linux-postinstall/

**Step-2:** Swap should be disabled. To refresh, this is required for all k8s installation *minikube or kubeadm*.
**Step-3:** Kernel Modules defined by RKE should be installed.
Refer: https://rancher.com/docs/rke/latest/en/os/
**Step-4:** Network configuration. Refer kubeadm step-6.

> Note: This is common setting required for all multi node cluster, hence its not required in minikube.

**Step-5:** Install and validate docker is installed properly.

```sh
# create a yum repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker in centos
yum install docker-ce-18.09.2 docker-ce-cli-18.09.2 containerd.io

# start docker service and make it enable so that it runs after boot
systemctl enable docker && systemctl start docker

# check version
docker version --format '{{.Server.Version}}'
rpm -qa docker-ce

# verify that docker works as non root user
su rancher
docker run hello-world
```

**Step-6**: disable firewall

```sh
systemctl disable firewalld && systemctl stop firewalld
```

**Step-7**: Change the hostname, hosts file and network to use bridge so that separate IP is allocated to each vm.

### Install and Configure RKE

Step-1: Installation of RKE is done on the local machine. In my case I am installing it on my Mac.

```sh
brew install rke
```

Step-2: Validate RKE is installed properly on the local machine

```sh
rke --version
```

Step-3: prepare the cluster.yml

RKE uses a cluster configuration file, refereed to as cluster.yml to determine the below:

- What node will be in the cluster
- how to deploy and launch kubernetes

```sh
rke config --name kubernetes/cluster.yml
```

### Start the cluster

Step-1: Make sure all the Virtual machine are working as expected.

Step-2: bring up the cluster

```sh
rke up
```

## RKE functionality

COMMANDS:
     up       Bring the cluster up
     remove   Teardown the cluster and clean cluster nodes
     version  Show cluster Kubernetes version
     config   Setup cluster configuration
     etcd     etcd snapshot save/restore operations in k8s cluster
     cert     Certificates management for RKE cluster
     encrypt  Manage cluster encryption provider keys
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug, -d    Debug logging
   --quiet, -q    Quiet mode, disables logging and only critical output will be printed
   --trace        Trace logging
   --help, -h     show help
   --version, -v  print the version

## RKE certificate management

RKE saves its certificates in two place on the node where it is deploying.

1. /etc/kubernetes/ssl/*
2./opt/rke/etc/kubernetes/*