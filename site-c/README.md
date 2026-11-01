# Site C: separate media-company network

A standalone network, unrelated to the Site A <-> Site B WireGuard link. I oversee it, implemented
the owner's design, and give recommendations.

- **3 ISPs (2 × 1 Gbps + 500 Mbps, 2.5 Gbps total)** terminating on a FortiGate.
- **SD-WAN:** policy-based steering of user groups across the 3 ISPs with automatic link failover
  (owner's design, implemented and maintained by me).
- Firewall policies, NAT and port forwarding, a second LAN segment, SSL-VPN remote access.
- Virtualization host built on VMware ESXi, later rebuilt on Proxmox VE.

Sanitized config excerpt: [`site-c-fortigate-sdwan.conf`](site-c-fortigate-sdwan.conf)
