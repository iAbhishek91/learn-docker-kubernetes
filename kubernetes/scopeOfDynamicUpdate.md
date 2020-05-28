# We will discuss what we can update dynamically while something is running

## POD

we can only edit:

* image of containers
* image of initContainers
* spec.activeDeadlineSeconds
* spec.tolerations

## Deployment

* all pod details
