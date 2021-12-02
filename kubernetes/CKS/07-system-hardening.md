# System hardening

## Least privilege

### Limit Nodes Access

#### Limit users

This is purely Linux concept of how to define and manage users on linux machine

There are different type of user

- **User accounts**: normal user accounts
- **Superuser account**: root uid=0
- **System account**: majorly created during OS installation
- **Service account**: created when services are created like nginx, docker, postgres

<details>
<summary>Check user login information</summary>

```sh
# information about user: user id, group id, and groups
id # logged in user
# OUTPUT: uid=1000(abhishekd) gid=1000(abhishekd) groups=1000(abhishekd),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),116(lpadmin),126(sambashare),999(docker)
id <username> # any user

# list of user currently logged into the system
who
# abhishekd :0           2021-10-06 06:28 (:0)

# last time users were logged into the system
last
# abhishek :0           :0               Wed Oct  6 06:28   still logged in
# reboot   system boot  5.4.0-87-generic Wed Oct  6 06:28   still running
# abhishek :0           :0               Tue Oct  5 21:22 - down   (01:02)
# reboot   system boot  5.4.0-87-generic Tue Oct  5 21:21 - 22:25  (01:03)
# abhishek :0           :0               Tue Oct  5 09:21 - down   (07:02)
# reboot   system boot  5.4.0-87-generic Tue Oct  5 09:21 - 16:23  (07:02)
# abhishek :0           :0               Sun Oct  3 18:04 - down  (1+13:24)
# reboot   system boot  5.4.0-87-generic Sun Oct  3 18:04 - 07:29 (1+13:24)

# wtmp begins Sun Oct  3 18:04:41 2021
```

</details>

<details>
<summary>Important User/group files</summary>

```sh
cat /etc/passwd # list of user
cat /etc/shadow # list of user password
cat /etc/group # list of user group
```

</details>

With this above information we can remove access for the user that do not require.

<details>
<summary>Update/modify/delete users configuration</summary>

```sh
# create a user
useradd -h # check all the options
useradd sam -d /opt/sam -s /bin/bash -u 2328 -G admin

# remove default shell for the user to nologin
# this is basically disable/suspend a user
usermod -s /bin/nologin abhishek
usermod -s /bin/nologin root # RECOMMENDED as no should access the system as root, and only use sudo command for priviledge escalation

# delete a user
userdel abhishek

# remove user from group that they should not belong to
id <username>
deluser abhishek docker # OUTPUT: Removing user `abhishek` from `docker` group

# set password for user
passwd username
>enter password:
>reenter password:

# delete a group
groupdel <group-name>
```

</details>

#### SSH hardening

This as well is purely Linux, where we try to harden the SSH connectivity to the system.

- Make use of ssh key pair.
- Remove ssh access for root account.

SSH config is stored in **/etc/ssh/sshd_config**

> NOTE there are two type of ssh configuration: one for ssh client and one for ssh daemon: ssh_config and sshd_config

```txt
/etc/ssh/sshd_config
# bock ssh for root user
PermitRootLogin no

# bock password authentication
PasswordAuthentication no
```

```sh
echo jim ALL=(ALL:ALL) ALL >> /etc/sudoers
echo jim ALL=(ALL) NOPASSWD:ALL >> /etc/sudoers
```

RESTART the service: systemctl restart sshd

refer to interview-questions/os/linux.md

## Remove unwanted packages and services

We want only the required modules in the system, and they are updated regularly so that they have latest security patches applied.

Services(is managed by systemd process) runs by following the below stages:

**BIOS POST** >> **Boot Loader (GRUB2)** >> **Kernel initialization** >> **INIT process (SystemD)** >> services that are enabled

```sh
#list all the packages installed in system
apt list --installed
# to remove a package
apt remove apache2
# update a package
apt install -u <package-name>

# list of all active service
systemctl list-units --type service
# list all installed files
systemctl list-unit-files

# if a service is not needed
systemctl stop <service-name>
systemctl disable <service-name>

```

## Restrict kernel module

Linux kernel is modularized to allow them to dynamically extend their feature by adding. *For example: if a new hardware is added, then corresponding kernel module(in this case its nothing but the device driver) can be added to make the new hardware usable.

refer interview-questions/os/linux.md for modprobe

**What is the security risk?** different software automatically installs kernel module, which can exploit the system(nodes).
To prevent this we blacklist kernel module. **What is blacklist a kernel module?** blacklisted kernel modules prevents a module from loading.

to blacklist a kernel module

```sh
cat /etc/modprobe.d/blacklist.conf (can be any file, should be under /etc/modprobe.d dir and should have extension of .conf)
blacklist pcspkr
blacklist sctp
blacklist dccp
```

once edit is done shutdown the system and run `lsmod` command to verify.

## Disable unused ports

Step-1: Identify all the open ports.

```sh
netstat -an | grep -w LISTEN
```

Step-2: Know what each port is opened for(ofcourse well known ports are listed here)

```sh
cat /etc/services | grep 53
```

> Note: Once you determine which ports are not required disable them

```sh
```

## UFW

Refer 07a-UFW.md

## Aquasec tracee

Refer 07b-Aquasec-Tracee.md

## seccomp

Refer 07c-seccomp.md

## AppArmour

Refer 07d-AppArmour.md
