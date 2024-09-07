# Overview
An Ignition Kubernetes deployment

# Prerequisites
* You must have kubernetes deployed along with a load balancer to run this out of the box.

# My Infrastructure
* Microk8s on 3 Raspberry Pi 5s
* Load Balancing with MetalLB by enabling it on microk8s
* CoreDNS must also be enabled on microk8s

[filter "secrets"]
    clean = ./filter-secrets
    smudge = cat