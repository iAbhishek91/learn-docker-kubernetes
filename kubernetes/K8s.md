# K8s

- created by google
- container orchestration technology.

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

### Creation of pods

Pods can be created via yaml files.
Top level attributes are:

- `apiVersion`[type: string]: version
- `kind`[type: string]: type of object we are creating,
- `metadata`[type: dictionary]: details about the objects,
- `spec`[type dictionary]: specification of the object..

Few valid values of apiVerion are metioned below.

| kind       | version |
|------------|---------|
| POD        | v1      |
| Service    | v1      |
| ReplicaSet | apps/v1 |
| Deployment | apps/v1 |

> Note: all of the above are REQUIRED field.

Example of pod object yaml file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
    app: myapp
    type: front-end
spec:
  containers: # this is a list
    - name: nginx-container # this the first container
      image: ngnix
    - name: nginx-container # this the second container
      image: ngnix
```

## controller

- they are brain of kubernetes.
- there are several type of controller.

### replication controller

*What are replicas, and why do we need replication controller?*

- It allows multiple instances of same container to run. This simply because of **high avilability**, **load balancing**, **scaling**. So that if one fail then other pod can work. Replicas can bring up the application another pod in single pod scenario. When the one and only pod get destroed replicas set can spin up another pod. It basically make sure all time specified number of pod are running: it doesn't matter one or many. Replication controller can also span over multiple controller.

*What are the difference between replication controller and replica set?*

- Their purpose is same, however they are different. replication controller are older technology its been replaced with replica set. Replica set is reccomended.

#### Creation of replicaset controller

- In spec section we define `template`. The teplate defines a pod. Now we have see above how to create a pod. we bring in th pod `metadata` and `spec`
- Example of rc (replicaset controller) is as below:

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
    app: myapp
    type: front-end
spec:
  template: # this is a list
    metadata:
      name: myapp-pod
      labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
        app: myapp
        type: front-end
    spec:
      containers: # this is a list
        - name: nginx-container # this the first container
          image: ngnix
        - name: nginx-container # this the second container
          image: ngnix
  replicas: 3
```

### replicas set

- In replica set we have a attribute `selector`. `selector` is required attribute. In this section we mention which pod fall under this replica set. This is because replica set can also handel other pod which are not created by this perticular replicase config file. **This is one of the major difference between replica set and replication controller.
- One can mention the name of an already created pod. If not created replica set will try to create that.
- Replica set when executed, it will not create all the replicas, it will first see how many are available and if the number is less it will start creating new pods.

#### How to create replica set

```yaml
apiVersion: apps/v1
kind: Deployment 
metadata:
  name: myapp-rc
  labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
    app: myapp
    type: front-end
spec:
  template: # this is a list
    metadata:
      name: myapp-pod
      labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
        app: myapp
        type: front-end
    spec:
      containers: # this is a list
        - name: nginx-container # this the first container
          image: ngnix
        - name: nginx-container # this the second container
          image: ngnix
  replicas: 3
  selector:
    matchLabels:
      app: front-end
```

#### How to scale replica set

- Based on traffic we need to up scale or downscale replica set.

```sh
kubectl scale --replicas=6 -f replicaset.yml
```

## Deployments

Normally while deploying services we have few common scenario. Below are few

- for high availability we need to have multiple instances running.
- we should scale application at runtime.
- we should be able to upgrade or roll back changes. Upgrade and roll back can be done following different strategy. like: **rolling update** or **canary deployments**.
- upgrade the underlying dependencies, like upgrading node, or web server version etc.
- resume or start capabilities.

These all are available as a package in a kubernetes object known as `deployment`.
Deployment set are higher in the hierarchy.

**Kubenetes hierarchy**:

| level | k8s object  |
|-------|-------------|
| 1     | container   |
| 2     | pod         |
| 3     | replica set |
| 4     | deployment  |

### definition file of deployment

Its exactly same as replica set, except the Kind.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-rc
  labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
    app: myapp
    type: front-end
spec:
  template: # this is a list
    metadata:
      name: myapp-pod
      labels: # can contain any key as you wish, there can be multiple labels. We can later filter the pods based on labels.
        app: myapp
        type: front-end
    spec:
      containers: # this is a list
        - name: nginx-container # this the first container
          image: ngnix
        - name: nginx-container # this the second container
          image: ngnix
  replicas: 3
  selector:
    matchLabels:
      app: front-end
