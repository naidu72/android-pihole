#!/bin/bash
# Pi-hole Port Forwarding Script
# Forwards Pi-hole web interface from Linux container to local machine

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LOCAL_PORT="8080"
REMOTE_PORT="80"  # Pi-hole default web port

echo "Setting up Pi-hole port forwarding..."
echo "Android Host: ${ANDROID_USER}@${ANDROID_HOST}"
echo "Linux Container: ${LINUX_CONTAINER}"
echo "Local Port: ${LOCAL_PORT} -> Remote Port: ${REMOTE_PORT}"
echo ""

# Check if port is already in use
if lsof -Pi :${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port ${LOCAL_PORT} is already in use"
    echo "Killing existing process..."
    kill $(lsof -t -i:${LOCAL_PORT}) 2>/dev/null
    sleep 1
fi

# Forward Pi-hole web interface port
echo "Creating port forward..."
ssh -L ${LOCAL_PORT}:${LINUX_CONTAINER}:${REMOTE_PORT} \
    -N -f \
    ${ANDROID_USER}@${ANDROID_HOST}

if [ $? -eq 0 ]; then
    echo "✅ Pi-hole port forwarding established!"
    echo ""
    echo "Access Pi-hole web interface at:"
    echo "  http://localhost:${LOCAL_PORT}/admin/login"
    echo ""
    echo "Or:"
    echo "  http://127.0.0.1:${LOCAL_PORT}/admin/login"
    echo ""
    echo "Default credentials (if not changed):"
    echo "  No username required"
    echo "  Password: Check your Pi-hole setup"
    echo ""
    echo "To stop the tunnel:"
    echo "  ps aux | grep '${LOCAL_PORT}:${LINUX_CONTAINER}' | grep -v grep | awk '{print \$2}' | xargs kill"
    echo ""
    echo "Or:"
    echo "  kill \$(lsof -t -i:${LOCAL_PORT})"
else
    echo "❌ Failed to establish port forward. Check your SSH connection."
    exit 1
fi

