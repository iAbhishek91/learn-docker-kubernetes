# Kubelet

As we know its the captain of the ship, major functionality

- **register/etc a nodes** as instructed by API-server
- **send status to API-server back about the status**
- **creates a pod** by interacting with container runtime
- **Monitors and generate logs about the status of the nodes**
- **kubelet are not deployed in container** and its not part of kubeadm as well.

## installation/configuration of kubelet

Kubelet runs as service and takes in a config file. **kubelet-config.yaml**

```sh
# kubelet.service
ExecStart=/usr/local/bin/kubelet \\
--container-runtime=remote \\
--image-pull-progress-deadline=2m \\
--kubeconfig=/var/lib/kubelet/kubconfig \\
--network-plugin=cni \\
--register-node=true \\
--v=2 \\
--config=/var/lib/kubelet/kubelet-config.yaml
```

```yaml
# /var/lib/kubelet/kubelet-config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusterDomain: cluster.local
fileCheckFrequency: 0s
healthzPort: 10248
cluster DNS:
- 10.96.0.10
httpCheckFrequency: 0s
syncFrequency: 0s
authentication:
  anonymous:
    enabled: false
```

## validating and inspect config

```sh
ps -aufx | grep kubelet
## OUTPUT
# root 2095 1.8 2.4 698798 23423 ? Ssl  02:32   0:36  /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubeket.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=cgroupfs -cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cni

## inspect /var/lib/kubelet/config.yaml
```

## Security aspect of the kubelet

- kubelet listen at two port: **10250** and **10255**
- **10250**: Serves API that allows full access
- **10255**: Serves API that allows unauthenticated anonymous read-only access

```sh
# there are number of API endpoints available
curl -Ks https://localhost:10250/pods/
curl -Ks https:localhost:10250/logs/syslogs
#/attach
#/containerLogs
#/cri
#/exec
#/healthz
#/logs
#/metrics
#/pods
#/portforward
#/runningpods
#/spec
#/status
```

Both 10250 & 10255 opens up new security risks, as anyone who knows the IP address of the nodes can go in and perform any task that API-server does, because these ports by default allows all. described below

**OUR OBJECTIVE HERE** is to secure kubelet's port, on high level we will perform below:

- disable the read-only port(10255-default, or any custom configured)
- enable authentication and authorization for 10250 port

### Disable readonly port

Readonly port are HIGHLY RECOMMENDED to be disabled, as we dont want anyone to access the cluster without any authentication and authorization mechanism.

```sh
# in kubelet.service
ExecStart=/usr/local/bin/kubelet \\
--read-only-port=10255
```

```yaml
# Recommended approach
# in kubelet-config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
readOnlyPort: 0 # 0 disables the port, if any other number or default 10255 is set its enabled
```

### Kubelet Authentication

Similar to Kube API server: kubelet performs, Authentication and Authorization as well when someone hits the kubelet endpoints

By **default there is no security enabled** for kubelet, "curl -K https://localhost:10250/pods" lists all the pods running on that cluster.
HIGHLY RECOMMENDED: This behavior can be change by setting **"--anonymous-auth=false"** flag or in the kube configuration file: **authentication.anonymous.enabled** in the yaml

There are two authentication mechanism:

- Certificate based authentication(x509)
- API Bearer Token

**Certificate based authentication** configuration:

```sh
# in kubelet.service
ExecStart=/usr/local/bin/kubelet \\
--client-ca-file=/path/to/ca.crt
```

```yaml
# Recommended approach
# in kubelet-config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  x509:
    clientCAFile: /path/to/ca.crt
```

to authenticate you now need to pass the certificate

```sh
curl -sK https://localhost:10250/pods/ -key kubelet-key.pem -cert kubelet-cert.pem
# NOTE API server does the same way, API-server config contains --kubelet-client-certificate=kubelet-cert.pem and --kubelet-client-key=kubelet-key.pem
# This is how API-server authenticates with kubelet.
```

### Kubelet Authorization

By **default kubelet allows all actions on all APIs** once authenticated.

When authorization is configured to kubelet-config.yaml, Kubelet makes a call to API-server to validate that the request is authorized or not based on the API-servers authorization mechanism.

```yaml
apiVersion: kubeletConfiguration
kind: KubeletConfiguration
authorization:
  mode: Webhook # default to AlwaysAllow
```
