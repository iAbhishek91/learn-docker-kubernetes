# LINUX COMMANDS

## cat

concatination

## Find IP address

```sh
ifconfig
```

## Find verstion os

```sh
cat /etc/*release*
```

## Find hosts

```sh
cat /etc/hosts
```

## ps

This command lists all the process running on the host.

```sh
ps -eaf
```

## grep

to search a string

```sh
grep string-to-search
```

## pipe |

- This command takes output of one command and give as input to next command.
- This command takes 

## hostname

- displays the hosname of the system.
- change the hostname

```sh
hostname new-name
```

```sh
vi /etc/hostname
vi /etc/hosts
```

## set ip address to a network

```sh
ifconfig <networkname> xxx.xxx.x.x #this changes are not permanent
```

- make changes in the `/etc/network/interfaces`

```sh
auto enp0s8
iface enp0s8 inet static
address 198.168.53.2
netmask 255.255.255.0
```

## swap on off

from terminal: only valid for a perticular session

```sh
swapoff -a
```

to make this change permanent

```sh
vi /etc/fstab #comment all the swap lines
```

## service

- verify some service are available or not.
- One need to know the name of the service.
- For example I need to see if SSH service is available in my host.

```sh
service ssh status
```

## shutdown

to shut down a machine

```sh
shutdown now
```

## reboot

reboot will restart your server. This can be done only with root user. Use sudo su.

## apt-get

>NOTE: apt-get may throw error if it do not have permission. Grant access using sudo.

```sh
sudo su # this grant root user access
```

- **apt-get update** : this update the apt-get utility.
- **apt-get install package-name**: intall apackage manager.
- **apt-cache madison docker-ce**: lists all the docker images available for download
- **apt-cache pkgnames `<package name>`** lists all the docker packages installed.
- **apt-get remove `<package name>`** remove the package name.

ssh package name: openssh-server
docker package name: docker.io

## systemctl

`systemctl daemon-reload`
`systemctl restart docker`

## TODO

- read about cgroups in unix. Why kubernetes uses systemd
