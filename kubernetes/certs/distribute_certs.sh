# for k8s ctrl plane
for instance in master1-rke master2-rke master3-rke; do
  scp ca.pem ca-key.pem kubernetes.pem kubernetes-key.pem service-account.pem service-account-key.pem ${instance}:~/
done

# for k8s worker node
for instance in master1-rke master2-rke; do
  scp ca.pem ${instance}.pem ${instance}-key.pem ${instance}:~/
done
