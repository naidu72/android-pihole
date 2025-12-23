# SSH Tunneling Guide for Raspberry Pi 5 Android -> Linux Development Environment

## Current Setup
- **Android Host**: `root@192.168.0.151` (Raspberry Pi 5)
- **Linux Container**: `droid@10.214.236.233` (Android Linux Development Environment)
- **Services**: Docker, Pi-hole

## Quick Start

### Option 1: Simple SSH Tunnel (Recommended for Local Access)

```bash
# Make script executable
chmod +x tunnel-setup.sh

# Run the tunnel setup
./tunnel-setup.sh

# Connect to Linux container
ssh -p 2222 droid@localhost
```

### Option 2: Using SSH Config (Recommended for Regular Use)

1. Add the config to your `~/.ssh/config`:
```bash
cat ~/.ssh/config-pi5 >> ~/.ssh/config
```

2. Connect directly:
```bash
ssh pi5-linux
```

### Option 3: Docker and Pi-hole Access

```bash
# Make script executable
chmod +x docker-pihole-tunnel.sh

# Run port forwarding
./docker-pihole-tunnel.sh

# Access services:
# - Docker: DOCKER_HOST=tcp://localhost:2375 docker ps
# - Pi-hole Web: http://localhost:8080
# - Pi-hole DNS: Configure DNS to use localhost:5353
```

## Detailed Setup

### 1. Basic SSH Tunnel

Forward local port 2222 to Linux container SSH (port 22):

```bash
ssh -L 2222:10.214.236.233:22 -N -f root@192.168.0.151
```

**Explanation:**
- `-L 2222:10.214.236.233:22`: Forward local port 2222 to remote 10.214.236.233:22
- `-N`: Don't execute remote commands
- `-f`: Run in background

**Connect:**
```bash
ssh -p 2222 droid@localhost
```

### 2. Multiple Port Forwarding

Forward multiple ports at once:

```bash
ssh -L 2222:10.214.236.233:22 \
    -L 2375:10.214.236.233:2375 \
    -L 8080:10.214.236.233:80 \
    -L 5353:10.214.236.233:53 \
    -N -f root@192.168.0.151
```

**Ports:**
- `2222`: SSH to Linux container
- `2375`: Docker daemon (if exposed)
- `8080`: Pi-hole web interface
- `5353`: Pi-hole DNS (requires root for port 53)

### 3. Reverse Tunnel (For External Access)

If you have an external server, create a reverse tunnel:

**On Linux container or Android host:**
```bash
ssh -R 2222:localhost:22 -N -f user@external-server.com
```

**From external server, connect:**
```bash
ssh -p 2222 droid@localhost
```

**For persistent connection, use autossh:**
```bash
# Install autossh first
apt-get install autossh

# Create persistent reverse tunnel
autossh -M 20000 -R 2222:10.214.236.233:22 -N -f root@192.168.0.151
```

### 4. Accessing Docker

If Docker daemon is exposed on Linux container:

```bash
# Forward Docker port
ssh -L 2375:10.214.236.233:2375 -N -f root@192.168.0.151

# Use Docker
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

### 5. Accessing Pi-hole

**Web Interface:**
```bash
# Forward port 80 to 8080
ssh -L 8080:10.214.236.233:80 -N -f root@192.168.0.151

# Access in browser
open http://localhost:8080
```

**DNS Server:**
```bash
# Forward DNS port (requires sudo for port 53)
sudo ssh -L 5353:10.214.236.233:53 -N -f root@192.168.0.151

# Configure system to use localhost:5353 as DNS
```

## Troubleshooting

### Check if tunnel is running:
```bash
ps aux | grep ssh
netstat -tuln | grep 2222
```

### Kill existing tunnel:
```bash
# Find PID
ps aux | grep "2222:10.214.236.233"

# Kill process
kill <PID>
```

### Test connection:
```bash
# Test Android host
ssh root@192.168.0.151 "echo 'Android host OK'"

# Test Linux container (from Android host)
ssh droid@10.214.236.233 "echo 'Linux container OK'"

# Test through tunnel
ssh -p 2222 droid@localhost "echo 'Tunnel OK'"
```

### Common Issues

1. **Connection refused**: Check if SSH is running on Linux container
2. **Permission denied**: Verify SSH keys or password authentication
3. **Port already in use**: Change local port number
4. **Tunnel dies**: Use autossh for persistent connections

## Security Considerations

1. **Use SSH keys instead of passwords**:
```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id root@192.168.0.151
ssh-copy-id droid@10.214.236.233
```

2. **Restrict SSH access** (on Android/Linux):
   - Edit `/etc/ssh/sshd_config`
   - Set `PasswordAuthentication no`
   - Set `PermitRootLogin prohibit-password`

3. **Use VPN instead of direct SSH** for better security

4. **Firewall rules**: Ensure ports are properly configured

## Advanced: Systemd Service (For Persistent Tunnels)

Create a systemd service for automatic tunnel on boot:

```bash
# /etc/systemd/system/pi5-tunnel.service
[Unit]
Description=SSH Tunnel to Pi5 Linux Container
After=network.target

[Service]
Type=simple
User=your-username
ExecStart=/usr/bin/ssh -L 2222:10.214.236.233:22 -N root@192.168.0.151
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable pi5-tunnel.service
sudo systemctl start pi5-tunnel.service
```

