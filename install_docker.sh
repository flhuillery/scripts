#!/bin/bash
#
# Description: Docker installation script for Debian-based systems
# Author: Your Name
# Date: September 24, 2025
#

# Exit on any error
set -e

# Function to clean up on error
cleanup() {
    if [ $? -ne 0 ]; then
        echo "Error: Installation failed"
        echo "Cleaning up..."
        rm -f /etc/apt/keyrings/docker.asc
        rm -f /etc/apt/sources.list.d/docker.list
    fi
}

# Set up error handling
trap cleanup EXIT

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Check system compatibility
if ! grep -qi debian /etc/os-release && ! grep -qi ubuntu /etc/os-release; then
    echo "Error: This script is only compatible with Debian-based systems"
    exit 1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Notice: Docker is already installed"
    echo "Current version:"
    docker --version
    read -p "Do you want to continue with installation? (y/n): " continue
    if [ "$continue" != "y" ]; then
        echo "Installation cancelled by user"
        exit 0
    fi
fi

# Error handling
set -e

# Add Docker's official GPG key:
echo "Installing Docker prerequisites..."
apt update || { echo "Error: Failed to update apt"; exit 1; }
apt -y dist-upgrade || { echo "Error: Failed to upgrade system packages"; exit 1; }
apt -y install ca-certificates curl || { echo "Error: Failed to install prerequisites"; exit 1; }
install -m 0755 -d /etc/apt/keyrings || { echo "Error: Failed to create keyrings directory"; exit 1; }
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || { echo "Error: Failed to download Docker GPG key"; exit 1; }
chmod a+r /etc/apt/keyrings/docker.asc || { echo "Error: Failed to set permissions on Docker GPG key"; exit 1; }

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker engine & compose
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose gpg

# Test Docker functionality
echo "Testing Docker installation..."
if docker info > /dev/null 2>&1; then
    echo "Docker is running properly"
else
    echo "Docker is not running correctly"
    echo "Please check Docker service status with: systemctl status docker"
    exit 1
fi

# Reboot option
read -p "Do you want to reboot? (y/n): " response
if [ "$response" = "y" ]; then
    echo "Rebooting system..."
    /sbin/reboot
else
    echo "Reboot cancelled."
fi
