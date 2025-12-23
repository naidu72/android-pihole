#!/bin/bash
# Enable Docker TCP Access on Linux Container
# WARNING: This requires Docker daemon restart and opens Docker to network access

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LINUX_USER="droid"

echo "⚠️  WARNING: This will enable Docker TCP access on port 2375"
echo "This opens Docker to network access. Only use on trusted networks!"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Setting up Docker TCP access..."

# Create or update daemon.json
DAEMON_JSON='{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}'

echo "Creating Docker daemon.json..."
ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh ${LINUX_USER}@${LINUX_CONTAINER} 'sudo mkdir -p /etc/docker && echo \"$DAEMON_JSON\" | sudo tee /etc/docker/daemon.json'" || {
    echo "❌ Failed to create daemon.json"
    exit 1
}

echo "✅ Docker daemon.json created"
echo ""
echo "⚠️  You need to restart Docker daemon for changes to take effect."
echo ""
echo "To restart Docker, run on Linux container:"
echo "  ssh ${ANDROID_USER}@${ANDROID_HOST}"
echo "  ssh ${LINUX_USER}@${LINUX_CONTAINER}"
echo "  sudo systemctl restart docker"
echo ""
echo "Or if using service:"
echo "  sudo service docker restart"
echo ""
echo "After restart, you can use:"
echo "  ./docker-tunnel-only.sh"
echo "  export DOCKER_HOST=tcp://localhost:2375"
echo "  docker ps"

