# this is mainly used by etcd and API server
for instance in master1-rke master2-rke master3-rke; do
  scp encryption-config.yaml ${instance}:~/
done

