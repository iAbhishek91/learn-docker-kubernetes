# Docker commands

## Exit from a docker

```sh
exit
```

## docker pull

- This command is to download a docker image from the registry.
- If the image version is not mentioned explicitely, then the latest version will be used. For example: `docker pull ubuntu` will download `ubuntu:latest`. This known as a **tag**.
- By default, name of the images are downloaded from `library` folder. However, if you have your own images the name should be in formant `username/imagename`.

> Note: This command is triggered by `docker run` command as well if the image is not found locally.

```sh
docker pull ubuntu
```

- To download a specific version of ubuntu, mention the tag separated by colon.

```sh
docker pull ubuntu:17.4
```

## docker run

- It runs a container from a docker image. If the image do not exists it will go out to the registry and download the docker image and then run it. This is only done for the first time, for subsequent execution the same image will be used.
- Used to run a command in docker container.

```sh
docker run ubuntu
```

- docker containers are meant to run services or commands.
- If there is nothing to be exeuted, docker terminates the container immideately.
- `docker run ubuntu` will run the container and exit as there is nothing to be executed within the container.
- We can execute any commands, and until and unless that command finishes.
- the above example will keep the container alive for 10 seconds.

```sh
docker run ubuntu sleep 1000
```

- To **login to a container** automatically use the option `-it`.

```sh
docker run -it centos bash
```

- **Naming a container**

```sh
docker run --name=some_name image_name
```

- By default the containers runs in **attach mode**. However, to run the container as a background job use the option `-d`, this will run the container in **detach mode**.

```sh
docker run -d centos sleep 10
```

- to change from detach mode to attach mode, rarely used:

```sh
docker attach my_container
```

- to update the **ENTRYPOINT** command of the image.

```sh
docker run --entrypoint new-command my-image-name [command]
```

- to pass an environment variable to a container when a image is ran. using `-e` option.
- In the below example: APP_COLOR environment is set to red.

```sh
docker run -e APP_COLOR=red my-image-name
```

- By default container do not listen to **stdin**(inputs from user) of hosts.
- To containerise this type of app, use `-i` command.

```sh
docker run -i my_container
```

- **Port mapping** -p docker-host-port:container-internal-port
- We can run multiple instances of the web services in separate containers andmap to different docker host port.
- Obviously, use of one port multiple times are prohibited.

```sh
docker run -p 80:5000 my_webapp
docker run -p 81:5000 my_webapp
docker run -p 82:5000 my_webapp
docker run -p 83:5000 my_webapp
```

- **Volume mapping**
- The external drive will be mount and will be used to store any data inside the container. use `-v` option.
- another way to mount using `--mount`

> Note: this may throw some permission issue, you may have to use some other option. like `-u root`.

```sh
docker run -v my/dir/path/name:container/dir/path/name mysql
docker run --mount type=bind,source=my/dir/path/name,target=container/dir/path/name mysql
```

- **resource managment**
- restrict container to use only certain percentange of the CPUs use `--cpus`. The below example, restricts the container to use upto 50% of CPU.
- restrict container to use only certain amount of memory use `--memory`. The below example, restricts the container to use upto 100 mb of RAM memory.

```sh
docker run --cpus=.5 ubuntu
docker run --memory=100m ubuntu
```

- **Running docker cli from other remotely**

```sh
docker -H=ip-of-docker-host:port [any command] [other-parameter] #syntax
docker -H=10.123.2.1:2375 run ubuntu #example
```

- **Linking** two container
- this can be done using option `--link service-required:host-which-provide-the-service`
- *linking this way is deprecated, however the idea remain the same.*

- In docker-compose version 2 and above: the services are by default linked in the same bridge network, hence linking is not required.

> Note: --name=any_name should be used while running redis, so that we can use the name of the host to link.

```sh
docker run --link redis:redis image-dependent-require-redis
```

## docker inspect

- This command prints lot of information about the contianer that is running.
  - Environment variable
  - Networking details
  - File system and space utiized
  - many more

```sh
docker inspect container-id
```

## docker exec

- A running container is required for this command to work.
- This command will execute a command provided inside the docker container.
- This command needs a container name or ID, where you wish to execute a command.

```sh
docker exec my_container cat /etc/hosts
```

## docker ps

- Without any option, it lists all the running container.
- To see all the running and previously container:

```sh
docker ps -a
```

## docker stop

- To stop a running container.
- Mention the name of the container-id to stop a container.
- Verify the status of the container just stopped using `docker ps -a`.
- Note: stop command will not remove the container from the disk, it will stop it.

```sh
docker stop my-container
```

## docker rm

- To remove the container from the disk.
- Verify the container using `docker ps -a`. The container should not be displayed.

```sh
docker rm my-container
```

- Removing multiple container at time. Mention first few character of the container id.

```sh
docker rm 82 15 e4 57 de
```

## docker images

- To see all the images available in the disk

```sh
docker images
```

## docker rmi

- To remove an image from the disk.
- Verify the image is not available in the disk using `docker images`.

> Note: Before removing an image, make sure that all the container of that image are removed. Else an error(conflict) is thrown.

```sh
docker rmi my-image
```

- Removing multiple images at time. Mention first few character of the image id.

```sh
docker rmi 5d 31 5h
```

## docker build

- This command is used to create docker image file from the docker file.
- Each layer is **cached**.
- In case there is a failure in the build process, the previous sucessful steps will be used from cache.
- Cache is also used when we are rebuilding our docker image after modifying the dockerfile.

> Note: Cacheing only work from top, if any step has changed in between. Docker will not consider the cache even though the steps are same. They will be build from scrach.

```sh
docker build Dockerfile  -t account-username/my_image
```

## docker login

- Login to you docker hub using docker username and password.
- Enter you credential.

```sh
docker login
```

## docker push

- This command is used to push the image to the public docker image

> Note: you need to login before pushing any images to public.

```sh
docker push account-username/my-image
```

### FROM

- this instruction is used to mention the base image.
- every image should be based out from an existing image.

```sh
FROM imagename:tag
```

### RUN

- instruct to run a perticular command on the image.

```sh
RUN apt-get update
```

### COPY

- this will copy files from source to destination (inside the container).

```sh
COPY . /user/foldername
```

### ENTRYPOINT

- this will allow use to instruct a command, which will be run when the image is run as a container.
- this can be given as array. For example `node index.js` can be mentioned as `ENTRYPOINT ["node", "inde.js"].

## docker history

- the **layered architecture** of the image can be viewed using this command.
- this command also shows the size of each layer.

```sh
docker history image-name
```

## docker-compose up

- to bring up the entire stack up, we can execute the coammnd `docker-compose up`.

## docker network

- by default docker creates only one bridge network with a docket hosts.
- the above command is used create, view and update networking detials of a docker host.

- to **create**

```sh
docker network create --driver bridge --subnet 182.18.0.0/16 custom-isolated-network
```

- to **view all the networks**

`docker network ls`

## docker volume

- we can create delete a volume using this volume.
- while creating it will create volumes under `var/lib/my_data_volume`.

> Note: if volumes are not created before `docker run`, then docker will automatically create a volume under volume folder. So using this command is totally optional at the time of making this note.

```sh
docker volume create my_volume #create a new volume
docker run -v my_volume:/var/lib/mysql mysql #utilizing external volume
```

## docker system

- this command displayes all info about docker hosts.
- to see the storage consumed by docker, use `df` option.
- to see the break down of the size take by each image use `df -v` option.

```sh
docker system df
docker system df -v
```

## docker swarm

This commands are mentioned in the note section

## docker node

This commands are mentioned in the note section.
