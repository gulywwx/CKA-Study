# Docker Image Build Guide

This guide explains how to build and push three versions of the sample application for demonstrating Kubernetes rolling update failures.


## Version Overview

| Version | Status | Description |
|---------|--------|-------------|
| v1.0 | ✅ Working | Healthy application with working health checks |
| v2.0.1 | ❌ Broken | Crashes on startup |
| v2.0.2 | ❌ Broken | Health Check Fails |



## Build All Versions at Once

```bash
docker login
# Enter your Docker Hub username and password

# Build v1.0
docker buildx build --platform linux/amd64 -t gulywwx/myapp:v1.0 --push -f Dockerfile.v1.0 .

# Build v2.0.1
docker buildx build --platform linux/amd64 -t gulywwx/myapp:v2.0.1 --push -f Dockerfile.v2.0.1 .

# Build v2.0.2
docker buildx build --platform linux/amd64 -t gulywwx/myapp:v2.0.2 --push -f Dockerfile.v2.0.2 .
```


### Clean Up Local Images

```bash
docker rmi gulywwx/myapp:v1.0
docker rmi gulywwx/myapp:v2.0.1
docker rmi gulywwx/myapp:v2.0.2
```


## What's Next?

After building these images, use them in your Kubernetes deployment to demonstrate rolling update failures. See the parent directory for deployment examples.
