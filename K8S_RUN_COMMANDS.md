# Kubernetes Deployment Commands for Recipe App

## Prerequisites Setup

### 1. Start Minikube
```bash
minikube start
```

### 2. Enable Ingress Addon
```bash
minikube addons enable ingress
```

## Build and Load Docker Images

### 3. Build Backend Image
```bash
cd server
docker build -t recipe-app-backend:latest .
cd ..
```

### 4. Load Backend Image to Minikube
```bash
minikube image load recipe-app-backend:latest
```

### 5. Build Frontend Image
```bash
cd client
docker build -t recipe-app-frontend:latest .
cd ..
```

### 6. Load Frontend Image to Minikube
```bash
minikube image load recipe-app-frontend:latest
```

## Deploy to Kubernetes

### 7. Deploy All Resources
```bash
kubectl apply -k k8s/
```

### 8. Check Deployment Status
```bash
# Check all pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments
```

### 9. Get Access URLs

**Frontend (NodePort - Port 30000):**
```bash
minikube service frontend-service --url
```

**Or access directly:**
```bash
minikube service frontend-service
```

**Backend (Internal Service):**
```bash
kubectl get service backend-service
```

## Troubleshooting Commands

### Check Pod Logs
```bash
# MongoDB logs
kubectl logs -l app=mongodb

# Backend logs
kubectl logs -l app=backend

# Frontend logs
kubectl logs -l app=frontend
```

### Check Pod Details
```bash
# Describe a specific pod
kubectl describe pod <pod-name>

# Get all events
kubectl get events --sort-by='.lastTimestamp'
```

### Restart Pods
```bash
# Restart backend pods
kubectl rollout restart deployment backend

# Restart frontend pods
kubectl rollout restart deployment frontend
```

### Delete and Redeploy
```bash
# Delete all resources
kubectl delete -k k8s/

# Redeploy
kubectl apply -k k8s/
```

### Port Forward for Direct Access
```bash
# Port forward to frontend (access at http://localhost:8080)
kubectl port-forward service/frontend-service 8080:80

# Port forward to backend (access at http://localhost:5000)
kubectl port-forward service/backend-service 5000:5000
```

## Clean Up

### Stop Minikube
```bash
minikube stop
```

### Delete Minikube Cluster
```bash
minikube delete
```

### Delete All Resources
```bash
kubectl delete -k k8s/
```

---

## Quick Start (All Commands Together)

```bash
# 1. Start and setup minikube
minikube start
minikube addons enable ingress

# 2. Build and load images
cd server && docker build -t recipe-app-backend:latest . && cd ..
cd client && docker build -t recipe-app-frontend:latest .--no-cache && cd ..
minikube image load recipe-app-backend:latest
minikube image load recipe-app-frontend:latest

# 3. Deploy to Kubernetes
kubectl apply -k k8s/

# 4. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s

# 5. Open frontend in browser
minikube service frontend-service
```

## Access Your Application

After deployment, you can access your application using:

- **Frontend**: Run `minikube service frontend-service` to get the URL
- **Backend API**: Accessible internally at `backend-service:5000`
- **MongoDB**: Accessible internally at `mongodb-service:27017`

## Environment Variables

The backend connects to MongoDB using these credentials (defined in k8s files):
- Username: `admin`
- Password: `password123`
- Database: `recipe-app`

