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
  
