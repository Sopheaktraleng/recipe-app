# Jenkins Setup Guide for Recipe App Pipeline

## 1. Create New Jenkins Job

1. Go to Jenkins Dashboard
2. Click "New Item"
3. Enter job name: `recipe-app-pipeline` (or any name you prefer)
4. Select "Pipeline"
5. Click "OK"

## 2. Configure the Pipeline

### Pipeline Configuration Tab

-   In "Definition" section, select "Pipeline script from SCM"
-   SCM: Select "Git"
-   Repositories:
    -   Repository URL: `https://github.com/Sopheaktraleng/recipe-app.git`
    -   Credentials: Leave empty if using public repo
    -   Branch: `*/main`
-   Script Path: `Jenkinsfile`
-   Click "Save"

## 3. Create Docker Hub Repositories

**IMPORTANT: Create these repositories on Docker Hub BEFORE running the pipeline:**

1. Go to https://hub.docker.com/repositories
2. Click **"Create Repository"**
3. Create two repositories:
    - Name: `recipe-app-frontend` (Public or Private)
    - Name: `recipe-app-backend` (Public or Private)
4. Click **"Create"** for each

## 4. Configure SonarQube

Since you already have SonarQube running via Docker, let's configure it for Jenkins.

### Start SonarQube (if not already running):

```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e sonar.jdbc.url=jdbc:postgresql://postgres/sonar \
  sonarqube:latest
```

Or if you're using docker-compose:

```bash
docker-compose up -d sonarqube
```

### Access SonarQube:

