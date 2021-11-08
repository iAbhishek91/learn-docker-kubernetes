# TLS and K8s

## What is certificate

Certificate is used to create trust between two parties communicating. It serves two purpose

- it used to encrypt the data
- as well as to identify itself as trusted entitiy in the communication

### Interesting example of evolution

Step-1: Initially, client used to send credential in plain text over the network to authenticate to the server, however, this is not save as hacker can sniff the data and hack into the server.

Step-2: Client started encrypting the data with a random key. In this case the data is encrypted, and hacker cant read the data. But the server as well cant read the data as its encrypted, so user(client) needs to send the encryption key as well. So the threat remains same as hacker can get hold of the key and decrypt the data himself. This way is called **Symmetric encryption** as same key is used for encryption and decryption.

Step-3: Now comes in the **Asymmetric encryption**, where pair of key is used for encryption and decryption. In case of certificates they are known as private and public keys. The way it works is, if a data is encrypted with the public key, then it can be opened by the corrosponding private key only. *Lets take example of SSH: we generate a ssh key pair using ssh-keygen command, then send the public key is shared with the server's .ssh/authorized_key file, this locks down the server. Only users who have the private key can communicate with the server.* In case of certificate(TLS) its very simlar, the server generates a key pair, the public key is then attached with the certificate and shared with the client, client can encrypt the data with the public key and send it back to the server. Since server is the only one with the corrosponding private key it can safely decrypt the data.

Step-4: Now in previous step, back shared a certificate contianing the public key, however if you think this key is used to encrypt your confedintial data and passed on to the network. So there should be a way to validate that the certificate is coming from the bank you intend to, not from any other provider (*may be a hacker is providing you with the certificate, by tweaking your network and giving you a fake website which looks similar to the actual website*). So the concept of certificate signing comes into picture, a certificate can be self-signed or signed by CA(certificate authority). Self signed certificate are not safe.

Step-5: Now the question comes how do browser knows that the certificate is signed by legitimate CA, and not fake ones? CA have their private key and public keys. CA uses their private keys to sign the certificate, and the CA's public key is prebuilt within the browser, if not we can easily import the CA certificate into the browser. Hence browser can decrypt the certificate details and ensures that this is website is having a trusted(signed by CA which your browser knows). **IMP**: most of the public CA have internal offering, which can be hosted privately by the organization to host its own CA. Then you can install the private CA's public key in the browser of all the employee.

## Within the K8s

- Every communication between the components are secured.
- server and client component has a pair of certificate (public key that is signed by CA signed) and a private key.
- In each request, we need to send the clinet key(private key), client certificate and ca certificate.

**Question is why we need ca certificate?** the answer is to validate that client certificates are valid and signed by trusted user. Similar analogy why trusted CA's public key are installed in browser by default. For These reason remember CA.crt is to be drstributed to every client and server component that we discussed below.

```sh
curl https://kube-apiserver:6443/api/v1/pods --key admin.key --cert admin.crt --cacert ca.crt
```


## create a CA

> As discussed previously, CA should also have ca.csr and ca.crt

```sh
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "CN=KUBE-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
```

## server components

> Note they are not control plane component. Server component are components which host a service for others to consume.

* **API-server** has *three* pair of certificate
  * is the server used to serve all the component in k8s.
  * it speak with etcd server, hence it is a client for etcd.
  * it speak with kubelet server, hence it is a client for kubelet server.

* **etcd** has *one* pair of certificate
  * is the server which only receives connection from API server.

* **kubelet** has *two* pair of certificate
  * is the server, API server connects to kubelet fetch node level information.
  * it speak with API server, hence it is a client for API sever.

## client components

> Note they are not worker node component. Client component are components which only consumes services.

* kubectl for any user (at least one for admin)
* scheduler
* control manager
* kube-proxy

## Refer ssl commands

https://www.sslshopper.com/article-most-common-openssl-commands.html

### authentication using kubernetes API

> NOTE: Its responsibilit of controller mananger to enalbe this APIs. there are controller within controller manager for CSR-Approving and CST-Signing.
> NOTE: --cluster-signing-cert-file --cluster-signing-key-file values should be entered to make these API work.

