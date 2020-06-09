# Well known paths in K8s

/var/lib/kubelet/config.yaml: cgroup config is mentioned. This is used by kubeadm tool.
/etc/cni/net.d/ : directory keeps all the configuration of the network plugins. If there are multiple file here, kubernetes will choose in alphabetical order. It informs which binary to consider from /opt/cni/bin. config file standards are defined by CNI. These JSON structure input is given by kubernetes as a input to any CNI plugin like calico, flannel, weave.
/opt/cni/bin/: all cni binaries are kept.
~/.kube/my-kube-config.config: kube config file