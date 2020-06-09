# k8s Pod

restart policy of the pod: Never | Always | OnError

## Resource Template

We only speak about spec section:

- Containers: list of containers
- Volumes : list of volumes

## Pod application logging

Standard way of logging in all containerized application is writing in standard error or standard output stream (instead in a file).

```sh
# to see the logs of a pod.
k logs my-pod
# to see logs of a container inside a pod.
k logs my-pod -c my-container
# to see logs of previous container in a pod which is terminated, if it exits. Note if pod itself is recreated then logs are lost.
k logs -p my_pod -c my_container
# streaming log
k logs -f my_pod -c my_container
# logs from all the container having a specific label app=my_app
k logs -f --selector='app=my_app' --all-containers=true
# logs from max 10 containers and pods selected by the selector. by Default it is set to 5.
k logs my_pod --max-log-requests=10
# ignore errors in the log
k log my_pod --ignore_errors=true
# recent 20 lines of logs and prefix pod name container name in the log along with timestamp
k logs --tail=20 --prefix --timestamps my_pod
# recent 10 mints logs. valid values s, m, h.
k logs my_pod --since=10m
# previous instance
k log my_pod -f --previous
```

Containers logs are automatically rotated. Daily and every time the log file reaches 10MB in size. k logs only shows logs from the rotation. Logs are automatically deleted when a pod is deleted. To save the logs look at how to configure cluster wide logging system.

## Creating a pod

### k run

Create and run a particular image in a pod.

```sh
# outputs the template of the resource being created
## valid values: json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-file
k run my_pod --image=my_image -o=yaml
# dry-run to print the object structure
k run my_pod --image=my_image --dry-run='client'
# start a pod in the cluster - manually create not managed by k8s
k run my_pod --image=my_image
# image pull policy
## by default latest tag are always pulled, and specific tags are not, as it consider it as available.
k run my_pod --image=my_image --image-pull-policy=''
# start a pod with exposing a port, by default it would consider it from the image. port is always an informational field.
k run my_pod --image=my_image --port=1234
# start a pod and attach it to displays the output
k run my_pod --image=my_image --attach=true
k run my_pod --image=my_image -i -t
# delete the resource when exiting the attach mode
k run my_pod --image=my_image --attach=true --rm=true
# mention the restart policy. Default is always and 'never' for cronjob
## Deployment is create if restart is Always
## Job (scheduled work) is create if restart is OnFailure
## Pod is create if restart is Never
k run my_pod --image=my_image --restart=Always
# set limit and ranges
k run my_pod --image=my_image --limits='cpu=200m,memory=512Mi' --request='cpu=100m,memory=256Mi'
# set env variables for the pod
k run my_pod --image=my_image --env=[] # **NEED to SEE the format of how to send the values**
# set labels for the pods
k run my_pod --image=my_image --labels='app=my_app,app_type=frontend'
# set a service account for the pod. Note one pod can have only one service a/c from the same namespace.
k run my_pod --image=my_image --serviceaccount='abhishek'
# --- mostly NOT used as its configured and mostly default is used ---
# delete all the resources created or managed by this resource
k run my_pod --image=my_image --cascade=true
# use a specific generator to change the default behavior. we want to create RC instead of deployment.
k run my_pod --image=my_image --generator=run/v1
# set flag force to true, instead of default false, deletes the resource from API server by passing grace deletion
k run my_pod --image=my_image --force=true
```

### k create

```sh
k create -f ../02_pod-temperature-service.yml
```

## Debug a container

### k attach

Attach a process running in a existing container. Very similar to `k exec`

```sh
# displays output from first container of pod my_pod
k attach my_pod
# displays output from specific container my_container of pod my_pod
k attach my_pod -c my_container
# attach stdin and tty to a pods first container
k attach my_pod -c my_node_container -i -t
```

### k port-forward

This command is used mainly for debugging
Forward local system(host system you are) to a pod. Two pre-requisites:

- **Kubectl** configured to access the k8s cluster where the pod is deployed.
- **socat** installed.

If multiple pods are selected, then only one is picked automatically.

