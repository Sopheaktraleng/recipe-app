# Jenkins Pipeline Diagnostic Check

## What's Not Working?

Please share:

1. Which stage is failing? (SonarQube, Docker Hub push, etc.)
2. What's the exact error message from Jenkins logs?

---

## Quick Diagnostic Steps

### 1. Check SonarQube Stage

**Error**: "withSonarQubeEnv: SonarQube 'SonarQube Server' not found"

**Solution**:

-   Go to Jenkins → Manage Jenkins → Configure System
-   Add SonarQube server with name exactly: `SonarQube Server`
-   Configure URL: `http://localhost:9000`

**Error**: "sonar-scanner: command not found"

**Solution**:

```bash
# SSH into Jenkins server
which sonar-scanner

# If not found, install:
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
```

---

### 2. Check Docker Hub Credentials

**Error**: "credentials not found"

**In Jenkins**:

1. Manage Jenkins → Credentials
2. Find credential with ID: `dockerhub`
3. Verify it's type: **Username with password**
4. Verify username and token are correct

**To test Docker Hub credentials manually**:

```bash
# SSH into Jenkins server
docker login -u sopheaktraleng
# Enter your Docker Hub Personal Access Token when prompted
```

---

### 3. Common Issues by Error Message

#### "Repository does not exist"

-   Create repositories on Docker Hub:
    -   `sopheaktraleng/recipe-app-frontend`
    -   `sopheaktraleng/recipe-app-backend`

#### "Authentication required"

-   Docker Hub Personal Access Token might be wrong
-   Regenerate token and update in Jenkins

#### "denied: requested access to the resource is denied"

-   Check you have push permissions to the repositories
-   Verify username in Jenkins credentials matches Docker Hub username

#### "Quality Gate failed"

-   Temporary fix: Change line 32 in Jenkinsfile from:
    ```groovy
    waitForQualityGate abortPipeline: true
    ```
    to:
    ```groovy
    waitForQualityGate abortPipeline: false
    ```

---

## Easy Fix: Temporarily Skip SonarQube

If SonarQube is causing issues and you want to push Docker images first:

1. Comment out SonarQube stages in Jenkinsfile:

```groovy
stages {
  stage('Checkout') {
    steps {
      git branch: "main", url: "https://github.com/Sopheaktraleng/recipe-app.git"
    }
  }

  // Temporarily disabled
  // stage('Code Quality Analysis') {
  //   steps {
  //     script {
  //       withSonarQubeEnv('SonarQube Server') {
  //         sh "sonar-scanner"
  //       }
  //     }
  //   }
  // }

  // stage('Quality Gate Check') {
  //   steps {
  //     script {
  //       timeout(time: 5, unit: 'MINUTES') {
  //         waitForQualityGate abortPipeline: true
  //       }
  //     }
  //   }
  // }

  stage('Build and Push Docker Images') {
    // ... rest of the pipeline
```

---

## Test Commands

### Test SonarQube Connection

```bash
# From Jenkins server
curl http://localhost:9000
```

### Test Docker Login

```bash
# From Jenkins server
docker login -u sopheaktraleng
```

### Test sonar-scanner

```bash
# From Jenkins server
sonar-scanner -v
```

---

## Share This Information

When reporting the issue, please include:

1. Full error message from Jenkins console output
2. Which stage failed
3. Your Jenkins version
4. Whether SonarQube is accessible from Jenkins server
