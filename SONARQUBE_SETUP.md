# SonarQube Setup Guide

## Quick Start for Docker

Since you already have SonarQube running via Docker, follow these steps:

### 1. Verify SonarQube is Running

```bash
# Check if SonarQube container is running
docker ps | grep sonarqube

# Or list all containers
docker ps -a
```

If not running, start it:

```bash
docker start sonarqube
```

Or if you need to create a new one:

```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  sonarqube:latest
```

### 2. Access SonarQube

1. Open browser: `http://localhost:9000` (or `http://YOUR_SERVER_IP:9000`)
2. Wait for SonarQube to fully start (can take 1-2 minutes)
3. Login with:
    - Username: `admin`
    - Password: `admin`
4. Change password when prompted

### 3. Generate Authentication Token

1. Click on user icon (top right) → **My Account**
2. Go to **Security** tab
3. Scroll down to **Generate Tokens** section
4. Enter token name: `jenkins-recipe-app`
5. Click **Generate**
6. **IMPORTANT:** Copy the token immediately (you won't see it again!)

### 4. Configure Jenkins

#### Step 1: Install SonarQube Plugin

1. Jenkins → **Manage Jenkins** → **Manage Plugins**
2. Go to **Available** tab
3. Search for: **SonarQube Scanner**
4. Check the box and click **Install without restart**

#### Step 2: Add SonarQube Server in Jenkins

1. Jenkins → **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers** section
3. Click **Add SonarQube**
4. Fill in:

    - **Name**: `SonarQube Server`
    - **Server URL**: `http://localhost:9000` (or your server URL)
    - **Server authentication token**: Click **Add** → Select **Secret text**
        - Secret: [Paste your SonarQube token]
        - ID: `sonarqube-token`
        - Description: `SonarQube auth token`
        - Click **Add**

5. Select the credential from dropdown
6. Click **Apply** and **Save**

#### Step 3: Install SonarQube Scanner (CLI)

SSH into your Jenkins server and install:

```bash
# Download SonarQube Scanner
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip

# Unzip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip

# Move to /opt
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner

# Add to PATH
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile
source /etc/profile

# Verify installation
sonar-scanner -v
```

### 5. Test the Setup

1. Go to your Jenkins pipeline
2. Click **Build Now**
3. Watch the build logs for the SonarQube stages

### 6. View Results

After successful build:

1. Go to SonarQube: `http://localhost:9000`
2. Click **Projects** in the top menu
3. Find **recipe-app** project
4. Click to view detailed analysis

## Troubleshooting

### Problem: "sonar-scanner: command not found"

**Solution:**

```bash
# Install sonar-scanner as shown in step 3 above
# Or add to PATH for jenkins user specifically:
sudo su - jenkins
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' >> ~/.bashrc
source ~/.bashrc
```

### Problem: "Could not connect to SonarQube server"

**Solution:**

1. Check SonarQube is running: `docker ps | grep sonarqube`
2. Test connection: `curl http://localhost:9000`
3. Verify URL in Jenkins configuration matches
4. If Jenkins is on different server, use IP instead of localhost

### Problem: "Authentication failed"

**Solution:**

1. Regenerate token in SonarQube
2. Update credential in Jenkins
3. Make sure credential ID is `sonarqube-token`

### Problem: "Quality Gate failed"

**Solution:**

-   Option 1: Fix the code issues in SonarQube dashboard
-   Option 2: Temporarily disable quality gate in Jenkinsfile:
    ```groovy
    waitForQualityGate abortPipeline: false
    ```

## Pipeline Stages

Your pipeline now includes:

1. ✅ **Checkout** - Get code from GitHub
2. ✅ **Code Quality Analysis** - SonarQube scans your code
3. ✅ **Quality Gate Check** - Ensures code meets quality standards
4. ✅ **Build and Push Docker Images** - Build and push to Docker Hub
5. ✅ **Deploy to EC2** - Deploy to Kubernetes

## SonarQube Dashboard Features

Once scans complete, you can see:

-   **Code Smells** - Code that should be refactored
-   **Bugs** - Actual bugs in code
-   **Vulnerabilities** - Security issues
-   **Coverage** - Test coverage percentage
-   **Duplications** - Duplicate code blocks
-   **Technical Debt** - Estimated time to fix all issues

## Next Steps

1. Configure Quality Gates to match your requirements
2. Set up branch analysis for pull requests
3. Add more analysis parameters in `sonar-project.properties`
4. Configure email notifications for quality issues
