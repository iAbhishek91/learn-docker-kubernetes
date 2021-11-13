# Supply chain security

## Minimize Base Image footprint

What is the difference **between base and parent image**?

- Parent image is the image from which another image is created, i.e. image used in FROM tag in dockerfile.
- Image which is built on from **scratch** are known as base image. "FROM scratch"
- However this terms are used interchangeably, not a big deal.

best practices of creation containers?

- Moduler, do not keep everything in one image like monolith.
- Do not persist state inside a container
- keep images as small/slim as possible (use multi-stage images)
- remove tools like curl , wget, also package managers like yum or apt. These are heavily used to by attacker to download images.

how to choose base image?

- official images are preferred
- images should be up-to-date, they are less likely to have vulnerability in them.
- there are different version(tags) of same images available, use the smaller one. For example alpine.
- use Googles Distroless docker images: static.io/distroless/statis-debian10 ( they have application and runtime dependencies only). No shell, network tools, pkg mgr, or txt editor.

## Image security

Images are referred as docker.io[Registry]/library[User/Account]/nginx[ImageName]:latest[Tag]

Docker hub is NOT the only registry, there are multiple public registry available.

Private registry: use dockerhub or nexus or anything else. For private registry the mandatory part is to login.

How to use private registry in kubernetes? - As we need to login to the registry in container runtime. There are multiple ways:

We can also set kubernetes to pull from particular registry by default

- Create a secret of type "docker-registry" `k create secret docker-registry nexus --docker-server="nexus-ca.io" --docker-username="" --docker-password="" --docker-email=""`
- imagePullSecrets are mentioned on the each pod: like this `spec.imagePullSecrets[0].name: nexus`

## Whitelist image registries

- By default everything is allowed.
- However, this may not be desirable, hence we can block this using admission controller or OPA. There is another option to block images from unwanted registries.
- Its by using "ImagePolicyWebhook" a builtin admission webhook, this 

```yaml
# /etc/kubernetes/admission-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook # here we mention the name of the webhook 
  configuration:
    imagePolicy:
      kubeConfigFile: <path to kubeconfig-file> # path to Admission webhook server, it looks like kubeconfig file
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: true # this allows if admission webhook server have issue, or deny a request or do not exists
      # If we set this to false, this means, all request are rejected until and unless Admission webhook server allowes it
```

```yaml
clusters:
- name: name-of-remote-imagepolicy-service
  cluster:
    certificate-authority: /path/to/ca/pem
    server: https://images.example.com/policy

users:
- name: name-of-api-server
  user:
    client-certificate: /path/to/cert.pem
    client-key: /path/to/key.pem
```

```sh
# configuration required for API server
--enable-admission-plugins=ImagePolicyWebhook
--admission-control-config-file=/etc/kubernetes/admission-config.yaml
```

## Static analysis of k8s manifest

Static analysis is done after the manifest is defined and before using the **kubectl** command.

so API server have nothing to do in static analysis.

We need some third party tools like

- kubesec.io: it scans the YAML file and returns *critical*, *advice* security flaws as well as a overall score.
