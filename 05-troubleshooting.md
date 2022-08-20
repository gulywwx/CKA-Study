# Lab Exercises for Troubleshooting

# Exercise 1 - Troubleshooting a Broken Kubernetes Cluster

1. Determine What is Wrong with the Cluster
2. Fix the Problem

<details><summary>Answer</summary>

Find out which node is having a problem by using kubectl get nodes. Identify if a node is in the NotReady state
  
Get more information on the node by using 

```shell  
kubectl describe node <NODE_NAME>
```
  
Look for the Conditions section of the Node Information and find out what is affecting the node's status, causing it to fail
  
Log in to the worker 2 node server using the credentials provided. Look at the kubelet logs of the worker 2 node by using. 
  


  
Go to the end of the log by pressing Shift + G and see the error messages stating that kubelet has stopped
  
Look at the status of the kubelet status by using
  
```shell  
sudo systemctl status kubelet
```  
  
and note whether the kubelet service is running or not  
  
In order to fix the problem, we need to not only start the server but also enable kubelet to ensure that it continues to work if the server restarts in the future. 
  
Use clear to clear the service status, and then start and enable kubelet

```shell  
sudo systemctl enable kubelet
sudo systemctl start kubelet  
```    
Check if kubelet is active by using sudo systemctl status kubelet, and note if the service is listed as active (running)  
</details>   

# Exercise 2 - Troubleshooting a Broken Kubernetes Application

1. Identify What is Wrong with the Application
2. Fix the Problem

<details><summary>Answer</summary>  
  
Identify What is Wrong with the Application
  
```shell  
kubectl get deployment -n web web-consumer
kubectl describe deployment -n web web-consumer
kubectl get pods -n web
kubectl describe pod -n web <POD_NAME>
kubectl logs -n web <POD_NAME> -c busybox
kubectl get pod -n web <POD_NAME> -o yaml  
```      
Determine which command is causing the errors (in this case, the while true; do curl auth-db; sleep 5; done command)
  
Fix the Problem
  
```shell  
kubectl get svc -n web auth-db
kubectl get namespaces 
kubectl get svc -n data
kubectl edit deployment -n web web-consumer  
```   
  
Change the command to while true; do curl auth-db.data.svc.cluster.local; sleep 5; done to give the fully qualified domain name of that service. This will allow the web-consumer deployment's Pods to communicate with the service successfully.

```shell  
kubectl logs -n web <POD-NAME> -c busybox
```     
  
</details>   
  
# Exercise 3 - Troubleshooting k8s Network Issues

1. Using nicolaka/netshoot image

<details><summary>Answer</summary>  
  
Create a simple Nginx Pod to use for testing, as well as a service to expose it
  
```yaml
nginx-netshoot.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: nginx-netshoot
  labels:
    app: nginx-netshoot
spec:
  containers:
  - name: nginx
    image: nginx:1.19.1
---
apiVersion: v1
kind: Service
metadata:
  name: svc-netshoot
spec:
  type: ClusterIP
  selector:
    app: nginx-netshoot
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```      
```shell
kubectl apply -f nginx-netshoot.yml
```      
  
Create a Pod running the netshoot image in a container  
  
```yaml
netshoot.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'while true; do sleep 5; done']
```      
```shell
kubectl apply -f netshoot.yml
```        
  
Open an interactive shell to the netshoot container
```shell
kubectl exec --stdin --tty netshoot -- /bin/sh
curl svc-netshoot
ping svc-netshoot
nslookup svc-netshoot  
```     
  
  
</details>   
  
