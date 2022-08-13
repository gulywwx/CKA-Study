
# Lab Exercises for Workloads & Scheduling


# Exercise 1 - Use ConfigMaps to configure applications

1. Create a configmap and secret
2. Create a busybox pod. Configure this Pod so that the underlying container has the environment variable set to the value of this configmap and the environment variable set to the value of the secret


<details><summary>Answer</summary>

Create a ConfigMap my-configmap.yml:
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
