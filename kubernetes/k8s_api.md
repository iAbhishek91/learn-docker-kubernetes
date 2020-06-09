# Structure of K8s API

## how to access

First way:

* find the API URL: `k cluster-info`
* hit the API using: `curl https://url:6443/version --key=/path/a.key --cert=/path/a.crt --cacert=/path/ca.crt`

Second way:

* get the token of service account.
* hit the API using: `curl -H "Authorization: Bearer $TOKEN" https://url/6443/version`

Third way:

* open proxy to API server: `k proxy`
* hit the API using: `curl http://127.0.0.1:8001`

## API path structure

/: list all the apis

/api: versions details. Array of version available. Each item in the array represent a group and version. Under api there is no group, hence only one item is listed ("v1") - version. **namespaces**, **pods**, **rc**, **events**, **endpoints**, **nodes**, **bindings**, **PV**,**PVC**, **cm**, **secrets**, **services**
/api/v1:
/api/v1/namespaces/blue: to see all the pod under one namespaces
/api/v1/namespaces/blue/pods/podName: to see details of one pod.

/apis: these have all new features and have version and groups under it.
/apis/apps/v1/: all apps resources of version v1
/apis/apps/v1/deployments: all deployments
/apis/apps/v1/namespaces/default/deployments/: all deployments of a particular namespaces.
/apis/extensions/v1...
/apis/networking.k8s.io/v1
/apis/networking.k8s.io/v1beta1


/version: get the version
