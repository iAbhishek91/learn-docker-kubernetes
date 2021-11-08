# Docker Runtime

What happens when docker runs `docker run -d nginx`

Step-1: docker CLI is invoked
Step-2: docker CLI converts the call into a REST  and invokes Docker Daemon
Step-3: docker Daemon:
  - checks for the image
  - contacts docker registry configured pulls the image
  - manges volumes and network
Step-4: containerd manages the container
Step-5: containerd-shim
Step-6: runC is the default container runtime
Step-7: runC then speaks with Linux namespaces and CGroup to create the namespace

Apart from **runC**, there are other container runtime. Each runtime needs to be compliant with **OCI**. Other run times are **kata** used by kata containers and **Runsc** used by gVisor. Refer CKS notes for more info on Kata container and gVisor.

We can run container using other runtime using docker like below:

```sh
docker run --runtime kata -d nginx
docker run --runtime runsc -d nginx
```

## How to configure container runtime in Kubernetes to spin pods

Here we assume that we are configuring Kubernetes to spin up gVisor pods.

Once gVisor is installed on the nodes, create the below kubernetes resource.

Note: you can have multiple `RuntimeClass` in a cluster

```yaml
apiVersion: node.k8s.io/v1beta1
kind: RuntimeClass
metadata:
  name: gvisor # can be anything
handler: runsc # should be exactly same as the name of the runtime
```

While creating pod mention the runtime that you wish to use

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  runtimeClassName: gvisor # use the name of the runtime class used.
  containers:
  - image: nginx
    name: nginx
```

How to validate that it gVisor is working as expected.

```sh
# execute the below command on the linux
pgrep -a nginx # note that this command do not provide any outputs, This indicate that gVisor is working fine.
pgrep -a runsc # this is running as a process on the native machine
# the above two command proves that pod nginx is completely sandboxed by gVisor
```
