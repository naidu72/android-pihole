#!/bin/bash
# Docker SSH Context Setup
# This uses Docker's built-in SSH context feature (no TCP port needed)
# Recommended method - more secure and doesn't require Docker daemon restart

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LINUX_USER="droid"
CONTEXT_NAME="pi5-linux"

echo "Setting up Docker SSH context..."
echo "This uses Docker's SSH context feature (Docker 20.10+)"
echo ""

# Check Docker version supports SSH
echo "Checking Docker version..."
DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unknown")
echo "Docker version: $DOCKER_VERSION"
echo ""

# Create SSH config entry if not exists
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host pi5-linux-tunnel" "$SSH_CONFIG" 2>/dev/null; then
    echo "Adding SSH config entry..."
    cat >> "$SSH_CONFIG" << EOF

# Pi5 Linux Container via Android Host
Host pi5-linux-tunnel
    HostName ${ANDROID_HOST}
    User ${ANDROID_USER}
    ProxyCommand ssh -W ${LINUX_CONTAINER}:22 %h

Host pi5-linux-direct
    HostName ${LINUX_CONTAINER}
    User ${LINUX_USER}
    ProxyJump ${ANDROID_USER}@${ANDROID_HOST}
EOF
    echo "✅ SSH config updated"
else
    echo "✅ SSH config already exists"
fi

# Create Docker context
echo ""
echo "Creating Docker context: $CONTEXT_NAME"
docker context create $CONTEXT_NAME \
    --docker "host=ssh://${LINUX_USER}@pi5-linux-direct" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Docker context created: $CONTEXT_NAME"
elif docker context ls | grep -q "$CONTEXT_NAME"; then
    echo "✅ Docker context already exists: $CONTEXT_NAME"
else
    echo "❌ Failed to create Docker context"
    echo ""
    echo "Trying alternative method with direct SSH..."
    docker context create $CONTEXT_NAME \
        --docker "host=ssh://${LINUX_USER}@${LINUX_CONTAINER}" \
        --description "Pi5 Linux Container via SSH tunnel" 2>/dev/null || {
        echo "❌ Failed. Make sure Docker supports SSH contexts (Docker 20.10+)"
        exit 1
    }
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Usage:"
echo "  docker context use $CONTEXT_NAME"
echo "  docker ps"
echo "  docker images"
echo ""
echo "To switch back to default:"
echo "  docker context use default"
echo ""
echo "To list contexts:"
echo "  docker context ls"

