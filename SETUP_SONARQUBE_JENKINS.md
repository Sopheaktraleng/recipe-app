# Quick Setup Guide for SonarQube & Jenkins

Since you have SonarQube running in Docker and Trivy installed, here's what you need to do:

## ✅ What You Already Have:

-   SonarQube running in Docker
-   Trivy installed on server

## ⚙️ What You Need to Configure:

### Step 1: Install sonar-scanner CLI (if not already installed)

SSH into your Jenkins server and run:

```bash
# Check if sonar-scanner is already installed
which sonar-scanner

# If not found, install it:
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Verify installation
sonar-scanner -v
```

---

### Step 2: Generate SonarQube Token

1. Open SonarQube: `http://YOUR_SERVER_IP:9000`
2. Login: `admin` / `admin` (change password if prompted)
3. Click user icon → **My Account** → **Security** tab
4. Generate Token named: `jenkins-recipe-app`
5. **Copy the token!**

---

### Step 3: Configure SonarQube in Jenkins

1. Go to **Jenkins → Manage Jenkins → Configure System**
2. Scroll to **"SonarQube servers"** section
3. Click **"Add SonarQube"**
4. Configure:
    - **Name**: `SonarQube Server` (MUST be exactly this!)
    - **Server URL**: `http://YOUR_SERVER_IP:9000` (your SonarQube Docker instance)
    - **Server authentication token**: Click **"Add"**
        - Secret: [Paste your token]
        - ID: `sonarqube-token`
        - Description: `SonarQube auth token`
        - Click **Add**
5. Select the credential from dropdown
6. Click **"Apply"** and **"Save"**

---

### Step 4: Install SonarQube Scanner Plugin (if not installed)

1. Go to **Jenkins → Manage Jenkins → Manage Plugins**
2. **Available** tab → Search: **"SonarQube Scanner"**
3. Check box → Click **"Install without restart"**
4. Wait for installation

---

### Step 5: Verify Trivy

Trivy should already work since you installed it. Test it:

```bash
trivy --version
```

---

## 🎯 Your Pipeline Stages Now:

1. ✅ **Checkout** - Get code from GitHub
2. ✅ **Code Quality Analysis** - SonarQube scans your code
3. ✅ **Quality Gate Check** - Ensures code meets standards (non-blocking)
4. ✅ **Build Docker Images** - Build frontend & backend
5. ✅ **Security Scan with Trivy** - Scan for vulnerabilities
6. ✅ **Push to Docker Hub** - Push images with tags
7. ✅ **Deploy to EC2** - Deploy to Kubernetes

---

## 🐛 Troubleshooting:

### Issue: "sonar-scanner: command not found"

**Fix**: Install sonar-scanner (see Step 1 above)

### Issue: "withSonarQubeEnv: SonarQube 'SonarQube Server' not found"

**Fix**: Configure SonarQube in Jenkins (see Step 3 above)

### Issue: "SonarQube connection refused"

**Fix**:

-   Check SonarQube is running: `docker ps | grep sonarqube`
-   Update Server URL in Jenkins to correct IP/port
-   Make sure SonarQube port 9000 is accessible from Jenkins server

### Issue: Trivy scan fails

**Check**: `trivy --version` (should be installed already)

---

## 🚀 After Configuration:

1. Commit and push the Jenkinsfile:

    ```bash
    git add Jenkinsfile
    git commit -m "feat: enable SonarQube and Trivy security scanning"
    git push origin main
    ```

2. Run your Jenkins pipeline

3. All stages should now work! 🎉
