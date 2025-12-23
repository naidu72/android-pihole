#!/bin/bash
# Docker Socket Forwarding via SSH
# Forwards Docker socket through SSH (most compatible method)

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LINUX_USER="droid"
SOCKET_PATH="$HOME/.docker-pi5.sock"

echo "Setting up Docker socket forwarding..."
echo "This forwards Docker socket through SSH"
echo ""

# Kill existing socket forward if any
if [ -S "$SOCKET_PATH" ]; then
    echo "Removing existing socket..."
    rm -f "$SOCKET_PATH"
fi

# Create SSH tunnel for Docker socket
echo "Creating SSH tunnel for Docker socket..."
ssh -N -f -L "$SOCKET_PATH:/var/run/docker.sock" \
    ${ANDROID_USER}@${ANDROID_HOST} \
    -o "ProxyCommand ssh -W ${LINUX_CONTAINER}:22 %h" \
    -o "LocalCommand ssh ${LINUX_USER}@${LINUX_CONTAINER} 'echo Socket ready'" 2>/dev/null

# Alternative: Direct socket forwarding through Android host
echo "Setting up socket forwarding through Android host..."
ssh -N -f \
    -L "$SOCKET_PATH:/var/run/docker.sock" \
    ${ANDROID_USER}@${ANDROID_HOST} \
    ssh ${LINUX_USER}@${LINUX_CONTAINER} "socat TCP-LISTEN:2376,fork,reuseaddr UNIX-CONNECT:/var/run/docker.sock" &

# Wait a moment
sleep 2

if [ -S "$SOCKET_PATH" ]; then
    echo "✅ Docker socket forwarding established!"
    echo ""
    echo "Usage:"
    echo "  export DOCKER_HOST=unix://$SOCKET_PATH"
    echo "  docker ps"
    echo "  docker images"
    echo ""
    echo "To stop:"
    echo "  rm -f $SOCKET_PATH"
    echo "  pkill -f 'docker.sock'"
else
    echo "⚠️  Socket forwarding may require socat on Linux container"
    echo ""
    echo "Alternative: Use Docker SSH context instead"
    echo "  ./docker-ssh-context.sh"
fi

