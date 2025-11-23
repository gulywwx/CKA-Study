# Kubernetes Deployment Troubleshooting

This guide demonstrates common Kubernetes Deployment issues and how to troubleshoot them.

## Prerequisites

- Kubernetes cluster (Minikube, Kind, or any K8s cluster)
- kubectl configured
- Docker images built and pushed to Docker Hub (see [materials/README.md](materials/README.md))

## Scenarios

### Scenario 1: Rolling Update Failure - Application Crashes on Startup

**Problem:** New version of the application crashes immediately, preventing rolling update from completing.

#### Setup

```bash
# Create namespace
kubectl create namespace joey

# Deploy working v1.0
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-update-test
  namespace: joey
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0 # Keep all old pods running
      maxSurge: 4       # Create 4 new pods at a time
  selector:
    matchLabels:
      app: rolling-test
  template:
    metadata:
      labels:
        app: rolling-test
    spec:
      containers:
      - name: app
        image: gulywwx/myapp:v1.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 3
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
EOF

# Wait for deployment to be ready
kubectl -n joey rollout status deployment/rolling-update-test
```

#### Trigger the Problem

```bash
# Update to broken v2.0.1
kubectl -n joey set image deployment/rolling-update-test app=gulywwx/myapp:v2.0.1
```

#### Symptoms

```bash
# Check pods
kubectl -n joey get pods

# Output shows:
# - 4 old pods still running (v1.0)
# - 4 new pods in CrashLoopBackOff (v2.0.1)

# Check rollout status
kubectl -n joey rollout status deployment/rolling-update-test
# Output: Waiting for deployment "rolling-update-test" rollout to finish...
```

#### Troubleshooting Steps

1. **Check pod status**
   ```bash
   kubectl -n joey get pods
   ```

2. **Describe the failing pod**
   ```bash
   # Get the pod name
   POD_NAME=$(kubectl -n joey get pods | grep rolling-update-test | grep -v Running | awk '{print $1}' | head -1)
   
   kubectl -n joey describe pod $POD_NAME
   ```

3. **Check pod logs**
   ```bash
   kubectl -n joey logs $POD_NAME
   ```

4. **Check deployment events**
   ```bash
   kubectl -n joey describe deployment rolling-update-test
   ```

5. **Check ReplicaSets**
   ```bash
   kubectl -n joey get rs
   # Shows old RS with 4 replicas, new RS with 4 replicas (not ready)
   ```


#### Resolution

**Option 1: Rollback to previous version**
```bash
kubectl -n joey rollout history deployment/rolling-update-test
kubectl -n joey rollout undo deployment/rolling-update-test --to-revision=1
kubectl -n joey rollout status deployment/rolling-update-test
```

**Option 2: Deploy a fixed version**
```bash
# Deploy v1.0 again
kubectl -n joey set image deployment/rolling-update-test app=gulywwx/myapp:v1.0
```

---

### Scenario 2: Rolling Update Failure - Readiness Probe Fails

**Problem:** New version starts successfully but fails readiness probes, preventing rolling update completion.

#### Setup

Ensure v1.0 is deployed (from Scenario 1 resolution).

#### Trigger the Problem

```bash
# Update to broken v2.0.2
kubectl -n joey set image deployment/rolling-update-test app=gulywwx/myapp:v2.0.2
```

#### Symptoms

```bash
# Check pods
kubectl -n joey get pods

# Output shows:
# - 0 old pods still running (v1.0)
# - 4 new pod in 0/1 Ready state (v2.0.2)

# Check rollout status
kubectl -n joey rollout status deployment/rolling-update-test
# Output: Waiting for deployment "rolling-update-test" rollout to finish...
```

#### Troubleshooting Steps

1. **Check pod readiness**
   ```bash
   kubectl -n joey get pods
   # Note the pod with 0/4 READY
   ```

2. **Describe the pod**
   ```bash
   POD_NAME=$(kubectl -n joey get pods | grep rolling-update-test | grep "0/1" | awk '{print $1}' | head -1)
   
   kubectl -n joey describe pod $POD_NAME
   # Look for: Readiness probe failed: HTTP probe failed with statuscode: 500
   ```

