# SonarQube Token Setup in Jenkins

## Step-by-Step Guide

### Step 1: Generate Token in SonarQube

1. **Open SonarQube**: `http://localhost:9000`
2. **Login** with: `admin` / `admin`
3. Click on **user icon** (top right) → **My Account**
4. Go to **Security** tab
5. Scroll to **Generate Tokens** section
6. Enter name: `jenkins-recipe-app`
7. Click **Generate**
8. **COPY THE TOKEN IMMEDIATELY** (you won't see it again!)
    - Example: `squ_abc123def456ghi789jkl012mno345pqr678stu901`

---

### Step 2: Add Token to Jenkins Credentials

1. **Go to Jenkins** → **Manage Jenkins** → **Credentials**
2. Click on **System** → **Global credentials (unrestricted)**
3. Click **Add Credentials** on the left
4. Configure:
    - **Kind**: Select **Secret text** ▼
    - **Secret**: Paste your token here
    - **ID**: `sonarqube-token` (MUST be exactly this)
    - **Description**: `SonarQube authentication token for recipe app`
5. Click **Create**

---

### Step 3: Configure SonarQube Server in Jenkins

1. Go to **Jenkins** → **Manage Jenkins** → **Configure System**
2. Scroll down to **SonarQube servers** section
3. Click **"Add SonarQube"**
4. Fill in:
    - **Name**: `SonarQube Server` (MUST match exactly)
    - **Server URL**: `http://localhost:9000` (or your SonarQube URL)
5. In **Server authentication token**:
    - Click **Add** button
    - Select **Secret text** from dropdown
    - Enter:
        - **Secret**: [Paste your token again]
        - **ID**: `sonarqube-token`
        - **Description**: `SonarQube token`
        - Click **Add**
6. Select the credential `sonarqube-token` from the dropdown
7. Click **Apply** and **Save**

---

### Step 4: Verify Configuration

Your Jenkinsfile uses this configuration automatically:

```groovy
withSonarQubeEnv('SonarQube Server') {
    sh "sonar-scanner"
}
```

The `withSonarQubeEnv('SonarQube Server')` automatically:

-   Injects `SONAR_HOST_URL` from server URL
-   Injects `SONAR_LOGIN` from the token credential
-   These environment variables are available to `sonar-scanner` command

---

## Visual Guide

```
Jenkins Configuration
├── Manage Jenkins
    ├── Configure System
    │   └── SonarQube servers
    │       ├── Name: SonarQube Server
    │       ├── Server URL: http://localhost:9000
    │       └── Authentication token: sonarqube-token
    │
    └── Credentials
        └── Global credentials
            └── sonarqube-token (Secret text)
```

---

## Troubleshooting

### Issue: "Credentials 'sonarqube-token' not found"

**Solution**:

1. Make sure you created the credential with ID exactly `sonarqube-token`
2. Check: Jenkins → Manage Jenkins → Credentials → System → Global
3. Verify the ID matches exactly (case-sensitive)

### Issue: "SonarQube 'SonarQube Server' not found"

**Solution**:

1. Make sure you configured the SonarQube server in Jenkins
2. The name must be exactly `SonarQube Server` (case-sensitive)
3. Check: Jenkins → Manage Jenkins → Configure System → SonarQube servers

### Issue: "Authentication failed"

**Solution**:

1. Regenerate token in SonarQube
2. Update the credential in Jenkins with new token
3. Check if SonarQube is accessible: `curl http://localhost:9000`

### Issue: Token working but connection fails

**Solution**:

-   If Jenkins is on a different server than SonarQube:
    -   Update Server URL to: `http://YOUR_SERVER_IP:9000`
    -   Make sure firewall allows access to port 9000

---

## Quick Test

After configuration, run your pipeline and check the "Code Quality Analysis" stage:

```bash
# The logs should show:
[INFO] ---------- Scan Summary ----------------
[INFO] PROJECT KEY: recipe-app
[INFO] PROJECT NAME: Recipe App
[INFO] ANALYSIS SUCCESSFUL
```

If you see authentication errors, double-check the token was added correctly to Jenkins credentials.
