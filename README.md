# Hublink Hypervisor Setup

## Quick Start

### Raspberry Pi Setup

For installation on Raspberry Pi 5, download and run the setup script with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/Neurotech-Hub/Hublink-Hypervisor-Setup/main/setup.sh | sudo bash
```

This script will:
1. Create the installation directory at `/opt/hublink-hypervisor`
2. Clone the latest configuration files
3. Pull the latest Docker image
4. Start the Hublink Hypervisor service

The application will be available at `http://localhost:8081` and will start automatically on boot.

### Prerequisites

- Docker and Docker Compose (installed by Hublink-Gateway-Setup)
- Hublink containers running from `/opt/hublink` directory (installed by Hublink-Gateway-Setup)

## Installation

### Quick Installation (Recommended)

The setup script automatically:
- Stops any existing Hublink Hypervisor containers
- Removes the old installation directory
- Clones the latest configuration from GitHub
- Pulls the latest Docker image
- Starts the container with proper configuration

### Manual Installation

If you prefer to install manually:

1. **Clone the repository**:
   ```bash
   sudo mkdir -p /opt/hublink-hypervisor
   sudo chown $(whoami):$(whoami) /opt/hublink-hypervisor
   cd /opt/hublink-hypervisor
   git clone https://github.com/Neurotech-Hub/Hublink-Hypervisor-Setup.git .
   ```

2. **Pull the Docker image**:
   ```bash
   docker pull neurotechhub/hublink-hypervisor:latest
   ```

3. **Start the container**:
   ```bash
   docker-compose up -d
   ```

## Configuration

### Environment Variables

The hypervisor uses the following configuration:
- `HUBLINK_PATH`: `/opt/hublink` (path to Hublink containers)
- `DOCKER_SOCKET`: `/var/run/docker.sock` (Docker socket for container management)
- `APP_PORT`: `8081` (web interface port)

### Docker Compose Configuration

The `docker-compose.yml` file configures:
- Container name: `hublink-hypervisor`
- Network mode: `host` (for direct access to host network)
- Volumes: Docker socket and Hublink directory
- Restart policy: `always`
- Watchtower labels for automatic updates

## Usage

### Container Management

#### Check Status
```bash
docker ps | grep hublink-hypervisor
```

#### View Logs
```bash
docker logs -f hublink-hypervisor
```

#### Stop Container
```bash
cd /opt/hublink-hypervisor
docker-compose down
```

#### Start Container
```bash
cd /opt/hublink-hypervisor
docker-compose up -d
```

#### Restart Container
```bash
cd /opt/hublink-hypervisor
docker-compose restart
```

### Web Interface

Once running, access the hypervisor at:
```
http://localhost:8081
```

The web interface provides:
- Real-time status monitoring of Hublink containers
- Container control (start/stop/restart)
- Internet connectivity monitoring
- Auto-fix capabilities for common issues
- Container logs viewing
- System health information

## Updates

### Automatic Updates

The container is configured for automatic updates via Watchtower. When a new version is pushed to Docker Hub, Watchtower will automatically:
1. Pull the latest image
2. Stop the current container
3. Start a new container with the updated image

### Manual Updates

To manually update the container:

```bash
cd /opt/hublink-hypervisor
sudo git fetch origin
sudo git reset --hard origin/main
docker-compose down
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Container not starting**:
   - Check Docker is running: `systemctl status docker`
   - Check logs: `docker logs hublink-hypervisor`
   - Verify Docker socket permissions

2. **Cannot access web interface**:
   - Check container is running: `docker ps | grep hublink-hypervisor`
   - Verify port 8081 is not in use: `lsof -i :8081`
   - Check firewall settings

3. **Cannot access Hublink containers**:
   - Verify Hublink containers are running: `docker ps | grep hublink`
   - Check `/opt/hublink` directory exists and has proper permissions
   - Ensure Hublink-Gateway-Setup was run first

4. **Permission issues**:
   - Ensure user is in docker group: `groups $USER`
   - Restart Docker service: `sudo systemctl restart docker`
   - Log out and back in for group changes to take effect

### Log Analysis

#### Check Container Logs
```bash
docker logs hublink-hypervisor
```

#### Check Recent Logs
```bash
docker logs --since "1h" hublink-hypervisor
```

#### Follow Logs in Real-time
```bash
docker logs -f hublink-hypervisor
```

## Support

For additional support or to report issues, please visit:
https://github.com/Neurotech-Hub/Hublink-Hypervisor-Setup/issues

## License

This project is proprietary software for Hublink.cloud™. 