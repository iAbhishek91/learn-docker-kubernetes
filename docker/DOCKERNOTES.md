# learn-docker-kubernetes

docker concepts, commands, compose and kubernetes

## Why docker

We will have compatibility issues and to maintain the environment. We have to make sure that libraries, dependents, os and hardware used are consistent for all the system used, starting from development machine to production servers.

This problem is commonly known as **matrix of hell**.

This problem is mainly solved by docker.

## Architecture

### Docker (under the hood)

When we install docker we install three different component on your host(linux host to be specific):

- **Docker daemon**: this is a background process which manages networks, volumes and docker images, containers.
- **Rest API**: is a exposed layer which can communicate with the daemon and provide instruction to be executed. Engineers can use this to create their own tools.
- **Docker CLI**: Command line tool which are used to run commands that we have seen. Docker cli under the hood uses the rest-apis to communicate with the docker daemon.

These three component together known as Docker Cli.

> Note: Docker CLI's may not be present on the same system, it can connect from any system.
To achieve that we can use -H

### Container (under the hood)

- Docker uses namespace isolation to keep all the container's info separate.
- Namespace isolation are used in all the aspect of a container. Like: processes, etc.
- Linux system starts with one process, 'process-1'. Later that process-1 starts all other processes as child process.
- Inside a container there may be several processes, which are numbered as 1, 2, 3 and so on. However, in host system, we cant have process 1, 2 and 3 as these process number already exists. Two process cant have same process id. So they are mapped with other process_number in the host.
- This is the reason, the process running on container will always have separate process id inside the container and different one in the host machine.

- Host system will have resources CPU and Memory. These are shared among the system as well as the containers. The question how does docker manages all the resources.
- By default there is no such restriction or limitation of resources to be used by containers.
- However there is way we can explicitly put some restriction on the memory and CPU used by a container.
- Docker uses **CGROUPs** known as control group to manage the resources.

### Storage system (under the hood)

- In linux system docker by default get installed in `/var/lib/docker`.
- It creates sub directory inside the docker folder: aufs, containers, image, volumes.
- As docker uses layered architecture: each files that are created by each layer are read-only, and only can be edited by the `docker build` command.
- When we use `docker run` an extra layer is create known as **container layer**. Unlike other layers, this layer is read-write layer. This layer is alive until and unless container is running. All the data stored in this layer is destroyed when we destroy the container.
- If we intend to change any file which are part of image layer in the container layer, docker automatically creates a copy of the file and the changes are kept in the container layer. Hence other container running out of the same image are not impated. This mechanism is known as **COPY-ON_WRITE**.
- We can create docker volume by using `docker volume` command. Refer `DOCKERCOMMANDS.md` for syntax and details.
- Binding a volume from `/var/lib/docker/volume` is known as **VOLUME-BINDING**.
- When we map an extenal volume to a internal volume inside container, the external volume is mapped within the docker container. Hence everything that are written inside the container are persisted.
- If the volume do not live in the `/var/lib/docker/volume` folder, then we need provide the absolute path instead of only the name. This type of mounting is know as **BIND-MOUNTING**.

- All these file system management we spoke earlier are managed by **Storage drivers**.
  - AUFS
  - ZFS
  - BTFRS
  - Device manager
  - Overlay
- The selection of the storage driver depends on the Linux platform used. For example for Ubuntu AUFS is used for Fedora or Centos device manager is used.
- `layer`, `diff` and `mnt` folder are available under `/var/lib/docker/aufs`. All layer and files are stored in these directories.

