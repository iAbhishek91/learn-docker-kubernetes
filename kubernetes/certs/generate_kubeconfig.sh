# Gnerating several kube config for several k8s component
# - Kubelet kubeconfig to satisfy node authorization
# - kube-proxy kubeconfig for kube-proxy service to communicate with API server.
# - kube-controller-manager kubeconfig for kube-controller to communicate with API server.
# - kube-scheduler kubeconfig for scheduler to speak with API server
# - kube admin kubeconfig for admin to communicate with API server and hence the cluster.

# ------------------------------- Kubelet ---------------------------------
# we will not point to any perticular kube-api, instead we will use external Load balancer in our case its nginx load balancer which will point to all the three API server. Each API server points to etcd cluster

EXT_LOAD_BALANCER_IP=192.168.1.248

# in kubeconfig there are three main parameter
# cluster info
# context
# current context
# user


for instance in master1-rke master2-rke; do
  # configure the cluster section in the config file
  kubectl config set-cluster kubernetes-the-hard-way --certificate-authority=ca.pem --embed-certs=true --server=https://${EXT_LOAD_BALANCER_IP}:6443 --kubeconfig=${instance}.kubeconfig

  # configure the user and its authentication details
  kubectl config set-credentials system:node:${instance} --client-certificate=${instance}.pem --client-key=${instance}-key.pem --embed-certs=true --kubeconfig=${instance}.kubeconfig

  # configure the context
  kubectl config set-context default --cluster=kubernetes-the-hard-way --user=system:node:${instance} --kubeconfig=${instance}.kubeconfig

  # configure default context
  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done


# ------------------------------- Kube-proxy ---------------------------------
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


# ------------------------------- Kube controller ---------------------------------
 kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig


# ------------------------------- Kube-scheduler ---------------------------------
 kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig


# ------------------------------- Kubel admin ---------------------------------
 kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
