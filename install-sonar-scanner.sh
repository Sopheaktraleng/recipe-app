#!/bin/bash
# Install SonarQube Scanner on Jenkins Server

echo "Installing SonarQube Scanner..."

cd /tmp

# Download SonarQube Scanner
echo "Downloading sonar-scanner..."
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip

# Unzip
echo "Extracting..."
unzip sonar-scanner-cli-4.8.0.2856-linux.zip

# Move to /opt
echo "Installing to /opt/sonar-scanner..."
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner

# Create symbolic link
echo "Creating symlink..."
sudo ln -sf /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Make it executable for all users
sudo chmod +x /usr/local/bin/sonar-scanner

# Cleanup
echo "Cleaning up..."
rm sonar-scanner-cli-4.8.0.2856-linux.zip

# Verify installation
echo ""
echo "Verifying installation..."
sonar-scanner -v

echo ""
echo "✅ SonarQube Scanner installed successfully!"
echo ""
echo "If it still doesn't work, you may need to add to PATH:"
echo "export PATH=$PATH:/opt/sonar-scanner/bin"

