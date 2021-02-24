# Networking in k8s

- K8s do not provide solution for this, this is to implemented by the user
- CNI comes with a helping hand
- there are standards that are clearly defined though
  - every pod should have a unique IP
  - every pod should be able to communicate in the same node
  - every pod should be able to communicate in the cluster.

## How pod communicate

- Each node are having a IP address and can communicate with each other using LAN
- Each pod have a IP address
- Each node have a bridge network(should be in different network) and assign a IP address to the bridge network(RFC 1918).
- if there are three nodes the network may look like
  - node-1(192.168.1.11): 10.244.1.1/24
  - node-2(192.168.1.12): 10.244.2.1/24
  - node-3(192.168.1.13): 10.244.3.1/24
- we can add route like below to enable communication.
  - node-1: ip route add 10.244.2.0/24 via 192.168.1.12
  - node-1: ip route add 10.244.3.0/24 via 192.168.1.13
  - node-2: ip route add 10.244.1.0/24 via 192.168.1.11
  - node-2: ip route add 10.244.3.0/24 via 192.168.1.13
  - node-3: ip route add 10.244.1.0/24 via 192.168.1.11
  - node-3: ip route add 10.244.2.0/24 via 192.168.1.12
- Instead of the above step we an configure that in the router instead on each node.
  - 10.244.1.0/24 gateway 192.168.1.11
  - 10.244.2.0/24 gateway 192.168.1.12
  - 10.244.3.0/24 gateway 192.168.1.13
- this creates a large network runs across all the nodes: 10.244.0.0/16
- All these are done internally by CNI

## CNI in k8s

- CNI is configured in the kubelet as it is responsible for creating pods. Below options are provided
  - --network-plugin=cni
  - --cni-conf-dir=/etc/cni/net.d # this provides which plugin to be used. in case of multiple file, it will choose in alphabetical order.
  - --cni-bin-dir=/etc/cni/bin # bin directory contain all the plugin as executable.
