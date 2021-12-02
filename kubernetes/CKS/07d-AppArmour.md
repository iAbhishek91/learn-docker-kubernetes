# AppArmour

System call allow/deny us to perform specific action on the host, and by restricting specific call using seccomp we entirely allow or block the action.

If we need to implement specific requirements, like can't access specific directory: we make use of AppArmour

**AppArmour**: is Linux kernel security module, ir allows sysadmin to restrict programs capabilities with per-program profiles. Profiles can allow capabilities like network access, raw socket access and the permission to read, write or execute file.

Installed by default in most linux system.

Validate its installed and running:

```sh
systemctl status apparmor
```

App armour kernel module should be loaded in all the nodes where the containers would run.

Validate its loaded to kernel:

```sh
cat /sys/module/apparmor/parameters/enabled
## OUTPUT
# Y
```

## AppArmor profiles

Apparmor runs with help of profile.

Profiles are simple text files, which define what resources can be used as an application.

```sh
# to list all the apparmor profile
cat /sys/kernel/security/apparmor/profiles
```

### Examples of Apparmor profiles

<details>
<summary>Example, note these profile files are not created manually, they are created using app-armor tool</summary>

Rule 1: deny write to entire fs

```txt
profile apparmor-deny-write flags=(attach_disconnected) {
    # allow access to all file system
    file,
    # Deny all file writes
    deny /** w,
}
```

Rule 2: deny write only to proc fs

```txt
profile apparmor-deny-proc-write flags=(attach_disconnected) {
    file,
    # Deny all file writes to /proc.
    deny /proc/* w,
}
```

Rule 3: deny root re mount

```txt
profile apparmor-deny-remount-root flags=(attach_disconnected) {
    # Deny remount readonly the root filesystem.
    deny mount options=(ro, remount) -> /,
}
```

</details>

### check status of apparmor

This below command provides information about

- how many total profiles are loaded
- what is the mode of each profiles
- how many process have defined profile, undefined and unconfined

```sh
aa-status
```

### Modes of profiles

- **enforce**: the profile will be enforced.
- **complain**: it will not enforce the profile, but log them as events.
- **unconfined**: allows any tasks, and neither its logged as a event.

### creating apparmor profiles specific to application

create a bash script, for which we will create apparmor profile

```sh
#!/bin/bash
data_directory=/tmp/log/data
mkdir -p ${data_directory}
echo "=> File created at `date`" | tee ${data_directory}/create.log
```

```sh
chmod +x ./07d-apparmor-app.sh
./07d-apparmor-app.sh
cat /opt/app/data/create.log
```

create a apparmor profile for this above script

```sh
#Step 1: install apparmor util package
apt-get install -y apparmor-utils

#Step-2: generate a profile for a above script
aa-genprof /home/abhishekd/work/github/learn-docker-kubernetes/kubernetes/CKS/07d-apparmor-app.sh
## will ask for questionnaire
# press (s) to scan
# if we want profile to run mkdir command
# enter I for inherit
# Like this allow or deny or inherit for all the question asked

# Step-3: validate the profile is running
aa-status # look for the profile with program name

# Step-4: check the profile thats created
cat /etc/apparmor.d/home....07d-apparmor-app.sh
```

### Load an existing profile

```sh
apparmor_parser /etc/apparmor.d/profile-name
# if output is empty line that means the profile was loaded successfully
```

### Disable an loaded profile

```sh
apparmor_parser -R /etc/apparmor.d/profile-name
# then create a symlink
ln -s /etc/apparmor.d/profile-name /etc/apparmor.d/disable/
```

### apparmor inside kubernetes

[Kubernetes Apparmor feature](https://kubernetes.io/docs/tutorials/clusters/apparmor/) are still in beta for long time.

prerequisites:

- AppArmor kernel module should be enabled
- Apparmor profile loaded in the kernel
- Container runtime should be supported: docker, containerd etc all supports

Below is a simple pod, which do not require any access to filesystem, can be blocked via apparmor

```yaml
#pod definition
apiVersion: v1
kind: Pod
metadata:
  name: dummy
  annotations:
    container.apparmor.security.beta.kubernetes.io/nothing<container-name>: localhost/apparmor-deny-write #<profilename>
spec:
  containers:
  - name: nothing
    image: ubuntu
    command: ["/bin/sh", "-c", "echo 'sleeping for an hour' && sleep 1h"]
```

apparmor-deny-write profile, this profile should be loaded to all the worker nodes.

```txt
profile apparmor-deny-write flags=(attach_disconnected) {
    file,
    # Deny all file writes
    deny /** w,
}
```

To test the pod, exec and check you can perform any FS write operation.
