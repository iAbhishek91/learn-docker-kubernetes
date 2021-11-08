# Linux capabilities

We have seen in seccomp that even without Unconfined syscall rules we are not able to set the time.

This is because apart from syscall security docker and Kubernetes both used linux capabilities to secure the containers and pods.

## Bit of history

< Kernel 2.2, processes were segregated into two catagories: privileged and unprivileged process. Privileged process can basically can do any thing on the system.

However, > kernel 2.2 capabilities were defined, where privileged process were granted sub-set of permissions known as capabilities. CAP_CHOWN, CAP_NET_ADMIN, CAP_SYS_BOOT, CAP_SYS_TIME, CAP_KILL etc.. There are created based on the functionality.

## Check capability required by each command/processes

```sh
# For command
getcap /usr/bin/ping
# /usr/bin/ping = cap_net_raw+ep

# For processes
getpcap pid
```

## capability in kubernetes

Each pod have only 12 default capabilities(check in kubernetes code), and the capabilities for changing date and time are not allowed.

## Add or remove capabilities from pod

```yaml
  containers:
  - name: bla
    image: bla
    command: ["bla", "bla"]
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
        drop: ["CHOWN"]
```
