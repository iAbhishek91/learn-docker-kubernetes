# Service accounts

This are a/c(s) managed by Kubernetes.

They create a token automatically when they are created.

We can access k8s API using this token by passing it as below:

```sh
curl -k https://localhost:6443/api -h "Authorization: Bearer tokentokentoken..."
```

Every pod requires a  service account to authenticates itself with the API server. Secret token in automatically mounted based on the service account  passed. Mount location is */var/run/secrets/kubernetes.io/serviceaccount* you can fetch the token from any pod and access the API.

Default SA is very restricted, hence create custom SA if required.

We can't change Service account of a pod, pod must be recreated if changed.
