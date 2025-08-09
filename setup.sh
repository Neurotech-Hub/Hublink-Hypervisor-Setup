#!/bin/bash

set -e  # Exit on error
log_file="install.log"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Starting Hublink Hypervisor installation..." | tee -a "$log_file"

# Configuration
INSTALL_PATH="/opt/hublink-hypervisor"
IMAGE_NAME="neurotechhub/hublink-hypervisor:latest"
APP_PORT="8081"

# Stop any existing hypervisor containers first (only hublink-hypervisor containers)
if command -v docker &> /dev/null && systemctl is-active --quiet docker; then
    echo "Stopping existing Hublink Hypervisor containers..." | tee -a "$log_file"
    
    # First move out of /opt/hublink-hypervisor in case we're in it
    cd /

    # Stop containers using docker-compose if the file exists (this only affects hublink-hypervisor)
    if [ -f "/opt/hublink-hypervisor/docker-compose.yml" ]; then
        echo "Stopping hublink-hypervisor via docker-compose..." | tee -a "$log_file"
        (cd /opt/hublink-hypervisor && docker-compose down) || echo "docker-compose down failed, continuing..." | tee -a "$log_file"
    fi
    
    # Only stop containers that are specifically named hublink-hypervisor (targeted approach)
    echo "Checking for any remaining hublink-hypervisor containers..." | tee -a "$log_file"
    if docker ps --format "{{.Names}}" | grep -q "^hublink-hypervisor$"; then
        echo "Found hublink-hypervisor container, stopping it..." | tee -a "$log_file"
        docker stop hublink-hypervisor || echo "Failed to stop hublink-hypervisor container, continuing..." | tee -a "$log_file"
    else
        echo "No hublink-hypervisor containers found to stop" | tee -a "$log_file"
    fi
elif command -v docker &> /dev/null; then
    echo "Docker is installed but not running, skipping container cleanup..." | tee -a "$log_file"
else
    echo "Docker not found, skipping container cleanup..." | tee -a "$log_file"
fi

# Remove existing directory completely and recreate fresh
echo "Preparing installation directory..." | tee -a "$log_file"
cd /
rm -rf /opt/hublink-hypervisor
mkdir -p /opt/hublink-hypervisor
cd /opt/hublink-hypervisor || exit 1

# Clone the repository with more verbose output
echo "Downloading Hublink Hypervisor Setup..." | tee -a "$log_file"
git clone https://github.com/Neurotech-Hub/Hublink-Hypervisor-Setup.git /opt/hublink-hypervisor 2>> "$log_file" || {
    echo "Git clone failed! See $log_file for details" | tee -a "$log_file"
    cat "$log_file"
    exit 1
}
cd /opt/hublink-hypervisor || exit 1
echo "Repository cloned successfully" | tee -a "$log_file"

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo -e "Error: Docker is not installed" | tee -a "$log_file"
    exit 1
fi

# Enable Docker service to start on boot
echo "Ensuring Docker service starts on boot..." | tee -a "$log_file"
systemctl enable docker

if ! docker info &> /dev/null; then
    echo -e "Error: Docker is not running or user is not in docker group" | tee -a "$log_file"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "Error: docker-compose is not installed" | tee -a "$log_file"
    exit 1
fi

echo "✓ Docker and docker-compose are available" | tee -a "$log_file"

# Pull the Docker image
echo "Pulling Hublink Hypervisor Docker image..." | tee -a "$log_file"
docker pull "$IMAGE_NAME" >> "$log_file" 2>&1

# Start the container
echo "Starting Hublink Hypervisor container..." | tee -a "$log_file"
if command -v docker-compose &> /dev/null; then
    docker-compose up -d >> "$log_file" 2>&1
else
    docker compose up -d >> "$log_file" 2>&1
fi

# Wait a moment for the container to start
sleep 5

# Check if container is running
if docker ps --format "table {{.Names}}" | grep -q "hublink-hypervisor"; then
    echo "✓ Hublink Hypervisor container is running" | tee -a "$log_file"
else
    echo "✗ Failed to start Hublink Hypervisor container" | tee -a "$log_file"
    echo "Check logs with: docker logs hublink-hypervisor" | tee -a "$log_file"
    exit 1
fi

echo "" | tee -a "$log_file"
echo "Installation completed successfully!" | tee -a "$log_file"
echo "" | tee -a "$log_file"
echo "Container Information:" | tee -a "$log_file"
echo "  Container Name: hublink-hypervisor" | tee -a "$log_file"
echo "  Web Interface: http://localhost:$APP_PORT" | tee -a "$log_file"
echo "  Image: $IMAGE_NAME" | tee -a "$log_file"
echo "" | tee -a "$log_file"
echo "Container Management:" | tee -a "$log_file"
echo "  Check Status: docker ps | grep hublink-hypervisor" | tee -a "$log_file"
echo "  View Logs: docker logs -f hublink-hypervisor" | tee -a "$log_file"
echo "  Stop Container: cd $INSTALL_PATH && docker-compose down" | tee -a "$log_file"
echo "  Start Container: cd $INSTALL_PATH && docker-compose up -d" | tee -a "$log_file"
echo "  Restart Container: cd $INSTALL_PATH && docker-compose restart" | tee -a "$log_file"
echo "" | tee -a "$log_file"
echo "Auto-Updates:" | tee -a "$log_file"
echo "  The container is configured for automatic updates via Watchtower" | tee -a "$log_file"
echo "  Watchtower will automatically pull and restart the container when updates are available" | tee -a "$log_file"
echo "" | tee -a "$log_file"
echo "Manual Updates:" | tee -a "$log_file"
echo "  Pull Latest Image: docker pull $IMAGE_NAME" | tee -a "$log_file"
echo "  Restart Container: cd $INSTALL_PATH && docker-compose up -d" | tee -a "$log_file" 