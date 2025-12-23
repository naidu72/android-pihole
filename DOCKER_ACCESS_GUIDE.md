# Docker Access Guide

## Problem: Connection Reset Error

If you see this error:
```
error during connect: Get "http://localhost:2375/v1.47/containers/json": 
read tcp 127.0.0.1:44506->127.0.0.1:2375: read: connection reset by peer
```

This means Docker is **not listening on TCP port 2375**. Docker typically uses a Unix socket by default.

## Solution Options

### Option 1: Docker SSH Context (Recommended) ⭐

**Best for**: Docker 20.10+ with SSH support
**Pros**: Secure, no daemon restart, uses SSH authentication
**Cons**: Requires Docker 20.10+

```bash
# Setup (one time)
chmod +x docker-ssh-context.sh
./docker-ssh-context.sh

# Usage
docker context use pi5-linux
docker ps
docker images

# Switch back
docker context use default
```

### Option 2: Enable Docker TCP Access

**Best for**: Older Docker versions or when SSH context doesn't work
**Pros**: Works with any Docker version
**Cons**: Requires Docker daemon restart, opens Docker to network

```bash
# Setup (one time, requires Docker restart)
chmod +x docker-enable-tcp.sh
./docker-enable-tcp.sh

# Then restart Docker on Linux container:
ssh root@192.168.0.151
ssh droid@10.214.236.233
sudo systemctl restart docker

# Then use tunnel
./docker-tunnel-only.sh
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

### Option 3: Docker Socket Forwarding

**Best for**: Maximum compatibility
**Pros**: Works with any Docker setup
**Cons**: Requires socat on Linux container

```bash
# Install socat on Linux container first:
ssh root@192.168.0.151
ssh droid@10.214.236.233
sudo apt-get update && sudo apt-get install -y socat

# Then setup socket forwarding
chmod +x docker-socket-forward.sh
./docker-socket-forward.sh

# Usage
export DOCKER_HOST=unix://$HOME/.docker-pi5.sock
docker ps
```

## Troubleshooting

### Step 1: Run Diagnostics

```bash
chmod +x docker-troubleshoot.sh
./docker-troubleshoot.sh
```

This will check:
- SSH connectivity
- Docker status
- Docker socket location
- TCP port availability
- Docker configuration

### Step 2: Check Docker Version

```bash
# On Linux container
ssh root@192.168.0.151
ssh droid@10.214.236.233
docker --version
```

Docker 20.10+ supports SSH contexts (Option 1).

### Step 3: Verify Docker Socket

```bash
# On Linux container
ls -la /var/run/docker.sock
```

If this exists, Docker is using Unix socket (default).

## Quick Reference

| Method | Docker Version | Daemon Restart | Security | Ease |
|--------|---------------|----------------|----------|------|
| SSH Context | 20.10+ | No | High | Easy |
| TCP Access | Any | Yes | Medium | Medium |
| Socket Forward | Any | No | High | Hard |

## Recommended Approach

1. **First try**: Docker SSH Context (Option 1)
2. **If that fails**: Enable TCP Access (Option 2)
3. **If you need socket**: Socket Forwarding (Option 3)

## Security Notes

- **TCP Access (Option 2)**: Opens Docker to network access. Only use on trusted networks.
- **SSH Context (Option 1)**: Uses SSH authentication, more secure.
- **Socket Forward (Option 3)**: Uses SSH tunnel, secure.

