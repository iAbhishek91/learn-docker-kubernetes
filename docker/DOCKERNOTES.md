# learn-docker-kubernetes

docker concepts, commands, compose and kubernetes

## Why docker

We will have compatibility issues and to maintain the environment. We have make sure that libraries, dependents, os and hardware used are consistent for all the system used starting from development machine to web server.

This problem is commonly known as **matrix of hell**.

This problem is mainly solved by docker.

## Architecture

### Docker (under the hood)

When we install docker we install three different component on your host(linux host to be specific):

- **Docker deamon**: this is a background process which manages networks, volumes and docker images, containers.
- **Rest API**: is a exposed layer which can communicate with the deamon and provide innstruction to be executed. Engineers can use this to create their own tools.
- **Docker CLI**: Command line tool which are used to run commands that we have seen. Docker cli under the hood uses the rest-apis to communicate with the docker deamon.

These three component togather known as Docker Cli.

> Note: Docker CLI's may not be present on the same system, it can connect from any system.
To achieve that we can use -H

### Container (under the hood)

- Docker uses namespace isolation to keep all the container's info separate.
- Namespace isolations are used in all the aspect of a container. Like: processes, etc.
- Linux system starts with one process, 'process-1'. Later that process-1 starts all other processes as child process.
- Inside a container there may be several processes, which are numbered as 1, 2, 3 and so on. However, in host system, we cant have process 1, 2 and 3 as these process number already exists. Two process cant have same process id. So they are mapped with other process_number in the host.
- This is the reason, the process running on container will always have separate process id inside the container and different one in the host machine.

- Host system will have resources CPU and Memory. These are shared among the system as well as the containers. The question how does docker manages all the resources.
- By default there is no such restrition or limitation of resources to be used by containers.
- However there is way we can explicitely put some restriction on the memory and CPU used by a container.
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

- All these file system managment we spoke earlier are managed by **Storage drivers**.
  - AUFS
  - ZFS
  - BTFRS
  - Device manager
  - Overlay
- The selection of the storage driver depends on the Linux platform used. For example for Ubuntu AUFS is used for Fedora or Centos device manager is used.
- `layer`, `diff` and `mnt` folder are available under `/var/lib/docker/aufs`. All layer and files are stored in these directories.

Want to read more, please refer [Docker storage docs](https://docs.docker.com/storage/)

## what are images

- Images are created from docker file.
- Each docker image is a layered architecture.
- It also has a default command.
- When the image is instantiated and run as a container, the command is executed.
- The container lives until the command is completed.
- We can override the default command by passing a command from the run command.

```sh
docker run image_name [command]
```

- To make this change permanenet we need to create another image from the base image and mention the command.

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

If we dont want to mention the `sleep` keyword, what we can do?

Another way is to mention is **ENTRYPOINT**. Where we can append the argument to the command passed.

```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"] #json format is only supported
```

to execute the above image

```sh
docker run ubuntu-sleeper 50 #option is mandetory otherwise it will throw error
docker run ubuntu-sleeper 10 #option is mandetory otherwise it will throw error
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

- When we install docker it creats three networks automatically `bridge`, `none` and `host`.
- By default the each container gets attached with bridge network of the docker. We can change this using the below command.
  - Bridge network:
    They are private network.
    Each container gets a IP address, generally in a range of '172.17.X.X'.
    Containers can communicate within themselfs as they all are in the same private network.
    However to work with the external world, port should be mapped.
  Host netowrk:
    They are public network.
    Both containers and docker hub uses the same network, hence no port mapping is required.
    This also means that we cant run same contianers on the same docker host (post will same).
  None network:
    The containers do not have any network attached.
    Nither it can communicate with the internal containers nor it can communicate with the external world.

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

## File system

- Each container has its own file system.
- Any change in the file system remains in the container itself.
- So if you store any data in a container and stop or remove (rm) your container before backing up, it will destroy all your changes and data.
- For **persistenting data** we have to map a directory outside the container(probably in docker host), where we can backup the data.
- For mapping directory or volume, use the option `-v dir/path/name:internal/dir/path/name`.

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

## What can you containerise

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
- Docker swarm will take of placing the containers in the hosts, such that its highly available.
- To configure swarm, one of the docker hosts, should act as a manager(master) and all other docker hosts as workers(slaves).
- To initialize docker swarm trigger this command on docker manager(master) `docker swarm init` system.
- The previous command will give a command, and that command is to be issued in all the slave system.
  `docker swarm join --token <token-id>`
- Once the slave system joins the master they are known as **nodes**.
- In docker compose file: the below example will deploy five instances of the service across the docker:hosts available.

```yml
deploy:
  replicas: 5
```

- Deploy the above docker file by issuing below command:

```sh
docker stack deploy -c docker-compose.yml
```
