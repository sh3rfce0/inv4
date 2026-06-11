#!/bin/bash

# Configuration
API_DIR="/root/izin-api"
SERVICE_FILE="/etc/systemd/system/izin-api.service"
WORKSPACE_DIR="/root/v4/new-izin-api"
PORT="${PORT:-7888}"

echo "Setting up IZIN API..."

# Create directory
mkdir -p "$API_DIR"

# Copy files while preserving existing IP database
if [ -f "$API_DIR/ip" ]; then
    cp "$API_DIR/ip" /tmp/ip_backup
fi
cp -r "$WORKSPACE_DIR"/* "$API_DIR/"
if [ -f /tmp/ip_backup ]; then
    mv /tmp/ip_backup "$API_DIR/ip"
fi

# Install dependencies
cd "$API_DIR"
npm install --omit=dev

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
Environment=PORT=$PORT

[Install]
WantedBy=multi-user.target
EOF

# Reload and start service
systemctl daemon-reload
systemctl enable izin-api
systemctl restart izin-api

echo "IZIN API is now running on port $PORT"
echo "You can manage IPs at http://$(curl -s ipv4.icanhazip.com):$PORT"
