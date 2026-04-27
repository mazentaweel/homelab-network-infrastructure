/interface bridge
add admin-mac=B8:69:F4:D9:A2:E9 arp=reply-only auto-mac=no comment=defconf \
    name=bridge


/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1 max-mtu=1492 name=\
    "Paltel Fiber" user="YOUR_PPOE_USERNAME"


/interface wireguard
add disabled=yes listen-port=61853 mtu=1420 name=DO-VPS
add listen-port=443 mtu=1420 name=WG-Mikrotik-A


/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN


/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254


/ip dhcp-server
add address-pool=default-dhcp interface=bridge lease-time=1d name=defconf


/queue simple
add name=css-Priority packet-marks=css-packet priority=1/1 target=\
    192.168.1.13/32

/queue type
add kind=fq-codel name=fq_codel_up
add kind=fq-codel name=fq_codel_down


/queue simple
add disabled=yes max-limit=20M/20M name=showtv queue=\
    fq_codel_up/fq_codel_down target=192.68.88.38/32
add name=CS2-PRIORITY packet-marks=CS2 priority=1/1 queue=\
    fq_codel_up/fq_codel_down target=""
add max-limit=470M/470M name=WAN-fq-codel queue=fq_codel_up/fq_codel_down \
    target=""


/user group
add name=HA policy="read,write,test,api,!local,!telnet,!ssh,!ftp,!reboot,!poli\
    cy,!winbox,!password,!web,!sniff,!sensitive,!romon,!rest-api"


/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
add bridge=bridge comment=defconf interface=sfp1


/ip firewall connection tracking
set udp-timeout=10s


/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface="Paltel Fiber" list=WAN
add disabled=yes interface=WG-Mikrotik-A list=LAN


/interface wireguard peers
add allowed-address="192.168.100.3/32,192.168.2.0/24,192.168.1.0/24,192.168.25\
    3.0/24,192.168.88.0/24" interface=WG-Mikrotik-A name="Admin" \
    public-key="YOUR_PUBLIC_KEY"


add allowed-address=\
    192.168.100.1/32,192.168.2.0/24,192.168.253.0/24,192.168.90.0/24 \
    client-allowed-address=::/0 endpoint-address=\
    YOUR_ENDPOINT endpoint-port=443 interface=\
    WG-Mikrotik-A name=A-To-B public-key=\
    "YOUR_PUBLIC_KEY"


add allowed-address=10.66.66.7/24 disabled=yes endpoint-address=\
    167.172.182.189 endpoint-port=61775 interface=DO-VPS name=\
    DigitalOcean-VPS-VPN public-key=\
    "YOUR_PUBLIC_KEY"


/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=\
    192.168.88.0
add address=192.168.1.1/24 interface=bridge network=192.168.1.0
add address=192.168.100.2/24 interface=WG-Mikrotik-A network=192.168.100.0
add address=10.66.66.7 interface=DO-VPS network=10.66.66.7



/ip arp
#STATIC ARP FOR EACH DEVICE


/ip cloud #YOU CAN UES THE THIS IF YOU DOES NOT HAVE A STATIC IP FROM YOUR ISP
set ddns-enabled=yes ddns-update-interval=1m


/ip dhcp-server lease
#STATIC IP address FOR EACH DEVICE


/ip dhcp-server network #TWO SUBNETS
add address=192.168.1.0/24 comment=SERVERS SUBNET dns-server=192.168.1.1 gateway=192.168.1.1 \
    ntp-server=192.168.88.1
add address=192.168.88.0/24 comment=USERS SUBNET dns-server=192.168.88.1 gateway=\
    192.168.88.1


/ip dns
set allow-remote-requests=yes max-udp-packet-size=512 servers=\
    192.168.1.13,8.8.8.8


/ip firewall address-list
add address=192.168.88.35 list=Admin
add address=192.168.88.36 list=Admin
add address=192.168.88.37 list=Admin
add address=192.168.88.100 list=Admin
add address=192.168.88.101 list=Admin
add address=192.168.88.102 list=Admin
add address=192.168.88.26 list=Admin
add address=192.168.88.100 disabled=yes list=DNS
add address=192.168.88.19 disabled=yes list=DNS
add address=192.168.88.4 disabled=yes list=DNS
add address=192.168.88.0/24 list=mgmt
add address=192.168.1.0/24 list=mgmt
add address=192.168.2.0/24 list=mgmt
add address=10.10.0.0/24 list=mgmt
add address=167.172.182.189 list=mgmt
add address=192.168.88.3 disabled=yes list=DNS
add address=192.168.88.8 disabled=yes list=DNS
add address=192.168.1.90 list=DNS
add address=192.168.88.15 disabled=yes list=DNS
add address=192.168.88.248 disabled=yes list=DNS
add address=192.168.88.101 disabled=yes list=DNS
add address=192.168.88.44 disabled=yes list=DNS
add address=192.168.88.16 disabled=yes list=DNS
add address=192.168.1.13 list=DNS
add address=192.168.88.1 list=DNS
add address=192.168.100.3 list=DNS
add address=192.168.100.0/24 list=mgmt
add address=192.168.100.8 list=DNS
add address=192.168.1.1 list=DNS
add address=192.168.88.29 list=DNS
add address=192.168.1.123 list=DNS


