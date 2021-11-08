# Seccomp

Seccomp- stands for **secure computing** its a kernel level feature to access only the system calls that they need. Introduced in 2005, and its part of linux kernel since then.

We have seen that system call made by container, command , processes can be traced using strace or aquasec-tracee.

However if we want to restrict any system call, use Seccomp.

Allowing application to make any syscalls(all 435), basically increases the attack surface.

## Check if seccomp is enable

Check the boot configuration, to find out seccomp is supported by kernel or not.

```sh
grep -i seccomp /boot/config-$(uname -r)
# CONFIG_SECCOMP=y
# CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
# CONFIG_SECCOMP_FILTER=y
```

## Example without any change

<details>
<summary>Check how secomp is implemented</summary>

```sh
# run the image whalesay
docker run -it -rm docker/whalesay /bin/sh

# try changing date and time
date -s "12 OCT 2021 20:00:00"
# date: cannot set date: Operation not permitted

## QUESTION: why operation is not permitted
## check the process for /bin/sh
ps aufx
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.0   4444   780 pts/0    Ss   19:02   0:00 /bin/sh
# root         8  0.0  0.0  15564  2232 pts/0    R+   19:04   0:00 ps aufx

## Now looking for seccomp status of the process
grep -i seccomp /proc/1/status
# Seccomp:       2
# value 2 indicates that seccomp is implemented in this container
```

Seccomp works in three mode:

- `mode-0` - Disabled,
- `mode-1`- Strict - allows 4 syscall: read(), write(), exit(), rt_sigreturn()
- `mode-2`- Filtered

</details>

## **Questions**?

- **Who enabled seccomp inside the container**?

By default docker injects seccomp configuration whenever we run a container, and works if host machine have seccomp enabled.

seccomp configuration is a json file, a example below:

```json
## Whitelist type profile, allow only that are defined, this is very very restrictive as one need to white list all the sys calls that are not permitted
{
    "defaultAction": "SCMP_ACT_ERRNO", ## default action if the below list do not match
    "architecture": [ ## architecture where this configuration will be implied.
        "SCMP_ARCH_X86_64",
        "SCMP_ARCH_X86",
        "SCMP_ARCH_X32"
    ],
    "syscalls": [
        {
            "names": [
                "syscall-1",
                "syscall-2",
                "syscall-3"
            ],
            "action": "SCMP_ACT_ALLOW"  ## allow the above syscalls
        }
    ]
}
```

```json
## Blacklist type profile, deny all that are blacklisted. Easy to define and maintain than whitelist one
{
    "defaultAction": "SCMP_ACT_ALLOW", ## default action if the below list do not match
    "architecture": [ ## architecture where this configuration will be implied.
        "SCMP_ARCH_X86_64",
        "SCMP_ARCH_X86",
        "SCMP_ARCH_X32"
    ],
    "syscalls": [
        {
            "names": [
                "syscall-1",
                "syscall-2",
                "syscall-3"
            ],
            "action": "SCMP_ACT_ERRNO"  ## deny the above syscalls
        }
    ]
}
```

- **What are the filters applied on the container**

docker by default blocks ~60 out of 435 syscalls

- clock_adjtime
- clock_settime
- reboot
- mount
- umount
- settimeofday
- create_module
- delete_module
- swapoff
- stime

```sh
# to check the exact syscall blocked
docker run r.j3ss.co/amicontained amicontained
##
## OUTPUT
##
#Container Runtime: docker
#Has Namespaces:
#        pid: true
#        user: false
#AppArmor Profile: docker-default (enforce)
#Capabilities:
#        BOUNDING -> chown dac_override fowner fsetid kill setgid setuid setpcap net_bind_service net_raw sys_chroot mknod audit_write setfcap
#Seccomp: filtering
#Blocked Syscalls (61):
#        MSGRCV SYSLOG SETPGID SETSID USELIB USTAT SYSFS VHANGUP PIVOT_ROOT _SYSCTL ACCT SETTIMEOFDAY MOUNT UMOUNT2 SWAPON SWAPOFF REBOOT SETHOSTNAME SETDOMAINNAME IOPL IOPERM CREATE_MODULE INIT_MODULE DELETE_MODULE GET_KERNEL_SYMS QUERY_MODULE QUOTACTL NFSSERVCTL GETPMSG PUTPMSG AFS_SYSCALL TUXCALL SECURITY LOOKUP_DCOOKIE CLOCK_SETTIME VSERVER MBIND SET_MEMPOLICY GET_MEMPOLICY KEXEC_LOAD ADD_KEY REQUEST_KEY KEYCTL MIGRATE_PAGES UNSHARE MOVE_PAGES PERF_EVENT_OPEN FANOTIFY_INIT NAME_TO_HANDLE_AT OPEN_BY_HANDLE_AT SETNS PROCESS_VM_READV PROCESS_VM_WRITEV KCMP FINIT_MODULE KEXEC_FILE_LOAD BPF USERFAULTFD PKEY_MPROTECT PKEY_ALLOC PKEY_FREE
#Looking for Docker.sock
```

- **Can we modify the default list provided by docker**

YES

- Define a custom.json and pass that to docker as below
- OR disable seccomp completely, NOT RECOMMENDED

```sh
# pass custom
docker run -it -rm --security-opt seccomp=/root/custom.json docker/whalesay /bin/sh

# disabled completely
docker run -it -rm --security-opt seccomp=unconfined docker/whalesay /bin/sh
```

>NOTE: changing date in docker container is not only because of seccomp, there are multiple security gates applied.

## Seccomp in kubernetes

### Default behavior

Run the above validation image as pod and check what syscalls are blocked.

```sh
k run amicontained --image r.j3ss.co/amicontained amicontained -- amicontained
k get logs
# The result are quite different as compared to docker. On average, only 21 syscalls were blocked by default. And Seccomp is disabled ie in 0 mode.
```

## how to implement seccomp in pod

As we have learnt in previous step that they are disabled by default

[Official documents](https://kubernetes.io/docs/tutorials/clusters/seccomp/)

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: amicontianed
  name: amicontained
spec:
  securityContext: #this will enable seccomp on the pod
    seccompProfile:
      type: RuntimeDefault # default fo docker, also **Unconfined** is allowed( default), **Localhost** for custom seccomp
      localhostProfile: <path to the custom JSON file> # used only in case of **Localhost** only. This path is not mounted, it should be relative to default seccomp profile location which is by default: /var/lib/kubelet/seccomp
      # step-1: create a directory under: /var/lib/kubelet/seccomp/profiles/audit.json { "defaultAction": "SCMP_ACT_LOG"} OR to block everything: { "defaultAction": "SCMP_ACT_ERRONO" } note for block all the container will not be created as no syscalls are allowed
      # step-2: provide the path in the pod yaml profiles/audit.json
      # step-3: validate the logs in /var/log/syslog file
      # step-4: in the syslog there will numbers syscall=35|257 etc what are these? to map grep -w 35 /usr/include/asm/unistd_64.h
  containers:
  - args:
    - amicontained
    image: r.j3ss.co/amicontained
    name: amicontained
    securityContext:
      allowPrivilegeEscalation: false # ensure that pods runs with bare minimum security alone
```

### in CKS exam

- we will not be asked to create a new seccomp profile
- we will be asked to used certain profile already built in and we have to use it in the pod
