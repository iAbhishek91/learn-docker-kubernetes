# pod config passed from env vars

env vars are embedded in pod definition.

command field similar to entrypoint
args field similar to cmd

## config maps

There are three way to inject config map /secrets to pods

1; as entire config map:

```sh
envFrom:
  - configMapRef|secretRef:
      name: my-config-map
```

2; as single variable

```sh
env:
  - name:
    valueFrom:
      configMapKeyRef|secretRef:
        name: firstName
        key: FIRST_NAME
```

3; as a volume

```sh
spec:
  containers:
    - image: nginx:alpine
      name: container-nginx-alpine-config-volume
      volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
          readOnly: true
  volumes:
    - name: config-volume
      configMap|secret:
        name: my-config
```