```sh
# Performed by the new user: create a private key
openssl genrsa -out admin2.key 2048

# Performed by the new user: create a csr using the private key,
# NOTE system:masters group is requried field for configuring Admin users
openssl req -new -key admin2.key -out admin2.csr -subj “/CN=jenkins/O=system:masters”

# Performed by existing admins: create a CSR k8s resource
# base64 encoding is required to create the k8s resources
cat admin2.csr | base64

# CSR k8s resource YAML
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: admin-2
spec:
  groups:
  - system:authenticated
  usages:
  - digital signature
  - key encipherment
  - server auth
  request:
      LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2J6Q0NBVmNDQVFBd0tqRVBNQTBHQTFVRUF3d0dZV1J0YVc0eU1SY3dGUVlEVlFRS0RBNXplWE4wWlcwNgpiV0Z6ZEdWeWN6Q0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU1GTTlUNmJBUGhICmxVbzFSUHNLbDIxWEwwZnZLcWI1SmtjYWJJU0NRTkh2NzU1TVcrVEs0bEJoZWNhaGxoZnlyM2ZkdjR1czlJWGIKOEZubUxySWdxUXZMS0ErbXBZVERJWGFhV3kyQy90NzloaDRjRytnekN4M1pxaDhiU1Y1RlFwUXlnLzhmU1pVSQpibzhOL3JTUFNPd253L1UyWTkvQlVZT0xvdmEreGppZXZKalJRU0l4M2hDMDNTc1g0ZTc2UWtXczFZUGl4M0lTCms5ckxMUkQ1K1N5amVyS2hoVGJONlZwRXdOMFk3dkJUamY4dEtNQWpBT0t4MVJmV2ZiMDBaa0FNZndIU25ZS2IKMnhXcnc2KzBPcUkwcDlYc1pycHVEdU5RRlRaL1hUQ3Z0K1lyekZoaHhGbTlTQUxTeVVoVHNpdm9lTFJHMXFrUQo1aGVmekdyenFyRUNBd0VBQWFBQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVR0M1o3Y2FkVGFacFE3RUVKCjBKZGNxZzl2UnUvVHltWW1TSWFieWpVaE5wNDVVNEd0bm9OUTBKSmNTYlRWMzNsRy94bUdBNVErNjIxRUNYK0IKeTd2S200VEwxZmgzOEtPZSt2VkdjcVFFZ0wyUGVQZ1ppNzhnYlc1MTVZd1B3ODNvRjIzODNLRXhZbWFCekJwdQozNklQRUZTeHJZNUhzTDRVN0dPZllRbmVSYTlJdnJvNnNNYVNEMkhwNDdIZkg0eURTdGhWZVB6ZU01OUk3VmtuCjVtYmlWVlZwUk0zRlQzU0JpOVhWTXJKeElwc0hWekJob1RCL01LbnhxMkhMek5DWStISW5Lb3V2cVgzblRQM3UKNVJTd3ZiRnpMYzZxVEt0TzhzR2VYMWxseFZGU2ZsWXNIVjlvaVdBcHk1ZVhhcXoyQUhpU1RnUHNvZlFHVHlYbwpFT09mCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=

# create the object in cluster
k apply -f csr.yml

# validate the status of the object
k get csr
#NAME      AGE   SIGNERNAME                     REQUESTOR          CONDITION
#admin2   10s   kubernetes.io/legacy-unknown   kubernetes-admin   Pending

# approve the above request
# once it is denied, it cant be approved, however if its approved, it can be denied. In this case delete and recreate the csr in the system.
k certificate approve|deny admin2

# get the status certificate
k get csr
#NAME      AGE   SIGNERNAME                     REQUESTOR          CONDITION
#admin-2   16m   kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issued

# extract the certificate
k get csr admin2 -o yaml | grep certificate:

# convert it into a crt and share with the user
echo "LS0tLS1CRUdJTiBDRVJUSUZJQ..."  | base64 --decode > admin2.crt

# Perform by the new user: generate kube config file.
k config set-cluster admin2 --kubeconfig=admin2.kubeconfig --embed-certs=true --certificate-authority=ca.crt --server=https://192.168.1.216:6443

k config set-credentials admin-2 --client-certificate=admin-2.crt --client-key=admin-2.key --embed-certs=true --kubeconfig=admin2.kubeconfig 

k config set-context admin-2 --cluster=admin-2 --user=admin-2 --kubeconfig=admin2.kubeconfig

k config use-context admin-2
```

### Manually handling certificates

```sh
Create a user account:

#Create a namespace:
k create ns Jenkins

#create a private key
openssl genrsa -out jenkins.key 2048

#create a CSR using the private key
openssl req -new -key Jenkins.key -out jenkins.csr -subj “/CN=jenkins/O=lloyds”
# OR using config
openssl req -new -out san_domain_com.csr -key san_domain_com.key -config openssl.cnf

#sign the CSR using the cluster CA
openssl x509 -req -in jenkins.csr -CA /path/ca.crt -CAkey <(cat /path/ca.key) -CAcreateserial -out developer.crt -days 730
# OR using config
openssl x509 -req -in etcd.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd.crt -extensions v3_req -extfile etcd.cnf -days 100

# to view a certificate and it details
openssl x509 -in certificate/path/server.crt -text -noout

# role for the name space
kind: Role
apiVersion: brace.authorization.k8s.io/v1beta1
metadata:
  Namespace: jenkins
  Name: jenkins
rules:
- apiGroups: [“”, “extensions”, “apps”]
       Resources: [“deployments”, “replicasets”, “pods”]
       Verbs: [“get”, “list”, “watch”, “create”, “update”, “patch”, “delete”]

#. role binding
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
    Name: deployment-manager-binding
    Namespace: jenkins
subjects:
- Kind: User
       Name: jenkins
       apiGroups: “”
roleRef:
       Kind: Role
       Name: jenkins # name of the role and this should match
       apiGroup: “”

# setting credential for the user
k config set-credentials jenkins —client-certificate=/path/jenkins.crt —client-key=/path/jenkins.key

# setting context for the user
k config set-context Jenkins-context —cluster=kubernetes —namespaece=jenkins —user=jenkins

# separate out tube config to separate out  
{
  kubectl config set-cluster abhishek-cka    --certificate-authority=ca.crt    --embed-certs=true \    --server=https:192.168.1.223//:6443 \
    --kubeconfig=worker1.kubeconfig

  kubectl config set-credentials system:node:worker01 \
    --client-certificate=worker1.crt \
    --client-key=worker1.key \
    --embed-certs=true \
    --kubeconfig=worker1.kubeconfig

  kubectl config set-context default \
    --cluster=abhishek-cka \
    --user=system:node:worker01 \
    --kubeconfig=worker1.kubeconfig

  }
```

## What's inside a certificate contains

```yaml
Certificate:
  Data:
    Serial Number: 420327018966204255
  Signature Algorithm: sha256WithRSAEncryption
    Issuer: CN=kubernetes
    Validity
      Not After : Feb 123:41:28 2022 GMT
    Subject: CN=my-bank.com
 X509v3 Subject Alternative Name:
      DNS:mybank.com, DNS:i-bank.com,
      DNS:we-bank.com,
    Subject Public Key Info:
      00:b9:b0:55:24:fb:a4:ef:77:73:7c:9b
```
