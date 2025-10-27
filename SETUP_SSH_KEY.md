# SSH Key Setup for Jenkins to K8s Master

## What SSH Key is Needed?

Jenkins needs to SSH into your **K8s master node** (54.254.75.157) to run kubectl commands.

## Where the Key Goes

The key must be **on the Jenkins server**, not on your local PC or K8s master.

```
┌──────────────┐      SSH Key      ┌─────────────┐
│   Jenkins    │ ──────(uses)─────> │  K8s Master │
│   Server     │                    │     Node    │
└──────────────┘                    └─────────────┘
```

## Setup Instructions

### Step 1: Find Your EC2 Key

On your local PC, locate your EC2 key file:
- Likely location: `~/.ssh/k8s-master-key.pem` or similar
- The key that allows SSH to your K8s master node

### Step 2: Copy Key to Jenkins Server

```bash
# From your local PC, copy the key to Jenkins server
scp ~/.ssh/k8s-master-key.pem jenkins@JENKINS_SERVER_IP:/var/lib/jenkins/.ssh/

# OR if you need to use a different user:
scp ~/.ssh/k8s-master-key.pem root@JENKINS_SERVER_IP:/var/lib/jenkins/.ssh/
```

### Step 3: Set Correct Permissions

```bash
# SSH into Jenkins server
ssh jenkins@JENKINS_SERVER_IP

# Navigate to .ssh directory
cd /var/lib/jenkins/.ssh

# Set permissions
chmod 600 k8s-master-key.pem
chown jenkins:jenkins k8s-master-key.pem

# Verify permissions
ls -la
# Should show: -rw------- jenkins jenkins k8s-master-key.pem
```

### Step 4: Test SSH Connection

```bash
# From Jenkins server, test connection to K8s master
ssh -i /var/lib/jenkins/.ssh/k8s-master-key.pem ec2-user@54.254.75.157

# Or using full path
ssh -i ~/.ssh/k8s-master-key.pem ec2-user@54.254.75.157

# You should be able to SSH into the K8s master node
```

### Step 5: Update Jenkinsfile

Edit Jenkinsfile line 9 with your actual key name:

```groovy
SSH_KEY_PATH = "/var/lib/jenkins/.ssh/k8s-master-key.pem"
```

**Important**: Replace `k8s-master-key.pem` with your actual key filename!

## Current Configuration

- **EC2_HOST**: `54.254.75.157` (your K8s master IP)
- **EC2_USER**: `ec2-user`
- **SSH_KEY_PATH**: `/var/lib/jenkins/.ssh/k8s-master-key.pem` (on Jenkins server)

## Verify Everything Works

After setting up the key:

1. **Test from Jenkins server**:
   ```bash
   ssh -i /var/lib/jenkins/.ssh/k8s-master-key.pem ec2-user@54.254.75.157
   ```

2. **Run Jenkins pipeline** - it should be able to SSH and deploy

## Troubleshooting

### Issue: Permission denied (publickey)

**Solution**:
```bash
# Check key permissions
ls -la /var/lib/jenkins/.ssh/

# Fix permissions
chmod 600 /var/lib/jenkins/.ssh/k8s-master-key.pem
chown jenkins:jenkins /var/lib/jenkins/.ssh/k8s-master-key.pem
```

### Issue: Key not found

**Solution**: 
- Check the key filename matches in Jenkinsfile
- Verify key exists at the path
- Check you're using absolute path

### Issue: Wrong user

**Solution**:
- Try `ec2-user` (default AWS EC2 user)
- Or `ubuntu` (if Ubuntu AMI)
- Update EC2_USER in Jenkinsfile if needed

## Summary

✅ **Key location**: `/var/lib/jenkins/.ssh/your-key.pem` (on Jenkins server)
✅ **Permissions**: `600` and owned by `jenkins:jenkins`
✅ **Purpose**: Jenkins uses it to SSH into K8s master to run kubectl
✅ **User**: The user that can SSH to K8s master (usually `ec2-user`)

