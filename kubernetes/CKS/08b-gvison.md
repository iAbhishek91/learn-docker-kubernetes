# Container sandboxing

Sandboxing has different meaning in computing world, however on security it means when we segregate something from rest of the things.

- seccomp
- app armour
- gVisor
- kata containers

## gVisor

gVisor is another tool from Google, which separates containers from linux kernel.

Basically all containers or pods directly speaks with the Linux kernel to perform anything.

gVisor sits in between container and linux kernel: **container >> syscalls >> gVisor >> Kernel >> Hardware**

gVisor have several process internal to it, for example Sentry: this processes makes calls to other sub-processes within gVisor to invoke linux kernel.

There are multiple gVisor that are available for multiple contianerized system. Even though any of the pods breaks it will still be in the network.

Disadvantage of gVisor, not all apps work along with gVisor, so make sure you test the app. Also it may sometime cause performance problems as every requests goes through a middle man.
