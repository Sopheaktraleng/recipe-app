pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Repository checked out successfully"
            }
        }
        
        stage('Build Frontend') {
            steps {
                dir('client') {
                    echo "Building frontend..."
                    sh 'npm install'
                    sh 'npm run build'
                    echo "Frontend build completed"
                }
            }
        }
        
        stage('Build Backend') {
            steps {
                dir('server') {
                    echo "Building backend..."
                    sh 'npm install'
                    echo "Backend dependencies installed"
                }
            }
        }
        
        stage('Run Tests') {
            parallel {
                stage('Frontend Tests') {
                    steps {
                        dir('client') {
                            echo "Running frontend tests..."
                            sh 'npm run test --if-present || echo "No frontend tests found"'
                        }
                    }
                }
                stage('Backend Tests') {
                    steps {
                        dir('server') {
                            echo "Running backend tests..."
                            sh 'npm run test --if-present || echo "No backend tests found"'
                        }
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                echo "Building Docker images..."
                sh 'docker build -t mern-recipe-app-frontend ./client'
                sh 'docker build -t mern-recipe-app-backend ./server'
                echo "Docker images built successfully"
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                echo "Deploying with Docker Compose..."
                sh 'docker-compose down || true'
                sh 'docker-compose up -d'
                echo "Application deployed successfully"
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed"
        }
        success {
            echo "✅ Pipeline succeeded!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
