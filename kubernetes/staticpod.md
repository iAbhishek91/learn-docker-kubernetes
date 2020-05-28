# Static pods

That are created by kubelet without tht help of the api-server.

They are saved in a directory in the node and will be scheduled on the node itself.

Only pods can be scheduled in this fashion, NOT any other resources.

They are read only and only change in the file will update the pods.

The naming convention, the pod name is appended with the name of the node.

If the node is not a part of the cluster use the docker os command, else use kubectl command, kubelet will inform the api-server about the static pods.

Some use cases: deploying k8s components as pods, like scheduler, config manager, api-server etc.

## configure tht path

- Pass as argument

Configure **--pod-manifest-path** while starting the kubelet.

- Pass as config

Pass **--config** which will consume a yaml, and in the config file pass it as **staticPodPath** in the config file.
