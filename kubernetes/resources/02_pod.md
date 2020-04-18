# k8s Pod

## Resource Template

We only speak about spec section:

- Containers: list of containers
- Volumes : list of volumes

## Pod logging

Standard way of logging in all containerized application is writing in standard error or standard output stream (instead in a file).

**k logs my-pod** to see the logs of a pod.
**k logs my-pod -c my-container** to see logs of a container inside a pod.

Containers logs are automatically rotated. Daily and every time the log file reaches 10MB in size. k logs only shows logs from the rotation. Logs are automatically deleted when a pod is deleted. To save the logs look at how to configure cluster wide logging system.
