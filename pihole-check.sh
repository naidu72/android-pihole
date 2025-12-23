#!/bin/bash
# Pi-hole Status Check and Port Forwarding Setup

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
LINUX_USER="droid"
LOCAL_PORT="8080"

echo "🔍 Pi-hole Status Check"
echo "======================"
echo ""

# Check 1: Test SSH connection
echo "1. Testing SSH connections..."
if ssh -o ConnectTimeout=5 ${ANDROID_USER}@${ANDROID_HOST} "echo 'Connected'" 2>/dev/null; then
    echo "   ✅ SSH to Android host works"
else
    echo "   ❌ Cannot connect to Android host"
    exit 1
fi

# Check 2: Check if Pi-hole is running on Linux container
echo ""
echo "2. Checking Pi-hole status on Linux container..."
PIHOLE_STATUS=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh ${LINUX_USER}@${LINUX_CONTAINER} 'docker ps --filter name=pihole --format \"{{.Status}}\" 2>/dev/null || systemctl is-active pihole-FTL 2>/dev/null || echo \"not found\"'" 2>/dev/null)

if [ -n "$PIHOLE_STATUS" ] && [ "$PIHOLE_STATUS" != "not found" ]; then
    echo "   ✅ Pi-hole is running"
    echo "   Status: $PIHOLE_STATUS"
else
    echo "   ❌ Pi-hole is not running or not found"
    echo ""
    echo "   Checking Docker containers..."
    ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh ${LINUX_USER}@${LINUX_CONTAINER} 'docker ps -a | grep -i pihole || echo \"No Pi-hole containers found\"'"
fi

# Check 3: Check what ports Pi-hole is using
echo ""
echo "3. Checking Pi-hole ports..."
PIHOLE_PORTS=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh ${LINUX_USER}@${LINUX_CONTAINER} 'docker ps --filter name=pihole --format \"{{.Ports}}\" 2>/dev/null || netstat -tuln 2>/dev/null | grep -E \"(80|53|8080)\" || ss -tuln 2>/dev/null | grep -E \"(80|53|8080)\"'" 2>/dev/null)
if [ -n "$PIHOLE_PORTS" ]; then
    echo "   Pi-hole ports:"
    echo "   $PIHOLE_PORTS"
else
    echo "   ⚠️  Could not determine Pi-hole ports"
fi

# Check 4: Check if port 8080 is already forwarded
echo ""
echo "4. Checking if port forwarding is active..."
if lsof -Pi :${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "   ✅ Port ${LOCAL_PORT} is already forwarded"
    lsof -Pi :${LOCAL_PORT} -sTCP:LISTEN
else
    echo "   ⚠️  Port ${LOCAL_PORT} is not forwarded"
fi

# Check 5: Test direct access to Linux container
echo ""
echo "5. Testing direct access to Linux container port 80..."
HTTP_TEST=$(ssh ${ANDROID_USER}@${ANDROID_HOST} "ssh ${LINUX_USER}@${LINUX_CONTAINER} 'curl -s -o /dev/null -w \"%{http_code}\" http://localhost/admin/login 2>/dev/null || curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1/admin/login 2>/dev/null || echo \"failed\"'" 2>/dev/null)
if [ "$HTTP_TEST" = "200" ] || [ "$HTTP_TEST" = "301" ] || [ "$HTTP_TEST" = "302" ]; then
    echo "   ✅ Pi-hole web interface is accessible on Linux container"
    echo "   HTTP Status: $HTTP_TEST"
else
    echo "   ⚠️  Could not access Pi-hole web interface on Linux container"
    echo "   HTTP Status: $HTTP_TEST"
fi

echo ""
echo "=========================================="
echo "📋 Summary"
echo "=========================================="
echo ""
echo "Pi-hole is running on Linux container: ${LINUX_CONTAINER}"
echo "To access from your local machine, you need port forwarding."
echo ""
echo "Run: ./pihole-forward.sh"
echo ""

