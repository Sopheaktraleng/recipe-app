pipeline {
  agent any
  environment {
    DOCKER_HUB_REPO = "sopheaktraleng"
    FRONTEND_IMAGE = "recipe-app-frontend"
    BACKEND_IMAGE  = "recipe-app-backend"
    EC2_HOST       = "54.254.75.157"
    EC2_USER       = "ec2-user"
    SSH_KEY_PATH   = "/var/lib/jenkins/.ssh/id_rsa"
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: "main", url: "https://github.com/Sopheaktraleng/recipe-app.git"
      }
    }

    stage('Build Docker Images') {
      steps {
        script {
          def frontendImageName = "${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE}"
          def backendImageName  = "${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE}"

          def frontendImage = docker.build("${frontendImageName}:${env.BUILD_ID}", "./client")
          def backendImage  = docker.build("${backendImageName}:${env.BUILD_ID}", "./server")
        }
      }
    }

    stage('Security Scan with Trivy') {
      steps {
        script {
          def frontendImageName = "${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE}"
          def backendImageName  = "${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE}"
          
          sh "trivy image ${frontendImageName}:${env.BUILD_ID}"
          sh "trivy image ${backendImageName}:${env.BUILD_ID}"
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          def frontendImageName = "${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE}"
          def backendImageName  = "${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE}"

          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh "echo '$DOCKER_PASS' | docker login -u '$DOCKER_USER' --password-stdin"

            sh "docker push ${frontendImageName}:${env.BUILD_ID}"
            sh "docker push ${backendImageName}:${env.BUILD_ID}"

            sh """
              docker tag ${frontendImageName}:${env.BUILD_ID} ${frontendImageName}:latest
              docker tag ${backendImageName}:${env.BUILD_ID}  ${backendImageName}:latest
              docker push ${frontendImageName}:latest
              docker push ${backendImageName}:latest
            """
          }
        }
      }
    }

    // Option 1: Traditional SSH-based deployment (currently active)
    stage('Deploy to Kubernetes') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
              set -euxo pipefail

              # Ship manifests
              scp -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r k8s ${env.EC2_USER}@${env.EC2_HOST}:/tmp/

              # Run everything on the remote host
              ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} 'bash -seu <<EOF
                set -euxo pipefail

                NS=\${K8S_NAMESPACE:-default}   # optionally export K8S_NAMESPACE in Jenkins

                cd /tmp/k8s

                # Verify kubectl & context
                kubectl version --client
                kubectl cluster-info
                kubectl get ns \${NS} >/dev/null 2>&1 || kubectl create ns \${NS}

                # Create/Update image pull secret in the right namespace
                kubectl create secret docker-registry docker-hub-secret \\
                  --namespace=\${NS} \\
                  --docker-server=https://index.docker.io/v1/ \\
                  --docker-username="${DOCKER_USER}" \\
                  --docker-password="${DOCKER_PASS}" \\
                  --dry-run=client -o yaml | kubectl apply -f -

                # If using Kustomize, ensure it targets the namespace; otherwise apply -f
                if [ -f kustomization.yaml ]; then
                  # Force namespace at apply time if kustomization lacks it
                  kubectl apply -k . -n \${NS}
                else
                  kubectl apply -f . -n \${NS}
                fi

                # Basic post-deploy checks
                kubectl get pods -n \${NS}
                kubectl get svc -n \${NS}

                # If something is pending, dump recent events for quick triage
                kubectl get events -n \${NS} --sort-by=.lastTimestamp | tail -n 50 || true
              EOF'
            """
          }
        }
      }
   }


    // Option 2: ArgoCD deployment (enable after setting up ArgoCD)
    // See: ARGOCD_SETUP.md for installation instructions
    // 
    // stage('Deploy with ArgoCD') {
    //   steps {
    //     sh "echo 'ArgoCD will automatically sync from Git!'"
    //     // ArgoCD watches the Git repo and auto-deploys
    //     // No manual steps needed - it's automatic!
    //   }
    // }
  }
}
