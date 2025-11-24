#!/bin/bash
set -euxo pipefail

K8S_VERSION=${K8S_VERSION:-"1.31"}

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release jq

# Install bash-completion and ensure kubectl completion is enabled for vagrant & root
sudo apt-get install -y bash-completion

# Helper function: add a line to a file if it doesn't already exist
ensure_contains() {
  local file="$1"; shift
  local line="$*"
  sudo touch "$file"
  if ! sudo grep -Fxq "$line" "$file"; then
    echo "$line" | sudo tee -a "$file" > /dev/null
  fi
}

# kubectl completion lines
KUBECTL_COMPLETION='source <(kubectl completion bash)'
KUBECTL_ALIAS='alias k=kubectl'
KUBECTL_COMPLETE='complete -F __start_kubectl k'

# Apply for vagrant user
ensure_contains /home/vagrant/.bashrc "$KUBECTL_COMPLETION"
ensure_contains /home/vagrant/.bashrc "$KUBECTL_ALIAS"
ensure_contains /home/vagrant/.bashrc "$KUBECTL_COMPLETE"
sudo chown vagrant:vagrant /home/vagrant/.bashrc || true

# Apply for root
ensure_contains /root/.bashrc "$KUBECTL_COMPLETION"
ensure_contains /root/.bashrc "$KUBECTL_ALIAS"
ensure_contains /root/.bashrc "$KUBECTL_COMPLETE"

# Install containerd
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet
