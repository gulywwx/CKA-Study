## 1 - role based access control – RBAC

You have been asked to create a new ClusterRole for a deployment pipeline and bind it to a specific ServiceAccount scoped to a specific namespace.

Create a new ClusterRole named deployment cluster role, which only allows to create the following resource types:

- Deployment
- StatefulSet
- DaemonSet

Create a new ServiceAccount named **cicd-token** in the existing namespace **app-team1**

Bind the new ClusterRole deployment clusterrole to the new ServiceAccount cicd-token, limited to the namespace app-team1

<details><summary>Answer</summary>
  
```shell
kubectl create clusterrole deployment-clusterrole --verb=create --resource=deployments,statefulsets,daemonsets
kubectl create namespace app-team1
kubectl -n app-team1 create serviceaccoun cicd-token
kubectl -n app-team1 create rolebinding cicd-token-binding --clusterrole=deployment-clusterrole --serviceaccount=app-team1:cicd-token
kubectl -n app-team1 describe rolebindings.rbac.authorization.k8s.io cicd-token-binding
```

</details>

## 2 - node maintenance – the specified node node is unavailable

Set the node named **ek8s-node-1** as unavailiable and reschedule all the pods running on it

<details><summary>Answer</summary>

```shell
kubectl cordon ek8s-node-1
kubectl drain ek8s-node-1 --delete-local-data --ignore-daemonsets --force
```
</details>

## 3 - k8s version upgrade

Given an existing kubernetes cluster running version 1.21.0,upgrade all of the Kubernetes control plane and node components on the master node only to version **1.22.0**.

You are also expected to upgrade **kubelet** and **kubectl** on the master node.

<details><summary>Answer</summary>

Set to maintenance status
Expel pod
  
```shell
kubectl get nodes
kubectl cordon mk8s-master-1
kubectl drain mk8s-master-1 --delete-local-data --ignore-daemonsets --force
```
  
SSH to a master node according to the topic prompt
  
```shell
ssh k8s-master
apt update
apt-cache policy kubeadm | grep 1.22.0
apt-get install -y kubeadm=1.22.0-00
kubeadm version 
kubeadm upgrade plan
kubeadm upgrade apply v1.22.0 --etcd-upgrade=false
```

Upgrade kubectl and kubelet
  
```shell
apt-get install kubelet=1.22.0-00 kubectl=1.22.0-00
kubelet version
kubectl version
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
kubectl get node 
```
</details>

## 4 - etcd database backup and recovery

First, create a snapshot of the existing etcd instance running at https://127.0.0.1:2379, saving the snapshot to **/srv/data/etcd-snapshot.db**.
Next, restore an existing, previous snapshot localted at **/var/lib/backup/etcd-snapshot-previous.db**.

<details><summary>Answer</summary>

```shell
apt-get install -y etcd-client  
export ETCDCTL_API=3
etcdctl --endpoints 127.0.0.1:2379 --cacert=/opt/KUIN00601/ca.crt --cert=/opt/KUIN00601/etcd-client.crt --key=/opt/KUIN00601/etcd-client.key snapshot save /srv/data/etcd-snapshot.db
```

```shell
mkdir /opt/backup/ -p
cd /etc/kubernetes/manifests && mv kube-* /opt/backup  
export ETCDCTL_API=3 
etcdctl --endpoints="https://127.0.0.1:2379" --cacert=/opt/KUIN000601/ca.crt --cert=/opt/KUIN000601/etcd-client.crt --key=/opt/KUIN000601/etcd-client.key   snapshot restore /var/lib/backup/etcd-snapshot-previous.db --data-dir=/var/lib/etcd-restore
```

Change the path: /var/lib/etcd of volume configuration to /var/lib/etcd-restore
 
```yaml
etcd.yaml
---  
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd-restore
```
  
```shell
mv /opt/backup/* /etc/kubernetes/manifests
systemctl restart kubelet
```  
</details>

## 5 - network policy

Create a new NetworkPolicy named **allow-port-from-namespace** that allows Pods in the existing namespace **internal** to connect to port 9000 of other Pods in the same namespace.

