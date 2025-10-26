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

## 3. Set Up Docker Hub Credentials

1. Go to Jenkins → **Manage Jenkins** → **Manage Credentials**
2. Click **"Global"** (or create a folder for your project)
3. Click **"Add Credentials"**
4. Select **"Username with password"**
5. Configure:
    - **Username**: `sopheaktraleng`
    - **Password**: [Your Docker Hub Personal Access Token]
    - **ID**: `docker-hub-credentials`
    - **Description**: `Docker Hub credentials for recipe app`
6. Click **"OK"**

### How to Get Docker Hub Personal Access Token:

1. Go to https://hub.docker.com/settings/security
2. Click **"New Access Token"**
3. Description: "Jenkins Pipeline"
4. Click **"Generate"**
5. Copy the token (you won't see it again!)
6. Use this token as the password in step 5 above

## 4. Verify Required Plugins

Make sure these Jenkins plugins are installed:

-   Docker Pipeline Plugin
-   Docker Plugin
-   SSH Agent Plugin
-   Trivy Scanner Plugin

To install/verify:

1. Jenkins → **Manage Jenkins** → **Manage Plugins**
2. Go to **"Installed"** tab
3. Search for each plugin above
4. If missing, go to **"Available"** tab, search and install

## 5. Configure SSH Key (for EC2 deployment)

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

## 6. Build the Pipeline

1. Go to your Jenkins job
2. Click **"Build Now"**
3. Watch the build logs
4. Check each stage:
    - ✓ Checkout
    - ✓ Build and Push Docker Images
    - ✓ Deploy to EC2

## 7. Troubleshooting

### Issue: "docker-hub-credentials" not found

-   Solution: Make sure the credential ID is exactly `docker-hub-credentials`
-   Check in: Jenkins → Credentials → Global

### Issue: 504 Gateway Timeout

-   Solution: Already fixed in nginx.conf with timeout settings

### Issue: Push to Docker Hub fails

-   Check if your Docker Hub username is correct
-   Verify the Personal Access Token is valid
-   Make sure you have permission to push to the repository

### Issue: Cannot connect to Docker daemon

-   Ensure Jenkins has Docker installed
-   Jenkins user needs to be in docker group: `sudo usermod -aG docker jenkins`
-   Restart Jenkins after adding user to docker group

## 8. Testing the Docker Images Locally

After successful build, test locally:

```bash
docker pull sopheaktraleng/mern-recipe-app-frontend:latest
docker pull sopheaktraleng/mern-recipe-app-backend:latest
```

## Environment Variables in Jenkinsfile

Current configuration:

-   `DOCKER_HUB_REPO`: `sopheaktraleng`
-   `EC2_HOST`: `18.140.51.105`
-   `EC2_USER`: `ec2-user`
-   `SSH_KEY_PATH`: Update this to your actual path

Adjust these in the Jenkinsfile if needed for your environment.
