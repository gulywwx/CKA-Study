# Lab Exercises for Cluster Architecture, Installation and Configuration


# Exercise 1 - Use Kubeadm to install a basic cluster

1. On the master node, install kubeadm and stand up the control plane, using `10.244.0.0/16` as the pod network CIDR, and https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml as the CNI
2. On work nodes, install kubeadm and join it to the cluster as a worker node

<details><summary>Answer</summary>

## All Nodes:

Create configuration file for containerd
  
```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```
  
Load modules
  
```shell
sudo modprobe overlay
sudo modprobe br_netfilter
```
  
Set system configurations for Kubernetes networking
  
```shell  
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
  
sudo sysctl --system
```
  
Install containerd
  
```shell    
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```

Install kubeadm Packages  
  
```shell  
sudo swapoff -a
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```
  
## Control Plane Node:

Initialize the Cluster
  
```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
  
Install the Calico Network Add-On  

```shell  
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

create the token and copy the kubeadm join command

```shell  
kubeadm token create --print-join-command
```  
  
## Work Node
  
Join the Worker Nodes to the Cluster
  
```shell
kubeadm join 172.16.10.210:6443 --token 9tjntl.10plpxqy85g8a0ui \
    --discovery-token-ca-cert-hash sha256:381165c9a9f19a123bd0fee36fe36d15e918062dcc94711ff5b286ee1f86b92b 
```

Validate by running `kubectl get no` on the master node:

</details>


# Exercise 2 - Perform a version upgrade on a Kubernetes cluster using Kubeadm 

1. Using `kubeadm`, upgrade a cluster to the lastest version

<details><summary>Answer</summary>

## Master Node
  
Upgrade the `kubeadm` version:

```shell
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubeadm=1.22.2-00
kubeadm version
kubectl drain k8s-control --ignore-daemonsets  
```

`plan` the upgrade:

```shell
sudo kubeadm upgrade plan v1.22.2

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
kubelet     1 x v1.19.0   v1.20.2

Upgrade to the latest stable version:

COMPONENT                 CURRENT   AVAILABLE
kube-apiserver            v1.19.7   v1.20.2
kube-controller-manager   v1.19.7   v1.20.2
kube-scheduler            v1.19.7   v1.20.2
kube-proxy                v1.19.7   v1.20.2
CoreDNS                   1.7.0     1.7.0
etcd                      3.4.9-1   3.4.13-0
```

Upgrade the cluster

```shell
sudo kubeadm upgrade apply v1.22.2
```

Upgrade Kubelet:

```shell
sudo apt-get update && \
sudo apt-get install -y --allow-change-held-packages kubelet=1.22.2-00 kubectl=1.22.2-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl uncordon k8s-control  
```

## Work Node
  
Run the following on the control plane node to drain worker node
  
```shell
kubectl drain k8s-worker1 --ignore-daemonsets --force
```
  
Upgrade the `kubeadm` version:

```shell
sudo apt-get update && sudo apt-get install -y --allow-change-held-packages kubeadm=1.22.2-00
kubeadm version
sudo kubeadm upgrade node
```
  
Upgrade the work node:

```shell
sudo kubeadm upgrade node
```
  
Upgrade Kubelet:

```shell
sudo apt-get update && \
sudo apt-get install -y --allow-change-held-packages kubelet=1.22.2-00 kubectl=1.22.2-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
  
From the control plane node, uncordon worker node  

```shell
kubectl uncordon k8s-worker1
```  
  
</details>


# Exercise 3 - Implement etcd backup and restore

1. Take a backup of etcd
2. Verify the etcd backup has been successful
3. Restore the backup back to the cluster

<details><summary>Answer</summary>

Look up the value for the key cluster.name in the etcd cluster

```shell
ETCDCTL_API=3 etcdctl get cluster.name \
  --endpoints=https://10.0.1.101:2379 \
  --cacert=/etc/kubernetes/pki/etcd/server.crt \
  --cert=/etc/kubernetes/pki/etcd/ca.crt \
  --key=/etc/kubernetes/pki/etcd/ca.key
```
  
  
Take a snapshot of etcd:

```shell
ETCDCTL_API=3 etcdctl snapshot save etcd_backup.db \
  --endpoints=https://10.0.1.101:2379 \
  --cacert=/etc/kubernetes/pki/etcd/server.crt \
  --cert=/etc/kubernetes/pki/etcd/ca.crt \
  --key=/etc/kubernetes/pki/etcd/ca.key 
```
  
Verify the snapshot:

```shell
sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status etcd_backup.db
```
  
Reset etcd by removing all existing etcd data
  
```shell
sudo systemctl stop etcd
sudo rm -rf /var/lib/etcd
```  

Perform a restore:

```shell
sudo ETCDCTL_API=3 etcdctl snapshot restore etcd_backup.db \
  --initial-cluster etcd-restore=https://10.0.1.101:2380 \
  --initial-advertise-peer-urls https://10.0.1.101:2380 \
  --name etcd-restore \
  --data-dir /var/lib/etcd  
sudo chown -R etcd:etcd /var/lib/etcd
sudo systemctl start etcd  
```

</details>


# Exercise 1 - RBAC

A third party application requires access to describe `job` objects that reside in a namespace called `rbac`. Perform the following:

1. Create a namespace called `rbac`
2. Create a service account called `job-inspector` for the `rbac` namespace
3. Create a role that has rules to `get` and `list` job objects
4. Create a rolebinding that binds the service account `job-inspector` to the role created in step 3
5. Prove the `job-inspector` service account can "get" `job` objects but not `deployment` objects

<details><summary>Answer - Imperative</summary>

```shell
kubectl create namespace rbac
kubectl create sa job-inspector -n rbac
kubectl create role job-inspector --verb=get --verb=list --resource=jobs -n rbac
kubectl create rolebinding permit-job-inspector --role=job-inspector --serviceaccount=rbac:job-inspector -n rbac
kubectl --as=system:serviceaccount:rbac:job-inspector auth can-i get job -n rbac 
kubectl --as=system:serviceaccount:rbac:job-inspector auth can-i get deployment -n rbac
```
</details>


<details><summary>Answer - Declarative</summary>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: rbac
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: job-inspector
  namespace: rbac
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: job-inspector
  namespace: rbac
rules:
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: permit-job-inspector
  namespace: rbac
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: job-inspector
subjects:
  - kind: ServiceAccount
    name: job-inspector
    namespace: rbac
```
</details>


# Exercise 3 - Manage a highly-available Kubernetes cluster

1. Using `etcdctl`, determine the health of the etcd cluster
2. Using `etcdctl`, identify the list of members   
3. On the master node, determine the health of the cluster by probing the API endpoint


<details><summary>Answer</summary>

```shell
etcdctl cluster-health

cluster is healthy
member <id> is healthy
member <id> is healthy
member <id> is healthy

etcdctl member list
<id>: name=etcd1 peerURLs=http://<ip>:2380 clientURLs=<ip>:2379
<id>: name=etcd0 peerURLs=http://<ip>:2380 clientURLs=<ip>:2379
<id>: name=etcd2 peerURLs=http://<ip>:2380 clientURLs=<ip>:2379

curl -k https://localhost:6443/healthz?verbose
[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-kube-apiserver-admission-initializer ok
...
```

</details>

