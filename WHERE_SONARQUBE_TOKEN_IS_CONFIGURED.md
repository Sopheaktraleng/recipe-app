# Where SonarQube Token is Configured

## ❌ NOT in Jenkinsfile (Code)

The token is **NOT hardcoded** in your Jenkinsfile. This is intentional and secure!

Look at lines 21-23 in your Jenkinsfile:

```groovy
withSonarQubeEnv('SonarQube Server') {  // ← Just references the server name
  sh "sonar-scanner"                      // ← Runs the scanner
}
```

## ✅ In Jenkins UI (Configuration)

The credentials are configured in Jenkins web interface:

### Step-by-Step Location:

1. **Login to Jenkins**: `http://your-jenkins-url`
2. **Go to**: `Manage Jenkins` → `Configure System`
3. **Scroll down** to section: **"SonarQube servers"**
4. Click **"Add SonarQube"** button
5. Configure:
    - **Name**: `SonarQube Server` ← This name is used in your Jenkinsfile line 21
    - **Server URL**: `http://localhost:9000`
    - **Server authentication token**: Click **"Add"**
        - Secret: [Your SonarQube token]
        - ID: `sonarqube-token`
6. Select the credential from dropdown
7. Click **"Apply"** and **"Save"**

### Visual Path:

```
Jenkins
  └── Manage Jenkins
      └── Configure System
          └── SonarQube servers
              └── Add SonarQube
                  ├── Name: SonarQube Server
                  ├── Server URL: http://localhost:9000
                  └── Server authentication token: [Your token here]
```

## How It Works:

```groovy
// In Jenkinsfile line 21:
withSonarQubeEnv('SonarQube Server') {
  // ↑ This looks up the server configuration from Jenkins UI
  //   and automatically injects:
  //   - SONAR_HOST_URL
  //   - SONAR_LOGIN (your token)
  //   - Other needed environment variables
}
```

## Why This Design?

✅ **Security**: No secrets in code repository
✅ **Flexibility**: Change credentials without changing code
✅ **Best Practice**: Follows Jenkins recommended approach

## Quick Setup:

### 1. Get Token from SonarQube:

```
http://localhost:9000
→ Login as admin
→ My Account → Security
→ Generate Token: jenkins-recipe-app
```

### 2. Add to Jenkins:

```
Jenkins → Configure System
→ SonarQube servers
→ Add SonarQube
→ Name: SonarQube Server
→ URL: http://localhost:9000
→ Token: [paste token here]
```

That's it! Your Jenkinsfile doesn't need any changes.