Ensure that the new NetworkPolicy:

- does not allow access to Pods not listening on port 9000
- does not allow access from Pods not in namespace internal

<details><summary>Answer</summary>

```yaml
allow-port-from-namespace.yml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: all-port-from-namespace
  namespace: internal
spec:
  ingress:
  - from:
    - podSelector: {}
    ports:
    - port: 9000
      protocol: TCP
  podSelector: {}
  policyTypes:
  - Ingress
```

```shell
kubectl apply -f allow-port-from-namespace.yml
```
</details>

## 6 - four layer load balancing service
Reconfigure the existing deployment **front-end** and add a port specification named http exposing port 80/tcp of the existing container nginx

Create a new service named **front-end-svc** exposing the container port http.

Configure the new service to also expose the individual Pods via a NoedPort on the nodes on which they are scheduled.

<details><summary>Answer</summary>

```
kubectl edit deploy front-end  
kubectl config use-context k8s
kubectl expose deployment front-end --port=80 --target-port=80 --protocol=TCP --type=NodPort --name=front-end-svc
```
</details>

## 7 - seven layer load balancing progress

Create a new nginx ingress resource as follows:

- Name: pong
- Namespace: ing-internal
- Exposing service hi on path /hi using service port 5678

<details><summary>Answer</summary>

```yaml
ping-ingress.yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ping
  namespace: ing-internal
spec:
  rules:
  - http:
    paths:
    - path: /hi
      pathType: Prefix
      backend:
        service:
        name: hi
        port:
          number: 5678
```

```shell
kubectl apply -f ping-ingress.yaml
kubectl get pod -n ing-internal -o wide
curl -kL
```
</details>
  
## 8 - expansion and contraction of deployment management pod

Scale the deployment loadbalancer to 6 pods.

<details><summary>Answer</summary>

```shell
kubectl scale deployment loadbalancer --replicas=6
kubectl edit deployment loadbalancer  
```
</details>
  
## 9 - pod specified node deployment

Schedule a pod as follows:

- Name: nginx-kusc00401
- Image: nginx
- Node selector: disk=spinning

<details><summary>Answer</summary>

```yaml
nginx-kusc00401.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-kusc00401
  labels:
    role: nginx-kusc00401  
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disk: spinning

spec:
  nodeSelector:
    disk: spinning
  containers:
    - name: nginx
      image: nginx  
```

```shell
kubectl apply -f nginx-kusc00401.yml
kubectl get pod nginx-kusc00401 -o wide
```
</details>
  
## 10 - check the health status of node

Check to see how many nodes are ready (not including nodes tainted NoSchedule) and write the number to **/opt/KUSC00402/kusc00402.txt**

<details><summary>Answer</summary>

```shell
kubectl get node | grep -i ready   
kubectl describe node | grep -i taints|grep -v -i noschedule
echo $num > /opt/KUSC00402/kusc00402.txt
```
</details>

## 11 - one pod encapsulates multiple containers

Create a pod named **kucc1** with a single app container for each of the following images running inside(there may be between 1 and 4 images specified): nginx+redis+memcached+consul.

<details><summary>Answer</summary>

```yaml
kucc1.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: kucc1
spec:
  containers:
  - name: nginx
    image: nginx
  - name: redis
    image: redis
  - name: memcached
    image: memcached
  - name: consul
    image: consul
```

```shell
kubectl apply -f kucc1
```
</details>

## 12 - persistent storage volume

Create a persistent volume with name **app-config**, of capacity 2Gi and access mode ReadWriteMany. the type of volume is hostPath and its location is **/srv/app-config**

<details><summary>Answer</summary>

```yaml
app-config-pv.yml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-config
  labels:
    type: local  
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/srv/app-config"
```

```shell
kubectl apply -f app-config-pv.yml
```
</details>

## 13 - PersistentVolumeClaim

Create a new PersistentVolumeClaim:

- Name: pv-volume
- Class: csi-hostpath-sc
- Capacity: 10Mi

