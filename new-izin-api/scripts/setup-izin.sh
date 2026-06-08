#!/bin/bash

# Configuration
API_DIR="/root/izin-api"
SERVICE_FILE="/etc/systemd/system/izin-api.service"
WORKSPACE_DIR="/root/v4/new-izin-api"

echo "Setting up IZIN API..."

# Create directory
mkdir -p "$API_DIR"

# Copy files
cp -r "$WORKSPACE_DIR"/* "$API_DIR/"

# Install dependencies
cd "$API_DIR"
npm install express body-parser

# Create systemd service
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=IZIN API Service
After=network.target

[Service]
ExecStart=/usr/bin/node $API_DIR/server.js
Restart=always
User=root
WorkingDirectory=$API_DIR

[Install]
WantedBy=multi-user.target
EOF

# Reload and start service
systemctl daemon-reload
systemctl enable izin-api
systemctl restart izin-api

echo "IZIN API is now running on port 8888"
echo "You can manage IPs at http://$(curl -s ipv4.icanhazip.com):8080"
