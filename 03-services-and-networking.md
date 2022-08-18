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
  
  
# Exercise 3 - Exposing Kubernetes Pods Using Services

1. Expose the Pods from the User-db Deployment as an Internal Service
2. Expose the Pods from the Web-frontend Deployment as an External Service

<details><summary>Answer</summary>
  
Examine the properties of the user-db deployment by using kubectl get deployment user-db -o yaml

In the deployment properties, find the spec and look for the Pod template, paying particular attention to the labels, especially the label app: user-db.
  
Take note of which port(s) are exposed.
  
Start creating a Service that will expose its Pods to other components within the cluster by using vi user-db-svc.yml
  
```yaml
user-db-svc.yml
---  
apiVersion: v1 
kind: Service 
metadata: 
  name: user-db-svc 
spec: 
  type: ClusterIP 
  selector: 
    app: user-db 
  ports: 
  - protocol: TCP 
    port: 80 
    targetPort: 80
```      
```shell
kubectl create -f user-db-svc.yml
kubectl exec busybox -- curl user-db-svc  
```    
  
Now, examine the properties of the frontend deployment by using kubectl get deployment web-frontend -o yaml
  
Check the labels applied to the Pod template. You should see the label app=web-frontend. Take note of which port(s) are exposed
  
Start creating a Service that will expose its Pods on port 30080 of each cluster node by using vi web-frontend-svc.yml  
  
```yaml
web-frontend-svc.yml
---  
apiVersion: v1 
kind: Service 
metadata: 
  name: web-frontend-svc 
spec: 
  type: NodePort 
  selector: 
    app: web-frontend 
  ports: 
  - protocol: TCP 
    port: 80 
    targetPort: 80 
    nodePort: 30080
```      
```shell
kubectl create -f web-frontend-svc.yml
curl http://<PUBLIC_IP_ADDRESS>:30080
```    
  
  
</details>
  
# Exercise 4 - Using Kubernetes Services with DNS

1. Perform an Nslookup for a Service in the Same Namespace
2. Perform an Nslookup for a Service in a Different Namespace

<details><summary>Answer</summary>  
  
Start using the busybox Pod in the web namespace to perform an nslookup on the web-frontend Service by entering
  
```shell
kubectl exec -n web busybox -- nslookup web-frontend
```  
  
Look up the same Service using the fully qualified domain name by entering

```shell
kubectl exec -n web busybox -- nslookup web-frontend.web.svc.cluster.local
```        
  
Use the busybox Pod in the web namespace to perform an nslookup on the user-db Service in the data namespace, while only utilizing the short Service name, by entering. This first request is supposed to result in an error message
  
```shell
kubectl exec -n web busybox -- nslookup user-db
```    
  
Perform the same lookup using the fully qualified domain name by entering
  
```shell
kubectl exec -n web busybox -- nslookup user-db.data.svc.cluster.local
```      
  
  
</details>
