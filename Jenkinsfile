pipeline {
  agent any
  environment {
    DOCKER_HUB_REPO = "sopheaktraleng"
    FRONTEND_IMAGE = "recipe-app-frontend"
    BACKEND_IMAGE  = "recipe-app-backend"
    EC2_HOST       = "18.140.51.105"
    EC2_USER       = "ec2-user"
    SSH_KEY_PATH   = "/var/lib/jenkins/.ssh/your-ec2-key.pem"
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
              scp -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r k8s ${env.EC2_USER}@${env.EC2_HOST}:/tmp/

              ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} \\
                "export DOCKER_USER='$DOCKER_USER' && export DOCKER_PASS='$DOCKER_PASS' && \\
                cd /tmp/k8s && \\
                kubectl create secret docker-registry docker-hub-secret --docker-server=https://index.docker.io/v1/ --docker-username=\\\$DOCKER_USER --docker-password=\\\$DOCKER_PASS --dry-run=client -o yaml | kubectl apply -f - && \\
                kubectl apply -k . && \\
                kubectl get pods && \\
                kubectl get services"
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
