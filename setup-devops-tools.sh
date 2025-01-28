#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting the installation of DevOps tools on Ubuntu..."

# Update and upgrade system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt install -y curl wget gnupg2 apt-transport-https software-properties-common

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker installed successfully!"

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose installed successfully!"
else
    echo "Docker Compose installation failed. Falling back to package manager..."
    sudo apt install -y docker-compose-plugin
    echo "Docker Compose (plugin) installed successfully!"
fi

# Install Elasticsearch
echo "Installing Elasticsearch..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list'
sudo apt update
sudo apt install -y elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
echo "Elasticsearch installed successfully!"

# Install Fluentd
echo "Installing Fluentd..."

# For Ubuntu Noble:
# fluent-package 5 (LTS)
# curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-noble-fluent-package5-lts.sh | sh
# sudo systemctl start fluentd.service
# sudo systemctl status fluentd.service
# sudo systemctl status fluentd

curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
sudo systemctl start td-agent
sudo systemctl enable td-agent
echo "Fluentd installed successfully!"

# Install Grafana
echo "Installing Grafana..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
echo "Grafana installed successfully!"

# Verify installations
echo "Verifying installations..."
docker --version && echo "Docker is working."
docker-compose --version && echo "Docker Compose is working."
curl -X GET "http://localhost:9200/_cluster/health?pretty" && echo "Elasticsearch is working."
sudo systemctl status td-agent && echo "Fluentd is working."
sudo systemctl status grafana-server && echo "Grafana is working."

# Final message
echo "All tools installed successfully! You can access Grafana at http://<your-server-ip>:3000"
