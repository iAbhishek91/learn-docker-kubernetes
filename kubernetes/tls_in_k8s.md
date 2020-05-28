# TLS and K8s

* Every communication between the components are secured.
* server and client component has a pair of certificate (public key that is signed by CA signed) and a private key.

## create a CA

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

```sh
# Performed by the new user: create a private key
openssl genrsa -out admin2.key 2048

# Performed by the new user: create a csr using the private key
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
openssl x509 -req -in jenkins.csr -CA /path/ca.crt -CAKey <(cat /path/ca.key) -CAcreateserial -out developer.crt -days 730
# OR using config
openssl x509 -req -in etcd.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd.crt -extensions v3_req -extfile etcd.cnf -days 100

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
```
