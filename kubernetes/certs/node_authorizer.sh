# NOTE: this certs are used by kubelets client to speak with API server. This is facilated by K8s feature known as special purpose authorization mode.
# In order to be authorized by the Node Authorizer, kubelets must use a credential that identifies them as being in the system:nodes group, with a username of system:node:nodename.
# The below certificates are all meets the "node authorizer" requirement.

for instance in master1-rke master2-rke; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "name": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

if [ ${instance} == "master1-rke" ]; then
  EXTERNAL_IP=192.168.1.144
else
  EXTERNAL_IP=192.168.1.247
fi

echo "${instance} ${EXTERNAL_IP}"

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=${instance},${EXTERNAL_IP},${EXTERNAL_IP} -profile=kubernetes ${instance}-csr.json | cfssljson -bare ${instance}

done