/ip firewall filter
add action=drop chain=forward dst-address=!192.168.1.13 dst-port=53 protocol=\
    tcp src-address=192.168.90.0/24

add action=drop chain=forward dst-address=!192.168.1.13 dst-port=53 protocol=\
    udp src-address=192.168.90.0/24


add action=drop chain=forward src-address=192.168.88.38


add action=accept chain=input src-address-list=mgmt


add action=accept chain=input in-interface-list=LAN


add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked


add action=accept chain=forward comment="Allow LAN DNS forwarding to Pi-hole" \
    dst-address=192.168.1.13 src-address=192.168.88.0/24


add action=accept chain=forward comment="Allow Pi-hole replies to LAN" \
    dst-address=192.168.88.0/24 src-address=192.168.1.13


add action=accept chain=input dst-port=443 protocol=udp
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp

#DROP brute forcers, WAS USED FOR L2TP ONLY BEFORE NOW GLOBAL
add action=drop chain=input comment="dropl2tp brute forcers" in-interface=\
    "Paltel Fiber" src-address-list=l2tp_blacklis

add action=add-src-to-address-list address-list=l2tp_blacklist \
    address-list-timeout=1w3d chain=input connection-state=new \
    src-address-list=l2tp_stage6

add action=add-src-to-address-list address-list=l2tp_stage6 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=l2tp_stage5

add action=add-src-to-address-list address-list=l2tp_stage5 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=l2tp_stage4

add action=add-src-to-address-list address-list=l2tp_stage4 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=l2tp_stage3

add action=add-src-to-address-list address-list=l2tp_stage3 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=l2tp_stage2

add action=add-src-to-address-list address-list=l2tp_stage2 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=l2tp_stage1

add action=add-src-to-address-list address-list=l2tp_stage1 \
    address-list-timeout=1m chain=input connection-state=new \
    src-address-list=!mgmt



add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN


add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec

add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec


add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-nat-state=!dstnat connection-state=established,related \
    protocol=tcp


add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked


add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid


add action=accept chain=forward dst-address=192.168.1.90


add action=accept chain=forward comment="Allow mDNS for AirPlay & Casting" \
    dst-port=5353 protocol=udp


add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN


add action=drop chain=input in-interface="Paltel Fiber" src-address-list=\
    !mgmt


/ip firewall mangle
add action=change-mss chain=forward comment="Clamp MSS" new-mss=clamp-to-pmtu \
    protocol=tcp tcp-flags=syn
add action=mark-packet chain=forward comment="CS2 Game" dst-port=27000-27100 \
    new-packet-mark=CS2 protocol=udp
add action=mark-packet chain=forward comment=Steam dst-port=4380 \
    new-packet-mark=CS2 protocol=udp
add action=mark-packet chain=forward comment="Steam Voice" dst-port=3478-3480 \
    new-packet-mark=CS2 protocol=udp
add action=mark-connection chain=forward dst-address=192.168.1.13 dst-port=\
    27017 new-connection-mark=css protocol=tcp
add action=mark-connection chain=forward dst-address=192.168.1.13 dst-port=\
    27017 new-connection-mark=css protocol=udp
add action=mark-packet chain=prerouting connection-mark=css new-packet-mark=\
    css-packet


/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN

#ENFORCE DEVICES TO USE PI-HOLE DNS

add action=dst-nat chain=dstnat dst-port=53 protocol=udp src-address-list=\
    !DNS to-addresses=192.168.1.13 to-ports=53
add action=dst-nat chain=dstnat dst-port=53 protocol=tcp src-address-list=\
    !DNS to-addresses=192.168.1.13 to-ports=53


add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface="Paltel Fiber"

add action=masquerade chain=srcnat comment="defconf: masquerade" disabled=yes \
    ipsec-policy=out,none out-interface=DO-VPS

add action=masquerade chain=srcnat disabled=yes dst-address=192.168.1.90 \
    out-interface=bridge protocol=tcp src-address=192.168.88.0/24

add action=masquerade chain=srcnat disabled=yes dst-address=192.168.88.16 \
    out-interface=bridge protocol=tcp src-address=192.168.88.0/24

