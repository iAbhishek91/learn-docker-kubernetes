# Helm

package manager of kubernetes. It can be treated as maven, npm or docker.

- There are CLI,
- There are global repository, open source developer commit to that repo, which can be reused.

> we are talking about helm 3 (without tiller)

## Main there component of helm

**Chart** :

**Repository** :

**Release** :

## How helm3 work without tiller

In any scenario, helm need to authenticate itself with API server. In helm-3 it uses kubeconfig file used by kubectl to authenticate with the API server.
