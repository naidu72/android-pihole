#!/bin/bash
# Docker-only Port Forwarding Script
# Simple script to forward Docker daemon port for remote access

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LOCAL_DOCKER_PORT="2375"

echo "Setting up Docker port forward..."
echo "Android Host: ${ANDROID_USER}@${ANDROID_HOST}"
echo "Linux Container: ${LINUX_CONTAINER}"
echo "Local Port: ${LOCAL_DOCKER_PORT}"
echo ""

# Check if port is already in use
if lsof -Pi :${LOCAL_DOCKER_PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Port ${LOCAL_DOCKER_PORT} is already in use"
    echo "Killing existing process..."
    kill $(lsof -t -i:${LOCAL_DOCKER_PORT}) 2>/dev/null
    sleep 1
fi

# Forward Docker daemon port
ssh -L ${LOCAL_DOCKER_PORT}:${LINUX_CONTAINER}:${LOCAL_DOCKER_PORT} \
    -N -f \
    ${ANDROID_USER}@${ANDROID_HOST}

if [ $? -eq 0 ]; then
    echo "✅ Docker port forwarding established!"
    echo ""
    echo "Usage:"
    echo "  export DOCKER_HOST=tcp://localhost:${LOCAL_DOCKER_PORT}"
    echo "  docker ps"
    echo "  docker images"
    echo ""
    echo "Or use with docker-compose:"
    echo "  DOCKER_HOST=tcp://localhost:${LOCAL_DOCKER_PORT} docker-compose up"
    echo ""
    echo "To stop:"
    echo "  ps aux | grep '${LOCAL_DOCKER_PORT}:${LINUX_CONTAINER}' | grep -v grep | awk '{print \$2}' | xargs kill"
else
    echo "❌ Failed to establish Docker tunnel. Check your SSH connection."
    exit 1
fi

