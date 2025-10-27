# ArgoCD Quick Start Guide

## What You Get with ArgoCD

-   ✅ **Automatic Deployments**: Code pushed to Git → Auto-deployed to K8s
-   ✅ **Visual Dashboard**: See all your apps in one place
-   ✅ **GitOps**: Everything stored in Git, easy to audit and rollback
-   ✅ **No SSH needed**: Jenkins just builds, ArgoCD handles deployment

---

## Installation (5 minutes)

### 1. Install ArgoCD on Your Kubernetes Cluster

```bash
# SSH to your EC2 instance
ssh ec2-user@18.140.51.105

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for it to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=90s
```

### 2. Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### 3. Access ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser: https://localhost:8080
# Username: admin
# Password: (from step 2)
```

### 4. Deploy Your Application

```bash
kubectl apply -f k8s/argocd/recipe-app-argocd.yaml
```

### 5. Verify in ArgoCD UI

-   Open https://localhost:8080
-   You should see "recipe-app" application
-   It will automatically sync from your Git repo!

---

## How It Works

```
┌─────────────┐
│   GitHub    │ ← Your code repository
└──────┬──────┘
       │
       │ (Jenkins watches for changes)
       ↓
┌─────────────┐
│   Jenkins   │ ← Builds Docker images
└──────┬──────┘
       │
       │ (pushes images)
       ↓
┌─────────────┐
│  Docker Hub │ ← Stores your images
└──────┬──────┘
       │
       │ (ArgoCD watches Git repo)
       ↓
┌─────────────┐
│   ArgoCD    │ ← Deploys to Kubernetes
└──────┬──────┘
       │
       │ (applies manifests)
       ↓
┌─────────────┐
│ Kubernetes  │ ← Your running application
└─────────────┘
```

---

## Enable ArgoCD Deployment

Once ArgoCD is installed, update your Jenkinsfile:

### Comment out SSH-based deployment:

```groovy
// stage('Deploy to EC2') { ... }
```

### Uncomment ArgoCD stage:

```groovy
stage('Deploy with ArgoCD') {
  steps {
    sh "echo 'ArgoCD will automatically sync from Git!'"
  }
}
```

**That's it!** ArgoCD handles deployment automatically.

---

## Commands You'll Use

### Check Application Status

```bash
kubectl get applications -n argocd
```

### Manual Sync (if needed)

```bash
argocd app sync recipe-app --server localhost:8080
```

### View App Details

```bash
argocd app get recipe-app
```

---

## Benefits

| Before (SSH)           | After (ArgoCD)          |
| ---------------------- | ----------------------- |
| Manual SSH commands    | Automatic deployment    |
| Manual kubectl apply   | GitOps automation       |
| No UI                  | Beautiful dashboard     |
| Hard to rollback       | One-click rollback      |
| Credentials in scripts | Secure Git-based config |

---

## Next Steps

1. ✅ Install ArgoCD (see above)
2. ✅ Access UI and verify setup
3. ✅ Deploy application manifest
4. ✅ Update Jenkinsfile to use ArgoCD
5. ✅ Push code and watch ArgoCD deploy!

---

## Help

-   Full guide: See `ARGOCD_SETUP.md`
-   Kubernetes configs: `k8s/` directory
-   ArgoCD manifest: `k8s/argocd/recipe-app-argocd.yaml`
