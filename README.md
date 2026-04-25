# 🏠 Homelab Network Infrastructure

Multi-site production network I design, build, and operate.
Built on MikroTik RouterOS 7, WireGuard, Pi-hole, TrueNAS, and Linux.

---

## 🗺️ Network Overview

| Site | Device | Role |
|------|--------|------|
| Home | MikroTik RB760iGS | Core router, WireGuard server, QoS |
| Work | MikroTik RB2011 | Branch router, WireGuard client |
| Home | Raspberry Pi | Pi-hole DNS |
| Home | TrueNAS | NAS, SMB shares, n8n automation |
| Home | Linux Server | SSH, game server, Docker |
| Home | Windows Server | RDP, Active Directory |
| Cloud | DigitalOcean VPS | WireGuard exit node, VPN gateway |

---

## 🔧 Key Features

### WireGuard VPN Mesh
- Site-to-site tunnel between Home and Work on port 443
- Multiple peer support: mobile, laptop, inter-site
- Routes: 192.168.88.0/24 (home LAN), 192.168.2.0/24 (work LAN), 192.168.100.0/24 (VPN mesh)

### Automated DNS Failover
- Pi-hole as primary DNS for all clients
- MikroTik Netwatch monitors Pi-hole every 30s
- On failure: NAT rules auto-update, DNS falls back to 8.8.8.8, Telegram alert fires
- On recovery: everything reverts automatically, zero manual intervention

### Application-Aware QoS
- fq-CoDel queuing on WAN interface (470 Mbps shaped)
- CS2/Steam game traffic marked and prioritized
- Per-device bandwidth control

### Infrastructure Monitoring & Alerting
- Telegram bot receives alerts for: VPN up/down, server up/down, Pi-hole status, router reboots
- Reboot script reports router name, uptime, and public IP on startup
- Log filtering script sends error/warning digest via Telegram

### DNS Security Enforcement
- All clients DNS-intercepted via NAT rules
- Non-whitelisted devices redirected to Pi-hole
- Prevents DNS bypass attempts

### Automated Backups
- Daily config export (.rsc) and binary backup (.backup)
- Emailed automatically via scheduled script
- Both routers covered

---

## 📁 Repository Structure

- /configs — Sanitized router configuration exports
- /scripts — RouterOS automation scripts
- /diagrams — Network topology diagrams

---

## 🛠️ Technologies Used

MikroTik RouterOS 7 · WireGuard · Pi-hole · TrueNAS ·
n8n · Fortinet · OpenVPN · VMware ESXi · Linux · Windows Server ·
Telegram Bot API · fq-CoDel QoS · L2TP/IPSec · DDNS
