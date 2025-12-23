#!/bin/bash
# Pi-hole Complete Port Forwarding
# Forwards all Pi-hole ports: web (80), DNS (53), and admin

ANDROID_HOST="192.168.0.151"
ANDROID_USER="root"
LINUX_CONTAINER="10.214.236.233"
WEB_PORT="8080"
DNS_PORT="5353"  # Using 5353 instead of 53 (requires root)

echo "Setting up complete Pi-hole port forwarding..."
echo ""

# Web interface (port 80 -> 8080)
echo "Forwarding Pi-hole web interface (80 -> ${WEB_PORT})..."
ssh -L ${WEB_PORT}:${LINUX_CONTAINER}:80 -N -f ${ANDROID_USER}@${ANDROID_HOST} &
WEB_PID=$!
echo $WEB_PID > /tmp/pihole-web-tunnel.pid

# DNS port (53 -> 5353, requires root for port 53)
echo "Forwarding Pi-hole DNS (53 -> ${DNS_PORT})..."
sudo ssh -L ${DNS_PORT}:${LINUX_CONTAINER}:53 -N -f ${ANDROID_USER}@${ANDROID_HOST} &
DNS_PID=$!
echo $DNS_PID > /tmp/pihole-dns-tunnel.pid

sleep 1

echo "✅ Pi-hole port forwarding established!"
echo ""
echo "Access Pi-hole:"
echo "  Web Interface: http://localhost:${WEB_PORT}/admin/login"
echo "  DNS Server: localhost:${DNS_PORT} (for testing)"
echo ""
echo "Note: For local network devices, use ${ANDROID_HOST} as DNS server"
echo "      (no port forwarding needed for devices on 192.168.0.0/24)"
echo ""
echo "To stop tunnels:"
echo "  kill \$(cat /tmp/pihole-web-tunnel.pid)"
echo "  sudo kill \$(cat /tmp/pihole-dns-tunnel.pid)"

