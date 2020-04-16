# Passing kubernetes metadata using env variable and downwardAPI

## what we can pass are limited using env variable

- pod name
- pod ip
- pod namespace
- node on which pod is running
- service account name
- cpu and memory utilization

## what we can pass from downwardAPI are

Everything from env + labels + annotations

## All these are passed in the app

The displays in HTML format.

https://github.com/iAbhishek91/print-k8s-details

## to test the pod in minikube

**Port Forward** is feature used to test pod without creating services.

```sh
k port-forward pod-passing-metadata 1222:1222
```

## URL to access

URL: http://localhost:1222

Everything is displayed are from environment variable

URL: http://localhost:1222/downwardAPI

Everything is displayed are passed from downwardAPI volume.

## why labels and annotations can't be passed from env variables

env variables are static and cant be changed once passed.

however as we know annotation and labels can change, dynamically, hence downwardAPI is required.

## changing labels and annotation at runtime

```sh
k label po pod-passing-metadata-downward-volume new-label=yoyo # new label
# pod/pod-passing-metadata-downward-volume labeled
k label pod pod-passing-metadata-downward-volume author=DoctorD --overwrite # update label
# pod/pod-passing-metadata-downward-volume labeled
k annotate pod pod-passing-metadata-downward-volume abdas81/author=DoctorD
# pod/pod-passing-metadata-downward-volume annotated
```

## verify changes in label & annotation

just refresh: URL: http://localhost:1222/downwardAPI
