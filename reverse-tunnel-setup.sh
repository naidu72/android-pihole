#!/bin/bash
# Reverse SSH Tunnel Setup
# This allows external access to your Linux container through a jump server
# 
# Run this script ON the Linux container (10.214.236.233) or Android host
# to create a reverse tunnel to an external server

# Configuration
EXTERNAL_SERVER="your-external-server.com"  # Change this to your external server
EXTERNAL_USER="your-username"                # Change this
EXTERNAL_PORT="2222"                         # Port on external server
LOCAL_PORT="22"                              # SSH port on Linux container
LINUX_CONTAINER="10.214.236.233"

echo "Setting up reverse SSH tunnel..."
echo "This will forward external server port ${EXTERNAL_PORT} to local port ${LOCAL_PORT}"
echo ""

# Option 1: Run from Linux container directly
# ssh -R ${EXTERNAL_PORT}:localhost:${LOCAL_PORT} -N -f ${EXTERNAL_USER}@${EXTERNAL_SERVER}

# Option 2: Run from Android host, forwarding to Linux container
# ssh -R ${EXTERNAL_PORT}:${LINUX_CONTAINER}:${LOCAL_PORT} -N -f ${EXTERNAL_USER}@${EXTERNAL_SERVER}

# Option 3: Using autossh for persistent connection (recommended)
# First install autossh: apt-get install autossh (on Android or Linux container)
# autossh -M 20000 -R ${EXTERNAL_PORT}:${LINUX_CONTAINER}:${LOCAL_PORT} -N -f ${EXTERNAL_USER}@${EXTERNAL_SERVER}

echo "⚠️  Please update EXTERNAL_SERVER and EXTERNAL_USER variables first!"
echo ""
echo "After setup, connect from external server using:"
echo "  ssh -p ${EXTERNAL_PORT} droid@localhost"
echo ""
echo "Or from anywhere:"
echo "  ssh -p ${EXTERNAL_PORT} droid@${EXTERNAL_SERVER}"

