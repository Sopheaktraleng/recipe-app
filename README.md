# Recipe App Deployment Guide

## Overview

The Recipe App provides a complete platform for users to create, manage, and share their favorite recipes. It includes intuitive features for adding, storing, and deleting recipes. Users can include rich details such as ingredients, preparation steps, and images, making it easy to organize and revisit their culinary creations anytime. This repository contains all necessary configurations and scripts to deploy the API to an AWS K8s cluster using Jenkins and Kubernetes.

## Repository Structure

```bash
└── 📁recipe-app
    ├── 📁client              # React frontend (Vite + Tailwind)
    │   ├── Dockerfile
    │   ├── package.json
    │   └── 📁src
    ├── 📁server              # Node.js/Express API
    │   ├── Dockerfile
    │   ├── package.json
    │   └── 📁controllers
    ├── 📁k8s                 # Kubernetes manifests and kustomize overlays
    │   ├── api/
    │   ├── frontend/
    │   ├── db/
    │   └── argocd/
    ├── Jenkinsfile           # CI/CD pipeline definition
    ├── docker-compose.yml    # Local development stack
    ├── sonar-project.properties
    ├── install-sonar-scanner.sh
    ├── ARGOCD_SETUP.md
    ├── ARGOCD_QUICK_START.md
    ├── DEPLOY_K8S.md
    ├── DEPLOY_ARGOCD.md
    ├── K8S_RUN_COMMANDS.md
    └── README.md
```

### Kubernetes Manifests Breakdown

-   `k8s/kustomization.yaml` stitches together the base application, database, and frontend overlays for cluster-wide deployment.
-   `k8s/docker-registry-secret.yaml` holds the manifest to create the image pull secret referenced by the workloads.
-   `k8s/api/backend-deployment.yaml` defines the API Deployment (replicas, containers, env vars, probes).
-   `k8s/api/backend-service.yaml` exposes the API via a ClusterIP service.
-   `k8s/api/backend-config.yaml` carries non-sensitive configuration such as API base URLs and feature flags.
-   `k8s/api/backend-secret.yaml` stores sensitive API settings (JWT secrets, database connection strings).
-   `k8s/api/kustomization.yaml` bundles the API deployment, service, config, and secrets for reuse.
-   `k8s/frontend/frontend-deployment.yaml` describes the static frontend Deployment and container image settings.
-   `k8s/frontend/frontend-service.yaml` publishes the frontend through a LoadBalancer.
-   `k8s/frontend/nginx-configmap.yaml` configures the NGINX reverse proxy for the frontend container.
-   `k8s/frontend/kustomization.yaml` composes the frontend resources into a deployable unit.
-   `k8s/db/mongodb-deployment.yaml` provisions MongoDB with persistent storage claims and resource limits.
-   `k8s/db/mongodb-service.yaml` exposes MongoDB internally for the API to consume.
-   `k8s/db/mongodb-configmap.yaml` keeps MongoDB configuration such as initialization scripts or small settings.
-   `k8s/db/mongodb-secret.yaml` provides MongoDB credentials and connection details.
-   `k8s/db/kustomization.yaml` packages the database manifests into a single overlay.
-   `k8s/argocd/recipe-app-argocd.yaml` defines the Argo CD Application resource pointing to this repository for GitOps automation.

## Prerequisites

Before deploying the recipe-app, ensure you have the following:

-   AWS account with permissions to manage EC2 instances, networking, and security groups
-   Manually provisioned EC2 hosts running your Kubernetes control plane and worker nodes (or a self-managed cluster you can reach)
-   Jenkins server configured with the credentials/secrets referenced in the pipeline
-   Docker installed on the Jenkins agent along with authenticated access to Docker Hub for image pushes
-   kubectl configured on the Jenkins agent (or deployment runner) with access to your cluster kubeconfig

## Deployment Process

### 1. GitHub Webhook for Automatic Deployment

This project is configured to automatically deploy whenever a new commit is pushed to the repository.

Webhook Configuration:

1. In your GitHub repository, go to Settings > Webhooks.
2. Click Add webhook.
3. Set the Payload URL to `http://<JENKINS-IP>:8080/github-webhook/`.
4. Choose application/json as the Content type.
5. Select Just the push event.
6. Click Add webhook.

Jenkins Configuration:

1. In Jenkins, install the GitHub Plugin if not already installed.
2. Go to your Jenkins job, then Configure.
3. Under Build Triggers, enable Poll SCM and GitHub hook trigger for GITScm polling.
4. Save the configuration.

With this setup, Jenkins will automatically trigger a build whenever changes are pushed to the GitHub repository.

### 2. Build and Push Docker Image

Jenkins automates the process of building and pushing the API image to Docker Hub.

-   The Jenkinsfile defines the pipeline steps:
    1. Checkout the latest code
    2. Generate a unique image tag
    3. Authenticate with Docker Hub using stored credentials
    4. Build and push the Docker image

### 3. Deploy to Kubernetes (Self-Managed)

-   The pipeline updates the Kubernetes deployment on your EC2-backed cluster with the new image:

    1. Configure kubectl using the kubeconfig for your self-managed control plane
    2. Apply Kubernetes secrets (image pull secret, API secrets, database creds)
    3. Deploy the updated manifests to the cluster
    4. Trigger a rollout restart or image update on the running workloads

## Accessing the Application

The API is exposed using a Kubernetes LoadBalancer service. Once deployed, retrie

```bash
kubectl get services api-service
```

You can access the API via the LoadBalancer's external IP:

```bash
curl http://<EXTERNAL-IP>/health
```

## Post-Deployment Verification

After deployment, verify the application is running:

-   Check running pods:

```bash
kubectl get pods
```

-   Check logs:

```bash
kubectl logs -l app=api
```