#WEB SERVER
add action=dst-nat chain=dstnat comment=Hesabate dst-port=8443 protocol=udp \
    src-address-list=mgmt to-addresses=192.168.1.90
add action=dst-nat chain=dstnat comment=Hesabate dst-port=8443 protocol=tcp \
    src-address-list=mgmt to-addresses=192.168.1.90


add action=dst-nat chain=dstnat comment="css server" dst-port=27017 \
    in-interface="Paltel Fiber" protocol=udp to-addresses=192.168.1.13

add action=dst-nat chain=dstnat comment="css server" dst-port=27017 \
    in-interface="Paltel Fiber" protocol=tcp to-addresses=192.168.1.13


add action=dst-nat chain=dstnat comment="SSH ubuntu" dst-port=22 \
    in-interface="Paltel Fiber" protocol=tcp src-address-list=mgmt to-addresses=192.168.1.13


add action=dst-nat chain=dstnat comment=N8n disabled=yes dst-port=9443 \
    in-interface="Paltel Fiber" protocol=udp to-addresses=192.168.88.16 \
    to-ports=30022

add action=dst-nat chain=dstnat comment=N8n disabled=yes dst-port=9443 \
    in-interface="Paltel Fiber" protocol=tcp to-addresses=192.168.88.16 \
    to-ports=30022


add action=dst-nat chain=dstnat comment="Admin's-PC WOW" dst-port=9 protocol=\
    udp to-addresses=192.168.88.100 to-ports=9

add action=dst-nat chain=dstnat dst-port=32400 protocol=tcp to-addresses=\
    192.168.88.16 to-ports=32400

add action=dst-nat chain=dstnat dst-port=32400 protocol=udp to-addresses=\
    192.168.88.16 to-ports=32400


add action=dst-nat chain=dstnat disabled=yes dst-port=8081 protocol=tcp \
    to-addresses=192.168.1.13 to-ports=8081


/ip route
add check-gateway=ping disabled=no distance=1 dst-address=208.67.222.222/32 \
    gateway=DO-VPS pref-src=0.0.0.0 routing-table=main scope=30 target-scope=\
    10
add disabled=no distance=1 dst-address=192.168.253.0/24 gateway=\
    WG-Mikrotik-A pref-src=0.0.0.0 routing-table=main scope=10
add disabled=no distance=1 dst-address=192.168.2.0/24 gateway=\
    WG-Mikrotik-A pref-src="" routing-table=main scope=10
add disabled=no distance=3 dst-address=208.67.220.220/32 gateway=\
    "Paltel Fiber" pref-src=0.0.0.0 routing-table=main
add disabled=no distance=3 dst-address=208.67.222.222/32 gateway=\
    "Paltel Fiber" pref-src=0.0.0.0 routing-table=main
add disabled=no distance=3 dst-address=1.1.1.1/32 gateway="Paltel Fiber" \
    pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10
add disabled=no distance=3 dst-address=8.8.8.8/32 gateway="Paltel Fiber" \
    pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=8.8.8.8/32 gateway=\
    DO-VPS pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=10.66.66.0/24 \
    gateway=DO-VPS routing-table=main scope=30 target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=1.1.1.1/32 gateway=\
    DO-VPS pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=208.67.220.220/32 \
    gateway=DO-VPS pref-src=0.0.0.0 routing-table=main scope=30 target-scope=\
    10
add disabled=no distance=1 dst-address=192.168.90.0/24 gateway=\
    WG-Mikrotik-A routing-table=main scope=10 target-scope=10


/ip service
#ROUTER WEB LOG-IN SSL/HTTPS
set www disabled=yes
set www-ssl certificate=Webfig disabled=no


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
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" \
    dst-port=33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack6" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN


/system clock
set time-zone-name=Asia/Hebron


/system identity
set name="MikroTik A"


/system scheduler
add interval=1d name=backup on-event=\
    "/system script run backup-and-email\r\
    \n/system script run ROS-Backup" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive start-date=\
    2020-05-16 start-time=04:00:00


/system script
add dont-require-permissions=yes name=B-MikroTik-UP owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=B MikroTik VPN is \
    UP\""


add dont-require-permissions=yes name=B-MikroTik-Down owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=B MikroTik VPN is \
    Down\""

add dont-require-permissions=yes name=server-test-up owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=Server is UP \
    \"\
    \n"

add dont-require-permissions=yes name=server-test-down owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=Server is Down\
    \_\"\
    \n"

add dont-require-permissions=yes name=pihole-down owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=PiHole is Down\""

add dont-require-permissions=yes name=pihole-up owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=PiHole is Up\""

