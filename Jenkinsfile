pipeline {
  agent any
  environment {
    DOCKER_HUB_REPO = "sopheaktraleng"
    FRONTEND_IMAGE = "mern-recipe-app-frontend"
    BACKEND_IMAGE = "mern-recipe-app-backend"
    EC2_HOST = "18.140.51.105"
    EC2_USER = "ec2-user"
    SSH_KEY_PATH = "/var/lib/jenkins/.ssh/your-ec2-key.pem"
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: "main", url: "https://github.com/Sopheaktraleng/recipe-app.git"
      }
    }
    stage('Build and Push Docker Images') {
      steps {
        script {
          // Define image names
          def frontendImageName = "${env.DOCKER_HUB_REPO}/mern-recipe-app-frontend"
          def backendImageName = "${env.DOCKER_HUB_REPO}/mern-recipe-app-backend"
          
          // Build images
          def frontendImage = docker.build("${frontendImageName}:${env.BUILD_ID}", "./client")
          def backendImage = docker.build("${backendImageName}:${env.BUILD_ID}", "./server")
          
          // Scan with Trivy
          sh "trivy image ${frontendImage.id}"
          sh "trivy image ${backendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${frontendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${backendImage.id}"
          
          // Get Docker Hub credentials
          withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            // Login to Docker Hub
            sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
            
            // Push frontend with build ID tag
            sh "docker push ${frontendImageName}:${env.BUILD_ID}"
            // Tag and push latest
            sh "docker tag ${frontendImageName}:${env.BUILD_ID} ${frontendImageName}:latest"
            sh "docker push ${frontendImageName}:latest"
            
            // Push backend with build ID tag
            sh "docker push ${backendImageName}:${env.BUILD_ID}"
            // Tag and push latest
            sh "docker tag ${backendImageName}:${env.BUILD_ID} ${backendImageName}:latest"
            sh "docker push ${backendImageName}:latest"
          }
        }
      }
    }
    stage('Deploy to EC2') {
      steps {
        script {
          sh """
          # Copy kustomization files to EC2
          scp -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r k8s ${env.EC2_USER}@${env.EC2_HOST}:/tmp/
          
          # SSH into EC2 and deploy
          ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} << 'EOF'
            cd /tmp/k8s
            
            # Pull the latest images
            docker pull ${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE}:latest
            docker pull ${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE}:latest
            
            # Apply Kubernetes deployments with kustomize
            kubectl apply -k .
            
            # Check deployment status
            kubectl get pods
            kubectl get services
          EOF
          """
        }
      }
    }
  }
}