3. **Check pod logs**
   ```bash
   kubectl -n joey logs $POD_NAME
   ```

4. **Check deployment conditions**
   ```bash
   kubectl -n joey describe deployment rolling-update-test
   # Look for: Progressing - ReplicaSet has timed out progressing
   ```

#### Root Cause

The new application version (v2.0.2) has a flaky health check endpoint that returns 500 errors 80% of the time, causing readiness probes to fail continuously.

#### Resolution


**Option 1: Check rollout history and rollback to specific revision**
```bash
kubectl -n joey rollout history deployment/rolling-update-test
kubectl -n joey rollout undo deployment/rolling-update-test --to-revision=1
```

---

## Common Troubleshooting Commands

### Check Deployment Status
```bash
# Get deployments
kubectl -n joey get deployments

# Describe deployment
kubectl -n joey describe deployment rolling-update-test

# Check rollout status
kubectl -n joey rollout status deployment/rolling-update-test

# View rollout history
kubectl -n joey rollout history deployment/rolling-update-test
```

### Check Pods
```bash
# Get pods
kubectl -n joey get pods

# Get pods with more details
kubectl -n joey get pods -o wide

# Watch pods
kubectl -n joey get pods -w

# Describe pod
kubectl -n joey describe pod <pod-name>

# Check pod logs
kubectl -n joey logs <pod-name>

# Check previous container logs (if crashed)
kubectl -n joey logs <pod-name> --previous
```

### Check ReplicaSets
```bash
# Get ReplicaSets
kubectl -n joey get rs

# Describe ReplicaSet
kubectl -n joey describe rs <replicaset-name>
```

### Check Events
```bash
# Get events sorted by time
kubectl -n joey get events --sort-by='.lastTimestamp'

# Get events for specific pod
kubectl -n joey get events --field-selector involvedObject.name=<pod-name>
```

### Rollback Operations
```bash
# Undo last rollout
kubectl -n joey rollout undo deployment/rolling-update-test

# Undo to specific revision
kubectl -n joey rollout undo deployment/rolling-update-test --to-revision=2

# Pause rollout
kubectl -n joey rollout pause deployment/rolling-update-test

# Resume rollout
kubectl -n joey rollout resume deployment/rolling-update-test
```

### Debug Running Pods
```bash
# Execute commands in pod
kubectl -n joey exec -it <pod-name> -- /bin/sh

# Port forward to pod
kubectl -n joey port-forward <pod-name> 8080:8080

# Copy files from pod
kubectl -n joey cp <pod-name>:/path/to/file ./local-file
```

## Key Concepts

### Rolling Update Strategy

- **maxUnavailable**: Maximum number of pods that can be unavailable during update
- **maxSurge**: Maximum number of extra pods that can be created during update

**Configuration:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0  # Keep all pods available
    maxSurge: 1        # Create 1 extra pod at a time
```

### Readiness Probes

Determines when a pod is ready to accept traffic:

```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3
```

### Deployment States

- **Progressing**: Deployment is in the middle of a rollout
- **Complete**: All replicas have been updated
- **Failed**: Deployment has failed (e.g., progress deadline exceeded)

## Cleanup

```bash
# Delete deployment
kubectl -n joey delete deployment rolling-update-test

# Delete namespace
kubectl delete namespace joey
```

## Best Practices

1. **Always configure readiness probes** - Ensures pods are only marked ready when they can serve traffic
2. **Use `maxUnavailable: 0` for zero-downtime** - Keeps all pods running during updates
3. **Set appropriate resource requests** - Prevents scheduling failures
4. **Test deployments in staging first** - Catch issues before production
5. **Monitor rollout progress** - Use `kubectl rollout status` to track updates
6. **Set `progressDeadlineSeconds`** - Automatically fail stuck deployments
7. **Use `rollout history`** - Track deployment changes over time
8. **Implement health checks** - Both readiness and liveness probes