Want to read more, please refer [Docker storage docs](https://docs.docker.com/storage/)

## Installation

### CentOS or RHEL

There are multiple way to do that, however the below is recommended way.
Recommended way: https://docs.docker.com/install/linux/docker-ce/centos/#install-using-the-repository

## what are images

- Images are just a tarball.
- Images are created from docker file.
- Each docker image is a layered architecture.
- It also has a default command.
- When the image is instantiated and run as a container, the command is executed.
- The container lives until the command is completed.
- We can override the default command by passing a command from the run command.

```sh
docker run image_name [command]
```

- To make this change permanent we need to create another image from the base image and mention the command.

First way is to mention the **CMD**. In this case the entire command have to be mentioned.

```dockerfile
FROM Ubuntu
CMD sleep 50 || ["sleep", "50"]
```

to execute the above image

```sh
docker run ubuntu-sleeper #executes the command mentioned
docker run ubuntu-sleeper sleep 10 #override the default command, hence entire command is always required
```

If we don't want to mention the `sleep` keyword, what we can do?

Another way is to mention is **ENTRYPOINT**. Where we can append the argument to the command passed.

```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"] #json format is only supported
```

to execute the above image

```sh
docker run ubuntu-sleeper 50 #option is mandatory otherwise it will throw error
docker run ubuntu-sleeper 10 #option is mandatory otherwise it will throw error
```

How to define a default value to **ENTRYPOINT**:

```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"] #json format is only supported
CMD ["5"] #json format is only supported
```

```sh
docker run ubuntu-sleeper #this will sleep from 5 sec by default
docker run ubuntu-sleeper 10 #this will sleep for 10 sec by default
```

The above is the only difference between **CMD** and **ENTRYPOINT**.

## What are containers

- Containers are isolated environments.
- They contains their own processes, netowrk and mounts. Very similar to VMs.
- Dockers uses the same OS kernel. i.e, that means it sit on top of OS kernel.
- Main objective of docker is to containerize application.

## Differences b/w containers and virtual machine

- Virtual machines sits on top of hypervisor, containers sits on top of OS
- VMs have its own OS, however container utilizes the underlying OS.
- VMs are heavier(in GBs) than container(in  MBs).
- Bootup time is much higher for VMs than containers.
- Greater isolations of resources in VMs compared to containers.

## Differences b/w images and containers

- Images are template from which multiple containers can be created.
- Containers are nothing but running instance of a docker image.

## What is docker hub

- It is a global registry, where all images are stored.

## Networking

- When we install docker it creates three networks automatically `bridge`, `none` and `host`.
- By default the each container gets attached with bridge network of the docker. We can change this using the below command.
  - Bridge network:
    They are private network.
    Each container gets a IP address, generally in a range of '172.17.X.X'.
    Containers can communicate within themselfs as they all are in the same private network.
    However to work with the external world, port should be mapped.
  Host network:
    They are public network.
    Both containers and docker hub uses the same network, hence no port mapping is required.
    This also means that we cant run same containers on the same docker host (post will same).
  None network:
    The containers do not have any network attached.
    Neither it can communicate with the internal containers nor it can communicate with the external world.

```sh
`docker run ubuntu` #containers are running in the bridge network
`docker run ubuntu --network=none` #containers are running in the none network
`docker run ubuntu --network=host` #containers are running in the host network
```

- We may come across a problem, as all the containers in a docker hosts can communicate with each other as they are in the same private network. How to separate them?
- To separete group of containers to create user defined network within a docker host. Refer Docker command `docker network` comamnd how to implement the above.

- The machine which runs docker is known as `docker host or docker engine`.
- Now the engine runs multiple containers.
- Mostly container has a service running, and running on a port(assume 5000).
- Every container gets a IP assigned. But this is an internal private IP (assume 172.17.0.2).
- So within the docker hosts, we can access the internal IP and we can access the service (http://172.17.0.2:5000).
- But this is not possible outside the docker host. In that case users outside my docker host can access the IP assigned to docker host itself (assume 192.168.1.5).
- However the port of the container needs to be mapped from the container to docker hub. Assume we need to map internal port 5000 to port 80 of docker hub, use option `-p 80:5000`.

### Overlay networking

This is a advance concept. In a scenario, where **container running on different host** need to communicate. This where **overlay network** comes into play.

- This is forth type network that we can create. Now all the service can communicate between themself.

```sh
docker network create --driver overlay --subnet 10.0.9.0/24 my_overlay_network
docker service create --replicas 3 --network my_overlay_network my_server
```

### Ingress network

This is also an advance topic. In a scenario, where we have **single node swarm cluster**, and we create multiple instance of a service and map a port like 8080:80. This will not work as two instance cant map to a single port 8080. But it works!!

```sh
docker service create --replicas 2 -p 8080:80 my-web-server # this should not work in single node swarm cluster, but it works!!
```

- Ingress network is automatically created when swarm is initialised. It's a type of overlay network.
- Ingress network has a in built load balancer, the container ports are mapped to load balancer and the load balancer port is mapped to docker-host's port. For example if two instance of a server is running on a same docker host an exposing at 80, then both the port 80 is load balanced in the ingress network. The ingress network in turn is mapped with docker-host port 8080.
- Even though the command looks same, the underlying working are very different.
- [Without Ingress neetwork]Now when we have multiple node swarm cluster, and the service is replicated over the hosts. Now how does user access the service. They have to access the service by specifying ip-address of specific host. Hence we have be sure on which node the sevice is running and the access it via it's IP address.
- Since ingress network is overlay network with a load balancer you can access the application without the knowledge where the application / service is deployed. This concepts is known as **routing mesh**. It will look like all the host are running service.

### Embedded DNS

How exactly container communicates with each other?

All host can resolve each other by their name. We should not use IP address, as they are dynamic and we are not sure, as this may change after reboot.

Docker have a built in DNS server which maps container name with the ip address.

Always the internal DNS server runs on `127.0.0.11`.

## File system

- Each container has its own file system.
- Any change in the file system remains in the container itself.
- So if you store any data in a container and stop or remove (rm) your container before backing up, it will destroy all your changes and data.
- For **persistenting data** we have to map a directory outside the container(probably in docker host), where we can backup the data.
- For mapping directory or volume, use the option `-v dir/path/name:internal/dir/path/name`. Volumes are mounted within the container.

## what are Dockerfile

Docker file are used to create docker image.

- This is required when you want you application to be containerized.
- Dockerfile is a text file which docker can understand, hence it has a specific syntax.
- Each line is in a format `instruction arguments`. Instruction are metion in capital letter.
  - FROM ubuntu
  - Run apt-get update
  - RUN apt-get install python
- Docker creates a image as a layered fashion. Hence docker follows a layered architecture.
  - every instruction creates a layer in the image.
  - the next layer just add another layer on top of the layer with the change mentioned in the current instruction.
- this layer architecture can be viewed by using `docker history` command.
- this layered architecture helps in caching the steps, and reusing if it is required in future.

## What can you containerize

- everything. chrome, Skype, spotify etc.
- installation is not required and cleanup is pretty easy.

## Environment variables

Environment variable can be passed to a container from the run command by using `-e` option.

## Docker compose

- This is to automate multiple docker commands. Its best to use docker compose and execute the same file again and again.
- This is mainly used in environment where there are different type of configurations to be done.
- This file is defined in ymal format, which contain a requied dictionary called **services**.
- key of each **services**, is a user defined name. and value sould be a dictionary again. Required field within a **service** is image.
- Again to make docker understand we need to follow some syntax.
For example

```yaml
version: 2

services:
  web:
    image: ngnix #instead of image we can give a build command to the directory where our dockerfile is available.
    container_name: nginx_container
    ports:
      - 1313:1313
    command:
      - node
      - index.js
    links: #links are not required in version 2 & above
      - database #this is similar as writing database:database
    depends_on: # this feature is available on version 2 & above
      - database
    networks: #network command attach the service to the perticular network
      - network_name_1
      - network_name_2
  database:
    image: mongodb
    container_name: mongodb_container
    volumes:
      - /ext/volume:/internal/volume
    networks:
      - network_name_2
  messaging:
    image: redis:alpine
  networks:
      - network_name_2
  orchastration:
    image: ansible
    environment:
      - ENV_VAR: bla_bla
    networks:
      - network_name_2

networks:
  network_name_1: #used for front end
    driver: bridge
  network_name_2: #used for back end

volumes:
    redis-data:
    db-data:
```

- **version** of docker compose. There are many docker compose version available. You have to mention which version of docker compose file you are referring to. If not mentioned it will take version one as default. Version is mandetory from version 2 and higher.
- Version 2 and 3 are almost same but the major change is that docker-compose version 3 supports docker swarm.

## Docker swarm

- One docker host is not possible in production environment as this is **single point of failure**.
- With docker swarm, we can manage multiple docker machine as **single cluster**.
- Docker swarm will take care of placing the containers in the hosts, such that its highly available.
- Docker swarm also helps in load balancing.
- To configure swarm, one of the docker hosts, should act as a **manager(master)** and all other docker hosts as **workers(slaves)**.
- More about **docker manager**
  - responsible for:
    - maintaining cluster state.
    - managing the workers or node or slave.
    - adding and removing workers.
    - creating, distributing and ensuring the containers
    - state of services running across all workers.
  - As Manager is the main docker host taking care of docker nodes, it is not recommended to have one docker master in a cluster. For **fault tolerance** configure multiple docker manager within a cluster.
  - However if there are multiple manager, a scenario of **conflict of interest** arises b/w the managers.
  - In this scenario, only one manager is allowed to make decision, that manager is known as **leader**.
  - Now, leader also can't make its decision of it's own. All decision have to be mutually agreed upon. So in other words, all manager need to have same information about the cluster.
  - This has been implemented using **RAFT (distributed consensus)**. Details about RAFT algorithm mention below.
    - A timer is started on all the managers.
    - The first manager to finish the timer, sends a request to all the other managers. Once all the manager agrees, then this manager is assigned a role of leader.
    - From this point leader sends notification to all the manager, stating that he is continuing his role. In case the leader goes down and there is no notification sends to the manager. Then the re-election process is triggered again (stated in step-1).
    - All the manager nodes keep their own copy of cluster information. And it's important to keep the data in sync.
    - Any change that leader is initiating(like adding a new worker), then it should be first communicated to the other managers,then once positive response is received from **majority** the action is triggerd and database of all the manger is updated.
    - Majority - is a known as **quorum**. Quorum is defined as minimum number of member required in a assembly to carry on with the procedings.
    - There is a formula to calculate the number of member required in quorom (Q). Q = (N/2 + 1). The floor value is considered. For N = 1, 2, 3, 4, 5, 6, 7 | Q = 1, 2, 2, 3, 3, 4, 4 | fault tolarance(how many failure a cluster can with stand) F = 0, 0, 1, 1, 2, 2, 3.
    - Docker reccommends **not more than 7 manager** for swarm. However there is no hard limit to the number of manager. in the cluster.
    - Best practice: to keep number of managers to be odd number like 3 or 5 or 7. see the fault tolarance.
  - **Cluster failure**: a cluster fails when quorum number are not meet. However the network will continue to work. But we cant change anything which are taken care be manager. Cluster failure can be determined by failure of `docker node ls`. It will display a clear message *a swarm does not have a leader. Too few managers online*.
  - **Cluster recovery**: the best way to recover is to bring the master failed node back again. Else we can **force create the cluster** by issuing `docker swarm init --force-new-cluster --advertise-addr 192.168.56.3`. Now the total number of manager is updated with the number of available master node.
  - **Can manager node work**: yes,by default all manager node are worker node and can do what normal worker node can do. However this can be disable this by setting the drain option. `docker node update --availability drain hostname`. This is recommended by docker for production environment..
- More about **worker node**:
  - worker node can be **promoted as manager node**. This can be done using `docker node promote hostname`. This can be done only from the master node.
- To initialize docker swarm trigger this command on docker manager(master) `docker swarm init` system.
- If docker finds that the host is not connected to any network to connect it will throw error. If there are multiple connection, then we need to specify which connection is used for the cluster. `docker swarm init --advertise-addr 198.172.10.3`.
- The previous command will give a command, and that command is to be issued in all the slave system.
  `docker swarm join --token <token-id>`
- Once the slave system joins the master they are known as **nodes**.
- In docker compose file: the below example will deploy five instances of the service across the docker:hosts available.
- To list all the nodes: `docker node ls`. This command works on the master only.
- leave a cluster, issue this in the worker machine: `docker swarm leave`. This change the status of the node, however to take the node out from managers database execute `docker node rm hostname-of-the-node`.
- To get the key from the manager for a worker role: `docker swarm join-token worker`
- To get the key from the manager for a manager role: `docker swarm join-token master`

```yml
deploy:
  replicas: 5
```

- Deploy the above docker file by issuing below command:

```sh
docker stack deploy -c docker-compose.yml
```

## Docker services

- Now we are have docker swarm, how do we run multiple instances of same service on multiple hosts to support large user base (as an example). Simple way to do is by running docker run command separately on all the hosts. But its tedious and time consuming. This is impossible task as we have to many things manually like, load balancing, monitering, maintainence etc.
- This where **docker swarm orchastration** comes into play.
- **Docker service is the key component** of docker swarm orchastration.
- **Docker services are one or more instance of a single application or service that runs across the swarm cluster**. That means docker service can run multiple instances of my application on swarm cluster.
- To create docker service with 3 instances of my server running, use the below command.

```sh
docker service create --replicas 3 my-web-server #this command works only on manager node
```

- Docker service command takes almost all options as docker run. Infact service command have lopt more options than run command.
- **Under the hood** The service command use **swarm orchastrator** to create the instances and then **swarm scheduler** schedules the instances among the worker nodes. The schedular than creates that many tasks on the worker nodes. The tasks are process on the worker node which kicks of the container instances. Task has **one to one** relation with the container instances. The task is responsible for updating the status of the container to the manager node. This way manager keep track of the instances running on the worker node. So if  a container fails, then manager gets updated and automatically starts another task on a worker node based on availability. It may use same node or different node.
- There are **two type of services** *replicas* and *global*. Replicas are created based on *replicas* option. In this option we have a requirement of running specific number of replicas irrespective of underlying infra on the cluster. There may be a usecase where you want to run one instance of container on all the worker node. For exmaple we want to run antivirus, or monitering or log collection agent. This type of service is known as global service. Use the below command to define a global service.

```sh
docker service create --mode global my-monitering-service
```

- list the service 

```sh
docker service ls #list all the service
docker service ps service-name # list details of all the service instances.
```

- Naming a container in this case can be done in similar way. However, since we are running multiple container, docker will append the name with a number. For example: for the below command `my-web-server.1`, `my-web-server.2` and `my-web-server.3`.

```sh
docker service create --replicas 3 --name my-web-server my-web-server
```

- Update service, any configuration can be changed on the already running services. To update mention the name of the service.

```sh
docker service create --replicas 3 --name web-server my-web-server
docker service update --replicas 4 web-server
```

## Docker stack

We combine multiple `docker run` command into `docker-compose`. How about swarm. We use `docker service` commands.

- We still use docker-compose. But insted of `docker-compose up`, we use `docker stack deploy`.

FYI: *Same type of containers combine together to form service, many services combine togather to form a stack. Stack generally represent a application*.

```yml
version: 3
services:
  redis:
    image: redis
    deploy:
      replicas: 1
      resources:
        limits:
          cpus: 0.01
          memory: 50M
  vote:
    image: voting-app
      deploy:
        replicas: 2
  result:
    image: result
      deploy:
        replicas: 1
  db:
    image: postgres:9.4
      deploy:
        replicas: 1
        placement:
          constrains:
            - node.hostname == node1
            - node.role == manager
  worker:
    image: worker
      deploy:
        replicas: 1
```

## Docker visualiser

This is UI available in the docker hub. Follow the instruction there.

- preety good UI when we use swarm.

## Docker registry

Docker registry are used in organization where, they dont want to publish their image to globa docker hub.

To create a local docker registry, there are couple of options:

- install docker registry software on the server
- or run a image of a docker registry server.
- or play with docker also play with kubs(for learning purpose) this gives access to cloud.

To **push** a image in the private registry, simply give the url of the registry.

```sh
docker tag hello-world localhost:5000/hello-world
docker push localhost:5000/hello-world
docker pull localhost:5000/hello-world
```
