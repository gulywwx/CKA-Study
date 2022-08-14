## 1 - sorted by capacity

List all persistent volumes sorted by capacity, saving the full kubectl output to
/opt/KUCC00102/volume_list. Use kubectl 's own functionality for sorting the output, and do not manipulate it any further.

<details><summary>Answer</summary>
  
```shell
kubectl  get pv -A  --sort-by={.spec.capacity.sotrge} >  /opt/KUCC00102/volume_list
```

</details>

## 2 - Daemonset

Ensure a single instance of Pod nginx is running on each node of the Kubernetes cluster where nginx also represents the image name which has to be used. Do no override any taints currently in place. Use Daemonset to complete this task and use ds.kusc00612 as Daemonset name

<details><summary>Answer</summary>
  
```yaml
Daemonset.ayml  
---  
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds.kusc00612
  labels:
    k8s-app: ds.kusc00612
spec:
  selector:
    matchLabels:
      name: ds.kusc00612
  template:
    metadata:
      labels:
        name: ds.kusc00612
    spec:
      containers:
      - name: nginx
        image: nginx
```
  
```shell
kubectl  apply -f Daemonset.ayml 
kubectl  get  daemonset  
```

</details>

## 3 - init container
Add an init container to lumpy-koala(which has been defined in spec file /opt/kucc00100/pod-specKUCC00612.yaml). The init container should create an empty file named /workdir/calm.txt. If /workdir/calm.txt is not detected, the Pod should exit. Once the spec file has been updated with the init container definition, the Pod should be created

<details><summary>Answer</summary>
  
```yaml
init-pod.yaml
---  
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "touch /workdir/calm.txt"]
    volumeMounts:
    - mountPath: /workdir
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```
  
```shell
kubectl  apply -f init-pod.yaml 
```
</details>

## 4 - Node Selector
Schedule a Pod as follows: Name: nginxkusc00612 Image: nginx Node selector: disk=ssd

<details><summary>Answer</summary>
  
```yaml
nodeSelector.yaml 
---  
apiVersion: v1
kind: Pod
metadata:
  name: nginxkusc00612
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```
  
```shell
kubectl  apply -f nodeSelector.yaml  
```
</details>

## 5 - Deployment
Create a deployment as follows: Name: nginxapp Using container nginx with version 1.11.9-alpine. The deployment should contain 3 replicas. Next, deploy the app with new version 1.12.0-alpine by performing a rolling update and record that update.Finally,rollback that update to the previous version 1.11.9-alpine.

<details><summary>Answer</summary>
  
```shell
kubectl create deployment nginxapp --image=nginx:1.11.9-alpine
kubectl scale deployment nginxapp  --replicas=3
kubectl set image deployment/nginxapp nginx=nginx:1.12.0-alpine --record=true
kubectl rollout undo deployment.apps/nginxapp   
  
```
</details>

## 6 - Service
Create and configure the service front-endservice so it’s accessible through NodePort/ClusterIp and routes to the existing pod named nginxkusc00612

<details><summary>Answer</summary>
  
```yaml
service.yaml
---  
apiVersion: v1
kind: Service
metadata:
  name: pod-service
spec:
  selector:
    app: front-end
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: http
```
  
```shell
kubectl  apply -f service.yaml  
```
</details>

## 7 - Jenkins Pod
Create a Pod as follows: Name: jenkins Using image: jenkins In a new Kubernetes namespace named pro-test
<details><summary>Answer</summary>
  
```shell
kubectl  get namespaces  pro-test 
kubectl run jenkins --image=jenkins --namespace=pro-test   
kubectl  get pods -n pro-test   
```
</details>

## 8 - replicas deployment
Create a deployment spec file that will: Launch 7 replicas of the redis image with the label : app_enb_stage=dev Deployment name: kual00612 Save a copy of this spec file to /opt/KUAL00612/deploy_spec.yaml (or .json) When you are done,clean up(delete) any new k8s API objects that you produced during this task
<details><summary>Answer</summary>
  
```yaml
ReplicaSet.yaml
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kual00612
  labels:
    app_enb_stage: dev
spec:
  replicas: 7
  selector:
    matchLabels:
      app: kual00612
  template:
    metadata:
      labels:
        app: kual00612
    spec:
      containers:
      - name: redis
        image: redis
```
  
```shell
kubectl  apply -f ReplicaSet.yaml
cat ReplicaSet.yaml >  /opt/KUAL00612/deploy_spec.yaml  
kubectl  get pods |grep kual00612|grep  Running|wc -l  
```
</details>

## 9 - search pods
Create a file /opt/KUCC00612/kucc00612.txt that lists all pods that implement Service foo in Namespace production. The format of the file should be one pod name per line.
<details><summary>Answer</summary>

```shell
kubecet get svc   -n production  --show-lables|grep foo
kubectl  get pods -nccod45 -l name=foo |grep -v NAME|awk '{print $1}' >>   /opt/KUCC00302/kucc00302.txt
```
</details>

## 10 - dns
Create a deployment as follows: Name: nginxdns Exposed via a service : nginx-dns Ensure that the service & pod are accessible via their respective DNS records The container(s) within any Pod(s) running as a part of this deployment should use the nginx image. Next, use the utility nslookup to look up the DNS records of the service & pod and write the output to /opt/service.dns and /opt/pod.dns respectively. Ensure you use the busybox:1.28 image (or earlier) for any testing, an the latest release has an upstream bug which impacts the use of nslookup

<details><summary>Answer</summary>

```yaml
deployment.yaml
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  selector:
    matchLabels:
      app: nginxdns
  replicas: 1
  template:
    metadata:
      labels:
        app: nginxdns
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - name: http
              containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginxdns
spec:
  selector:
    app: nginxdns
  ports:
  - protocol: TCP
    port: 80
    targetPort: http
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-test
  labels:
    app: busybox-test
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
```
```shell
kubecet apply -f deployment.yaml
kubectl exec -ti busybox-test -- nslookup nginxdns > /opt/service.dns
kubectl exec -ti busybox-test -- nslookup  10.244.1.52 > /opt/pod.dns  
```
</details>

