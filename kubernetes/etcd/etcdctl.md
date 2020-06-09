# etcdctl

Its a client for etcd database.

## download and install etcdctl

Its downloaded as part of etcd using the below command

```sh
wget -q --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"
tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/
```

## set env variable

in bashrc in order etcdctl to work.

```sh
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CERT=/etc/etcd/kubernetes.pem
export ETCDCTL_KEY=/etc/etcd/kubernetes-key.pem
export ETCDCTL_CACERT=/etc/etcd/ca.pem
```

>NOTE: CLI names are always in format ETCDCTL_(in caps cli options)

## pass cluster info from CLI

```sh
etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```

## Imp etcdctl command

```sh
# cluster endpoints details in table format
etcd -w table endpoint --cluster status
ETCDCTL_API=3 etcdctl -w table endpoint health

# cluster health
etcdctl -w table endpoint --cluster health

# member details in table format.
etcdctl -w table member list
```
