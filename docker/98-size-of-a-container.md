# Container size

https://bobcares.com/blog/docker-container-size/#:~:text=In%20Docker%2C%20there%20is%20a,size%20set%20for%20the%20containers.

* Docker has a limit in the storage size.
* Docker storage is managed by storage manager, there are many storage drivers like overlay2, devicemapper.
* Find the docker storage driver in **Storage Driver** under **docker info**. It also shows the **Backing filesystem** as **extfs**.
* Note **Overlay**, **Overlay2** are better than **deviceMapper** and **aufx**. **Overlay2** is better than **Overlay**, hence docker recommends to use **Overlay2** device driver.

## DeviceMapper

When storage driver is **device mapper**, the total storage pool size id defined as **Data Space Total** and size per container is **Base Device Size**

## OverlayFS

* OverlayFS is one of the union filesystem.
* OverlayFS is a Linux concepts and nothing to do with Docker.
* Docker provides 2 storage driver of OverlayFS, **overlay** and **overlay2**. **Overlay** driver is not supported by docker EE.
* Docker can use **Backing Filesystem** as extfs, only if d_type is true. *Learn more about d_type below.

**What is d_type and why Docker overlayfs need it**?

In my previous post I’ve mentioned a strange problem that occurs on Discourse running in Docker. Today I’m going to explain this further as this problem could potentially impact any Docker setup uses overlayfs storage driver. Practically, CentOS 7 with all default setup during installation is 100% affected. Docker on Ubuntu uses AUFS so is not affected.

**What is d_type**?
d_type is the term used in Linux kernel that stands for “directory entry type”. Directory entry is a data structure that Linux kernel used to describe the information of a directory on the filesystem. d_type is a field in that data structure which represents the type of an “file” the directory entry points to. It could a directory, a regular file, some special file such as a pipe, a char device, a socket file etc.

d_type information was added to Linux kernel version 2.6.4. Since then Linux filesystems started to implement it over time. However still some filesystem don’t implement yet, some implement it in a optional way, i.e. it could be enabled or disabled depends on how the user creates the filesystem.

> Very Very important note: A problem with centOS, the XFS filesystem is created with d_type=0, instead of d_type=1. And only if d_type=1(true) it can ve used by Docker. However, ext4 in centOS is created with d_type=1 by default hence can be used in Docker if ext4 is the filesystem of partition.
> To overcome the problem with XFS: use Use xfs_info to verify that the ftype option is set to 1. To format an xfs filesystem correctly, use the flag -n ftype=1

## How docker overlay2 storage driver works

* Containers do not have their own physical disk, hence its uses the disk from the host.
* OverlayFS layers two directories on a single linux host and present them as single directories.
  * Two directories are known as *layers*.
  * The directories are ordered, the lowerone is known as *lowerdir* and upper one is known as *upperdir*
* 128 layers are supported by overlayFS.
* the layers has contents and are saved in host's /var/ib/docker/overlay2.
* Example:
  * if we download 5 layer image we can see all the layer on the above directory.
  * an extra directory is created called **l**. This contain short name to the directories and links to the actual five directories.
  * **lowest layer**: contains directory *diff*(actual content), and a file *link* (short name from the **l** directory)
  * **upper layers**: contains files *lower*(short name of the parent from **l** directory), *link*(same as above), *diff*(same as above), *merged*(directory contains unified contents of its parent layer & itself), *work*(directory is used by OverlayFS itself).
