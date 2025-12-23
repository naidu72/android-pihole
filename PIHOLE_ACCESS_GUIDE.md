# Pi-hole Access Guide

## Problem: Unable to Connect to http://192.168.0.151:8080/admin/login

Pi-hole is running on the **Linux container** (`10.214.236.233`), not directly on the Android host (`192.168.0.151`). You need to set up port forwarding to access it.

## Quick Solution

### Step 1: Check Pi-hole Status

```bash
cd /home/frontier/android-pihole
chmod +x pihole-check.sh
./pihole-check.sh
```

This will tell you:
- If Pi-hole is running
- What ports it's using
- If port forwarding is already active

### Step 2: Set Up Port Forwarding

```bash
chmod +x pihole-forward.sh
./pihole-forward.sh
```

### Step 3: Access Pi-hole

Open in your browser:
```
http://localhost:8080/admin/login
```

## Access Methods

### Method 1: Port Forwarding (For Remote Access)

**Use when**: Accessing from outside the local network or from your development machine

```bash
./pihole-forward.sh
# Then access: http://localhost:8080/admin/login
```

### Method 2: Direct Access (For Local Network Devices)

**Use when**: Devices are on the same network (192.168.0.0/24)

Pi-hole should be accessible directly if it's properly configured:

1. **Check if Pi-hole is exposed on Android host**:
   ```bash
   ssh root@192.168.0.151
   # Check if port 80 is forwarded or if Pi-hole is accessible
   ```

2. **Access directly** (if configured):
   ```
   http://192.168.0.151/admin/login
   ```

3. **Or access via Linux container IP** (if on same network):
   ```
   http://10.214.236.233/admin/login
   ```

### Method 3: Complete Port Forwarding (All Ports)

For both web and DNS access:

```bash
chmod +x pihole-all-ports.sh
./pihole-all-ports.sh
```

Then access:
- Web: `http://localhost:8080/admin/login`
- DNS: `localhost:5353` (for testing)

## Troubleshooting

### Check 1: Is Pi-hole Running?

```bash
ssh root@192.168.0.151
ssh droid@10.214.236.233
docker ps | grep pihole
# OR
systemctl status pihole-FTL
```

### Check 2: What Port is Pi-hole Using?

```bash
ssh root@192.168.0.151
ssh droid@10.214.236.233
docker ps --filter name=pihole --format "{{.Ports}}"
```

Common ports:
- **80**: Web interface (HTTP)
- **443**: Web interface (HTTPS)
- **53**: DNS server

### Check 3: Test Direct Access on Linux Container

```bash
ssh root@192.168.0.151
ssh droid@10.214.236.233
curl http://localhost/admin/login
```

If this works, Pi-hole is running but needs port forwarding.

### Check 4: Verify Port Forwarding

```bash
# Check if port 8080 is listening locally
lsof -i :8080
netstat -tuln | grep 8080
```

### Check 5: Test the Forwarded Port

```bash
curl http://localhost:8080/admin/login
```

## Common Issues

### Issue 1: "Connection Refused"

**Cause**: Port forwarding not active or Pi-hole not running

**Solution**:
```bash
./pihole-check.sh  # Diagnose
./pihole-forward.sh # Set up forwarding
```

### Issue 2: "Unable to Connect"

**Cause**: Pi-hole might be on a different port or not exposed

**Solution**:
1. Check Pi-hole container ports: `docker ps | grep pihole`
2. Update `pihole-forward.sh` with correct port
3. Or check if Pi-hole needs to be exposed on Android host

### Issue 3: Port Already in Use

**Cause**: Another process is using port 8080

**Solution**:
```bash
# Kill existing process
kill $(lsof -t -i:8080)

# Or use a different port
# Edit pihole-forward.sh and change LOCAL_PORT
```

### Issue 4: Pi-hole Not Accessible on Android Host

**Cause**: Pi-hole is only accessible on Linux container IP

**Solution**: Use port forwarding (Method 1) or configure Docker port mapping

## Network Configuration

### Current Setup
```
Your Machine
    │
    ├─> SSH Tunnel (port 8080) ──> 192.168.0.151 (Android)
    │                                      │
    │                                      └─> 10.214.236.233 (Linux Container)
    │                                                      │
    │                                                      └─> Pi-hole (port 80)
    │
    └─> Browser: http://localhost:8080/admin/login
```

### For Local Network Devices
```
Device on 192.168.0.0/24
    │
    └─> DNS: 192.168.0.151 (or 10.214.236.233)
              │
              └─> Pi-hole blocks ads ✅
```

## Default Pi-hole Access

- **Web Interface**: Usually on port 80 (HTTP) or 443 (HTTPS)
- **Admin Path**: `/admin/login`
- **Default**: No username, password set during installation

## Quick Reference

| Access Method | URL | When to Use |
|--------------|-----|-------------|
| Port Forward | `http://localhost:8080/admin/login` | Remote access |
| Direct (Android) | `http://192.168.0.151/admin/login` | If exposed on Android |
| Direct (Container) | `http://10.214.236.233/admin/login` | If on same network |
| DNS (Local) | `192.168.0.151` | For devices on 192.168.0.0/24 |

