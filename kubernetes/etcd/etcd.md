# Etcd

Key-value store used by k8s to store its data.

Installation: https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/07-bootstrapping-etcd.md

## ETCD

Make sure to clean the node before installing, so that no other previous cluster disturb the configuration.

## RAFT protocol

- Each noe has a timer. The node which completes the timer sends a request to other and the waits for the response. Since other have not completed the clock they accept the request.
- On getting the majority of accepts the node become the leader.
- The leader continues to send the notification every 2-5 seconds (configurable) to the other nodes. Hence the node continues to remain as leader.
- If the loader do not send the notification to the other nodes, for specific time, then the leader election process starts again.
- The RAFT protocol maintains a quorum: n/2 +1. Transactions(writes) are considered complete if they have successfully completed on majority of the cluster.
- Suggested number of ETCD is 3 5 and 7. one is network split (also known as network segments) can be tolerated and second is even and odd have same tolerance.
