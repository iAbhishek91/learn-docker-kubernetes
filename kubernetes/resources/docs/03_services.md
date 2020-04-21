# Services

- They are used internally as well as externally.
- Every service have fixed IP address and port.
- Services uses level selectors to identify pods.
- Service can expose rc, rs, po, deploy, svc. Yes, service can be exposed through another service. Mainly done for security.
- type of services ClusterIP, NodePort, LoadBalancer, or ExternalName.
- service can be both TCP or UDP or SCTP.

## Creating service

### k expose

- Exposes resources as new kubernetes service.
- Can be used to create a headless service. Use *--cluster-ip='None'*.
- Can be used to create service from filename of the resource. Use *--filename=[/path/to/file.yml]*
- Labels are automatically taken from the underlying resource if not mentioned. If they are not convertible, then command will fail. Note: labels may fail only for deploy and RS, u know why :)
- Ports are also automatically taken from the underlying resource until explicitly mentioned..
- Target port (resource port) is defaulted to port of underlying resource. Can be name or number.
- to the object before its created, use *--dry-run='client'*. By default *--dry-run='none'*
- to use UDP *--protocol='UDP'*. By default its TCP.

```sh
k expose rc my_rc --type=LoadBalancer --name=my_svc
```

### k create

```sh
k create -f below.yml
```

```yml
apiVersion: v1
kind: Service
metadata:
  name: my_svc
spec:
  ports:
    - port: 80
      targetPort: 8080 # can be name or number
  selector:
    app: my_pod
```

## Testing and debugging service

### k exec

- test the *cluster IP* of the service. Cluster-IP is the internal to the cluster.
- resource type is pod by default if not specified. However we can change by mentioning the resource-type. For example: deploy/my_deploy, svc/my_svc

```sh
# execute a command in container. In this example we will hit the first container in the pod.
k exec my_pod -- curl -s http://10.10.10.10
# incase of multiple pod
k exec my_pod -c my_container -- curl -s http://10.10.10.10
# to exec in interactive mode
k exec my_pod -c my_container -i -t -- bash
# to get hostname of the first pod and first container of a deployment
k exec deploy/my_deploy -- hostname
# to get hostname of the first pod and first container of a svc
k exec svc/my_svc -- hostname
```
