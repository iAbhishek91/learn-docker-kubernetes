# Ingress

Its not a build in component and hence do not come by default.

They consist of two part: **ingress controller** & **ingress resource**.

## Ingress controller

Its the actual ingres solution that we need install. Its can be anything GCE, Ingress, etc, etc

Its a deployment that we do after deploying downloading.

### Deployment details

```sh
# selector: name=nginx-ingress
# replicas: 1
# service account: nginx-ingress-serviceaccount
# strategy type: rolling update (default)
# image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
# ports: 80/tcp, 443/tcp
# args: /nginx-ingress-controller, --configmap=$(POD_NAMESPACE)/nginx-configuration, --default-backend-service=app-space/default-http-backend
# env: POD_NAME: v1.metadata.name, POD_NAMESPACE: v1:metadata:namespace
```

### replica-set details

below RS is created by the above deploy, hence all the info are same

```sh
# selector: name=nginx-ingress, pod-template-hash=59dfb9d88
# replicas: 1
# service account: nginx-ingress-serviceaccount
# image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
# ports: 80/tcp, 443/tcp
# args: /nginx-ingress-controller, --configmap=$(POD_NAMESPACE)/nginx-configuration, --default-backend-service=app-space/default-http-backend
# env: POD_NAME: v1.metadata.name, POD_NAMESPACE: v1:metadata:namespace
```

### pod details

below PO are created by the above RS.

```sh
# ip: 10.88.0.5
# image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
# args: /nginx-ingress-controller, --configmap=$(POD_NAMESPACE)/nginx-configuration, --default-backend-service=app-space/default-http-backend
# env: POD_NAME: nginx-ingress-controller-59dfb9d88-fwx8p, POD_NAMESPACE: ingress-space
# Mounts: /var/run/secrets/kubernetes.io/serviceaccount from nginx-ingress-serviceaccount-token-bc5m7
```

### config map

```sh
# self link: not sure how it will be useful
# api/v1/namespaces/ingress-space/configmaps/nginx-configuration
```

### node service details

this service is used to connect external world with k8s cluster ingress component.

```sh
# selector: name=nginx-ingress
# type: NodePort
# ip: 10.97.182.193
# port: http 80/TCP
# target port: http 80/TCP
# node port: http 30080/TCP
# endpoints: 10.88.0.5:80
# port: https 443/TCP
# target port: https 443/TCP
# node port: https 30877/TCP
# endpoints: 10.88.0.5:443
# session affinity: none
```

## Ingress resources

There can be multiple ingress resources as they are namespaces specific. Hence we can have one ingress per namespaces (best practice).

But there can be only one controller, which all the resources will be pointing to.

### creating ingress

```yaml
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pay-service
          servicePort: 8282
        path: /pay
```

### Multiple ingress resources

need to make sure your Ingress targets exactly one Ingress controller by specifying the ingress.class annotation, and that you have an ingress controller running in your cluster.

nginx.ingress.kubernetes.io/rewrite-target /

without rewrite option above the path option will be triggered in the application as well. Application is serving at / and not at /watch or /wear.

https://kubernetes.github.io/ingress-nginx/examples/rewrite/
