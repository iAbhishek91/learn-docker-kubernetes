# kubesec

Used for static analysis of k8s resources or dockerfiles.

Kubesec runs as binary and use CLI to scan the k8s manifests(both YAML and JSON), like below

```sh
# install kubesec
wget https://github.com/controlplaneio/kubesec/releases/download/v2.11.0/kubesec_linux_amd64.tar.gz
tar -xvf  kubesec_linux_amd64.tar.gz
mv kubesec /usr/bin/

# scan using kubesec
kubesec scan pod.yaml
```

Or we can use the online tool, use it like below

```sh
curl -sSX POST --data-binary @"pod.yaml" https://v2.kubesec.io.scan
```
