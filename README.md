# Android Pi-hole Setup - SSH Tunneling Guide

This repository contains scripts and documentation for setting up SSH tunneling to access a Linux development environment running on a Raspberry Pi 5 with Android (KonstaKANG LineageOS).

## Setup Overview

- **Android Host (Raspberry Pi 5)**: `192.168.0.151`
- **Linux Development Environment**: `10.214.236.233` (private IP)
- **Pi-hole**: Running on private network `192.168.0.0/24` for ad blocking

## Quick Start

### 1. SSH Tunnel to Linux Container

```bash
chmod +x tunnel-setup.sh
./tunnel-setup.sh
ssh -p 2222 droid@localhost
```

### 2. Docker Access

```bash
chmod +x docker-tunnel-only.sh
./docker-tunnel-only.sh
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

### 3. SSH Config (Optional)

Copy `ssh-config-pi5.example` to your `~/.ssh/config`:

```bash
cat ssh-config-pi5.example >> ~/.ssh/config
ssh pi5-linux
```

## Files

- `tunnel-setup.sh` - Basic SSH tunnel to Linux container
- `docker-tunnel-only.sh` - Docker daemon port forwarding
- `docker-pihole-tunnel.sh` - Combined Docker and Pi-hole forwarding (Pi-hole already works locally)
- `reverse-tunnel-setup.sh` - Reverse tunnel for external access
- `ssh-config-pi5.example` - SSH config template
- `TUNNEL_SETUP_GUIDE.md` - Detailed tunneling documentation
- `NETWORK_SETUP.md` - Network topology and configuration

## Pi-hole Configuration

Pi-hole is already running on the private network (`192.168.0.0/24`) and will block ads for all devices on that network.

- **Web Interface**: `http://192.168.0.151` (or `http://10.214.236.233`)
- **DNS Server**: `192.168.0.151` - Configure this on devices in your network
- **No tunneling needed** for local network devices

## Requirements

- SSH access to Android host: `root@192.168.0.151`
- SSH access to Linux container: `droid@10.214.236.233`
- SSH client on your local machine

## License

See individual files for license information.

