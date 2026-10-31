# Overview
An Ignition Kubernetes deployment

# Prerequisites
* You must have kubernetes deployed along with a load balancer to run this out of the box.

# My Infrastructure
* Microk8s on 3 Raspberry Pi 5s
* Load Balancing with MetalLB by enabling it on microk8s
* CoreDNS must also be enabled on microk8s

# Deployment (Helm)
The gateway is deployed with the official Inductive Automation chart ([charts.ia.io](https://charts.ia.io)), chart 0.2.5 / Ignition 8.3.10.
* Values live in `helm/values.yaml`: Maker edition, MetalLB IP 10.20.160.251, 10Gi volume on `microk8s-hostpath`.
* The admin password is stored in the `ignition-gateway-admin` Secret, not in git.
* First-time cutover from the old manifests: run `microk8s enable hostpath-storage` on a node, then `./helm/cutover.sh`.
* Upgrades: `helm upgrade ignition inductiveautomation/ignition --version <ver> -n ignition -f helm/values.yaml`
* The gateway is at http://10.20.160.251:8088 (https on 8043).

# Legacy Deployment (raw manifests, Ignition 8.1)
The `deploy/` manifests are kept for rollback only. Their PVC is mounted at `/var/lib/ignition`, but the 8.1 image keeps its data in `/usr/local/bin/ignition/data`, so the gateway lost its config every time the container restarted.
## Makefile
* A Makefile is including if you're able to run the make command. It will build the Go script as well as deploy the K8S manifest.
    * The Go script only removes passwords from plain text in yaml files.
## Manifest Files
* Deployment file
    * This file contains the username and password for your ignition gateway.
* Service file
    * This file contains the ip address for your load balancer.
* Namespace file
## Kubernetes
* Run "make deploy-k8s" to deploy the namespace, service, and deployment in that order
* From the project's root directory, you should be able to run "kubectl apply -f deploy"
* Apply individual manifest files by changing directory into deploy and running "kubectl apply -f file.yaml"

# Basic Kubectl for Verification
Run the following commands to verify the PiHole app is running
* kubectl get pods -o wide -n ignition
* kubectl get services -o wide -n ignition
    * Make sure the EXTERNAL-IP here matches the load balancer ip you set.
* kubectl get deployments -o wide -n ignition

# Secret Filtering
* There is a go script that removes password/secret values from any yaml files

# Git Attributes
* This config tells git to run filter-secrets on any yaml files

# Git Config
* The filter secrets config here causes the files to be cleaned before being committed.
* Make sure the following is in your local .git/config if you plan to use the Go script.
```
[filter "secrets"]
    clean = ./filter-secrets
    smudge = cat
```