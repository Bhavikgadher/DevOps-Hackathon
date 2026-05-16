#!/bin/bash

echo "Updating package list..."
sudo apt-get update -y

echo "Installing Docker..."
sudo apt-get install -y docker.io

echo "Starting Docker service..."
sudo systemctl start docker

echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "NOTE: You may need to logout/login for docker group changes to apply."

echo "Clearing screen..."
clear

echo "Checking Docker..."
docker --version
docker ps

echo "Downloading KIND..."
if [ "$(uname -m)" = "x86_64" ]; then
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
else
  echo "Unsupported architecture"
  exit 1
fi

echo "Making KIND executable..."
chmod +x ./kind

echo "Moving KIND to /usr/local/bin..."
sudo mv ./kind /usr/local/bin/kind

echo "Verifying KIND..."
kind --version

echo "Downloading kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

echo "Installing kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Cleaning up kubectl file..."
rm -f kubectl

echo "Final verification..."
kubectl version --client
kind --version
docker --version

echo "Full setup completed successfully!"