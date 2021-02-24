# K8s networking

> Interesting: CNI is not supported by docker, docker uses something called CNM. Then How kubernetes uses docker as runtime engine? Refer below:

Docker have three type of networking, host,none and bridge. The bridge network in docker creates a bridge known as bridge (docker network ls). But this same bridge is known as "docker0". "docker0" is not used by kubernetes. While doing port forwarding it uses the port forwarding mechanism to allow traffic from one host:port to dockerhost(netns):port. This is done by adding entry in the nat table(in iptables) for chain forward and allow traffic there. view the rule in iptables of the host "iptables -nvL -t nat". Kubernetes always uses none networking for docker then manually adds the namespace to the CNI in use.

CNI: container networking interface
CNM: container networking model. (this is used by docker).

Both are standards for creating networking solutions.

> Note: Integration of CNI plugin with k8s is done by Kubelet as that is the component responsible for creating pod.

## physical networking on the cluster host

* Each host must have an network interface for communicating with the other hosts.
* Each host must have an address assigned and should be unique from other host.
* Each host should have unique MAC address configured.
* All the host should be connected to the network via bridge or other network devices. The bridge network should be able to consider all the sub-network as its child.
* below well-known port should be opened.

## well known ports

Max port range is 1 - 65535, 16 bit unsigned number.

API server: 6443
Kubelet: 10250
scheduler: 10251
ctrl manager: 10252
services: 30000 - 32767
etcd: 2379, 2380 (clients for HA)

## well known paths

/etc/cni/net.d/ : directory keeps all the configuration of the network plugins. If there are multiple file here, kubernetes will choose in alphabetical order. It informs which binary to consider from /opt/cni/bin. config file standards are defined by CNI. These JSON structure input is given by kubernetes as a input to any CNI plugin like calico, flannel, weave.
/opt/cni/bin/: all cni binaries are kept.
~/.kube/my-kube-config.config: kube config file

## Pod networking

* Every pod should have unique IP address (same and different nodes in the cluster).
* Every pod should able to reach other pod with NAT.

### manually solving the above problem

* *Lets assume the node have IP address 192.168.1.11/24, 192.168.1.12/24, 192.168.1.13/24*.
* each node creates a internal bridge network.
* this bridge is used to connect all the pod in the same node. *The bridge network has pipe to connect to all the pods, the bridge end of the pipe is named as veth0,1,2,3*.
* each bridge network may be on their private network Hence assign any private IP address. *To visualize lets assign address to bridge network: 10.244.1.1/24, 10.244.2.1/24, 10.244.3.1/24*.
* Hence all the pods get a IP address from the sub network. *one of the pod in node01 may have IP address 10.244.1.2, similarly one of the pod in the node02 may have IP address 10.244.2.2*.
* the bridge network forward traffic to physical interface of the node *probably eth0*.
* Now to enable internode communication we need to add routing table entry on each node. *to enable connection from node-1' bridge to node-2' bridge, add the below on node-1 ip route add 10.244.2.0 via 192.168.1.12. Similarly from node-1 to node-3, ip route add 10.244.2.0 via 192.168.1.13*.
* OPTIONAL step to make life easy: we can use a router to connect all the nodes and configure all the routing rules in router instead of each host. Now to configure default gateway as 192.168.1.0 which has all the routing rules defined.
* Now we have a big cluster network of address **10.244.0.0/16**.

Now, how this is done automatically when a pod is created? - magic of CNI, it automates the above process and assigns a IP address to each pod, and deletes it when the pod is deleted. Some part of the list is done by container orchestration tool(or container runtime) and few by the CNI plugin. See below for the roles of these two parties.

> Note: routing tables have limits on the number of entry, hence with 100 of nodes this is not possible hence most of the  CNI deploy their own agents on each nodes. This agent envelops the packets and send it through the network. on delivery the agent on the source decodes and retrieve the actual packet. 

## CNI bridge program

As all the platform, k8s, rkt, mesos have same problem to solve (networking between namespace between multiple nodes), hence they created a common program called bridge.

common steps: (as seen in network namespaces) all the below is done by the program bridge.

* create the bridge n/w (ip link add v-bridge type bridge)
* enable the bridge interface (ip link set v-bridge up)
* assign IP address bridge interface (ip addr add 192.168.1.1/24 dev v-bridge)
* create the pipe (ip link add veth-red type veth peer name veth-red-br)
* move the one end of the pipe to pod network namespace. (ip link set veth-red netns red)
* move the the other end to bridge interface (ip link set veth-red-br master v-bridge)
* assign ip address to the pipe (ip netns exec red ip address add 192.168.1.100/24 dev veth-red)
* enable the pipe interface (ip netns exec red ip link set veth-red up)
* enable NAT using IP masquerade ()

next simple we tell "bridge add red-container red-nw-namespace"

## standard for CNI

Few important standard defined by CNI. Two group of rules are defined - one for container runtime and other for the CNI program (also called as plugin). This is done so that all can be compatible.

For **container runtime**

* creation of network namespace
* identify the network the namespace should be attached to
* it should able to call the plugin, when container is added.
* it should able to call the plugin, when container is deleted.
* JSON format of configuration should be passed from container runtime to the plugins.

