# K8s Volume

Here we are not talking about docker volume, however its similar.

Few points about volume:

- Every container inside a pod share same network, resources but not file systems. *The done by infrastructure container (can be identified as /pause in docker ps in cluster node). Infrastructure container holds together all the container in same name space. Even though all the container uses same name space, they don't share FS.*
- Since FS is not shared b/w containers, once a pod dies all the data is lost.
- Volume are part of pod and hence they are NOT standalone, and hence cant be created or deleted independently. *Pod and volume are tightly coupled. There is no K8s resource as volume.*
- Linux allows you to mount a FS at arbitrary location in the file tree. Files of the mounted filesystem can be accessible from the directory its mounted into. *Under the hood this is what K8s does to share external data (or self written) within the container.*

## Classification

1. Volume to store data *emptyDir, gitRepo, hostPath, nfs, gcePersistentDisk, persistentVolumeClaim.*
2. Volume to store meta-data *secret, downwardAPI, configMap.*

### emptyDir (within pod)

- non-persistent data volume. Deleted along with pod.
- mainly used to share data between containers.
- to write temp data as container FS is readonly. *Note: Container FS generally have a r/w layer, however for security this can be disabled by setting spec.containers.securityContext.readOnlyRootFilesystem to true.*
- emptyDir can be created on memory instead of disk. Disk is default place to mount, baut can be changed.

```yaml
# to load in disk (default)
volumes:
  - name: html
    emptyDir: {}
# to load in memory
volume:
  - name: html
    emptyDir:
      medium: Memory
```

### GitRepo (within pod)

- its an emptyDir
- clones a git repo only while pod is created. *They do not pull git repo automatically, bring a side car to do this job.*

```yaml
volumes:
  - name: html
    gitRepo:
      repository: url
      revision: master
      directory: . # without '.' it will create a folder with the project name
```

### hostPath (node file system)

- hostPath volume points to specific files or directory on the nodes filesystem.
- This is mostly used by system pod or daemon sets. *Which points to specific files in the OS.*
- This is not a good idea to use hostPath for regular pods as pod may easily be rescheduled on different node.

```yml
volumes:
  - name: log
    hostPath:
      path: /var/log/
```

### gcePersistentDisk (external to node)

- first create persistent storage in GCP.
- the use that in the pod definition.

```yaml
volumes:
  - name: mongoDb
    gcePersistentDisk:
      pdName: mongoDB # this name should exactly match a persistent volume in gcp
      fsType: ext4
```

### NFS volume (external to node)

- instead of using cloud operator we can use NFS for storage in on-premise environment.

```yml
volumes:
  - name: mongoDB
    nfs:
      server: 10.10.10.10 # NFS server
      path: /some/path # path exported by the server
```

## Decouple K8s developer and administrator

As seen above there are lot of infrastructure related information, this is not best practice *because pods definitions are pretty much tied to specific k8s cluster. Also, developer's need to deal (or to know the actual network storage) with all the admin related work.*

**K8s basic principle is to hide the actual infrastructure from application and developer.** This will help to make more portable application.

- persistentVolume
- persistentVolumeClaim
- storageClass (required for dynamic provisioning)
