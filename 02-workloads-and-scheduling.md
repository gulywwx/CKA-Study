
# Lab Exercises for Workloads & Scheduling


# Exercise 1 - Use ConfigMaps/Secret to configure applications

1. Create a configmap and secret
2. Create a busybox pod. Configure this Pod so that the underlying container has the environment variable set to the value of this configmap and the environment variable set to the value of the secret


<details><summary>Answer</summary>

Create a ConfigMap my-configmap.yml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  key1: Hello, world!
  key2: |
    Test
    multiple lines
    more lines  
```  
```shell
kubectl create -f my-configmap.yml
```  

Validate:

```shell
kubectl describe configmap my-configmap
```
  
Create a secret my-secret.yml:

Get two base64-encoded values  

```shell
echo -n 'secret' | base64
echo -n 'anothersecret' | base64
```
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  secretkey1: <base64 String 1>
  secretkey2: <base64 String 2>
```    
```shell
kubectl create -f my-secret.yml
```    
  
Create a pod and supply configuration data using environment variables env-pod.yml
  
```json
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo "configmap: $CONFIGMAPVAR secret: $SECRETVAR"']
    env:
    - name: CONFIGMAPVAR
      valueFrom:
        configMapKeyRef:
          name: my-configmap
          key: key1
    - name: SECRETVAR
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: secretkey1
```    
```shell
kubectl create -f env-pod.yml
kubectl logs env-pod  
```     
  
Create a pod and supply configuration data using volumes volume-pod.yml

```json
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
    volumeMounts:
    - name: configmap-volume
      mountPath: /etc/config/configmap
    - name: secret-volume
      mountPath: /etc/config/secret
  volumes:
  - name: configmap-volume
    configMap:
      name: my-configmap
  - name: secret-volume
    secret:
      secretName: my-secret
```
```shell
kubectl create -f volume-pod.yml
kubectl exec volume-pod -- ls /etc/config/configmap
kubectl exec volume-pod -- cat /etc/config/configmap/key1
kubectl exec volume-pod -- cat /etc/config/configmap/key2
kubectl exec volume-pod -- ls /etc/config/secret
kubectl exec volume-pod -- cat /etc/config/secret/secretkey1
kubectl exec volume-pod -- cat /etc/config/secret/secretkey2
```   
</details>

# Exercise 3 - Building Self-Healing Containers
  
1. Set a Restart Policy to Restart the Container When It Is Down
2. Create a Liveness Probe to Detect When the Application Has Crashed
  
<details><summary>Answer</summary>
Get the pod's YAML descriptor
  
```shell
kubectl get pod beebox-shipping-data -o yaml > beebox-shipping-data.yml
```     
  
Set the restartPolicy to Always  
  
```yaml
beebox-shipping-data.yml
---  
spec:
  ...
  restartPolicy: Always
  ...
```      
  
Add a liveness probe
```yaml
beebox-shipping-data
---  
spec:
  containers:
  - ...
    name: shipping-data
    livenessProbe:
      httpGet:
        path: /
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
    ...
```
```shell
kubectl delete pod beebox-shipping-data
kubectl apply -f beebox-shipping-data.yml
kubectl exec busybox -- curl <beebox-shipping-data_IP>:8080  
```
  
</details>
  
# Exercise 2 - Using Init Containers
1. Create a Sample Pod That Uses an Init Container to Delay Startup
2. Test Your Setup by Creating the Service and Verifying the Pod Starts Up
  
<details><summary>Answer</summary>
  
```yaml
pod.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: shipping-web
spec:
  containers:
  - name: nginx
    image: nginx:1.19.1
```
Add an init container (at the same level as containers in the file) to delay startup until the shipping-svc service is available 
  
```yaml  
spec:
  ...
  initContainers:
  - name: shipping-svc-check
    image: busybox:1.27
    command: ['sh', '-c', 'until nslookup shipping-svc; do echo waiting for shipping-svc; sleep 2; done']
```
```shell
kubectl create -f pod.yml
kubectl get pods  
```  
It should remain in the Init status until

```yaml  
shipping-svc.yml
---  
apiVersion: v1
kind: Service
metadata:
  name: shipping-svc
spec:
  selector:
    app: shipping-svc
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: shipping-backend
  labels:
   app: shipping-svc
spec:
  containers:
  - name: nginx
    image: nginx:1.19.1
```
  
```shell  
kubectl create -f shipping-svc.yml
kubectl get pods  
```  
It should enter the Running status after about a minute  
  
</details>
  

  
