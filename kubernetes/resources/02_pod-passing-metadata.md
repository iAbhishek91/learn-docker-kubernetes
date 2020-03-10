# Passing kubernetes metadata using env variable

## what we can pass are limited using env variable

- pod name
- pod ip
- pod namespace
- node on which pod is running
- service account name
- cpu and memory utilization

## All these are passed in the app

The displays in HTML format.

https://github.com/iAbhishek91/print-k8s-details

## to test the pod in mimikube

**Port Forward** is feature used to test pod without creating services.

```sh
k port-forward pod-passing-metadata 1222:1222
```
