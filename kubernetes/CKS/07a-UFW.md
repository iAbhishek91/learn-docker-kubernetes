# Uncomplicated Firewall

Scenario:

Target server: App01
Listen port: 8080

Connection via
Admin jump server: 172.16.238.5 (SSH:22, HTTP:80)
Internal jump server: 172.16.100.0/28 (HTTP:80)

Most simple firewall in Linux is **iptables**, however this comes with a bit of learning curve

**UFW** is a simple and easy frontend for iptables.

## install UFW

```sh
apt-get update
apt-get install ufw

systemctl enable ufw
systemctl start ufw

# check status
ufw status # OUTPUT: Status: inactive
# allow all egress/outbound connection
ufw default allow outgoing
# default deny for all ingress
ufw default deny incoming
# allow specific client from specific IP to port 22
ufw allow from 172.16.238.5 to any port 22 proto tcp
# allow specific client from specific IP to port 80
ufw allow from 172.16.238.5 to any port 80 proto tcp
# allow specific client from specific IP to port 80
ufw allow from 172.16.100.0/28 to any port 80 proto tcp
ufw allow 1000:2000/tcp

# to activate the firewall use the below command
ufw enable
# to deactivate the firewall, bu preserve previous conversation
ufw disable
# check status again with number
ufw status numbered
#To       Action   From
#-----    -----    -----
#22/TCP   ALLOW    172.16.238.5 (line1)
#80/TCP   ALLOW    172.16.238.5 (line2)
#80/TCP   ALLOW    172.16.100.0/28 (line3)
#8080     DENY     Anywhere (line4)

## delete a rule
ufw deny 8080
ufw delete deny 8080
# alternative way: by ufw status line number
ufw delete 4

# reset ufw
ufw reset
```
