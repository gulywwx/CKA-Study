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
