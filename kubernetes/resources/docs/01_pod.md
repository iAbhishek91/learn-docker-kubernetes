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
