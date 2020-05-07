# Debugging a running container

## I need to know the container is running or not

docker ps -a -f=name='kube-proxy|etcd'
docker ps -a -f name-'kube-*|etcd'
docker ps -a -f=name='ngi*'

-f for filter: **list of filters** important to check: are https://docs.docker.com/engine/reference/commandline/ps/

## I need to the standard logs

docker logs etcd

## I need to know all the volume mapped

docker inspect -f '{{ .Mounts }} etcd

## I need to execute some command on the container

docker exec -it etcd ls /var/lib/etcd
docker exec -it etcd /bin/bash
docker exec -it etcd /bin/sh