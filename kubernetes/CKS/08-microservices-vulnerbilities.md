# Securing Microservices

## Secret management

for CKS, kubernetes secrets

```sh
k create secret generic name --from-literal=DB_Host=mysql --from-literal=DB_Password=mysql
k create secret generic name --from-file=app_secret.properties

# to encode
echo -n "secrete values" | base64
```

## Security context

- can be defined at container level or at pod level

- linux capabilities(only at containers level)
- user and group you belong to
- seccomp

## Admission controller

Admission controllers are plugins in API server, which validates your resource manifest along with the rules in admission controller.

Admission controller are executed after the request is authenticated and authorized.

To give a taste of what admission controller can do:

- fail if images have latest tag
- fail if capabilities defined are not allowed
- fail if pod run as root user
- inject default fields etc

**check enabled Admission controllers**:

```sh
# default admission controller
k exec -it kube-apiserver-controlplane -- kube-apiserver -h | grep enable-admission-plugins # lists all the admission controller that are enabled by default
# in control-plane node,
ps -ef | grep kube-apiserver | grep admission-plugins
# check the api-server -o yaml
k get po kube-apiserver-controlplane -o yaml
```

**enable/disable Admission controller**:

```sh
--enable-admission-plugins=NodeRegistration,NamespaceAutoProvision
--disable-admission-plugins=NodeRegistration,NamespaceAutoProvision
```

> Examples of Admission controllers: AlwaysPullImages, DefaultStorageClass, NamespaceExists, NamespaceAutoProvision etc etc

**Type of Admission controller plugin**:

- Mutating Admission controller | executed first | eg DefaultStorageClass
- Validating Admission controller | after mutating AC | eg NamespaceExists

**Define custom Admission controller**:

- to support custom AC: there are two special admission controller
  - MutatingAdmissionWebhook
  - ValidatingAdmissionWebhook
- Custom admission controller runs our custom logic in a separate webhook server(can be a pod, container or linux service)(can be in any language, only requirement is that it accept connection from the webhook controller and response back with proper JSON).
- Once all the AC is executed, Mutating AdmissionWebhook makes a call to custom mutating admission controller by sending the JSON object.
- The Custom mutating AC then return back with the JSON and "allowed" flag back to webhook.
- Then Validating AdmissionWebhook makes a call to same webhook server by to different to different route.

```py
''' this is an simple example of custom admission controller written in python'''
@app.route("/validate", methods=["POST"])
def validate():
    object_name = request.json["request"]["object"]["metadata"]["name"]
    user_name = request.json["request"]["userInfo"]["name"]
    status = True
    if object_name == user_name:
        message = "You can't create objects with your own name"
        status = False
    return jsonify(
        {
            "response": {
                "allowed": status,
                "uid": request.json["request"]["uid"]
                "status": {"message": message}
            }
        }
    )

@app.route("/mutate", methods=["POST"])
def mutate():
    user_name = request.json["request"]["userInfo"]["name"]
    pathch = [{
        "op": "add",
        "path": "/metadata/labels/users",
        "value": user_name
    }]
    return jsonify(
        {
            "response": {
                "allowed": True,
                "uid": request.json["request"]["uid"]
                "patch": base64.b64encode(patch)
                "patchtype": "JSONPathc",
            }
        }
    )
```

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration | MutatingWebhookConfiguration
metadata:
  name: "pod-policy.example.com"
webhooks:
- name: "pod-policy.example.com"
  clientConfig:
    # url: "https://external-server.example.com" # this is for external server
    service:
      namespace: "webhook-namespace"
      name: "webhook-service"
    caBundle: "asjdf;laks............djfl"
  rules: # when to invoke the admission controller, below eg: make call only when pods are created
  - apiGroups: [""]
    apiVersion: ["v1"]
    operations: ["CREATE"]
    resources: ["pods"]
    scope: "Namespaced"

```

## Pod Security Policies[deprecated in 1.21, removed in 1.25 because of complexity, something similar will be coming soon by then]

**PodSecurityPolicy** is a built in admission controller that is not enabled by default. The controller looks for all pod creation method and validates the pod creation mechanism. Along with validation PSP can add/mutate the pod metadata.

Step-1: Enable PSP admission controller in the API-server:

```sh
## NOTE: if you enable PSP and there is not policy defined all pod will be prevented from creation
# enable it by
- --enable-admisison-plugins=PodSecurityPolicy
```

Step-2: Authorize User/SA to communicate with PSP resources

Whom to authorize? The user who is creating the pod i,e the service account associate with the pod should have access to PSP API, so that pod can read the policy and validate it. This is done using RBAC.

```yaml
# Create a role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: psp-example-role
rules:
- apiGroups: ["policiy"]
  resources: ["podsecuritypolicies"]
  resourceNames: ["example-psp"]
  verbs: ["use"]
# Create a rolebinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: psp-example-rolebinding
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role
  name: psp-example-role
  apiGroup: rbac.authorization.k8s.io
```

Step-3: Create PSP resource

This will be validated against all the pods that are created. This is not a namespace resources.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: example-psp
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny | MustRunAsNonRoot
  requiredDropCapabilities:
  - 'CAP_SYS_BOOT'
  defaultAddCapabilities: # this mutate the pod manifest YAML
  - 'CAP_SYS_TIME'
  fsGroup:
    rule: RunAsAny
  volumes: # allows only specified volume types
  - 'persistentVolumeClaim'
```
