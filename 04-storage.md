# Lab Exercises for Storage

# Exercise 1 - Managing Container Storage with Kubernetes Volumes

1. Create a Pod That Outputs Data to the Host Using a Volume
2. Create a Multi-Container Pod That Shares Data Between Containers Using a Volume

<details><summary>Answer</summary>

Create a Pod that will interact with the host file system by using vi maintenance-pod.yml
  
```yaml
dnstest-pods.yml
---  
apiVersion: v1
kind: Pod
metadata:
    name: maintenance-pod
spec:
    containers:
    - name: busybox
      image: busybox
      command: ['sh', '-c', 'while true; do echo Success! >> /output/output.txt; sleep 5; done']
      volumeMounts:
      - name: output-vol
        mountPath: /output  
    volumes:
    - name: output-vol
      hostPath:
          path: /var/data  
```      
```shell
kubectl apply -f dnstest-pods.yml
```    
  
Make sure the Pod is up and running by using kubectl get pods and check that maintenance-pod is running, so it should be outputting data to the host system

Create another YAML file for a shared-data multi-container Pod by using vi shared-data-pod.yml. Start with the basic Pod definition and add multiple containers, where the first container will write the output.txt file and the second container will read the output.txt file
  
```yaml
shared-data-pod.yml
---  
apiVersion: v1
kind: Pod
metadata:
    name: shared-data-pod
spec:
    containers:
    - name: busybox1
      image: busybox
      command: ['sh', '-c', 'while true; do echo Success! >> /output/output.txt; sleep 5; done']
      volumeMounts:
      - name: shared-vol
        mountPath: /output  
    - name: busybox2
      image: busybox
      command: ['sh', '-c', 'while true; do cat /input/output.txt; sleep 5; done']
      volumeMounts:
      - name: shared-vol
        mountPath: /input  
    volumes:
    - name: shared-vol
      emptyDir: {}  

```      
```shell
kubectl apply -f shared-data-pod.yml
```    
  
To make sure the Pod is working, check the logs for shared-data-pod.yml and specify the second container that is reading the data and printing it to the console, using kubectl logs shared-data-pod -c busybox2. If you see the series of "Success!" messages, you have successfully created both containers, one of which is using a host path volume to write some data to the host disk and the other of which is using an emptyDir volume to share a volume between two containers in the same Pod.  
  
</details>  

# Exercise 2 - Managing Container Storage with Kubernetes Volumes

1. Create a PersistentVolume That Allows Claim Expansion
2. Create a PersistentVolumeClaim
3. Create a Pod That Uses a PersistentVolume for Storage

<details><summary>Answer</summary>
Create a custom Storage Class
  
```yaml
localdisk.yml
---  
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata: 
  name: localdisk 
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
```      
```shell
kubectl create -f localdisk.yml
```     
  
Create the PersistentVolume 
  
```yaml
host-pv.yml
---  
kind: PersistentVolume 
apiVersion: v1 
metadata: 
   name: host-pv 
spec: 
   storageClassName: localdisk
   persistentVolumeReclaimPolicy: Recycle 
   capacity: 
      storage: 1Gi 
   accessModes: 
      - ReadWriteOnce 
   hostPath: 
      path: /var/output
```      
```shell
kubectl create -f host-pv.yml
kubectl get pv  
```     
  
Start creating a PersistentVolumeClaim for the PersistentVolume to bind
  
```yaml
host-pvc.yml
---  
apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
   name: host-pvc 
spec: 
   storageClassName: localdisk 
   accessModes: 
      - ReadWriteOnce 
   resources: 
      requests: 
         storage: 100Mi
```      
```shell
kubectl create -f host-pvc.yml
kubectl get pv  
kubectl get pvc  
```     
  
Create a Pod that uses the PersistentVolumeClaim
  
```yaml
pv-pod.yml
---  
apiVersion: v1 
kind: Pod 
metadata: 
   name: pv-pod 
spec: 
   containers: 
      - name: busybox 
        image: busybox 
        command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep 5; done'] 
```      
  
Mount the PersistentVolume to the /output location by adding the following, which should be level with the containers spec in terms of indentation
  
```yaml
pv-pod.yml
---  
volumes: 
 - name: pv-storage 
   persistentVolumeClaim: 
      claimName: host-pvc
```      
      
In the containers spec, below the command, set the list of volume mounts by using
  
```yaml
pv-pod.yml
---  
volumeMounts: 
- name: pv-storage 
  mountPath: /output 
```        
  
  
  
```shell
kubectl create -f pv-pod.yml
kubectl get pods
cat /var/output/success.txt
```   
  
  
  
  
</details>  
