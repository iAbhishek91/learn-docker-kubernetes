# Aquasec Tracee

How system call works under the hood

- Kernel is an interface between the hardware and the application/processes. It manages system resource as efficiently as possible.

- There are two memory: **User space** and **kernel space**

- Place where application written in C, Java, Python are executed : Userspace, Kernel(kernel code, kernel extensions and device drivers) runs on kernel space.

- Application running on userspace makes calls the kernel space known as **System Calls**(currently there are 435 sys calls in total in linux), Examples of system calls are open(), close(), execve(), readdir(), strlen(), closedir()

- Trace syscalls

```sh
strace touch /tmp/test.log 
strace -c touch /tmp/test.log # pretty output
## OUTPUT
## explain: binary, parameter, 23 indicates 23 variables were inherited by the system call == "env | wc -l"
#execve("/usr/bin/touch", ["touch", "/tmp/error/log"], 0x7ffce8f874f8 /* 23 vars */) = 0
#
#

# trace a running process
pidof postges
strace -p <pid from above command>
```

- traces syscall of a containers
- Open source
- EBPF(extended Berkeley Packer Filter) is used to trace the system at runtime. EBPF helps you to run code in kernel space without loading any kernel modules or interfering with kernel code.

## Run tracee

we need to bind below paths:

- /tmp/tracee Default workspace
- /lib/modules Kernel Headers
- /usr/src Kernel Headers

also it requires privilege flag

- in docker use `--priviledge` flag

```sh
# command to trace ls command
docker run --name tracee --rm --privilege --pid=host -v /lib/modules/:/lib/modules/:ro -v /usr/src:/usr/src:ro -v /tmp/tracee:/tmp/tracee aquasec/tracee:0.4.0 --trace comm=ls

# command to trace all the new processes
# this will generate lots of outputs
docker run --name tracee --rm --privilege --pid=host -v /lib/modules/:/lib/modules/:ro -v /usr/src:/usr/src:ro -v /tmp/tracee:/tmp/tracee aquasec/tracee:0.4.0 --trace pid=new

# command to trace for a new container
# this is applicable for k8s as well, we just filter by the pod name
docker run --name tracee --rm --privilege --pid=host -v /lib/modules/:/lib/modules/:ro -v /usr/src:/usr/src:ro -v /tmp/tracee:/tmp/tracee aquasec/tracee:0.4.0 --trace container=new
```
