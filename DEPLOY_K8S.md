# Direct Kubernetes Deployment Guide

## What's Configured

✅ **Deployment files updated** with Docker Hub images
✅ **Docker registry secret** will be created automatically
✅ **Jenkins pipeline** ready to deploy directly to K8s
✅ **Image pull secrets** configured for both frontend and backend

---

## Current Pipeline Stages

1. **Checkout** - Get code from GitHub
2. **Build Docker Images** - Build frontend & backend
3. **Security Scan with Trivy** - Scan for vulnerabilities
4. **Push to Docker Hub** - Push images with tags
5. **Deploy to Kubernetes** - Deploy to your K8s cluster ✨

---

## Prerequisites

- ✅ K8s cluster (1 master, 1 worker) - **You have this!**
- ✅ Jenkins with Docker Hub credentials
- ✅ SSH access to master node
- ✅ kubectl installed on master node

---

## What the Pipeline Does

### During Deployment:

1. **Builds images** with tag: `sopheaktraleng/recipe-app-frontend:BUILD_ID`
2. **Scans** with Trivy
3. **Pushes** to Docker Hub (both BUILD_ID and latest tags)
4. **Copies k8s manifests** to your master node
5. **Creates Docker registry secret** (for pulling from Docker Hub)
6. **Applies manifests** using kubectl (kustomize)
7. **Shows status** of pods and services

---

## Test the Deployment

### Step 1: Run Jenkins Pipeline

Your Jenkins pipeline will now:
- Build images
- Push to Docker Hub
- Deploy to K8s automatically!

### Step 2: Verify Deployment

SSH into your master node and check:

```bash
# Check all pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# If pods are not running, check events
kubectl get events --sort-by='.lastTimestamp'
```

### Step 3: Access Your Application

Check the services to get the access URL:

```bash
kubectl get svc

# If using LoadBalancer or NodePort, you'll see external IPs
```

---

## Troubleshooting

### Issue: ImagePullBackOff

**Cause**: K8s can't pull images from Docker Hub

**Solution**:
```bash
# Check if secret exists
kubectl get secret docker-hub-secret

# If missing, create it manually:
kubectl create secret docker-registry docker-hub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=sopheaktraleng \
  --docker-password=YOUR_DOCKER_HUB_TOKEN
```

### Issue: Pods in Pending state

**Check resource availability**:
```bash
kubectl describe pod <pod-name>
kubectl get nodes
```

### Issue: Connection refused

**Check if backend/frontend services are running**:
```bash
kubectl get pods -l app=frontend
kubectl get pods -l app=backend
```

---

## Manual Deployment (if needed)

If you want to deploy manually without Jenkins:

```bash
# SSH to master node
ssh ec2-user@YOUR_MASTER_IP

# Clone repo
git clone https://github.com/Sopheaktraleng/recipe-app.git
cd recipe-app/k8s

# Create Docker registry secret
kubectl create secret docker-registry docker-hub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=sopheaktraleng \
  --docker-password=YOUR_DOCKER_HUB_TOKEN

# Deploy
kubectl apply -k .

# Check status
kubectl get pods
kubectl get services
```

---

## Files Updated

- `k8s/api/backend-deployment.yaml` - Uses Docker Hub image
- `k8s/frontend/frontend-deployment.yaml` - Uses Docker Hub image
- `k8s/docker-registry-secret.yaml` - Docker registry secret template
- `Jenkinsfile` - Auto-creates secret and deploys

---

## Next Steps

1. ✅ **Run Jenkins pipeline** - It will deploy automatically!
2. ✅ **Check pods status** - `kubectl get pods`
3. ✅ **Access application** - Get service URL
4. ✅ **(Later) Switch to ArgoCD** - When ready for GitOps

Your pipeline is ready to deploy directly to Kubernetes! 🚀

