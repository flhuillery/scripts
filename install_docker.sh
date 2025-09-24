#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Error handling
set -e

# Add Docker's official GPG key:
echo "Installing Docker prerequisites..."
apt update || { echo "Failed to update apt"; exit 1; }
apt -y dist-upgrade
apt -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || { echo "Failed to download Docker GPG key"; exit 1; }
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker engine & compose
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose gpg

# Run Docker Hello World
echo "Testing Docker installation..."
docker run --name hello-world -d hello-world || { echo "Failed to run hello-world container"; exit 1; }

# Clean up Docker test
read -p "Do you want to remove the test container? (y/n): " response
if [ "$response" = "y" ]; then
    echo "Removing test container..."
    docker rm -f hello-world
    docker image rm -f hello-world
else
    echo "Test container was kept."
fi

# Reboot option
read -p "Do you want to reboot? (y/n): " response
if [ "$response" = "y" ]; then
    echo "Rebooting system..."
    /sbin/reboot
else
    echo "Reboot cancelled."
fi
