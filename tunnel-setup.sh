#!/bin/bash
# SSH Tunnel Setup Script for Raspberry Pi 5 Android -> Linux Development Environment
# 
# This script sets up SSH tunneling to access the Linux container (10.214.236.233)
# through the Android host (192.168.0.151)

# Configuration
ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LINUX_USER="droid"
LOCAL_PORT="2222"  # Local port to forward to
REMOTE_PORT="22"   # SSH port on Linux container

echo "Setting up SSH tunnel..."
echo "Android Host: ${ANDROID_USER}@${ANDROID_HOST}"
echo "Linux Container: ${LINUX_USER}@${LINUX_CONTAINER}"
echo "Local Port: ${LOCAL_PORT} -> Remote Port: ${REMOTE_PORT}"
echo ""

# Method 1: Direct tunnel through Android host
# This creates a tunnel: localhost:2222 -> Android -> Linux container:22
#ssh -L 2222:10.214.236.233:22 -N -f root@192.168.0.151
ssh -L ${LOCAL_PORT}:${LINUX_CONTAINER}:${REMOTE_PORT} \
    -N -f \
    ${ANDROID_USER}@${ANDROID_HOST}

if [ $? -eq 0 ]; then
    echo "✅ Tunnel established successfully!"
    echo "You can now connect to Linux container using:"
    echo "  ssh -p ${LOCAL_PORT} ${LINUX_USER}@localhost"
    echo ""
    echo "Note: Pi-hole is running on private network (192.168.0.0/24)"
    echo "  - Accessible locally at: http://192.168.0.151 (or http://10.214.236.233 if in container)"
    echo "  - Devices on 192.168.0.0/24 can use it as DNS to block ads"
    echo ""
    echo "To access Docker services, use additional port forward:"
    echo "  Docker daemon (2375): ssh -L 2375:${LINUX_CONTAINER}:2375 -N -f ${ANDROID_USER}@${ANDROID_HOST}"
    echo ""
    echo "To stop the tunnel, find the process: ps aux | grep ssh"
    echo "Then kill it: kill <PID>"
else
    echo "❌ Failed to establish tunnel. Check your SSH connection."
    exit 1
fi

