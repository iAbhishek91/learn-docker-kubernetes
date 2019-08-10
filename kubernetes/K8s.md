# K8s

- created by google
- container orchastration technoilogy.

## Advantages

- top rank project on github
- supported all popular cloud provider
- supported by Rancher
- most popular orchestration tool, compared to swarm and mesos
- easy scaling of hardware
- easy spinup new instances of the application
- all are handled by configuration files.

## K8s Architecture

- **Node(Minions)**: (phisycal or virtual) where k8s is installed. Its also a worker machine where containers will be launched by K8s.
- **Cluster**: group of multiple node. This is created for fault tolerance. This also help in sharing load as well.
In a cluster each node should have K8s installed.
- **Master node**: these are normal node in a cluster which are configured as master. Master node is responsible for managing the entire cluster and for orchestration.

## Orchestration

- Is to manage container holding the entire application stack.

## Pods

- in Kubernates containers are not implemented node directly.
- they run on pods.
- pods are kubernetes object, which encapsulate a container.
- pod is a smallest unit that you can create on kubernatese.
- pod is a single unit of applicaton. That means a multiple instance of container are not run on same pod. Refer next point.
- pod usually have **one to one relationship** with the container. There can be **multi container pod** created, but povided they are not of same type. This is mostly when we have helper container. The main container(which is running the actual application is depended on a supporting service) is dependent on a helper container, in those scenario we can design our pod carring multiple nodes.
- pods are created together and destroyed together.
- All the service running in the pod share the same volume and network.
- when we execute `kubectl run <podname> --image <container-name>` command, under the hood, k8s will create a pod and then deploy the container.
- the image is downloaded from docker registry configured.
- We can see the list of pod available using `kubectl get pds` will show you all the pods deployed in the cluster.

## Minikube

Provision and manages **single node** k8s cluster, optimised for dev workflow.

```sh
minikube start
```

- Downloads a VM iso image file. Minicube-v1.3.0.
- Creating vm on virtual box.
- Preparing K8s on Docker.
- Downloads kubelet
- Downloads kubeadm
- pull images
- Launches kubernetes
- waiting for all the component to start: apiserver, etcd, scheduler, controller.

## Kubeadm

- Kube admin helps to setup a **multi node** kubernetes cluster.
- To create the communication bw master and workers, kubernenes need to create a **POD network**.

### Set-up

- create 3 virtual machine (1 as master and 2 as worker nodes)
  - set bridge network. (This will be used for internet connectivity)
  - allow access to all system in the network.
  - configure ssh.
  - make ip address static, public IP address may not work. However this is not possible on a bridge network. As they will change.
  - Now every VM can communicate with the host system, however kubernetes will not work as stated above.
  - For that create a dedicated network, and assign static IP address to each node.
  - set ip: refer linux command file for seting ip address.
  - swapto be off `/etc/fstab`
- install *docker* on the nodes.
- install *kubeadm* in all the nodes.
- initialize
- create the POD network.
- join the nodes.