```sh
# pods service hosted at 8080, and accessing it to localhost 8888. by default address is localhost. 127.0.0.1
k port-forward my_pod 8888:8080
k port-forward pod/my_pod 8888:8080 # same as above.
# forward port to any of the pod using a deployment
k port-forward deploy/my_deploy 8888:8080
# forward port to any of the pod using a svc
k port-forward svc/my_svc 8888:8080
# forward port to mentioned ip address
k port-forward --address localhost,10.19.21.23 my_pod 8888:8080
```

## commands and argument

Container runs only where there is a process running. This is the basis of keeping the container run.

### Docker concept

```Dockerfile
# pass certain command to run in the container and then exit
docker run ubuntu sleep 5

# Embed the above command in image, to make it permanent.
docker run ubuntu-sleeper
# using CMD we can't append any more argument from the command line, thats the main diff b/w entrypoint and cmd.
# Two syntax are available. in Second option (JSON array) the first option should be executable.
CMD sleep 5
CMD ["sleep", "5"]

# now to make it more sophisticated, we want to pass the below command
docker run ubuntu-sleep 5

# Introducing Entry point in docker, the arguments get appended
ENTRYPOINT sleep
ENTRYPOINT ["sleep"]
CMD 5

# note entrypoint and cmd are best practice, else if you miss cmd and don't pass argument while running the container, then we will get err.
# will sleep for 5 seconds, this is the default behavior of the image.
docker run ubuntu-sleep
# will sleep for 10 seconds, overwrite default value of CMD
docker run ubuntu-sleep 10
# to overwrite entry point use --entrypoint option, now it will execute sleep2.0 command with arg 20
docker run --entrypoint sleep2.0 ubuntu-sleep 20
```

### k8s concept

To achieve the above functionality in K8s.

```yaml
# replicate "docker run ubuntu-sleep 5"
# args will override CMD in the image
args: ["5"]

# replicate "docker run --entrypoint sleep2.0 ubuntu-sleep 20"
# args will override CMD in the image
command: ["sleep2.0"]
```

## environment variable

- always in name-value pair, but there are way to bring the value from somewhere else like config map or secrets
- is a list (array)

```yaml
env:
  - name:
    value:
```

```yaml
# bring value from configmap or secret
env:
  - name: FROM_CONFIG_MAP
    valueFrom:
      configMapKeyRef:
        name:
        key:
  - name: FROM_SECRET
    valueFrom:
      secretKeyRef:
```

## config map

- These are data that are managed centrally, instead of hard coding it in env variables
- They are again key value pair in kubernetes

### Creating a config map

appConfig.properties

```properties
FIRST_NAME: abhishek
LAST_NAME: das
```

```sh
# config map
k create cm|secret my-config|my-secret --from-literal=FIRST_NAME=abhishek --from-literal=LAST_NAME=das
k create cm|secret my-config|my-secret --from-file=./appConfig.properties
```

```yaml
apiVersion:
kind: ConfigMap|Secret
metadata:
data:
  FIRST_NAME: abhishek|asdfasdf
  LAST_NAME: das|adsfadf
```

> NOTE: the values of secret should be echo -n 'passwd' | base64 || do decode echo -n 'adsfadf' | base --decode

### using config map in pod

There are several way of injecting config map|secret in pod

- as environment variable
- as single env var
- as volume

```yaml
# as environment variable
envFrom:
  - configMapRef|secretRef:
      name: name_of_the_configMap | name_of_the_secret
# as single env var
env:
  - name: FIRST_NAME
    valueFrom:
      configMapKeyRef|secretKeyRef:
        name: name_of_the_configMap | name_of_the_secret
        key: FIRST_NAME
# as volume
spec:
  containers:
    - volumeMounts:
       ....
volumes:
  - name: config_volume
    configMap|volumes:
      name|secretName: name_of_the_configMap
```

> When using volume, each every entry in the secret and config available as file.

## secrets

Concept and syntax is similar to config map. Only difference is that they content are base-64 encoded.

so to make it easy I have kept the notes together (see above section)
