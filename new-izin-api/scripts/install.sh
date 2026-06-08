#!/bin/bash
# Clean Optimized Installer by Sherif
start=$(date +%s)
IP=$(curl -s ipv4.icanhazip.com)
REPO="http://64.235.61.22/scripts/"

# 1. Permission Check
echo "Checking Permission..."
wget -q -O /tmp/iplist.txt http://64.235.61.22/ip
if ! grep -q "$IP" /tmp/iplist.txt; then
    echo -e "\e[31m❌ IP NOT AUTHORIZED\e[0m"
    exit 1
fi
echo -e "\e[32m✅ PERMISSION GRANTED\e[0m"

# 2. Update & Basic Tools
apt update -y
apt install -y jq curl wget zip unzip git python3

# 3. Download and Install Menu
echo "Installing Menu..."
wget -q -O /tmp/menu.zip "${REPO}Cdy/menu.zip"
unzip -o /tmp/menu.zip -d /tmp/
chmod +x /tmp/menu/*
mv /tmp/menu/* /usr/bin/
rm -rf /tmp/menu /tmp/menu.zip

# 4. Download and Install Core Scripts
echo "Installing Core Scripts..."
wget -q -O /usr/bin/update.sh "${REPO}update.sh" && chmod +x /usr/bin/update.sh
wget -q -O /usr/bin/fix-izin.sh "${REPO}fix-izin.sh" && chmod +x /usr/bin/fix-izin.sh

# 5. Success
clear
echo "=========================="
echo "      INSTALL SUCCESS     "
echo "=========================="
echo "Type 'menu' to start."
