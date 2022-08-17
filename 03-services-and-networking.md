# Lab Exercises for Services & Networking

# Exercise 1 - Understanding K8s DNS

Create a descriptor that will set up some sample Pods which you can use to test DNS functionality


<details><summary>Answer</summary>
  
```yaml
dnstest-pods.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: busybox-dnstest
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 3600; done']
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dnstest
spec:
  containers:
  - name: nginx
    image: nginx:1.19.2
    ports:
    - containerPort: 80
```    

```shell
kubectl apply -f dnstest-pods.yml
```  
  
Verify that you can reach the nginx-dnstest over the cluster network using its IP address and internal domain name

```shell
kubectl get pods nginx-dnstest -o wide
kubectl exec busybox-dnstest -- curl <nginx-dnstest IP address>
kubectl exec busybox-dnstest -- nslookup <nginx-dnstest-ip>.default.pod.cluster.local  
kubectl exec busybox -- curl <nginx-dnstest-ip>.default.pod.cluster.local  
```   
  
  
</details>
  
# Exercise 2 - Using NetworkPolicies

Create a network poliy on pod to control the traffic


<details><summary>Answer</summary>
  
Create a new namespace with label
```shell
kubectl create namespace np-test
kubectl label namespace np-test team=np-test  
```  
  
Create a web server Pod

```yaml
np-nginx.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: np-nginx
  namespace: np-test
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
```   
```shell
kubectl create -f np-nginx.yml 
```    
  
Create a client Pod

```yaml
np-busybox.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: np-busybox
  namespace: np-test
  labels:
    app: client
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 5; done']
```   
```shell
kubectl create -f np-busybox.yml
```    
  
Attempt to access the nginx Pod from the client Pod. This should succeed since no NetworkPolicies select the client Pod
```shell
kubectl get pods -n np-test -o wide
NGINX_IP=<np-nginx Pod IP>  
kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```     
  
Create a NetworkPolicy that selects the Nginx Pod
  
```yaml
my-networkpolicy.yml
---  
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-networkpolicy
  namespace: np-test
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  - Egress
```   
```shell
kubectl apply -f my-networkpolicy.yml
```    
  
This NetworkPolicy will block all traffic to and from the Nginx Pod. Attempt to communicate with the Pod again. It should fail
this time
```shell
kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```       
  
Modify the NetworkPolicy so that it allows incoming traffic on port 80 for all Pods in the np-test Namespace
```yaml
my-networkpolicy.yml
---  
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-networkpolicy
  namespace: np-test
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  - Egress
ingress:
- from:
  - namespaceSelector:
    matchLabels:
      team: np-test
  ports:
  - port: 80
    protocol: TCP  
```     
  
Attempt to communicate with the Pod again. This time, it should work!
</details>
  
