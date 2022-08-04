# Certified Kubernetes Administrator (CKA) Study

It is Certified Kubernetes Administrator (CKA) self study repository using online resources that I collected. 

You are allowed to access [Kubernetes Official Documentation](https://kubernetes.io) during the exam. Indeed, getting familiar with the official documentation should be always your best tip. 

For exam detail, please see [CNCF CKA](https://www.cncf.io/certification/cka/).


## Exam Objectives:
These are the exam objectives you review and understand in order to pass the test.

* [CNCF Exam Curriculum repository ](https://github.com/cncf/curriculum)



### Cluster Architecture, Installation & Configuration (25%)

- Manage role based access control (RBAC).

    - [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

- Use Kubeadm to install a basic cluster.

    - [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

- Manage a highly-available Kubernetes cluster.

    - [Creating Highly Available clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

- Provision underlying infrastructure to deploy a Kubernetes cluster.

    - [Getting started](https://kubernetes.io/docs/setup/)

- Perform a version upgrade on a Kubernetes cluster using Kubeadm.

    - [Administration with kubeadm > Upgrading kubeadm clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

- Implement etcd backup and restore.

    - [perating etcd clusters for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

### Workloads & Scheduling (15%)

- Understand deployments and how to perform rolling update and rollbacks.

    - [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

- Use ConfigMaps and Secrets to configure applications.

    - [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

    - [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

- Know how to scale applications.

    - [Scaling Your Application](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#scaling-your-application).

- Understand the primitives used to create robust, self-healing, application deployments.

    - [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

    - [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

- Understand how resource limits can affect Pod scheduling.

    - [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

- Awareness of manifest management and common templating tools.

    - [Managing Resources](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)

    - [Manage Kubernetes Objects](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/)

### Services & Networking (20%)

- Understand host networking configuration on the cluster nodes.

    - [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

- Understand connectivity between Pods.

    - [Networking](https://kubernetes.io/docs/concepts/workloads/pods/#pod-networking)

- Understand ClusterIP, NodePort, LoadBalancer service types and endpoints.

    - [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

- Know how to use Ingress controllers and Ingress resources.

    - [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
    - [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

- Know how to configure and use CoreDNS.

    - [Using CoreDNS for Service Discovery](https://kubernetes.io/docs/tasks/administer-cluster/coredns/)

- Choose an appropriate container network interface plugin.

    - [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)


### Storage (10%)

- Understand storage classes, persistent volumes.

    - [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
    - [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

- Understand volume mode, access modes and reclaim policies for volumes.

    - [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistent-volumes)

- Understand persistent volume claims primitive.

    - [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)

- Know how to configure applications with persistent storage.

    - [Configure a Pod to Use a PersistentVolume for Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume)

### Troubleshooting (30%)

- Evaluate cluster and node logging.

    - [Troubleshoot Clusters](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/)

- Understand how to monitor applications.

    - [Tools for Monitoring Resources](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

- Manage container stdout & stderr logs.

    - [Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

- Troubleshoot application failure.

    - [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/)
    - [Application Introspection and Debugging](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application-introspection/)

- Troubleshoot cluster component failure.

    - [Troubleshoot Clusters](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/)

- Troubleshoot networking.

    - [Debug Services](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/)



## Courses:

- [Certified Kubernetes Administrator (CKA) - A Cloud Guru](https://learn.acloud.guru/course/certified-kubernetes-administrator/dashboard)

- [Certified Kubernetes Administrator (CKA) Study Guide](https://learning.oreilly.com/library/view/certified-kubernetes-administrator/9781098107215/)

- [Kubernetes Deep Dive - A Cloud Guru](https://learn.acloud.guru/course/kubernetes-deep-dive/overview)

- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)



## Lab:
To simplely setup 1 control plane and 2 work nodes ec2 environment using terrafrom on AWS.
you will need a valid AWS account with administrative privileges (or at least is allowed to execute the actions in the Terraform code).

```bash
# To use your IAM credentials to authenticate the Terraform AWS provider, set two environment variable.
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

# Update terraform.tfvars
vim terraform.tfvars

# Initialize the directory
terraform init -plugin-dir=plugins

# Format and validate the configuration
terraform fmt
terraform validate

# Create infrastructure
terraform plan -var-file=terraform.tfvars -out=terraform.tfout
terraform apply -input=false -auto-approve=true -lock=true "terraform.tfout"
```
## Tips:


