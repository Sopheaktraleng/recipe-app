# Quick SonarQube Setup (5 minutes)

Since your Docker Hub pipeline is working, here's how to add SonarQube:

## ✅ Step 1: Generate SonarQube Token

1. Open: `http://localhost:9000` (or your SonarQube URL)
2. Login: `admin` / `admin`
3. Click user icon → **My Account** → **Security** tab
4. Generate Token: `jenkins-recipe-app`
5. **Copy the token!**

---

## ✅ Step 2: Add SonarQube Plugin to Jenkins

1. Jenkins → **Manage Jenkins** → **Manage Plugins**
2. **Available** tab → Search: **"SonarQube Scanner"**
3. Check box → Click **Install without restart**
4. Wait for installation

---

## ✅ Step 3: Configure SonarQube Server in Jenkins

### Part A: Add Server Configuration

1. Jenkins → **Manage Jenkins** → **Configure System**
2. Scroll to **"SonarQube servers"**
3. Click **"Add SonarQube"**
4. Fill in:
    - **Name**: `SonarQube Server` (MUST be exactly this!)
    - **Server URL**: `http://localhost:9000`
    - **Server authentication token**: Click **"Add"**
        - Select: **Secret text**
        - **Secret**: [Paste your token]
        - **ID**: `sonarqube-token`
        - Click **Add**
5. Select `sonarqube-token` from dropdown
6. Click **Apply** and **Save**

---

## ✅ Step 4: Install sonar-scanner CLI

SSH into your Jenkins server and run:

```bash
# Install sonar-scanner
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Verify it works
sonar-scanner -v
```

---

## ✅ Step 5: Test the Pipeline

1. Commit and push your changes to the repository
2. Run the Jenkins pipeline
3. Check if SonarQube stage completes

---

## 🎯 What Changed in Jenkinsfile

I re-enabled SonarQube but made it **non-blocking**:

-   If SonarQube fails → Pipeline continues
-   Quality Gate won't abort the build
-   You'll see analysis results but deployment still happens

**Line 32**: `waitForQualityGate abortPipeline: false`

This means your Docker Hub push and deployment will always succeed even if SonarQube has issues.

---

## 🔍 Troubleshooting

### Error: "SonarQube 'SonarQube Server' not found"

**Fix**: Make sure you added SonarQube server in Jenkins with the exact name `SonarQube Server`

### Error: "sonar-scanner: command not found"

**Fix**: Install sonar-scanner (see Step 4 above)

### Error: "Authentication failed"

**Fix**: Regenerate token and update credential in Jenkins

### Pipeline runs but SonarQube is skipped

**Check**:

-   SonarQube server is running: `docker ps | grep sonarqube`
-   Accessible from Jenkins: `curl http://localhost:9000`

---

## Summary

1. ✅ Your Docker Hub pipeline works
2. 🔄 I re-enabled SonarQube (non-blocking mode)
3. ⚙️ Configure SonarQube server in Jenkins (5 min)
4. 🚀 Pipeline will run with code quality analysis

The pipeline will work even if SonarQube isn't configured - it will just skip that stage.