Create a new Pod which mounts the persistentVolumeClaim as a volume:

- Name: web-server
- Image: nginx
- Mount path: /usr/share/nginx/html

Configure the new Pod to have ReadWriteOnce access on the volume.

Finally, using kubectl edit or kubectl patch expand the PersistentVolumeClaim to a capacity of 70Mi and record that change.

<details><summary>Answer</summary>

```yaml
pv-volume-pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-volume
spec:
  storageClassName: csi-hostpath-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
```

```yaml
web-server-pod.yml 
---
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: pv-volume
  containers:
    - name: web-server
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
  nodeSelector:
    disk: ssd
```

```shell
kubectl apply -f pv-volume-pvc.yaml
kubectl get pvc
kubectl apply -f web-server-pod.yml 
kubectl edit pvc pv-volume --record
kubectl patch pvc pv-volume  -p '{"spec":{"resources":{"requests":{"storage": "70Mi"}}}}' --record  
```
</details>
  
## 14 - monitoring pod log

Monitor the logs of pod foobar and :

- Extract log lines corresponding to error unable-to-access-website
- Write them to /opt/KUTR00101/foobar

<details><summary>Answer</summary>

```
kubectl logs foobar | grep unable-to-access-website > /opt/KUTR00101/foobar
```
</details>
  
## 15 - sidecar agent

Without changing its existing containers, an existing Pod needs to be integrated into Kubernetes's build-in logging architecture(e.g kubectl logs).Adding a streaming sidecar container is a good and common way accomplish this requirement.
Task

Add a busybox sidecar container to the existing Pod legacy-app. The new sidecar container has to run the following command:

```
/bin/sh -c tail -n+1 -f /var/log/legacy-app.log
```

Use a volume mount named logs to make the file /var/log/legacy-app.log available to the sidecar container.

TIPS
Don't modify the existing container.
Don't modify the path of the log file, both containers
must access it at /var/log/legacy-app.log

<details><summary>Answer</summary>
  
```shell
kubectl get pod legacy-app -o yaml > legacy-app.yml
cp egacy-app.yml legacy-app-new.yml
vi legacy-app-new.yml
```
  
```yaml
legacy-app.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
spec:
  containers:
  - name: count
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      i=0;
      while true;
      do
        echo "$(date) INFO $i" >> /var/log/legacy-ap.log;
        i=$((i+1));
        sleep 1;
      done     
```
  
  
  
```yaml
legacy-app-new.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
spec:
  containers:
  - name: count
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      i=0;
      while true;
      do
        echo "$i: $(date)" >> /var/log/big-corp-app.log;
        sleep 1;
      done
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: busybox
    image: busybox
    args: [/bin/sh, -c, 'tail -n+1 -f /var/log/legacy-app.log']
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
emptyDir: {}
```

```shell
kubectl delete -f legacy-app.yml
kubectl apply -f legacy-app-new.yml
```
</details>
  
## 16 - monitoring pod metrics

From the pod label **name=cpu-user**, find pods running high CPU workloads and write the name of the pod consuming most CPU to the file **/opt/KUTR00401/KUTR00401.txt** (which already exists.)

<details><summary>Answer</summary>

```shell
kubectl top pod -l name=cpu-user -A
    NAMAESPACE NAME        CPU   MEM
    delault    cpu-user-1  45m   6Mi
    delault    cpu-user-2  38m   6Mi
    delault    cpu-user-3  35m   7Mi
    delault    cpu-user-4  32m   10Mi
```

```
echo 'cpu-user-1' >>/opt/KUTR00401/KUTR00401.txt
```
</details>

## 17 - cluster troubleshooting – kubelet fault

A Kubernetes worker node,named wk8s-node-0 is in state NotReady .
Investigate why this is the case,and perform any appropriate steps to bring the node to a Ready state,ensuring that any changes are made permanent.

<details><summary>Answer</summary>

```shell
ssh wk8s-node-0
sudo -i  
systemctl status kubelet 
systemctl start kubelet
systemctl enable kubelet 
```
</details>
