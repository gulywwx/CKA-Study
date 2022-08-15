
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

# Exercise 2 - Building Self-Healing Containers
  
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
  
# Exercise 3 - Using Init Containers
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
  

# Exercise 4 - Assigning a Kubernetes Pod to a Specific Node
1. Configure the `auth-gateway` Pod to Only Run on `k8s-worker2`
2. Configure the `auth-data` Deployment's Replica Pods to Only Run on `k8s-worker2`
  
<details><summary>Answer</summary>

Attach a label to k8s-worker2
```shell  
kubectl label nodes k8s-worker2 external-auth-services=true  
```  

```yaml  
auth-gateway.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: auth-gateway
  namespace: beebox-auth
spec:
  containers:
  - name: nginx
    image: nginx:1.19.1
    ports:
    - containerPort: 80
```  
  
Add a nodeSelector to the auth-gateway pod descriptor

```yaml  
auth-gateway.yml
---  
...

spec:
  nodeSelector:
    external-auth-services: "true"

  ...
```    
  
Delete and re-create the pod
```shell  
kubectl delete pod auth-gateway -n beebox-auth
kubectl create -f auth-gateway.yml
```    
  
Verify the pod is scheduled on the k8s-worker2 node
```shell  
kubectl get pod auth-gateway -n beebox-auth -o wide
```      
  
  
```yaml  
auth-data.yml
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-data
  namespace: beebox-auth
spec:
  replicas: 3
  selector:
    matchLabels:
      app: auth-data
  template:
    metadata:
      labels:
        app: auth-data
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.1
        ports:
        - containerPort: 80
```    

Add a nodeSelector to the pod template in the deployment spec (it will be the second spec in the file)
```yaml  
auth-data.yml
---  
...

spec:

  ...

  template:

    ...

    spec:
      nodeSelector:
        external-auth-services: "true"

      ...
```      
  
Update the deployment and verify the deployment's replicas are all running on k8s-worker2
```shell  
kubectl apply -f auth-data.yml
kubectl get pods -n beebox-auth -o wide  
```      
  
</details>
  
# Exercise 5 - Using DaemonSets
1. Create a DaemonSet Specification YAML File
2. Create the DaemonSet in the Cluster
  
<details><summary>Answer</summary>

```yaml  
daemonset.yml
---  
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: beebox-cleanup
spec:
  selector:
    matchLabels:
      app: beebox-cleanup
  template:
    metadata:
      labels:
        app: beebox-cleanup
    spec:
      containers:
      - name: busybox
        image: busybox:1.27
        command: ['sh', '-c', 'while true; do rm -rf /beebox-temp/*; sleep 60; done']
        volumeMounts:
        - name: beebox-tmp
          mountPath: /beebox-temp
      volumes:
      - name: beebox-tmp
        hostPath:
          path: /etc/beebox/tmp
```       
  
Create the DaemonSet in the cluster, and verify a DaemonSet pod is running on each worker node
```shell  
kubectl apply -f daemonset.yml
kubectl get pods -o wide  
```   
</details>

# Exercise 6 - Using Static Pods
1. Create a Manifest for a Static Pod
2. Start Up the Static Pod
  
<details><summary>Answer</summary>  
  
```yaml  
/etc/kubernetes/manifests/beebox-diagnostic.yml
---  
apiVersion: v1
kind: Pod
metadata:
  name: beebox-diagnostic
spec:
  containers:
  - name: beebox-diagnostic
    image: acgorg/beebox-diagnostic:1
    ports:
    - containerPort: 80
```         
  
Start Up the Static Pod
```shell  
sudo systemctl restart kubelet
kubectl get pods
kubectl delete pod beebox-diagnostic-k8s-worker1
kubectl get pods  
```     
</details>
  
# Exercise 7 - Managing Kubernetes Applications with Deployments
1. Update the App to a New Version of the Code
2. Scale the App to a Larger Number of Replicas
  
<details><summary>Answer</summary>  
  
Edit the beebox-web deployment
```shell  
kubectl edit deployment beebox-web
```   
  
```yaml  
beebox-web.yml
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: beebox-web
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: beebox-web
  template:
    metadata:
      labels:
        app: beebox-web
    spec:
      containers:
      - image: acgorg/beebox-web:1.0.1
        imagePullPolicy: IfNotPresent
        name: web-server
        ports:
        - containerPort: 80
          protocol: TCP
      restartPolicy: Always
```     
  
Locate the Pod's container specification, and change the 1.0.1 image version tag to 1.0.2
```yaml  
beebox-web.yml
---  
...

spec:
  containers:
  - image: acgorg/beebox-web:1.0.2
    imagePullPolicy: IfNotPresent
    name: web-server

...
```      

Check the status of your deployment to watch the rolling update occur
```shell  
kubectl rollout status deployment.v1.apps/beebox-web
```     

Scale the deployment to 5 replicas
```shell  
kubectl scale deployment.v1.apps/beebox-web --replicas=5
kubectl get deployment beebox-web
kubectl get pods  
```     
  
</details>
  
# Exercise 8 - Managing Rolling Updates with Deployments
1. Update a deployment
2. Roll back a deployment
  
<details><summary>Answer</summary>   
  
Edit the deployment spec, changing the image version to 1.19.2 
```shell  
kubectl edit deployment my-deployment
``` 
  
```yaml  
my-deployment.yml
---  
...

spec:
  containers:
  - image: nginx:1.19.2
    name: nginx
...
```     
  
Check the rollout status, deployment status, and pods
```shell  
kubectl rollout status deployment.v1.apps/my-deployment
kubectl get deployment my-deployment
kubectl get pods
```   
  
Perform another rollout, this time using the kubectl set image method. Intentionally use a bad image version
```shell  
kubectl set image deployment/my-deployment nginx=nginx:broken --record
```   
  
Check the rollout status again. You will see the rollout unable to succeed due to a failed image pull
```shell  
kubectl rollout status deployment.v1.apps/my-deployment
kubectl get pods
```   

Check the rollout history
```shell  
kubectl rollout history deployment.v1.apps/my-deployment
```  
  
Roll back to an earlier working version with one of the following methods
```shell  
kubectl rollout undo deployment.v1.apps/my-deployment
kubectl rollout undo deployment.v1.apps/my-deployment --to-revision=<last working revision>  
```   
  
</details>
  
