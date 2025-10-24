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
    stage('Build Docker Images') {
      steps {
        script {
          frontendImage = docker.build("${env.DOCKER_HUB_REPO}/${env.FRONTEND_IMAGE_TAG}", "./client")
          backendImage = docker.build("${env.DOCKER_HUB_REPO}/${env.BACKEND_IMAGE_TAG}", "./server")
        }
      }
    }
    stage('Scan with Trivy') {
      steps {
        script {
          sh "trivy image ${frontendImage.id}"
          sh "trivy image ${backendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${frontendImage.id}"
          // sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${backendImage.id}"
        }
      }
    }
    stage('Push Docker Images') {
      steps {
        script {
          docker.withRegistry("https://index.docker.io/v1/", "docker-hub-credentials") {
            frontendImage.push()
            frontendImage.push("latest")
            backendImage.push()
            backendImage.push("latest")
          }
        }
      }
    }
    stage('Deploy to EC2') {
      steps {
        script {
          sh '''
          # Copy deployment files to EC2
          scp -i $SSH_KEY_PATH -o StrictHostKeyChecking=no k8s/deployment.yaml $EC2_USER@$EC2_HOST:/tmp/
          
          # SSH into EC2 and deploy
          ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << 'EOF'
            # Pull the latest images
            docker pull $DOCKER_HUB_REPO/$FRONTEND_IMAGE_TAG
            docker pull $DOCKER_HUB_REPO/$BACKEND_IMAGE_TAG
            
            # Apply Kubernetes deployments
            kubectl apply -f /tmp/deployment.yaml
            
            # Check deployment status
            kubectl get pods
            kubectl get services
          EOF
          '''
        }
      }
    }
  }
}
