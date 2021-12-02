# Kubernetes Security Primitives

On high level our objective here is to:

- Secure the nodes on which clusters runs
- secure kube-apiserver
  - Who can access the cluster?
  - What can they do? RBAC
- secure kubelet
  - how to make sure connection between api-server and kubelet is secure *if kubelet start taking instruction from anywhere else, then major part of the cluster is compromised.
- Securing networking within the cluster

## Authentication

Different users that access the cluster most commonly

- Admins(Users)
- Developers(Users)
- Application End Users (they do not access the cluster directly instead application manage their access internally)
- Service Accounts(Bots)

There are different Mechanism kube-apiserver authenticate users:

- static files - username and password,
- static files - username and token,
- certificates and LDAP
- and service account

**BASIC authentication**:

THIS IS NOT RECOMMENDED AUTHENTICATION MECHANISM. This also deprecated on 1.19 version of Kubernetes.

- create a csv file with "password", "username" and "user-id" and "group-id"(optional) and pass it on to api-server using *--basic-auth-file=user-details.csv*.
- create a csv file with "token", "username", "uid" or "group-id"(optional) and pass it on to *--token-auth-file=user-token.csv*

```csv[user-details.csv]
password123, user1, u001
password123, user2, u002
password123, user3, u003
password123, user4, u004
```

```csv
token-1,user01,u0001,group1
token-2,user02,u0002,group1
token-3,user03,u0003,group2
token-4,user04,u0004,group2
```

> Note if you change the option of running api-server, you must restart to apply the changes. If we are using kubeadm, then we need to just update the pod of "kube-apiserver.yaml" and kubeadm will automatically take care of these.

how to authenticate using Basic auth?

```sh
# using username and password
curl -v -k https://localhost:6443/api/v1/pods -u "user1:password123"

# using username and token
curl -v -k https://localhost:6443/api/v1/pods --header "Authorization: Bearer token-1"

IMPORTANT: role and role-binding are still required to be defined.
```

**service account**: token that is created can also be used like above

disable **spec.automountServiceaccountToken: false** in the pod

```yaml
#CSR
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: akshay
spec:
  groups:
  - system:masters
  - system:authenicated
  username: akshay
  request: $(cat /path/to/csr | base64 | tr -d '\n') # use this command ot get the string and paste it
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```

```sh
# approve the certificate
k certificate approve akshay

# retrieve certificate
k 
```

## Authorization

Refer: 03a-authorization-rbac.md

## Kubelet

Refer: 03b-kubelet.md

## kubectl Proxy and Port Forward

Refer: 03c-kubectl-proxy-n-port-forward.md

## k8s dashboard

Refer 03d-k8s-dashboard-security.md

## platform binary verification

Validate the checksum hash provided with the binaries to make sure that you are using the correct binary.

>NOTE: A Attacker may change the binary over the network while the binary is getting downloaded.

<details>
<summary>Click to open</summary>

```sh
shasum -a 512 kubernetes.tar.gz # note this should match with what provided on the kubernetes github release page
sha512sum kubernetes.tag.gz # same command however, use in linux
```

```sh
# FOR FUN: how you can change the SHA of a binary easily(by changing the content of the file)
# download the binary
wget url

# decompress the binary(xtract, file, verbose)
tar -xfv kubernetes.tar.gz

# change the version file
echo v1.20.1 > version

# compress the file
tar -czvf kubernetes.tar.gz /kubernetes 
```

</details>

## Network policy - secure networking

Flannel do not support network policies.

Other does: like Calico, Weave-net

<details>
<summary>click here for a example...</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    # note we can have AND or OR operation between the from/to policies
    # for below example, podSelector AND namespaceSelector are combined, we can separate them by putting a "-" in front of namespaceSelector rule.
    # in Summary, from/to takes list of rules, and each rules are applied with OR condition, however if we want we can merge them to one rule to be applied with AND condition.
    - podSelector:
        matchLabels:
          name: api-pod
      namespaceSelector: # this is optional which allows traffic from only one namespace, of this is the only config without podSelector, then all pods from the current namespace is allowed.
        matchLabels:
          name: prod
    - ipBlock: # this is used when our traffic are from physical server and not part of kubernetes resources like pods or services
        cidr: 192.168.5.10/32
    port:
    - protocol: TCP
      port: 3306
```

</details>

## Ingress

Rules and paths

<details>
<summary>click here to create ingress controller</summary>

```sh
# create a ns for ingress contoller
k create ns ingress-space
# create a empty cm in the new ns
k create cm ingress-configuration
# create a sa
k create sa ingress-serviceaccount
# deploy the ingress-controller as a deployment
k create -f deployment.yaml # (provide in internet) has reference to the SA, Environment variable: name and namespace, command, configmap and correct image name
# create a svc of type Nodeport or LB
k expose deploy ingress-controller --name ingress --type NodePort --port=80
```

</details>

## securing docker daemon

most commonly docker have been container runtime for docker.

- docker listens at internal linux socket at path /var/run/docker.sock. *Linux socket is basically an IPC (inter-process communication) mechanism, which enable one process to communicate with other process*. This basically means docker daemon can be accessed only within the same host and docker-cli, can communicate with the docker daemon at this socket.
- Docker cli, from other system cant connect to docker host/docker daemon by default. To achieve that we need to expose docker to attach with the TCP connection. `dockerd --debug --host=tcp://192.168.1.10:2375` *NOTE: 2375 is default port for unencrypted traffic*. Now other user can connect to TCP socket with this env variable to connect to the docket host: export **DOCKER_HOST**="tcp://192.168.1.10:2375 && docker ps" **THIS is extremely risky and poses potential security risk, as there is not authentication or authorization mechanism**
- **How to enable security on the docker host?**
  - First harden the docker host itself.(for example: disabling root, restricted access on sudo, disable password base authentication, strict ssh policy, disable usb, unused ports, antivirus, networking around the host)
  - Exposing docker host: make sure the interface is private and below point
  - Enable tls by using the command "dockerd --debug --host=tcp://192.168.1.10:2376 --tls=true --tlscert=/var/docker/server.pem" --tlskey=/var/docker/serverkey.pem" *NOTE: 2376 is for encrypted traffic*. *Both server.pem and serverkey.pem are signed by private CA. For accessing, **DOCKER_TLS**=true. Till this point there is no authentication, just encryption using TLS
  - Now we enable certificate based authentication: for that we need to provide **CAcert.pem** to the docker daemon, and this CA will sign the users certificate pair, and only with that those certificate users can communicate with the docker daemon. Now to access either pass the certificate in cli OR in the .docker directory under user home.
- All these configuration can be moved to **/etc/docker/daemon.json**, now if the configuration file is configured, the no options are required to be passed to docker daemon or while running docker using systemctl

```json
{
  "debug": true,
  "hosts": ["tcp://192.168.1.10:2376"],
  "tls": true,
  "tlscert": "/var/docker/server.pem",
  "tlskey": "/var/docker/serverkey.pem",
  "tlsverify": true,
  "tlscacert": "/var/docker/caserver.pem"
}
```

```sh
systemctl status docker # using Linux service
dockerd --debug # run docker manually in debug mode, same is done within linux service
```
