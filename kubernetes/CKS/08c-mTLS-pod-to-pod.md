# Pod to Pod communication using mTLS

Implementing mTLS is overhead and complex for 1000 of pods on the cluster.

Best to off load this task to third party tools like Istio or Linkerd.

While using these system application do not implement any encryption or mTLS. Pods communicate non-securely. However before the request is forwarded to other pod istio(or other) encrypts the data.
