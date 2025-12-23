#!/bin/bash
# Docker Port Forwarding Script
# Forwards Docker daemon port to access Docker services on Linux container
#
# Note: Pi-hole is running on private network (192.168.0.0/24)
#   - Accessible locally at: http://192.168.0.151 (or http://10.214.236.233)
#   - Devices on 192.168.0.0/24 can use it as DNS to block ads
#   - No tunneling needed for local network devices

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"

echo "Setting up Docker port forward..."
echo ""

# Docker daemon port (if exposed)
echo "Forwarding Docker daemon (2375)..."
ssh -L 2375:${LINUX_CONTAINER}:2375 -N -f ${ANDROID_USER}@${ANDROID_HOST} &
DOCKER_PID=$!

# Save PID for cleanup
echo $DOCKER_PID > /tmp/docker-tunnel.pid

echo "✅ Docker port forwarding established!"
echo ""
echo "Access Docker:"
echo "  export DOCKER_HOST=tcp://localhost:2375"
echo "  docker ps"
echo ""
echo "Pi-hole (already working on local network):"
echo "  Web Interface: http://192.168.0.151 (or http://10.214.236.233)"
echo "  DNS Server: 192.168.0.151 (configure on devices in 192.168.0.0/24)"
echo ""
echo "To stop Docker tunnel:"
echo "  kill \$(cat /tmp/docker-tunnel.pid)"

