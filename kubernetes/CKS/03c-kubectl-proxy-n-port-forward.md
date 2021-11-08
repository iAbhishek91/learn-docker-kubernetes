# Kubectl from security perspective

First, what is the risk?

- Its the kubeconfig file(default at .kube/config) as its shared with many people and it stays in local laptop of every admin, dev security or networking team.
- **k proxy**, once proxy is on, no need to authenticate separately as proxy will fetch the information from kubeconfig file.
- **k port-forward services/nginx 28080:80**, access it using **curl http://localhost:28080**. Can also be done for pod **k prot-forward pod/test 8889:8181**

Access a clusterIP service using k proxy: **curl http://localhost:8001/api/v1/namespaces/default/services/nginx/proxy/**

## How we remediate these issue

Simple answer is be careful and harden your local system or workstation.

## Whats the difference b/w k proxy and k port-forward

k proxy: opens a port to API server
k port-forward: opens a port to pods and svc
