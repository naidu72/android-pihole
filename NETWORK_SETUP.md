# Network Setup Summary

## Current Network Configuration

### Devices
- **Android Host (Raspberry Pi 5)**: `192.168.0.151`
  - SSH: `root@192.168.0.151`
  - Running KonstaKANG LineageOS

- **Linux Development Environment**: `10.214.236.233` (private IP)
  - SSH: `droid@10.214.236.233`
  - Running Docker
  - Running Pi-hole

### Network
- **Private Network**: `192.168.0.0/24`
- **Pi-hole**: Accessible on local network for ad blocking

## Pi-hole Setup

✅ **Already Working on Local Network**
- Pi-hole is accessible at: `http://192.168.0.151` (or `http://10.214.236.233` if in container)
- Devices on `192.168.0.0/24` can use `192.168.0.151` as DNS server
- Will block ads for all devices on the private network
- **No tunneling needed** for local network devices

### To Configure Devices on Network:
1. Set DNS server to `192.168.0.151` (or `10.214.236.233`)
2. Devices will automatically get ad blocking

## SSH Tunneling (For Remote Access)

### Purpose
Tunneling is needed to access the **Linux container** (`10.214.236.233`) from outside the local network.

### What Needs Tunneling:
1. **SSH to Linux container** - Access the container remotely
2. **Docker daemon** - Manage Docker containers remotely
3. **Other services** running in the Linux container

### What Doesn't Need Tunneling:
- **Pi-hole web interface** - Already accessible on local network
- **Pi-hole DNS** - Already working for devices on `192.168.0.0/24`

## Quick Commands

### 1. SSH Tunnel to Linux Container
```bash
./tunnel-setup.sh
ssh -p 2222 droid@localhost
```

### 2. Docker Access Only
```bash
./docker-tunnel-only.sh
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

### 3. Combined (SSH + Docker)
```bash
# SSH tunnel
./tunnel-setup.sh

# Docker tunnel
./docker-tunnel-only.sh

# Use both
ssh -p 2222 droid@localhost
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

## Network Diagram

```
Internet
  │
  ├─> [Your Local Machine]
  │     │
  │     ├─> SSH Tunnel ──> 192.168.0.151 (Android) ──> 10.214.236.233 (Linux Container)
  │     │     Port 2222                                    │
  │     │                                                   ├─> Docker
  │     │                                                   └─> Pi-hole
  │     │
  │     └─> Docker Tunnel ──> 192.168.0.151 ──> 10.214.236.233:2375
  │           Port 2375
  │
  └─> [Local Network Devices: 192.168.0.0/24]
        │
        └─> DNS ──> 192.168.0.151 (Pi-hole) ──> Blocks Ads ✅
```

## Summary

- ✅ **Pi-hole**: Working on local network, no tunneling needed
- 🔧 **Linux Container Access**: Use `tunnel-setup.sh` for SSH
- 🐳 **Docker Access**: Use `docker-tunnel-only.sh` for Docker management
- 🌐 **Local Network**: All devices on `192.168.0.0/24` can use Pi-hole DNS

