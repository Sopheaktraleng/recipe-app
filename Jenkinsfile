pipeline {
  agent any
  environment {
    DOCKER_HUB_REPO = "sopheaktraleng"
    FRONTEND_IMAGE_TAG = "mern-recipe-app-frontend:${env.BUILD_ID}"
    BACKEND_IMAGE_TAG = "mern-recipe-app-backend:${env.BUILD_ID}"
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
          // Build images
          def frontendImage = docker.build("${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE_TAG}", "./client")
          def backendImage = docker.build("${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE_TAG}", "./server")
          
          // Scan with Trivy
          sh "trivy image ${frontendImage.id}"
          sh "trivy image ${backendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${frontendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${backendImage.id}"
          
          // Login and push to Docker Hub
          docker.withRegistry("https://index.docker.io/v1/", "docker-hub-credentials") {
            // Push frontend with build number and latest tags
            frontendImage.push()
            frontendImage.push("latest")
            
            // Push backend with build number and latest tags
            backendImage.push()
            backendImage.push("latest")
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
            docker pull ${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE_TAG}
            docker pull ${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE_TAG}
            
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
