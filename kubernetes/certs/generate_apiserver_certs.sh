KUBERNETES_HOSTNAME=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

CTRL_PLANE_HOSTNAME=master1-rke,master2-rke,master3-rke

CTRL_PLANE_IP=192.168.1.144,192.168.1.247,192.168.1.113

LOAD_BALANCER_IP=192.168.1.248

LOCALHOST=127.0.0.1

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=${KUBERNETES_HOSTNAME},${CTRL_PLANE_HOSTNAME},${CTRL_PLANE_IP},${LOAD_BALANCER_IP},${LOCALHOST} -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

