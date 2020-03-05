# pod

## start the pod manually

```sh
k create -f pod-temperature-service.yml 
```

> NOTE: generally pods are not created manually, they are managed by RC, RS or deployments.
> If they are created using above command, they will not be rescheduled, or restarted if they go down.

## start the pod in specific namespace

```sh
k create -f pod-temperature-service.yml -n my-namespace
```

> NOTE: namespace is a k8s resource, hence that is to be created before use
> namespace can be explicitely mentioned in pod template as well.

## test the pod

we cant test this pod as this are not exposed by any service. However, K8s has another mechanism called pord-forwarding using socat (used by kubectl port-forward command). It's a tool used for socker concatenation mainly used for bi-directional communication.

```sh
k port-forward pod-temperature-service 1314:1313
```

> NOTE: In case socat is not installed, use yum install socat

## retrieve log of the pods

```sh
k logs pod-temperature-service
```

> NOTE: similar to docker

## retrieve log of a container from a pod

```sh
k logs pod-temperature-service -c container-temerature-service 
```

## show all the labels of the pod

```sh
k get po --show-labels
#pod-temperature-service   1/1     Running   0          28s   created-by=abdas81,env=prod
```

## specifying labels by name

```sh
k get po -L created-by,env
#pod-temperature-service   1/1     Running   0          3m3s   abdas81      prod
```

## selecting pod by labels

```sh
k get po -l env # show pods whose env label is defined.
k get po -l env=prod # show pods whose env label is equal to prod.
k get po -l '!env' # show pods whose env lave is not defined.
k get po -l created-by=abdas81,env=prod # multiple label selectors
```
