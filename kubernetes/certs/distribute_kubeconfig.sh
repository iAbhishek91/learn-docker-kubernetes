# for worker node
for instance in master1-rke master2-rke; do
  scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done

# for ctrl plane
for instance in master1-rke master2-rke master3-rke; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
