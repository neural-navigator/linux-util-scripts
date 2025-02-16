#!/bin/bash

# Check if Docker is installed
if command -v docker &> /dev/null
then
    echo "Docker is already installed. Skipping installation."
else
    echo "Docker is not installed. Installing Docker..."

    # Download the install script
    wget -O install-docker.sh https://raw.githubusercontent.com/neural-navigator/linux-util-scripts/refs/heads/main/install-docker.sh

    # Make the script executable
    chmod +x install-docker.sh

    # Run the installation script
    ./install-docker.sh

    # Clean up by removing the downloaded script
    rm install-docker.sh
fi

# Configure the production repository:

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update -y

# Install the NVIDIA Container Toolkit packages:
sudo apt-get install -y nvidia-container-toolkit

# Configure the container runtime by using the nvidia-ctk command:
sudo nvidia-ctk runtime configure --runtime=docker

# Restart the Docker daemon:
sudo systemctl restart docker

# Run a test Docker command to check if NVIDIA runtime works
echo "Running the test command to check if NVIDIA runtime is working..."
if sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi; then
    echo "Container toolkit installed successfully and NVIDIA runtime is working."
else
    echo "Error: NVIDIA runtime did not work. Please check your setup."
fi
