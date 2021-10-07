# Kubernetes Security Primitives

On high level our objective here is to:

- Secure the nodes on which clusters runs
- secure kube-apiserver
  - Who can access the cluster?
  - What can they do? RBAC
- Securing networking within the cluster

## Authentication

Different users that access the cluster most commonly

- Admins(Users)
- Developers(Users)
- Application End Users (they do not access the cluster directly instead application manage their access internally)
- Service Accounts(Bots)

There are different Mechanism kube-apiserver authenticate users:

- static files - username and password,
- static files - username and token,
- certificates and LDAP
- and service account

**BASIC authentication**:

THIS IS NOT RECOMMENDED AUTHENTICATION MECHANISM. This also deprecated on 1.19 version of Kubernetes.

- create a csv file with "password", "username" and "user-id" and "group-id"(optional) and pass it on to api-server using *--basic-auth-file=user-details.csv*.
- create a csv file with "token", "username", "uid" or "group-id"(optional) and pass it on to *--token-auth-file=user-token.csv*

```csv[user-details.csv]
password123, user1, u001
password123, user2, u002
password123, user3, u003
password123, user4, u004
```

```csv
token-1,user01,u0001,group1
token-2,user02,u0002,group1
token-3,user03,u0003,group2
token-4,user04,u0004,group2
```

> Note if you change the option of running api-server, you must restart to apply the changes. If we are using kubeadm, then we need to just update the pod of "kube-apiserver.yaml" and kubeadm will automatically take care of these.

how to authenticate using Basic auth?

```sh
# using username and password
curl -v -k https://localhost:6443/api/v1/pods -u "user1:password123"

# using username and token
curl -v -k https://localhost:6443/api/v1/pods --header "Authorization: Bearer token-1"

IMPORTANT: role and role-binding are still required to be defined.
```
