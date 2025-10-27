#!/bin/bash

# Test Docker images from Docker Hub
echo "Testing Docker Hub images..."

# Pull the images
echo "\n1. Pulling frontend image..."
docker pull sopheaktraleng/recipe-app-frontend:latest

echo "\n2. Pulling backend image..."
docker pull sopheaktraleng/recipe-app-backend:latest

# Check if images were pulled successfully
echo "\n3. Checking local images..."
docker images | grep "recipe-app"

echo "\n✅ Images pulled successfully!"
echo "\nYou can now run:"
echo "  docker run -d -p 3000:80 sopheaktraleng/recipe-app-frontend:latest"
echo "  docker run -d -p 5000:5000 sopheaktraleng/recipe-app-backend:latest"

