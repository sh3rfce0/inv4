# Sherif VPN SiCepat V4

**Final Script Tunneling by Sherif VPN SiCepat**

## Description

Sherif VPN SiCepat V4 is a comprehensive tunneling script designed for setting up and managing VPN services, SSL certificates, UDP configurations, and backups. This script provides tools for various tunneling protocols including OpenVPN, Xray, Shadowsocks, Trojan, VLESS, VMess, and more.

## Features

- **SSL Certificate Fix**: Universal SSL certificate management and fixes.
- **UDP Configuration**: Tools for UDP tunneling and optimization.
- **Backup and Restore**: Universal backup and restore functionality for configurations.
- **VPN Services**: Support for multiple VPN protocols:
  - OpenVPN
  - Xray (VLESS, VMess, Trojan)
  - Shadowsocks
  - WebSocket (WS)
  - DNS over HTTPS (DoH)
  - SlowDNS
- **Bot Integration**: Automated bot scripts for management.
- **Configuration Management**: Easy setup for services like HAProxy, Nginx, Dropbear, and more.
- **Monitoring and Limits**: Built-in tools for speed testing, quota management, and IP limiting.
- **Webmin Menu**: Administrative interface for server management.

## Installation

### Custom OS UBUNTU 20.04
```bash
apt update -y && wget https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh -O reinstall && chmod +x reinstall && bash reinstall ubuntu 20.04 && reboot
```

### Install Script (Self-Hosted)
Ganti `<IP-SERVER-LISENSI>` dengan IP Server Lisensi Anda (port `7888`):
```bash
apt update -y && apt install screen curl wget -y && wget -q http://<IP-SERVER-LISENSI>:7888/install -O /tmp/install && chmod +x /tmp/install && bash /tmp/install
```

### Update Script
```bash
wget -O update.sh http://<IP-SERVER-LISENSI>:7888/update && chmod +x update.sh && ./update.sh
```

### Fix Izin
```bash
wget -O fix-izin.sh http://<IP-SERVER-LISENSI>:7888/fix-izin && chmod +x fix-izin.sh && ./fix-izin.sh        
```

### Fix SSL Certificate Universal
```bash
wget -O fix-add-ssl.sh http://<IP-SERVER-LISENSI>:7888/scripts/fix-add-ssl.sh && chmod +x fix-add-ssl.sh && ./fix-add-ssl.sh
```

### Fix UDP
```bash
wget -O udp.sh http://<IP-SERVER-LISENSI>:7888/scripts/udp.sh && chmod +x udp.sh && ./udp.sh
```

### Backup Universal
```bash
wget -O restore-universal.sh http://<IP-SERVER-LISENSI>:7888/scripts/Cdy/restore-universal.sh && chmod +x restore-universal.sh && ./restore-universal.sh
```

## Supported Services

- OpenVPN
- Xray (VLESS, VMess, Trojan)
- Shadowsocks
- WebSocket
- DNS Tunneling (DNSTT)
- UDP HC
- HAProxy
- Nginx
- Dropbear
- SSH
- Webmin

## Terms of Service

- **NO SPAM**
- **NO DDOS**
- **NO HACKING AND CARDING**
- **NO TORRENT**
- **NO MULTI LOGIN**

Violations may result in service termination.

---

**Sherif VPN SiCepat V4**
