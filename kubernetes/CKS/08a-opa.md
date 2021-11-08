# OPA

Open Policy Agent: its another way to secure microservice. IT enforces policy for  I(Identity), O(Operation) and R(Resources)

OPA has nothing to do with username, password or certificate. OPA happens after authentication.

OPA, is authorization technique for micro services. With OPA application(micro services) need not implement any authentication mechanism.

OPA is deployed externally and every application(micro services) now authorize by sending the request to OPA.

OPA is language agnostic and integrates as a API.

OPA is designed in Go and is in-memory(everything is cached).

## OPA installation

OPA can be installed as service, container or pod(may be a sidecar) or as a library with in the application.

By default authentication and authorization are disabled. OPA runs on port 8181.

```sh
export VERSION=v0.27.1
curl -L -o opa https://github.com/open-policy-agent/opa/releases/download/${VERSION}/opa_linux_amd64

chmod 755 ./opa # make OPA executable

./opa run -s & # start OPA
```

## OPA load policy

OPA policies are declarative and easily extensible. Policies of OPA is written in **rego**. Hence the policy file extensions are *.rego.

```py
# file: example.rego
package httpapi.authz

# HTTP API request
import input # consumes API input

default allow = false # variable allow declared and set to false

allow { # variable allow declared previously will be set to true if below validation succeeds
    input.path == "home" # every line within the block is a condition
    input.user == "john" # and each one of them need to be TRUE, hence its like AND operation
}
```

Load the policy in opa execute the below command:

```sh
# load policy in OPA
curl -X PUT --data-binary @example.rego http://localhost:8181/v1/policies/example1 # example.rego is the filename and example1 is the name with which the policy is loaded.

# find out list of available policies
curl http://localhost:8181/v1/policies
```

Now from the application send the authentication JSON, to OPA, if successful, OPA returns JSON stating pass or fail.

> NOTE: OPA framework are available for multiple language, which can used to authenticate against OPA.
> NOTE: REGO, provides a playground for writing policies and testing them. There is also a REGA policy testing framework.

## OPA in Kubernetes

There are multiple way we can integrate OPA with k8s:

1. Using admission controller: we have already seen that there are validating admission webhook, were we host our own server and define our own Admisison controller. Instead of that we can connect validating admission webhook with OPA server.

1a. Install OPA somewhere in the infrastructure
1b. define the policy, and load to OPA. For kubernetes the request sent to OPA is standard format. Example below

```py
# file: kubernetes.rego
package kubernetes.admission
deny[msg] {
    input.request.kind,kind == "Pod"
    image := input.request.object.spec.containers[_].image # define a variable
    startswith(image, "hooli.com/") # deny if image name starts with "hooli.com/
    msg := sprintf("image '%v' from untrusted registry", [image])
}
```

```py
# file: kubernetes-1.rego
package kubernetes.admission

## this brings in data pods
# how this work, how OPA know about the resources in kubernetes?
# This is achieved by using the "kube-mgmt" service is a sidecar container along with OPA. This side car fetches all the resources from kubernetes and saves it in cache.
# This is what is imported
import data.kubernetes.pods

deny[msg] {
    input.request.kind,kind == "Pod"
    input_pod_name := input.request.object.metadata.name
    other_pod_names := pods[other_ns][other_name].metadata.name
    input_pod_name == other_pod_names # reject if any pod exists with same name in the cluster
    msg := sprintf("Pod %v name already exists!", [input_pod_name])
}
```

1c. Create a ValidatingWebhookConfiguration which contains OPA details

```yaml
# For EXTERNAL implementation of OPA server
apiVersion: admisisonregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: opa-validating-webhook
webhooks:
- name: validating-webhook.openpolicyagent.org
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiVersions: ["*"]
    apiGroups: ["*"]
    resources: ["*"]
  clientConfig:
    url: "http://opa-address.8181"
# For INTERNAL implementation of OPA server
apiVersion: admisisonregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: opa-validating-webhook
webhooks:
- name: validating-webhook.openpolicyagent.org
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiVersions: ["*"]
    apiGroups: ["*"]
    resources: ["*"]
  clientConfig:
    caBundle: $(cat ca.crt | base64 | tr -d '\n')
    service:
      namespace: opa
      name: opa
```

2. Deploy everything on kubernetes using ValidatingAdmissionWebhook

2a. Deploy OPA and "kube-mgmt" service as a k8s deployment. Along with necessary Roles and RoleBindings. Deploy everything in OPA namespace and expose the deployment using a clusterIP service.
2b. Load policies using k8s config map, instead of defining them externally. Nothing magical, we just put everything defined in the policy to a configmap.

This above step is done via use of "kube-mgmt" service sidecar pod:

```yaml
apiVersion: v1
kind: configMap
metadata:
  name: policy-unique-podname
  namespace: opa
  labels:
    openpolicyagent.org/policy: rego # this is mandatory, OPA looks for this label and loads the CM
data:
  main: |
    package kubernetes.admission
    deny[msg] {
        input.request.kind,kind == "Pod"
        image := input.request.object.spec.containers[_].image # define a variable
        startswith(image, "hooli.com/") # deny if image name starts with "hooli.com/
        msg := sprintf("image '%v' from untrusted registry", [image])
    }
```

3. OPA gatekeeper service [Both 1 and 2 are old/first/original way of doing things]

NOT part of CKS

## References

How netflix is solving authorization across their cloud. https://www.youtube.com/watch?v=R6tUNpRpdnY

OPA deep dive: https://www.youtube.com/watch?v=4mBJSIhs2xQ

## CKS scope

You are not expected to write a OPA policy in REGA, but you may be asked to deal with it.
