# CKS

## Exam guidelines

- 15-20 Questions
- All questions are performance based
- duration 2 hours
- result within 24 hour
- passing score: 67%
- cert validity: 2 years
- Pre-requisite: CKA

## URL Allowed

Kubernetes Documentation:

- https://kubernetes.io/docs/ and their subdomains
- https://github.com/kubernetes/ and their subdomains
- https://kubernetes.io/blog/ and their subdomains
Tools:

- Trivy documentation https://github.com/aquasecurity/trivy
- Sysdig documentation https://docs.sysdig.com/
- Falco documentation https://falco.org/docs/
App Armor:

- Documentation https://gitlab.com/apparmor/apparmor/-/wikis/Documentation

## Exam environment

- total 16 cluster(all with one master and one worker nodes)
- switch context: `k config use-context "cluster name"`
- ssh to nodes: `ssh nodename`
- elevated privilege is provided
- alias configured: k, yq(yaml parsing), jq(json parsing), tmux, curl, wget, man
- Kubernetes 1.21.<latest minor>

## Curriculum

Refer CKS_Curriculum.pdf for details

- 10% cluster setup
- 15% cluster hardening
- 15% system hardening
- 20% minimize microservice vulnerabilities
- 20% supply chain security
- 20% monitoring, logging and runtime security

## tricks

print name of current namespace: k config get-contexts `k config current-context` --no-headers=true | awk '{ print $5 }'
change namespace: k config set-context --current --namespace $1