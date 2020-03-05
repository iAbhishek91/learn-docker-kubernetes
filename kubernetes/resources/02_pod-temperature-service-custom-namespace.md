# pod with namespace

## to spin the pod with specific namespace

```sh
k create -f pod-temperature-service-custom-namespace.yml
```

## deleting all pods of this namespace along with the namespace

```sh
k delete ns namespace-abhishek
```

## deleting all pods of this namespace without the namespace

```sh
k delete po -all
```