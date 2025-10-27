# Deploy ArgoCD to Your Kubernetes Cluster

## Step 1: SSH into Master Node

```bash
# Replace with your master node IP
ssh ec2-user@YOUR_MASTER_IP

# Or if you're using a specific user
ssh your-user@18.140.51.105
```

## Step 2: Install ArgoCD

Copy and run this script on your master node:

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for it to be ready (2-3 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Check status
kubectl get pods -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Step 3: Access ArgoCD UI

### Option A: Port Forward (Quick Access)

```bash
# Run this in a separate terminal
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open: https://localhost:8080
- Username: `admin`
- Password: (from step 2)

### Option B: LoadBalancer (Permanent Access)

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer}}'

# Get the external IP
kubectl get svc argocd-server -n argocd
```

Then open: https://EXTERNAL_IP

## Step 4: Deploy Your Application

Once ArgoCD is running, deploy your application:

```bash
# From your local machine or master node
kubectl apply -f k8s/argocd/recipe-app-argocd.yaml

# Verify the application
kubectl get applications -n argocd
```

## Step 5: Switch Jenkins to Use ArgoCD (Optional)

Edit `Jenkinsfile` and make these changes:

### Comment out SSH-based deployment (lines 65-86):

```groovy
// stage('Deploy to EC2') {
//   steps {
//     script {
//       sh """
//         scp -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r k8s ${env.EC2_USER}@${env.EC2_HOST}:/tmp/
//         ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} << 'EOF'
//           cd /tmp/k8s
//           kubectl apply -k .
//         EOF
//       """
//     }
//   }
// }
```

### Uncomment ArgoCD stage (lines 88-97):

```groovy
stage('Deploy with ArgoCD') {
  steps {
    sh "echo 'ArgoCD will automatically sync from Git!'"
    // ArgoCD watches the Git repo and auto-deploys
    // No manual steps needed - it's automatic!
  }
}
```

Then commit and push:

```bash
git add Jenkinsfile
git commit -m "feat: switch deployment to ArgoCD"
git push origin main
```

## How ArgoCD Works Now

1. ✅ **Jenkins** builds and pushes images to Docker Hub
2. ✅ **ArgoCD** watches your Git repository
3. ✅ **Auto-deploy**: When new code is pushed, ArgoCD automatically deploys
4. ✅ **Visual dashboard**: See deployment status in ArgoCD UI

## Verify Everything Works

1. Open ArgoCD UI
2. You should see "recipe-app" application
3. Click on it to see deployment status
4. All resources should be "Synced"

## Troubleshooting

### Issue: ArgoCD not accessible

```bash
# Check pods are running
kubectl get pods -n argocd

# Check logs if needed
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Issue: Application not showing

```bash
# Check application exists
kubectl get applications -n argocd

# Manually sync if needed
argocd app sync recipe-app
```

### Issue: Image pull errors

Ensure your K8s cluster has credentials to pull from Docker Hub:
```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=sopheaktraleng \
  --docker-password=YOUR_DOCKER_HUB_TOKEN
```

Then update your deployment files to use this secret (imagePullSecrets).

## What You Get

- ✅ **Automatic deployments** from Git
- ✅ **Beautiful UI** to monitor apps
- ✅ **GitOps workflow** - everything in Git
- ✅ **Easy rollback** with one click
- ✅ **No SSH required** for deployment

Enjoy GitOps! 🎉