For **plugin/program**

* plugin should support ADD, DEL and CHECK functionality.
* must support parameters like container-id, network ns etc.
* must support IP assignment to the pods.
* must return result in specific format.

## Available plugin

All this solution are available as binary and are saved in "/opt/cni/bin/".

There are inbuilt plugin in kubernetes: we will learn about those (bridge, vlan, ipvlan, macvlan, | (following are IPAM plugins) DHCP and host-local)

Then third part CNI plugins - Weave, flannel, cilium, calico

## Lets examine how one of the plugin works - weave

most of the third party plugin works in this way.

* need to install plugin, also some supported plugin if required. For example weave-net requires portmap plugin as well to be installed. it uses that for host-port.
* the deploy the manifests from the URL provided by the client. The manifest also downloads binary and stores it in /opt/cni/bin

## How CNI and Kubelet are integrated

Kubelet binary has option to connect CNI plugin. below args are important.

* --network-plugin=cni
* --cni-bin-dir=/opt/cni/bin
* --cni-conf-dir=/etc/cni/net.d/ (this config should adheres to CNI standards)

If multiple configuration are available, it will execute in alphabetical order .

> Note: kubelet is one of the component that mostly installed on bare metal and not as a container. Hence to check the configuration look at ps (ps aufx | grep -i kubelet)

## IPAM in CNI

IP address management.

> Note: IP address assigned to the node are not scoped in IPAM CNI.

Scope of IPAM:

* who and how virtual bridge assign an IP ?
* who and how virtual bridge assign an IP subnet ?
* who and how IP is assigned to a pod ?
* where is the input comes from ?
* what is role of k8s and CNI plugin ?
* How it makes sure that no duplicate IPs are assigned ?

**WHO**? - CNI defines that CNI plugins are responsible for assigning IP address to the containers and bridge along with the subnet. This is internally done under the hood using the command "ip netns exec red  ip addr add 192.168.1.100/24 dev veth-red".

**How it makes sure that no duplicate IPs are assigned**? - CNI do not does it automatically, it depends on dhcp or host-local plugin. The plugin saves the available IP(in a list file in each node) from the IP range and then assign it to the pods or bridge. However, the functions that are responsible (DHCP or host-local)are invoked in the CNI plugin. You can see the configuration in the "/etc/cni/net.d/plugin-name.conf"

**Who and how virtual bridge assign an IP**?
**Who and how virtual bridge assign an IP subnet**?
**Who and how IP is assigned to a pod**?
CNI json config file in /etc/cni/net.d has a section called IPAM, where it get mention the Subnet (10.32.1.0/16), plugin type (DHCP or host-local).

This is implemented differently by different CNIs.

For example: weave by default assigns 10.32.0.0/12 (10.32.0.1 to 10.47.255.254)for the entire network. Hence its not mandatory to provide subnet while using weave net. Then the peers decide to split the IP address and assign it to each node. for example node-1 may be in sub-network 10.32.0.1, node-2 in 10.38.0.1 and node-3 in 10.44.0.1. So pods created in this nodes will be using this range only assigned to the nodes.

**where is the input comes from**? - this are either default or given as parameter to CNI plugins.

## Service network in k8s cluster

* service is not bound to a specific node (cluster wide concept). They are available across all the nodes and can be accessible using below techniques:
  * the IP address of the service.
  * the domain name of the service.
  * in case of NodePort its can be accessed using the ip_of_node:nodePort. Node port ranges from 30000 to 32767.
* services are nothing and do not have existence, as it do not have an interface assigned not even processes. They are mere assigned with a virtual IP address, which connects the endpoints of the pod via selectors. This is the reason they cant be accessed using ping, only via curl. Later we are going to see how virtual IP address is assigned to a service and how things work under the hood.
* services are managed by kube-proxy: see the role of kube-proxy below:
  * kube-proxy watches the API-server when a pod is created.
* Services have a pre-defined IP range (they are known as service IPs and are defined in api-server config). When a service are created they get IP from that range. Under the hood.
  * kube-proxy uses iptables (may be something else, see in kube-proxy logs) to create a forwarding rules. if incoming request comes to service IP address, then forward it to the actual pods. the actual pods IP address are obtained by the Endpoint resource attached to the service. Endpoint resource keep all the IP address incase multiple replicas exists. *Visualized it as a server waiting for accept connection, and whenever we request a pod either from internal network or external it forward the request to any of the underlying pods.*

## DNS

dns names and the hierarchy of sub domain:

> Note: for kube dns, the configuration is passed from a config map object. Look their for root domain after the kubernetes word. Kubernetes mentions the config to be used in k8s cluster. Also if you want enable pod DNS, change it in the same file.
> Note: resolv.conf is configured in side the pod automatically. this is done by kubelet.
> CoreDNS is deployed as a deployment and are hosted as a service with name kube-dns.

for services:

* svc_name
* svc_name.namespace_name
* svc_name.namespace_name.svc
* svc_name.namespace_name.svc.cluster.local (root domain)

for pod: (not enabled by default and full name need to be used.)

* 10-32-1-2.namespace_name.pod.cluster.local
