# deployments

They are high level object in Kubernetes

## creating deployment

refer docs in kubectl.md

k create deploy deployName --image=my-image --replicas=3
k run deployName --image=my-image

## Managing deployments using kubernetes

### k rollout

```sh
# every time something is updated in the deployment it may create a history.
# Note: while the deployment is created, use the --record flag to make sure that history is shown properly.
k rollout history deploy my-deployment

# deployment of the application status
k rollout status deploy my-deployment

# restart the all the pods in a release, rarely used
k rollout restart deploy my-deployment

# pause and resume deployment
# once a deployment is paused, rollout is not triggered, hence we can do multiple update to the deployment.
# Note that application will continue to run, only that the changes in the pod is paused.
k rollout pause deploy my-deployment
k rollout resume deploy my-deployment

# roll back to previous version
# in case manually you doing a rollout by changing something, which is exactly same as previous one, it will also trigger undo.
k rollout undo deploy my-deployment
```