```

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
- install *docker* on the nodes. Note: `apt-get install docker.io` will always install latest version of docker. However kubernetes may not be compatible. To install specific version of docker, look at docker documentation `docker install for ubuntu`. Also verify online version of docker supported for kubernetes.
- install *kubeadm* in all the nodes. Refer kubernetes documentation: `kubeadm install on ubuntu`
- initialize
  - intialize kubeadmin. Again its better to go through K8s documentaion on `start using kubeadm`.
  - before initializing we need to make a choice of which type (there are many as inbuilt solution for networking on kubernetes, for example: flannel, cilium, calico, canal aws vpc, kube-router, romana) of pod network addin we are going to use.
  - Then based on the choice we are going to initialize `kubeadm`. For example: we have useing Flannel: `kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.2`.
- create the POD network. Note for this tutorial we are using flannel pod network. for the command look at `kubernetes pod network cration using kubeadm`
- join the nodes.

## Networking

- Host have a IP address, and if that host is directly deployed on the host it can be accessed via host IP address.
- Incase we have a minicube setup, then host have a separate IP and minicube has anther IP address. Pods located within a minicube can be accessed within the cluster. Hence networking is different based on the setups.
- Unlike in the docker world where IP address is assigned to a container, whereas in kubernetes world IP addresses are assigned to a pod. But **how each pod gets an IP?** When we install kubernetes, it creates a local network `10.244.0.0`, and each pod gets a IP from that network. for example if there are three pods attached, then IP of the pod will be `10.244.0.1`, `10.244.0.2` and `10.244.0.3` respectively. In this way pods can communicate to each other, however communicating with each pod using this IP is not an good idea, as they are dynamic IP and are subjected to change. We see better idea later.
- It is important to note that when we deploy kubernetes cluster (multiple nodes), automatically kubernetes do not setup any kind of networking between them. We have to create the cluster networking manually so that nodes communicate with each other. There are criterias that kubernetes expect us to setup as part of the cluster design.
  - All container/PODs should be able to communicate to one another without NAT.
  - All nodes can communicate with all containers and vice versa without NAT.
However, this configuration is not completely manual. There are multiple pre-built networking solution available.
  - cisco aci networks
  - flannel
  - vmware nsx
  - cilium
  - calico
Instead of the default IP address of kubernetes `10.244.0.0`, when we use this networking solution, this gives a specific IP to each kubernetes network (where each pods are connected in a single node). It also configures a routing mechanism between these IP address and then each nodes can communicate with other or other pods/containers. Long story short a virtual network is created of all pods and nodes, where each can communicate with each other.

## Services

- Services are virtual server inside the node and external to pods. Services  can connect to multiple pods.
- Kubernetes networking helps nedes and pods to communicate with each other. However to access the services in kubernetes pod from the external world for sending or receiving data, services are used. In docker world we do port mapping between the pods and hosts, and then external user can access the node service.
However, in kubernetes world we uses **services** for communicating between pods/nodes to external system.
- There are different type of services:
  - NodePort: this service maps a port on the node to a port on the pod. Similar to docker port mapping. Service has its own port. In details, pod's port is mapped with service port, the service port is mapped with node port. Thus we can access the node port and access the service internally.
  - ClusterIP: refer the PDF for understand the difference between them.
  - LoadBalancer: refer the PDF for understand the difference between them.
- Important to note that in case of multi node cluster, kubernetes creates a NodePort service automatically which spans between all the nodes. And it assignes same port to all the nodes, hence user can access the service from all the nodes.(refer services secion notes in pdf). Based on pod changes, dynamically updates itself making the service highly avilable.
- Once services are created typically we dont make any additional changes.
- **clusterIP**
  - Kubernetes services can be used to group multiple pods together. As there are multiple instance of database pod running, and multiple frontend pod. Which pod will connect to each other. The solution is services. They will group all the pods.

### How to create a service

- In a similar way how we have created a pod, replica set or deployments, we have to create a object in kubernetes.

type: **NodePort**

```yml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service # we may define labels as other object have
spec:
  type: NodePort # type of service we are creating
  ports:
  - targetPort: 80 # [Optional: if not provided, it will same as port] port of the pod where the service is hosted.
    port: 80 # [Required]port on the service object(server)
    nodePort: 30008 # [Optional: if not provided, then any free port is assigned from the node ]port on the node, in valid IP range: 30000:32767.
  selectors: # this is for linking between pods and service
    app: myapp # labels from pod definition
    type: front-end # another labels from pod definition
```

type: **ClusterIP**

```yml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service # we may define labels as other object have
spec:
  type: NodePort # type of service we are creating
  ports:
    - targetPort: 80
      port: 80
  selector:
    app: myapp
    type: back-end
```
