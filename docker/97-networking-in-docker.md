# Networking in docker

> Refer to networking_in_linux.md in interview questions repo.

For basic of namespace networking.

There are different networking option.

## NONE network

Container is not attached to outside world. Hence no communication ingress/egress.

```sh
d run --network none nginx
```

## HOST network

Docker container uses the hosts network, and there is no n/w isolation between the host and the container.

```sh
d run --network host nginx # no port mapping is required
```

## BRIDGE network

In this option a internal private network is created within the host.

This is the default option, and used when we deploy standalone containers.

```sh
d run nginx
```

## OVERLAY network

They connects multiple docker daemons together and enable swarm services to communicate with each other.

### How it works

- docker creates a n/w called as "bridge". This is same as the virtual network interface that we were creating.
  - validate using `d network ls`
- The interface is created on the host known as "docker0"
  - validate using `ip link`
- ip address is added: 172.17.0.1/24
  - validate using `id address`
- when we do docker run command
  - it creates a namespace
  - creates a pipe to establish connection between the v.network and the namespace. now they are part of same network and can communicate with each other.
  - port mapping is done, hence `-p 8080:80` is provided, which attaches the port of the namespace with the host. now external user can access the host:8080 to access the application. Internally this is done via iptables packet routing mechanism.
    - `iptables -t -A PREROUTING -j DNAT --dport 8080 --to-destination <containers-ip>:80`

## CNI

CNI are set of standard for creating a software that would be used by any container runtime to perform networking related tasks.

The software are generally known as plugins, there are multiple type plugins.

CNI defines the responsibilities of the container runtime like docker, rkt  or kubernetes and responsibilities for the cni plugins:

- Container runtime
  - must create network namespace
  - identify the network the container must attach to
  - to invoke network plugin (bridge), when container are added.
  - to invoke network plugin (bridge), when container are deleted.
  - JSON format network config
- Plugin vendors
  - support command line arguments ADD/DEL/CHECK
  - support parameters container id, network ns etc
  - manage IP address assignment to PODs
  - return result in a specific format.

> NOTE: Docker do not use CNI instead uses CNM(container networking model), however K8s uses CNI.
 