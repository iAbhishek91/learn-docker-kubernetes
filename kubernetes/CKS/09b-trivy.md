# Trivy

For scanning images for CVE (Common vulnerability and exposure) from Aquasecurity.

## What is CVE

CVE are identified by individuals like you, and they are reported and tracked globally.

Each CVE has a unique id and prevent us from creating duplicating.

This helps everyone to know about the vulnerability.

What are type of bugs or vulnerability that goes into CVE database, they are mostly

- anything that allows attackers to by pass security checks and do things that he/she is not allowed to do. (view payroll for without authorization)
- anything that messes up the system.

How CVE are scored?

CVE are scored from 0 - 10.
CVE V3 chart

None: 0.0
Low: 0.1 to 3.9
Medium: 4.0 to 6.9
High 7.0 to 8.9
Critical 9.0 to 10.0

## Trivy

Trivi can scan filesystem, git repo, or docker images.

```sh
# install trivy
#Add the trivy-repo
apt-get  update
apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

#Update Repo and Install trivy
apt-get update
apt-get install trivy
```

```sh
# run image scan
trivy image nginx:1.18.0
trivy image --severity CRITICAL nginx:1.18.0 # image scanning for Critical severity only
trivy image --severity CRITICAL,HIGH nginx:1.18.0 # image scanning for Critical, and High severity only
trivy image --ignore-unfix nginx:1.18.0 # issues that can be fixed by upgrading software packages
trivy image --input archive.tar # use tar format image, change it like this: "docker save nginx:1.18.0 > nginx.tar"
```

Best practices:

- Continiously rescan images
- use kubernetes admission controller to scan the images
- use private repository
- also have integrated scannin gon CI/CD
