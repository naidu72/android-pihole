#!/bin/bash
# Docker Troubleshooting Script
# Checks Docker configuration and provides solutions

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"

echo "🔍 Docker Troubleshooting"
echo "========================"
echo ""

# Check 1: Test SSH connection to Android host
echo "1. Testing SSH connection to Android host..."
if ssh -o ConnectTimeout=5 ${ANDROID_USER}@${ANDROID_HOST} "echo 'Connected'" 2>/dev/null; then
    echo "   ✅ SSH to Android host works"
else
    echo "   ❌ Cannot connect to Android host"
    exit 1
fi

# Check 2: Test SSH connection to Linux container
echo ""
echo "2. Testing SSH connection to Linux container..."
if ssh -o ConnectTimeout=5 ${ANDROID_USER}@${ANDROID_HOST} "ssh -o ConnectTimeout=5 droid@${LINUX_CONTAINER} 'echo Connected'" 2>/dev/null; then
    echo "   ✅ SSH to Linux container works"
else
    echo "   ❌ Cannot connect to Linux container"
    exit 1
fi

# Check 3: Check if Docker is running
echo ""
echo "3. Checking if Docker is running on Linux container..."
DOCKER_STATUS=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh droid@${LINUX_CONTAINER} 'systemctl is-active docker 2>/dev/null || service docker status 2>/dev/null | head -1'" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   Docker status: $DOCKER_STATUS"
else
    echo "   ⚠️  Could not check Docker status"
fi

# Check 4: Check Docker socket
echo ""
echo "4. Checking Docker socket..."
DOCKER_SOCKET=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh droid@${LINUX_CONTAINER} 'ls -la /var/run/docker.sock 2>/dev/null'" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   ✅ Docker socket exists: /var/run/docker.sock"
    echo "   $DOCKER_SOCKET"
else
    echo "   ❌ Docker socket not found"
fi

# Check 5: Check if Docker is listening on TCP port 2375
echo ""
echo "5. Checking if Docker is listening on TCP port 2375..."
DOCKER_TCP=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh droid@${LINUX_CONTAINER} 'netstat -tuln 2>/dev/null | grep 2375 || ss -tuln 2>/dev/null | grep 2375'" 2>/dev/null)
if [ -n "$DOCKER_TCP" ]; then
    echo "   ✅ Docker is listening on TCP port 2375"
    echo "   $DOCKER_TCP"
else
    echo "   ❌ Docker is NOT listening on TCP port 2375"
    echo "   Docker is likely using Unix socket only"
fi

# Check 6: Check Docker daemon configuration
echo ""
echo "6. Checking Docker daemon configuration..."
DOCKER_CONFIG=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh droid@${LINUX_CONTAINER} 'cat /etc/docker/daemon.json 2>/dev/null || echo \"No daemon.json found\"'" 2>/dev/null)
echo "   Docker daemon.json:"
echo "   $DOCKER_CONFIG"

# Check 7: Check if tunnel port is in use
echo ""
echo "7. Checking if local port 2375 is in use..."
if lsof -Pi :2375 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "   ✅ Port 2375 is in use (tunnel might be active)"
    lsof -Pi :2375 -sTCP:LISTEN
else
    echo "   ⚠️  Port 2375 is not in use (tunnel might not be active)"
fi

echo ""
echo "=========================================="
echo "📋 Summary and Solutions"
echo "=========================================="
echo ""
echo "If Docker is NOT listening on TCP port 2375, you have two options:"
echo ""
echo "Option 1: Enable Docker TCP access (requires Docker daemon restart)"
echo "  See: docker-enable-tcp.sh"
echo ""
echo "Option 2: Use Docker SSH context (recommended, no daemon restart)"
echo "  See: docker-ssh-context.sh"
echo ""

