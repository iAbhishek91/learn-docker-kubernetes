# Container sandboxing

Sandboxing has different meaning in computing world, however on security it means when we segregate something from rest of the things.

- seccomp
- app armour
- gVisor
- kata containers

## gVisor

gVisor is another tool from Google, which separates containers directly communication linux kernel.

Basically all containers or pods directly speaks with the Linux kernel to perform anything.

gVisor sits in between container and linux kernel: **container >> syscalls >> gVisor >> Kernel >> Hardware**

gVisor have several process internal to it, for example Sentry: this processes makes calls to other sub-processes within gVisor to invoke linux kernel.

There are multiple gVisor that are available for multiple contianerized system. Even though any of the pods breaks it will still be in the network.

Disadvantage of gVisor, not all apps work along with gVisor, so make sure you test the app. Also it may sometime cause performance problems as every requests goes through a middle man.

## kata container

Kata containers provides VM kernel for each containers. Unlike gVisor which speaks to single kernel, incase of kata container implementation each containers will have their own VM kernel.

Kata is light weight however their are some performance penalty.

Since Kata is a virtualization technique, we can use this on on bare metal VMs. This is because most cloud providers do not support virtualization inside virtualization.

Virtualization inside virtualization comes with poor performance hence implement kata container only when you know what you are doing.

## Runtime classes

refer 96-docker-runtime-classes.md
