# Kubernetes Cluster with Vagrant and VirtualBox

This project provisions a Kubernetes cluster on Windows using Vagrant and VirtualBox. The cluster consists of one control plane node and two worker nodes, configured with kubeadm and Calico CNI.

## Prerequisites

Before you begin, ensure you have the following installed on your Windows machine:

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (6.1 or later)
- [Vagrant](https://www.vagrantup.com/downloads) (2.3 or later)
- At least 6GB of free RAM
- At least 20GB of free disk space

## Cluster Configuration

- **Kubernetes Version**: 1.34
- **Container Runtime**: containerd
- **CNI Plugin**: Calico
- **Base OS**: Ubuntu 22.04 LTS (Jammy)

### Node Specifications

| Node | Hostname | IP Address | CPU | RAM |
|------|----------|------------|-----|-----|
| Control Plane | k8s-control | 192.168.56.10 | 2 | 2GB |
| Worker 1 | k8s-worker-1 | 192.168.56.11 | 2 | 2GB |
| Worker 2 | k8s-worker-2 | 192.168.56.12 | 2 | 2GB |

### Network Configuration

- **Pod Network CIDR**: 192.168.0.0/16
- **Service CIDR**: 10.96.0.0/12 (Kubernetes default)
- **Host Network**: 192.168.56.0/24

## Project Structure

```
k8s-vagrant/
├── Vagrantfile
├── README.md
└── scripts/
    ├── common.sh
    ├── control-plane.sh
    └── worker.sh
```

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/gulywwx/CKA-Study
cd k8s-vagrant
```

### 2. Start the Cluster

```bash
vagrant up
```

This command will:
1. Download the Ubuntu 22.04 box (first time only)
2. Create three virtual machines
3. Install and configure containerd
4. Install Kubernetes 1.34 components
5. Initialize the control plane with kubeadm
6. Install Calico CNI
7. Join worker nodes to the cluster

**Note**: The initial setup takes 10-15 minutes depending on your internet connection.

## Accessing the Cluster

### SSH into Nodes

```bash
# Access control plane
vagrant ssh k8s-control

# Access worker nodes
vagrant ssh k8s-worker-1
vagrant ssh k8s-worker-2
```

### Using kubectl

Once inside the control plane node:

```bash
# Check cluster status
kubectl get nodes

# View all pods across all namespaces
kubectl get pods -A

# Check Calico components
kubectl get pods -n calico-system
kubectl get pods -n calico-apiserver

# Get cluster information
kubectl cluster-info
```

### Access kubectl from Windows Host

To use kubectl from your Windows machine:

1. SSH into the control plane:
   ```bash
   vagrant ssh k8s-control
   ```

2. Copy the kubeconfig file:
   ```bash
   cat ~/.kube/config
   ```

3. On your Windows machine, create `%USERPROFILE%\.kube\config` and paste the content

4. Update the server address in the config:
   ```yaml
   server: https://192.168.56.10:6443
   ```

5. Install kubectl on Windows and run:
   ```bash
   kubectl get nodes
   ```

## Common Operations

### Check Cluster Status

```bash
vagrant ssh k8s-control
kubectl get nodes
kubectl get pods -A
```

### Stop the Cluster

```bash
# Gracefully halt all VMs
vagrant halt

# Halt specific node
vagrant halt k8s-worker-1
```

### Restart the Cluster

```bash
# Start all VMs
vagrant up

# Start specific node
vagrant up k8s-worker-1
```

### Destroy the Cluster

```bash
# Remove all VMs (this deletes all data)
vagrant destroy -f
```

### Rebuild the Cluster

```bash
vagrant destroy -f
vagrant up
```

## Troubleshooting

### Node Not Ready

Check the node status and events:

```bash
kubectl get nodes
kubectl describe node k8s-worker-1
```

Verify Calico is running:

```bash
kubectl get pods -n calico-system
```

### Network Issues

Check Calico installation:

```bash
kubectl get installation -o yaml
kubectl get pods -n calico-system -o wide
```

Verify containerd is running:

```bash
vagrant ssh k8s-control
sudo systemctl status containerd
```

### Join Command Issues

If a worker fails to join:

1. SSH into the control plane:
   ```bash
   vagrant ssh k8s-control
   ```

2. Generate a new join command:
   ```bash
   kubeadm token create --print-join-command
   ```

3. SSH into the worker and run the command:
   ```bash
   vagrant ssh k8s-worker-1
   sudo <join-command>
   ```

### Check Logs

```bash
# Kubelet logs
sudo journalctl -u kubelet -f

# Containerd logs
sudo journalctl -u containerd -f

# Pod logs
kubectl logs <pod-name> -n <namespace>
```

### Provisioning Fails

If provisioning fails partway through:

```bash
# Re-run provisioning on specific node
vagrant provision k8s-control

# Re-run provisioning on all nodes
vagrant provision
```

## Customization

### Change Kubernetes Version

Edit the `Vagrantfile` and modify:

```ruby
K8S_VERSION = "1.34"  # Change to desired version
```

Then rebuild:

```bash
vagrant destroy -f
vagrant up
```

### Change Node Resources

Edit the `Vagrantfile` and modify the provider settings:

```ruby
vb.memory = "4096"  # Change RAM (in MB)
vb.cpus = 4         # Change CPU count
```

### Change IP Addresses

Edit the `Vagrantfile`:

```ruby
CONTROL_PLANE_IP = "192.168.56.10"
WORKER_NODE_IPS = ["192.168.56.11", "192.168.56.12"]
```

### Add More Worker Nodes

Edit the `Vagrantfile` and change the worker node loop:

```ruby
# Change from (1..2) to (1..3) for 3 workers
(1..3).each do |i|
  # ... worker configuration
end
```

Add the new IP to the array:

```ruby
WORKER_NODE_IPS = ["192.168.56.11", "192.168.56.12", "192.168.56.13"]
```

## Testing the Cluster

### Deploy a Test Application

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=NodePort

# Check the service
kubectl get svc nginx

# Get the NodePort
kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}'

# Access from Windows browser
# http://192.168.56.11:<NodePort>
```

### Test Pod-to-Pod Communication

```bash
# Create two test pods
kubectl run test-1 --image=nginx
kubectl run test-2 --image=nginx

# Get pod IPs
kubectl get pods -o wide

# Exec into test-1 and ping test-2
kubectl exec -it test-1 -- curl <test-2-ip>
```

## Useful Commands Reference

```bash
# Vagrant commands
vagrant status              # Check VM status
vagrant ssh <node>         # SSH into a node
vagrant halt               # Stop all VMs
vagrant up                 # Start all VMs
vagrant destroy -f         # Delete all VMs
vagrant provision          # Re-run provisioning

# Kubernetes commands
kubectl get nodes                    # List nodes
kubectl get pods -A                  # List all pods
kubectl get svc -A                   # List all services
kubectl describe node <node-name>   # Node details
kubectl top nodes                    # Resource usage
kubectl get events                   # Cluster events
```

