# Kubernetes Dashboard

We all know what it is, here we look on how dashboard can open up security risk?

Dashboard were not really protected, and refer below [realtime attacks that were performed on tesla and other companies](https://redlock.io/blog/cryptojacking-tesla).

## Details on kubernetes dashboard deployment

As we know dashboard is deployed from a [public github](https://github.com/kubernetes/dashboard) recommended.yaml file.

- namespace **kubernetes-dashboard**
- deployment **kubernetes-dashboard**
- svc: **kubernetes-dashboard** a ClusterIP svc to expose the above
- config maps: containing secrets and certificates

## How we access Kubernetes dashboard

We have multiple options,  endpoint exposed by our ingress or load-balancer
or via proxy or port forward or make the svc of type NodePort and access if your network is secure.

There is another way to put some [auth-proxy](https://www.youtube.com/watch?v=od8TnIvuADg) in the namespace, which authenticate all the requests and the forwards it to the dashboard. *(this is out of scope for CKS exam)*

```sh
https://locahost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy
```

## Authentication mechanism for K8s Dashboard

When we have the dashboard, we need to login either using a Token(Bearer Token, can use service account token as well)

or using kubeconfig.
