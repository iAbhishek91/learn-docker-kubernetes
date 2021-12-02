# CIS Benchmark

Center for Internet Security

## What are security benchmarks

There are security benchmarks applied on the server where we deploy our application. There are best practices for

- Networking
- Physical devices
- Auditing
- Logging
- Access
- Services
- Filesystem

The question is where are these best practices?

There are multiple tools that can help us with this. Common one is **CIS benchmark**.

- Community driven
- Non-profit organization

*Our mission is to make the connected world a safer a place by developing, validating, and promoting timely best practice solution that help people, businesses and governments protect themselves against pervasive cyber threats.*

Their security service provides security over multiple vendors and system, as BELOW

- OS
  - Linux
  - Windows
  - ...
Cloud
  - AWS
  - GCP
  - Azure
Mobile
  - IOS
  - Andriod
- Network
  - Checkpoint
  - Cisco
  - Juniper
  - Palo Alto Network
- Desktop Apps
  - Web Browser
  - MS office
- Server
  - Tomcat
  - Docker
  - Kubernetes
  - VM

**CIS-CAT** a tool which automates the diagnosis of a server and detect the issues and provides a reports.

- **Lite version** is a free version, which supports only limited platforms like , Google Chrome, Ubuntu and MacOS, Windows 10.
- **Pro version** provides all the other available platform using Kubernetes.

Kube-bench is a free tool and an alternative for CIS_CAT pro.

```sh
## Below command to run CIS-CAT professional
# -i interactive mode
# -vvv verbose with info level
# -rp report prefix, is the name of the file
# -rd report directory
# -nts no timestamp to be included in the report
sh ./Assessor-CLI.sh -i -rd /var/www/html/ -nts -rp index -vvv
# while this is running it will be asking you about Benchmarks/data stream you wish to validate and also the profile

# IMPORTANT: open the file with HTML in browser and you can learn more about linux security

### Check the html report, remediating few executing the commands provided
# For example set ownership to /etc/crontab file
chown root:root /etc/crontab
chmod og-rwx /etc/crontab # og removes r,w,x from others and group

## Run the test once again.
```
