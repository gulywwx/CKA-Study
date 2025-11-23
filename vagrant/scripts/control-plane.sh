#!/bin/bash
set -euxo pipefail

CONTROL_PLANE_IP=${CONTROL_PLANE_IP:-"192.168.56.10"}
POD_NETWORK_CIDR=${POD_NETWORK_CIDR:-"192.168.0.0/16"}

# Initialize Kubernetes control plane
sudo kubeadm init \
  --apiserver-advertise-address=$CONTROL_PLANE_IP \
  --pod-network-cidr=$POD_NETWORK_CIDR \
  --node-name k8s-control

# Configure kubectl for vagrant user
mkdir -p /home/vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

# Configure kubectl for root
mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config

# Install Calico CNI plugin
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Create custom resources for Calico
cat <<EOF | kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: $POD_NETWORK_CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF

# Wait for Calico to be ready
echo "Waiting for Calico to be ready..."
kubectl --kubeconfig=/etc/kubernetes/admin.conf wait --for=condition=ready pod -l k8s-app=calico-node -n calico-system --timeout=300s || true

# Generate join command for worker nodes
kubeadm token create --print-join-command > /vagrant/join-command.sh
chmod +x /vagrant/join-command.sh

echo "Control plane setup complete!"
echo "Join command saved to /vagrant/join-command.sh"