add dont-require-permissions=yes name=backup-and-email owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    ### Modify these values to match your requirements ####\r\
    \n \r\
    \n#Your email address to receive the backups\r\
    \n:local toemail \"your@email.com\"\r\
    \n \r\
    \n#The From address (you can use your own address if you want)\r\
    \n:local fromemail \"your@email.com\"\r\
    \n \r\
    \n#A mail server your machines can send through\r\
    \n:local emailserver \"74.125.143.109\"\r\
    \n \r\
    \n############## Don\92t edit below this line ##############\r\
    \n \r\
    \n:local sysname [/system identity get name]\r\
    \n:local textfilename\r\
    \n:local backupfilename\r\
    \n:local time [/system clock get time]\r\
    \n:local date [/system clock get date]\r\
    \n:local newdate \"\";\r\
    \n:for i from=0 to=([:len \$date]-1) do={ :local tmp [:pick \$date \$i];\r\
    \n:if (\$tmp !=\"/\") do={ :set newdate \"\$newdate\$tmp\" }\r\
    \n:if (\$tmp =\"/\") do={}\r\
    \n}\r\
    \n#check for spaces in system identity to replace with underscores\r\
    \n:if ([:find \$sysname \" \"] !=0) do={\r\
    \n:local name \$sysname;\r\
    \n:local newname \"\";\r\
    \n:for i from=0 to=([:len \$name]-1) do={ :local tmp [:pick \$name \$i];\r\
    \n:if (\$tmp !=\" \") do={ :set newname \"\$newname\$tmp\" }\r\
    \n:if (\$tmp =\" \") do={ :set newname \"\$newname_\" }\r\
    \n}\r\
    \n:set sysname \$newname;\r\
    \n}\r\
    \n:set textfilename (\$\"newdate\" . \"-\" . \$\"sysname\" . \".rsc\")\r\
    \n:set backupfilename (\$\"newdate\" . \"-\" . \$\"sysname\" . \".backup\"\
    )\r\
    \n:execute [/export file=\$\"textfilename\"]\r\
    \n:execute [/system backup save name=\$\"backupfilename\"]\r\
    \n#Allow time for export to complete\r\
    \n:delay 2s\r\
    \n \r\
    \n#email copies\r\
    \n:log info \"Emailing backups\"\r\
    \n/tool e-mail send to=\$\"toemail\" from=\$\"fromemail\" server=[:resolve\
    \_\$emailserver] port=25 subject=\"[Config Backup] \$sysname \$time\" file\
    =\$\"textfilename\"\r\
    \n#Send as different subjects to force GMail to treat as new message threa\
    d.\r\
    \n:local time [/system clock get time]\r\
    \n/tool e-mail send to=\$\"toemail\" from=\$\"fromemail\" server=[:resolve\
    \_\$emailserver] port=587 subject=\"[Config Backup] \$sysname \$time\" fil\
    e=\$\"backupfilename\"\r\
    \n \r\
    \n#Allow time to send\r\
    \n:delay 60s\r\
    \n \r\
    \n#delete copies\r\
    \n/file remove \$textfilename\r\
    \n/file remove \$backupfilename"


/tool e-mail
#GMAIL SERVER
set certificate-verification=no from=your@email.com port=587 server=\
    74.125.143.109 tls=starttls user=your@email.com


/tool mac-server
set allowed-interface-list=LAN


/tool netwatch
add disabled=no down-script="/system/script/run B-MikroTik-Down" host=\
    192.168.2.1 http-codes="" interval=20s port=8081 src-address=192.168.88.1 \
    start-delay=0ms startup-delay=6m test-script="" type=icmp up-script=\
    "/system/script/run B-MikroTik-UP"


add disabled=no down-script="/system/script/run server-test-down" host=\
    192.168.1.90 http-codes="" src-address=192.168.1.1 startup-delay=7m \
    test-script="" type=simple up-script="/system/script/run server-test-up"


add disabled=no dns-server=192.168.1.13 down-script="/ip/dns/set servers=8.8.8\
    .8\
    \n\
    \n/ip/firewall/nat set 1,2 to-addresses=8.8.8.8\
    \n\
    \n\
    \n/ip/dns/cache/flush\
    \n\
    \n/tool/wol mac=2C:44:FD:32:68:B5 interface=bridge\
    \n\
    \n/system/script/run pihole-down" host=fb.com http-codes="" interval=10s \
    port=80 record-type=A src-address=192.168.88.1 startup-delay=30m \
    test-script="" timeout=2s type=dns up-script="/ip/dns/set servers=192.168.\
    1.13,8.8.8.8\
    \n\
    \n/ip/firewall/nat set 1,2 to-addresses=192.168.1.13\
    \n\
    \n/ip/dns/cache/flush\
    \n/system/script/run pihole-up"
