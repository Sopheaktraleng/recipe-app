# ArgoCD Setup Guide

## What is ArgoCD?

ArgoCD is a GitOps continuous delivery tool that automatically syncs Kubernetes applications with configurations defined in Git. It:

-   Automatically deploys when code changes
-   Keeps your cluster state in sync with Git
-   Provides a web UI to monitor applications
-   Can be triggered manually or automatically from Jenkins

## Installation Steps

### Step 1: Install ArgoCD on Your Kubernetes Cluster

SSH into your EC2 instance and run:

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready (takes 2-3 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=90s

# Check status
kubectl get pods -n argocd
```

### Step 2: Get ArgoCD Admin Password

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### Step 3: Access ArgoCD Web UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Or expose via LoadBalancer (for permanent access)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Then access: `https://localhost:8080`

-   Username: `admin`
-   Password: (from step 2)

### Step 4: Deploy ArgoCD Application

Create the ArgoCD application in your cluster:

```bash
kubectl apply -f k8s/argocd/recipe-app-argocd.yaml
```

### Step 5: Verify Application

Check ArgoCD UI or command line:

```bash
# Check application status
kubectl get applications -n argocd

# Or use ArgoCD CLI
argocd app get recipe-app
```

---

## Integration with Jenkins

### Option 1: Automatic Sync (Recommended)

ArgoCD will automatically sync when:

-   Code is pushed to `main` branch
-   Git configuration changes
-   Manual sync from ArgoCD UI

No Jenkins changes needed! ArgoCD watches the repo automatically.

### Option 2: Manual Sync from Jenkins

Update your Jenkinsfile to add ArgoCD sync stage:

```groovy
stage('Deploy with ArgoCD') {
  steps {
    sh """
      # Sync ArgoCD application
      argocd app sync recipe-app --server localhost:8080 --auth-token YOUR_TOKEN

      # Wait for deployment to complete
      argocd app wait recipe-app --server localhost:8080 --auth-token YOUR_TOKEN
    """
  }
}
```

---

## Update Jenkinsfile to Use ArgoCD

Replace the current Deploy stage with ArgoCD sync:

### Before (SSH + kubectl):

```groovy
stage('Deploy to EC2') {
  steps {
    script {
      sh """
        scp -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r k8s ${env.EC2_USER}@${env.EC2_HOST}:/tmp/
        ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} << 'EOF'
          cd /tmp/k8s
          docker pull ${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE}:latest
          docker pull ${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE}:latest
          kubectl apply -k .
        EOF
      """
    }
  }
}
```

### After (ArgoCD - simpler!):

```groovy
stage('Deploy with ArgoCD') {
  steps {
    sh "echo 'ArgoCD will automatically sync from Git!'"
    // Or manually trigger sync using argocd CLI
  }
}
```

---

## Benefits of ArgoCD

✅ **GitOps**: Infrastructure as code in Git
✅ **Automation**: Auto-sync when code changes
✅ **Consistency**: Environment matches Git state
✅ **Rollback**: Easy to rollback to previous versions
✅ **UI**: Visual dashboard to monitor deployments
✅ **Multi-cluster**: Can manage multiple clusters
✅ **RBAC**: Fine-grained access control

---

## Common Commands

### Check Application Status

```bash
argocd app get recipe-app
```

### Manual Sync

```bash
argocd app sync recipe-app
```

### View Application Logs

```bash
argocd app logs recipe-app
```

### Rollback to Previous Version

```bash
argocd app rollback recipe-app
```

### Refresh Application

```bash
argocd app refresh recipe-app
```

---

## Architecture with ArgoCD

```
GitHub Repo
    ↓
  Git Push
    ↓
Jenkins Pipeline
    ↓ (builds & pushes)
  Docker Hub
    ↓
ArgoCD watches Git
    ↓ (auto-syncs)
Kubernetes Cluster
```

**With ArgoCD:**

-   Jenkins builds images and pushes to Docker Hub
-   Jenkins commits image tags to Git (optional)
-   ArgoCD watches Git and auto-deploys to Kubernetes
-   No SSH needed!
-   No manual kubectl commands!

---

## Troubleshooting

### Issue: ArgoCD not syncing

1. Check application status:

    ```bash
    kubectl get applications -n argocd
    ```

2. Check ArgoCD logs:

    ```bash
    kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
    ```

3. Manually refresh:
    ```bash
    argocd app refresh recipe-app
    ```

### Issue: Permission denied

Add RBAC configuration to allow ArgoCD to access your namespace.

### Issue: Image pull errors

Ensure ArgoCD can access your Docker Hub registry (configure image pull secrets).

---

## Next Steps

1. Install ArgoCD on your Kubernetes cluster
2. Deploy the ArgoCD application manifest
3. Remove SSH-based deployment from Jenkins
4. Enjoy automated deployments! 🎉
