#!/bin/bash
# ArgoCD Installation Script for Kubernetes
# Run this on your master node

echo "🚀 Installing ArgoCD..."

# Create namespace
echo "📦 Creating namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "⬇️ Downloading and installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
echo "⏳ Waiting for ArgoCD to be ready (this may take 2-3 minutes)..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Check status
echo ""
echo "✅ ArgoCD installation status:"
kubectl get pods -n argocd

# Get admin password
echo ""
echo "🔑 ArgoCD Admin Password:"
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo "Username: admin"
echo ""
echo "📝 To access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then open: https://localhost:8080"
echo ""
echo "📝 Or expose via LoadBalancer (permanent access):"
echo "   kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"
echo ""