1. Open browser and go to: `http://localhost:9000` (or your server IP)
2. Default credentials:
    - Username: `admin`
    - Password: `admin` (you'll be prompted to change it)

### Generate SonarQube Token:

1. Once logged in, click on your user icon (top right) → **"My Account"**
2. Go to **"Security"** tab
3. In **"Generate Tokens"** section:
    - Enter a name: `jenkins-recipe-app`
    - Click **"Generate"**
    - **Copy the token immediately** (you won't see it again!)
4. Save this token for Jenkins configuration

### Configure SonarQube in Jenkins:

1. Go to **Jenkins → Manage Jenkins → Configure System**
2. Scroll down to **"SonarQube servers"** section
3. Click **"Add SonarQube"**
4. Configure:
    - **Name**: `SonarQube Server`
    - **Server URL**: `http://localhost:9000` (or your SonarQube URL)
    - **Server authentication token**: Click "Add" → Select "Secret text"
        - Secret: [Paste your SonarQube token here]
        - ID: `sonarqube-token`
        - Description: `SonarQube authentication token`
        - Click "Add"
    - Select the credential you just created
5. Click **"Apply"** and **"Save"**

### Install SonarQube Plugin (if not already installed):

1. Go to **Jenkins → Manage Jenkins → Manage Plugins**
2. Click **"Available"** tab
3. Search for **"SonarQube Scanner"**
4. Check the box and click **"Install without restart"** or **"Download now and install after restart"**
5. Wait for installation to complete

## 5. Set Up Docker Hub Credentials

1. Go to Jenkins → **Manage Jenkins** → **Manage Credentials**
2. Click **"Global"** (or create a folder for your project)
3. Click **"Add Credentials"**
4. Select **"Username with password"**
5. Configure:
    - **Username**: `sopheaktraleng`
    - **Password**: [Your Docker Hub Personal Access Token]
    - **ID**: `dockerhub`
    - **Description**: `Docker Hub credentials for recipe app`
6. Click **"OK"**

### How to Get Docker Hub Personal Access Token:

1. Go to https://hub.docker.com/settings/security
2. Click **"New Access Token"**
3. Description: "Jenkins Pipeline"
4. Click **"Generate"**
5. Copy the token (you won't see it again!)
6. Use this token as the password in step 5 above

## 6. Verify Required Plugins

Make sure these Jenkins plugins are installed:

-   Docker Pipeline Plugin
-   Docker Plugin
-   SSH Agent Plugin
-   Trivy Scanner Plugin
-   SonarQube Scanner Plugin

To install/verify:

1. Jenkins → **Manage Jenkins** → **Manage Plugins**
2. Go to **"Installed"** tab
3. Search for each plugin above
4. If missing, go to **"Available"** tab, search and install

## 7. Configure SSH Key (for EC2 deployment)

If deploying to EC2:

1. Ensure your SSH key is at: `/var/lib/jenkins/.ssh/your-ec2-key.pem`
2. Update the path in Jenkinsfile if different:
    ```groovy
    SSH_KEY_PATH = "/var/lib/jenkins/.ssh/your-ec2-key.pem"
    ```
3. Set proper permissions on the key:
    ```bash
    sudo chmod 600 /var/lib/jenkins/.ssh/your-ec2-key.pem
    sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/your-ec2-key.pem
    ```

## 8. Build the Pipeline

1. Go to your Jenkins job
2. Click **"Build Now"**
3. Watch the build logs
4. Check each stage:
    - ✓ Checkout
    - ✓ Build and Push Docker Images
    - ✓ Deploy to EC2

## 9. Troubleshooting

### Issue: "dockerhub" not found

-   Solution: Make sure the credential ID is exactly `dockerhub`
-   Check in: Jenkins → Credentials → Global

### Issue: 504 Gateway Timeout

-   Solution: Already fixed in nginx.conf with timeout settings

### Issue: Push to Docker Hub fails

**Common causes and solutions:**

1. **Repositories don't exist on Docker Hub**

    - Go to https://hub.docker.com
    - Create repositories: `recipe-app-frontend` and `recipe-app-backend`
    - Set them to Public or Private (match your Jenkins credentials permissions)

2. **Incorrect credentials format**

    - Verify credential ID is exactly `dockerhub`
    - Username should be: `sopheaktraleng`
    - Password should be your Docker Hub Personal Access Token (NOT your Docker Hub password)
    - Token must have `Read, Write & Delete` permissions

3. **Error: "repository does not exist"**

    - Create the repositories on Docker Hub first
    - Repositories must exist before you can push to them

4. **Error: "authentication required" or "unauthorized"**

    - Regenerate your Personal Access Token
    - Update the credential in Jenkins with the new token
    - Make sure the username in Jenkins matches your Docker Hub username

5. **Error: "denied: requested access to the resource is denied"**
    - Check that you have permission to push to those repositories
    - Verify the username is correct
    - Ensure the Personal Access Token has write permissions

**To verify credentials locally (from Jenkins server):**

```bash
# SSH into Jenkins server
docker login -u sopheaktraleng
# Enter your Personal Access Token as password
docker push sopheaktraleng/recipe-app-frontend:test
```

### Issue: SonarQube Analysis fails

**Common causes and solutions:**

1. **sonar-scanner not found**

    - Install SonarQube Scanner on Jenkins server:
        ```bash
        # Download and install sonar-scanner
        wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
        unzip sonar-scanner-cli-4.8.0.2856-linux.zip
        sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
        echo 'export PATH=$PATH:/opt/sonar-scanner/bin' >> ~/.bashrc
        source ~/.bashrc
        ```

2. **SonarQube Server connection fails**

    - Check SonarQube is running: `docker ps | grep sonarqube`
    - Verify SonarQube URL is correct in Jenkins configuration
    - Check if Jenkins can reach SonarQube server
    - Test connection: `curl http://localhost:9000`

3. **Authentication failed**

    - Regenerate SonarQube token
    - Update credential in Jenkins with new token
    - Verify credential ID is `sonarqube-token`

4. **Quality Gate failed**
    - Check SonarQube dashboard for specific issues
    - Adjust quality gate thresholds if needed
    - Or temporarily set `abortPipeline: false` to allow build to continue

### Issue: Cannot connect to Docker daemon

-   Ensure Jenkins has Docker installed
-   Jenkins user needs to be in docker group: `sudo usermod -aG docker jenkins`
-   Restart Jenkins after adding user to docker group

## 10. Testing the Docker Images Locally

After successful build, test locally:

```bash
docker pull sopheaktraleng/recipe-app-frontend:latest
docker pull sopheaktraleng/recipe-app-backend:latest
```

## Environment Variables in Jenkinsfile

Current configuration:

-   `DOCKER_HUB_REPO`: `sopheaktraleng`
-   `EC2_HOST`: `18.140.51.105`
-   `EC2_USER`: `ec2-user`
-   `SSH_KEY_PATH`: Update this to your actual path

Adjust these in the Jenkinsfile if needed for your environment.
