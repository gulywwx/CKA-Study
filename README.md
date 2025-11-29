# CKA Study Guide

This repository contains study materials and practice labs for the Certified Kubernetes Administrator (CKA) exam.

## CKA Exam Overview

The **Certified Kubernetes Administrator (CKA)** certification is designed to validate your skills in Kubernetes cluster administration.

- **Exam Duration:** 2 hours
- **Passing Score:** 66%
- **Kubernetes Version:** 1.31
- **Exam Format:** Performance-based exam with hands-on tasks in a real Kubernetes environment

## CKA Exam Domains and Weights

### Cluster Architecture, Installation & Configuration (25%)

- Manage role-based access control (RBAC)
- Use Kubeadm to install a basic cluster
- Manage a highly-available Kubernetes cluster
- Provision underlying infrastructure to deploy a Kubernetes cluster
- Perform a version upgrade on a Kubernetes cluster using Kubeadm
- Implement etcd backup and restore

### Workloads & Scheduling (15%)

- Understand deployments and how to perform rolling update and rollbacks
- Use ConfigMaps and Secrets to configure applications
- Know how to scale applications
- Understand the primitives used to create robust, self-healing, application deployments
- Understand how resource limits can affect Pod scheduling
- Awareness of manifest management and common templating tools

### Services & Networking (20%)

- Understand host networking configuration on the cluster nodes
- Understand connectivity between Pods
- Understand ClusterIP, NodePort, LoadBalancer service types and endpoints
- Know how to use Ingress controllers and Ingress resources
- Know how to configure and use CoreDNS
- Choose an appropriate container network interface plugin

### Storage (10%)

- Understand storage classes, persistent volumes
- Understand volume mode, access modes and reclaim policies for volumes
- Understand persistent volume claims primitive
- Know how to configure applications with persistent storage

### Troubleshooting (30%)

- Evaluate cluster and node logging
- Understand how to monitor applications
- Manage container stdout & stderr logs
- Troubleshoot application failure
- Troubleshoot cluster component failure
- Troubleshoot networking

## Repository Structure

- `/terraform` - AWS EC2 infrastructure setup using Terraform
- `/vagrant` - Local development environment using Vagrant and VirtualBox
- `/troubleshooting` - Practice scenarios for troubleshooting
- `/exam` - Practice exam questions and scenarios
- `01-cluster-architecture-installation-configuration.md` - Study notes for Domain 1
- `02-workloads-and-scheduling.md` - Study notes for Domain 2
- `03-services-and-networking.md` - Study notes for Domain 3
- `04-storage.md` - Study notes for Domain 4
- `05-troubleshooting.md` - Study notes for Domain 5

## Useful Resources

- [Official CKA Curriculum](https://github.com/cncf/curriculum)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [CKA Exam Page](https://www.cncf.io/certification/cka/)

## Lab Environment Setup

### 1. AWS

The current EC2/Terraform approach allows for scalable and reproducible deployments. Below is an overview of the steps involved:

1. Set up your AWS account and configure your IAM permissions.
2. Use Terraform to define your infrastructure as code.
3. Deploy your EC2 instances based on your Terraform configurations.

### 2. Vagrant

For a local setup, Vagrant with VirtualBox offers an easy way to create and configure lightweight, reproducible environments. Below is a minimal example of a Vagrantfile to get you started:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest: 80, host: 8080
end
```

Follow these instructions:
1. Install Vagrant and VirtualBox.
2. Create a directory for your Vagrant project.
3. Save the Vagrantfile in this directory.
4. Run `vagrant up` to start your virtual machine.
5. Access your application via `http://localhost:8080`.

This provides two effective ways of working with environments, whether leveraging cloud resources or running locally with Vagrant.

