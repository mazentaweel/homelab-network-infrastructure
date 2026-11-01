# RouterOS 7 export (sanitized)
# software id = <REDACTED>
#
# model = <ROUTER_MODEL>
# serial number = <REDACTED>
# [/ip firewall nat] 10 inbound port-forward (dst-nat) rules removed for publication.
/interface bridge
add admin-mac=<MAC> arp=reply-only auto-mac=no comment=defconf name=bridge
/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1 max-mtu=1492 name=WAN-Fiber user=<EMAIL>
/interface wireguard
add listen-port=<WG_PORT> mtu=1420 name=WG-SiteA
# [/disk] storage settings removed for publication
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip pool
add name=default-dhcp ranges=10.0.10.10-10.0.10.254
/ip dhcp-server
add address-pool=default-dhcp interface=bridge lease-script="/system script run vendor-tag-lease" lease-time=1d name=defconf
/queue simple
add disabled=yes name=queue1 packet-marks=no-mark priority=1/1 target=10.0.10.100/32
add name=css-Priority packet-marks=css-packet priority=1/1 target=10.0.10.100/32
/queue tree
add comment="Total WAN upload shaper" max-limit=480M name=WAN-upload packet-mark=no-mark parent=global
add comment="Total WAN download shaper" max-limit=480M name=WAN-download parent=WAN-Fiber
/queue type
add kind=fq-codel name=fq_codel_up
add kind=fq-codel name=fq_codel_down
add kind=fq-codel name=fq-codel-wg
/queue simple
add disabled=yes max-limit=470M/470M name=WAN-fq-codel queue=fq_codel_up/fq_codel_down target=""
/queue tree
add comment="WireGuard VPN  highest priority" limit-at=50M max-limit=480M name=WG-priority packet-mark=wg-tunnel parent=WAN-upload priority=1 queue=fq-codel-wg
add comment="General traffic  lower priority" limit-at=50M max-limit=480M name=bulk-traffic packet-mark=no-mark parent=WAN-upload queue=fq_codel_up
add comment="WireGuard tunnel guaranteed download" limit-at=50M max-limit=480M name=WG-tunnel-down packet-mark=wg-tunnel-down parent=WAN-download priority=1 queue=fq-codel-wg
add comment="General download best effort" limit-at=10M max-limit=480M name=general-download packet-mark=general-down parent=WAN-download queue=fq_codel_down
add comment=QoS-realtime-up limit-at=30M max-limit=480M name=realtime-up packet-mark=qos-rt parent=WAN-upload priority=1 queue=fq_codel_up
/system logging action
add name=wazuhlog remote=10.0.10.47 target=remote
/system script
add dont-require-permissions=yes name=SiteB-Router-UP owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-siteb\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-siteb\"] } on-error={}\r\n/system scheduler add name=\"nw-up-siteb\" start-time=([/system clock get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-siteb-up\""
add dont-require-permissions=yes name=SiteB-Router-Down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-siteb\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-siteb\"] } on-error={}\r\n/system scheduler add name=\"nw-down-siteb\" start-time=([/system clock get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-siteb-down\""
add dont-require-permissions=yes name=server-test-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-appsrv\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-appsrv\"] } on-error={}\r\n/system scheduler add name=\"nw-up-appsrv\" start-time=([/system clock get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-appsrv-up\""
add dont-require-permissions=yes name=server-test-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-appsrv\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-appsrv\"] } on-error={}\r\n/system scheduler add name=\"nw-down-appsrv\" start-time=([/system clock\_get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-appsrv-down\""
add dont-require-permissions=yes name=pihole-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-pihole\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-pihole\"] } on-error={}\r\n/system scheduler add name=\"nw-down-pihole\" start-time=([/system clock\_get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-pihole-down\""
add dont-require-permissions=yes name=pihole-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-pihole\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-pihole\"] } on-error={}\r\n/system scheduler add name=\"nw-up-pihole\" start-time=([/system clock get time] + 00:00:30) interval=0 on-event=\"/system script run confirm-pihole-up\""
add dont-require-permissions=yes name=backup-and-email owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#### Modify these values to match your requirements ####\n:local toemail \"<EMAIL>\"\n\n############## Script Logic ##############\n:local sysname [/system identity get name]\n:local time [/system clock get time]\n:local date [/system clock get date]\n\n# Format date to remove slashes\n:local newdate \"\"\n:for i from=0 to=([:len \$date]-1) do={ \n    :local tmp [:pick \$date \$i]\n    :if (\$tmp != \"/\" && \$tmp != \"-\") do={ :set newdate \"\$newdate\$tmp\" }\n}\n\n# Replace spaces in identity with underscores\n:local cleanName \"\"\n:for i from=0 to=([:len \$sysname]-1) do={ \n    :local tmp [:pick \$sysname \$i]\n    :if (\$tmp != \" \") do={ :set cleanName \"\$cleanName\$tmp\" } else={ :set cleanName \"\$cleanName_\" }\n}\n:set sysname \$cleanName\n\n:local textfilename \"\$newdate-\$sysname.rsc\"\n:local backupfilename \"\$newdate-\$sysname.backup\"\n\n# Generate files\n/export file=\$textfilename\n/system backup save name=\$backupfilename\n\n# Dynamic wait until backup files physically populate local storage\n:local timeout 0\n:while ([/file find name=\$backupfilename] = \"\" && \$timeout < 15) do={\n    :delay 1s\n    :set timeout (\$timeout + 1)\n}\n\n:log info \"Emailing backups...\"\n\n# FIX: Removed square brackets entirely to guarantee parser compatibility\n:local rscSubject (\"Config Backup RSC - \" . \$sysname . \" \" . \$time)\n:local binSubject (\"Config Backup BIN - \" . \$sysname . \" \" . \$time)\n\n# First Email (.rsc)\n/tool e-mail send to=\$toemail subject=\$rscSubject file=\$textfilename\n:delay 5s\n\n# Second Email (.backup)\n/tool e-mail send to=\$toemail subject=\$binSubject file=\$backupfilename\n\n# Allow 30 seconds for outbound transfer to finish before purging files\n:delay 30s\n\n# Clean files from local disk\n/file remove [find name=\$textfilename]\n/file remove [find name=\$backupfilename]\n:log info \"Backup script execution finished successfully.\"\n"
add dont-require-permissions=yes name=confirm-siteb-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"10.0.20.1\"] status] = \"down\") do={\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Site-B%20router%20VPN%20is%20Down\" keep-result=no\n}\n:do { /system scheduler remove [find name=\"nw-down-siteb\"] } on-error={}"
add dont-require-permissions=yes name=confirm-siteb-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"10.0.20.1\"] status] = \"up\") do={\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Site-B%20router%20VPN%20is%20UP\" keep-result=no\n}\n:do { /system scheduler remove [find name=\"nw-up-siteb\"] } on-error={}"
add dont-require-permissions=yes name=confirm-appsrv-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"10.0.11.90\"] status] = \"down\") do={\r\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=App%20Server%20is%20Down\" keep-result=no\r\n}\r\n:do { /system scheduler remove [find name=\"nw-down-appsrv\"] } on-error={}"
add dont-require-permissions=yes name=confirm-appsrv-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"10.0.11.90\"] status] = \"up\") do={\r\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=App%20Server%20is%20UP\" keep-result=no\r\n}\r\n:do { /system scheduler remove [find name=\"nw-up-appsrv\"] } on-error={}"
add dont-require-permissions=yes name=confirm-pihole-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"fb.com\"] status] = \"down\") do={\n/ip dns set servers=8.8.8.8\n/ip firewall nat set [find comment~\"DNS-redirect-Pihole\"] to-addresses=8.8.8.8\n/ip dns cache flush\n/tool wol mac=<MAC> interface=bridge\n/tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=PiHole%20is%20Down\" keep-result=no\n}\n:do { /system scheduler remove [find name=\"nw-down-pihole\"] } on-error={}"
add dont-require-permissions=yes name=confirm-pihole-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/tool netwatch get [find host=\"fb.com\"] status] = \"up\") do={\n/ip dns set servers=10.0.11.13,8.8.8.8\n/ip firewall nat set [find comment~\"DNS-redirect-Pihole\"] to-addresses=10.0.11.13\n/ip dns cache flush\n/tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=PiHole%20is%20Up\"\_keep-result=no\n}\n:do { /system scheduler remove [find name=\"nw-up-pihole\"] } on-error={}"
add dont-require-permissions=no name=vendor-tag-lease owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="\r\n  :if (\$leaseBound=1) do={\r\n    :local mac \$leaseActMAC\r\n    :local ip \$leaseActIP\r\n    :local lease [/ip dhcp-server lease find mac-address=\$mac]\r\n    :if ([:len \$lease] > 0) do={\r\n      :local cmt [/ip dhcp-server lease get \$lease comment]\r\n      :if (\$cmt = \"\") do={\r\n        :local vendor \"unknown vendor\"\r\n        :do {\r\n          :local result [/tool fetch url=\"https://api.macvendors.com/\$mac\" as-value output=user check-certificate=yes]\r\n          :set vendor (\$result->\"data\")\r\n        } on-error={\r\n          :set vendor \"vendor lookup failed\"\r\n        }\r\n        /ip dhcp-server lease set \$lease comment=\$vendor\r\n        :local body \"{\\\"chat_id\\\":\\\"<TELEGRAM_CHAT_ID>\\\",\\\"text\\\":\\\"New device auto-tagged on MikroTik\\\\nMAC: \$mac\\\\nVendor: \$vendor\\\\nIP: \$ip\\\"}\"\r\n        :do {\r\n          /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\" http-method=post http-header-field=\"Content-Type: application/json\" http-data=\$body output=none check-certificate=yes\r\n        } on-error={}\r\n      }\r\n    }\r\n  }\r\n"
# [/disk settings] storage settings removed for publication
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
add bridge=bridge comment=defconf interface=sfp1
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=WAN-Fiber list=WAN
add comment=defconf interface=WG-SiteA list=LAN
/interface wireguard peers
add allowed-address="10.99.0.3/32,10.0.20.0/24,10.0.11.0/24,10.0.253.0/24,10.0.10.0/24" interface=WG-SiteA name=Admin-Phone public-key="<WG_KEY>"
# allowed-address match other peers
add allowed-address="10.99.0.1/32,10.0.20.0/24,10.0.21.0/24,10.0.253.0/24,10.99.0.11/32" client-allowed-address=::/0 endpoint-address=<SITE_DDNS> endpoint-port=<WG_PORT_B> interface=WG-SiteA name=SiteA-To-SiteB persistent-keepalive=25s public-key="<WG_KEY>" responder=yes
# allowed-address match other peers
add allowed-address="10.99.0.4/32,10.0.10.0/24,10.0.11.0/24,10.0.20.0/24,10.0.253.0/24" interface=WG-SiteA name=Admin-Laptop public-key="<WG_KEY>"
add allowed-address=10.99.0.8/32 disabled=yes interface=WG-SiteA name=Peer-3 public-key="<WG_KEY>"
# allowed-address match other peers
add allowed-address=10.99.0.10/32,10.0.10.0/24 client-allowed-address=::/0 interface=WG-SiteA name=Peer-4 public-key="<WG_KEY>"
/ip address
add address=10.0.10.1/24 comment=defconf interface=bridge network=10.0.10.0
add address=10.0.11.1/24 interface=bridge network=10.0.11.0
add address=10.99.0.2/24 interface=WG-SiteA network=10.99.0.0
# [/ip arp] static ARP table (per-device MACs) removed for publication
/ip dhcp-client
add comment=defconf interface=ether1 name=client1
# [/ip dhcp-server lease] static DHCP leases (per-device MACs/names) removed for publication
/ip dhcp-server network
add address=10.0.11.0/24 dns-server=10.0.11.1 gateway=10.0.11.1 ntp-server=10.0.10.1
add address=10.0.10.0/24 comment=defconf dns-server=10.0.10.1 gateway=10.0.10.1
/ip dns
set allow-remote-requests=yes servers=10.0.11.13,8.8.8.8
/ip dns static
add address=10.0.11.13 name=pihole.lan type=A
add address=10.0.10.16 disabled=yes name=truenas.lan type=A
/ip firewall address-list
add address=10.0.10.35 list=Admin-Devices
add address=10.0.10.36 list=Admin-Devices
add address=10.0.10.37 list=Admin-Devices
add address=10.0.10.100 list=Admin-Devices
add address=10.0.10.101 list=Admin-Devices
add address=10.0.10.102 list=Admin-Devices
add address=10.0.10.26 list=Admin-Devices
add address=10.0.10.100 list=DNS
add address=10.0.10.19 disabled=yes list=DNS
add address=10.0.10.4 disabled=yes list=DNS
add address=10.0.10.0/24 list=mgmt
add address=10.0.11.0/24 list=mgmt
add address=10.0.20.0/24 list=mgmt
add address=10.0.30.0/24 list=mgmt
add address=10.0.10.3 disabled=yes list=DNS
add address=10.0.10.8 disabled=yes list=DNS
add address=10.0.11.90 list=DNS
add address=10.0.10.15 disabled=yes list=DNS
add address=10.0.10.248 disabled=yes list=DNS
add address=10.0.10.101 disabled=yes list=DNS
add address=10.0.10.44 disabled=yes list=DNS
add address=10.0.10.16 disabled=yes list=DNS
add address=10.0.11.13 list=DNS
add address=10.0.10.1 list=DNS
add address=10.99.0.3 list=DNS
add address=10.99.0.0/24 list=mgmt
add address=10.99.0.8 list=DNS
add address=10.0.11.1 list=DNS
add address=10.0.10.29 list=DNS
add address=10.0.11.123 list=DNS
add address=10.0.10.35 disabled=yes list=DNS
add address=1.1.1.1 comment=DoH-block list=DoH-Servers
add address=1.0.0.1 comment=DoH-block list=DoH-Servers
add address=162.159.36.1 comment=DoH-block list=DoH-Servers
add address=162.159.46.1 comment=DoH-block list=DoH-Servers
add address=8.8.8.8 comment=DoH-block list=DoH-Servers
add address=8.8.4.4 comment=DoH-block list=DoH-Servers
add address=9.9.9.9 comment=DoH-block list=DoH-Servers
add address=149.112.112.112 comment=DoH-block list=DoH-Servers
add address=94.140.14.14 comment=DoH-block list=DoH-Servers
add address=94.140.15.15 comment=DoH-block list=DoH-Servers
add address=45.90.28.0 comment=DoH-block list=DoH-Servers
add address=45.90.30.0 comment=DoH-block list=DoH-Servers
/ip firewall filter
add action=accept chain=forward comment=WG-OUT-FWD-ACCEPT out-interface=WG-SiteA
add action=accept chain=forward comment=WG-FWD-ACCEPT in-interface=WG-SiteA
add action=accept chain=forward comment=QoS-noFT-accept-before-fasttrack connection-mark=qos-no-ft
add action=fasttrack-connection chain=forward comment=FastTrack-active connection-state=established,related
add action=accept chain=forward comment="Allow established" connection-state=established,related
add action=drop chain=forward dst-address=!10.0.11.13 dst-port=53 protocol=tcp src-address=10.0.21.0/24
add action=drop chain=forward dst-address=!10.0.11.13 dst-port=53 protocol=udp src-address=10.0.21.0/24
add action=accept chain=input dst-port=<WG_PORT> protocol=udp
add action=accept chain=input src-address-list=mgmt
add action=drop chain=input comment="drop l2tp brute forcers" in-interface=WAN-Fiber src-address-list=l2tp_blacklist
add action=add-src-to-address-list address-list=l2tp_blacklist address-list-timeout=1d chain=input connection-state=new src-address-list=l2tp_stage6
add action=add-src-to-address-list address-list=l2tp_stage6 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage5
add action=add-src-to-address-list address-list=l2tp_stage5 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage4
add action=add-src-to-address-list address-list=l2tp_stage4 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage3
add action=add-src-to-address-list address-list=l2tp_stage3 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage2
add action=add-src-to-address-list address-list=l2tp_stage2 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage1
add action=add-src-to-address-list address-list=l2tp_stage1 address-list-timeout=1m chain=input connection-state=new src-address-list=!mgmt
add action=accept chain=forward comment="Allow LAN DNS forwarding to Pi-hole" dst-address=10.0.11.13 src-address=10.0.10.0/24
add action=accept chain=forward comment="Allow Pi-hole replies to LAN" dst-address=10.0.10.0/24 src-address=10.0.11.13
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1 in-interface=lo src-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment=defconf-drop-WAN-not-dstnat connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall mangle
add action=change-mss chain=forward comment="Clamp MSS" new-mss=clamp-to-pmtu protocol=tcp tcp-flags=syn
add action=mark-connection chain=forward dst-address=10.0.11.13 dst-port=27017 new-connection-mark=css protocol=tcp
add action=mark-connection chain=forward dst-address=10.0.11.13 dst-port=27017 new-connection-mark=css protocol=udp
add action=mark-packet chain=prerouting connection-mark=css new-packet-mark=css-packet
add action=mark-packet chain=output comment="WG tunnel out" dst-port=<WG_PORT> new-packet-mark=wg-tunnel protocol=udp
add action=mark-packet chain=prerouting comment="WG tunnel in" new-packet-mark=wg-tunnel protocol=udp src-port=<WG_PORT>
add action=change-dscp chain=forward comment="VoIP SIP+RTP  DSCP EF (highest)" dst-port=5060,5061,10000-20000 new-dscp=46 protocol=udp
add action=change-dscp chain=forward comment="RDP  DSCP AF41" dst-port=3389 new-dscp=34 protocol=tcp
add action=change-dscp chain=forward comment="SSH  DSCP AF21" dst-port=22 new-dscp=18 protocol=tcp
add action=change-dscp chain=output comment="WireGuard tunnel  DSCP CS5" dst-port=<WG_PORT> new-dscp=40 protocol=udp
add action=change-dscp chain=forward comment="CS2 game  DSCP AF41" dst-port=27000-27100 new-dscp=34 protocol=udp
add action=mark-packet chain=forward comment="WG tunnel inbound mark" in-interface=WAN-Fiber new-packet-mark=wg-tunnel-down protocol=udp src-port=<WG_PORT>
add action=mark-packet chain=forward comment="All other download" in-interface=WAN-Fiber new-packet-mark=general-down packet-mark=!wg-tunnel-down
add action=mark-connection chain=prerouting comment=QoS-noFT-UDP-realtime dst-port=3478-3480,4380,5060,5061,10000-20000,27000-27100 new-connection-mark=qos-no-ft protocol=udp
add action=mark-connection chain=prerouting comment=QoS-noFT-TCP-rdp-ssh dst-port=22,3389 new-connection-mark=qos-no-ft protocol=tcp
add action=mark-packet chain=prerouting comment=QoS-rt-packet connection-mark=qos-no-ft new-packet-mark=qos-rt
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN
add action=dst-nat chain=dstnat comment=DNS-redirect-Pihole-TCP dst-port=53 protocol=tcp socks5-port=1 socks5-server=0.0.0.0 src-address-list=!DNS to-addresses=10.0.11.13 to-ports=53
add action=dst-nat chain=dstnat comment=DNS-redirect-Pihole-UDP dst-port=53 protocol=udp src-address-list=!DNS to-addresses=10.0.11.13 to-ports=53
add action=dst-nat chain=dstnat disabled=yes dst-port=53 protocol=tcp src-address-list=DNS to-addresses=8.8.8.8 to-ports=53
add action=dst-nat chain=dstnat disabled=yes dst-port=53 protocol=udp src-address-list=DNS to-addresses=8.8.8.8 to-ports=53
add action=dst-nat chain=dstnat disabled=yes dst-port=53 log=yes protocol=udp src-address=10.0.11.13 to-addresses=8.8.8.8 to-ports=53
add action=dst-nat chain=dstnat disabled=yes dst-port=53 log=yes protocol=tcp src-address=10.0.11.13 to-addresses=8.8.8.8 to-ports=53
add chain=dstnat comment="Redirect DoT TCP to Pi-hole" dst-port=853 protocol=tcp to-addresses=10.0.11.13 to-ports=53
add chain=dstnat comment="Redirect DoT UDP to Pi-hole" dst-port=853 protocol=udp to-addresses=10.0.11.13 to-ports=53
add chain=dstnat comment="Redirect DoH to Pi-hole" dst-address-list=DoH-Servers dst-port=443 protocol=tcp to-addresses=10.0.11.13 to-ports=53
/ip route
add disabled=no distance=1 dst-address=10.0.253.0/24 gateway=WG-SiteA routing-table=main scope=10
add disabled=no distance=1 dst-address=10.0.20.0/24 gateway=WG-SiteA pref-src="" routing-table=main scope=10
add disabled=no distance=1 dst-address=10.0.21.0/24 gateway=WG-SiteA routing-table=main scope=10 target-scope=10
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set www-ssl certificate=Webfig disabled=no port=<MGMT_PORT>
/ip ssh
set password-authentication=yes
/ip upnp interfaces
add interface=bridge type=internal
add interface=WAN-Fiber type=external
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" dst-port=33434-33534 protocol=udp
add action=accept chain=input comment="defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=input comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack6" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=forward comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
# [/system clock] time zone removed (location) for publication
/system identity
set name=Router-A
/system logging
add action=wazuhlog topics=info
add action=wazuhlog topics=warning
add action=wazuhlog topics=error
add action=wazuhlog topics=critical
add action=wazuhlog topics=firewall
/system package update
set channel=long-term
/system scheduler
add !days interval=1w3d name=backup on-event="/system script run backup-and-email" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive start-date=2020-05-16 start-time=04:00:00
/tool e-mail
set certificate-verification=no from=<EMAIL> port=587 server=<SMTP_SERVER> tls=starttls user=<EMAIL>
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool netwatch
add disabled=no dns-server=10.0.11.13 down-script="/system/script/run SiteB-Router-Down" host=10.0.20.1 http-codes="" interval=20s port=22 src-address=10.0.10.1 startup-delay=5m test-script="" timeout=2s type=icmp up-script="/system/script/run SiteB-Router-UP"
add disabled=no down-script="/system/script/run server-test-down" host=10.0.11.90 http-codes="" interval=15s src-address=10.0.11.1 startup-delay=7m test-script="" timeout=3s type=simple up-script="/system/script/run server-test-up"
add disabled=no dns-server=10.0.11.13 down-script="/system script run pihole-down" host=fb.com http-codes="" interval=15s port=80 record-type=A src-address=10.0.10.1 startup-delay=10m test-script="" timeout=3s type=dns up-script="/system script run pihole-up"
# [/tool sniffer] packet-capture settings removed for publication
