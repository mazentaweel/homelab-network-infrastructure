/interface bridge
add admin-mac=C4:AD:34:8B:02:49 arp=reply-only auto-mac=no comment=defconf \
    dhcp-snooping=yes name=bridge port-cost-mode=short


/interface ethernet
set [ find default-name=sfp1 ] advertise="10M-baseT-half,10M-baseT-full,100M-b\
    aseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"


/interface wireguard
add listen-port=443 mtu=1420 name=WG-Mikrotik-B


/interface list
add comment=defconf name=WAN
add comment=defconf include=dynamic name=LAN




/ip pool
add name=default-dhcp ranges=192.168.2.10-192.168.2.254
add name=users ranges=192.168.90.2-192.168.90.254


/ip dhcp-server
add address-pool=default-dhcp interface=bridge lease-time=1d name=defconf


/routing table
add disabled=no fib name=vpn-DO
/interface bridge port
add bridge=bridge comment=defconf ingress-filtering=no interface=ether2 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether3 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether4 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether5 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether6 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether7 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether8 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether9 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether10 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=sfp1 \
    internal-path-cost=10 path-cost=10


/ip firewall connection tracking
set udp-timeout=10s


/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1 list=WAN


/interface wireguard peers
add allowed-address=192.168.100.2/32,192.168.1.0/24,192.168.88.0/24 \
    endpoint-address=YOUR_ENDPOINT endpoint-port=443 interface=\
    WG-Mikrotik-B name=Work-To-A persistent-keepalive=25s public-key=\
    "YOUR_PUBLIC_KEY"


add allowed-address="192.168.100.5/32,192.168.1.0/24,192.168.88.0/24,192.168.2\
    .0/24,192.168.253.0/24" disabled=yes interface=WG-Mikrotik-B name=\
    "ADMIN iPhone" persistent-keepalive=25s public-key=\
    "YOUR_PUBLIC_KEY" responder=yes


/ip address
add address=192.168.2.1/24 comment=Main-Lan interface=bridge network=\
    192.168.2.0
add address=192.168.90.1/24 interface=bridge network=192.168.90.0
add address=192.168.100.1/24 interface=WG-Mikrotik-B network=192.168.100.0


/ip arp
#STATIC ARP FOR EACH DEVICE


/ip cloud #YOU CAN UES THE THIS IF YOU DOES NOT HAVE A STATIC IP FROM YOUR ISP
set ddns-enabled=yes ddns-update-interval=1m


/ip dhcp-client
add comment=defconf interface=ether1 use-peer-dns=no


/ip dhcp-server lease
#STATIC IP address FOR EACH DEVICE


/ip dhcp-server network
add address=192.168.2.0/24 comment="Main Pool" dns-server=192.168.1.13,8.8.8.8 \
    gateway=192.168.2.1
add address=192.168.90.0/24 comment="Users Pool" dns-server=\
    192.168.1.13,8.8.8.8 gateway=192.168.90.1


/ip dns
set allow-remote-requests=yes servers=192.168.1.13,8.8.8.8



/ip firewall address-list
add address=192.168.1.0/24 comment="Admin A Sec LAN" list=LAN
add address=192.168.2.0/24 comment=LAN list=LAN
add address=192.168.100.0/24 comment="Admin Lan" list=LAN
add address=192.168.88.1 comment="Admin A Main LAN" list=LAN
add address=192.168.1.0/24 list=mgmt
add address=192.168.2.0/24 list=mgmt
add address=10.10.0.0/24 disabled=yes list=mgmt
add address=192.168.88.0/24 list=mgmt
add address=192.168.2.41 list=Allow
add address=192.168.2.2 list=Allow
add address=192.168.2.28 list=Allow
add address=192.168.2.59 list=Allow
add address=192.168.2.61 list=Allow
add address=192.168.2.62 list=Allow
add address=192.168.2.19 list=Allow
add address=192.168.2.5 list=Allow
add address=192.168.2.49 list=Allow
add address=192.168.2.18 list=Allow
add address=192.168.2.65 list=Allow
add address=192.168.2.23 list=Allow
add address=192.168.2.33 list=Allow
add address=192.168.2.11 list=Allow
add address=192.168.2.28 list=DNS
add address=192.168.2.59 list=DNS
add address=192.168.2.63 list=Allow
add address=192.168.2.46 list=Allow
add address=192.168.2.10 list=Allow
add address=192.168.2.27 list=Allow
add address=192.168.2.51 list=Allow
add address=192.168.2.16 list=Allow
add address=192.168.2.37 list=Allow
add address=192.168.2.29 list=Allow
add address=192.168.2.60 list=Allow
add address=192.168.253.1 comment=LAN list=LAN
add address=192.168.100.0/24 list=mgmt


/ip firewall filter
add action=drop chain=input src-address=192.168.90.0/24
add action=drop chain=forward dst-address=192.168.90.0/24 src-address=\
    192.168.90.0/24
add action=accept chain=forward dst-address=192.168.1.13 dst-port=53 \
    protocol=tcp src-address=192.168.90.0/24
add action=accept chain=forward dst-address=192.168.1.13 dst-port=53 \
    protocol=udp src-address=192.168.90.0/24
add action=drop chain=forward dst-address=192.168.0.0/16 src-address=\
    192.168.90.0/24
add action=accept chain=forward out-interface=ether1 src-address=\
    192.168.90.0/24


add action=accept chain=input in-interface=WG-Mikrotik-B

add action=accept chain=input src-address-list=LAN

add action=accept chain=input src-address-list=mgmt

add action=accept chain=input in-interface-list=LAN

add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked

add action=accept chain=input dst-port=443 protocol=udp

add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid

add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related

add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid

add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked

add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid

#DROP brute forcers, WAS USED FOR L2TP ONLY BEFORE NOW GLOBAL

add action=drop chain=input comment="drop l2tp brute forcers" in-interface=\
    ether1 src-address-list=l2tp_blacklis
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
    src-address-list=!LAN


add action=accept chain=input comment=ICMP/Ping protocol=icmp
add action=accept chain=input comment="L2TP/IPSec VPN" dst-port=500,1701,4500 \
    in-interface=ether1 protocol=udp
add action=accept chain=input comment="PPTP VPN" dst-port=1723 in-interface=\
    ether1 protocol=tcp
add action=accept chain=input comment="PPTP VPN" in-interface=ether1 \
    protocol=gre
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
add action=accept chain=input src-address-list=LAN
add action=reject chain=forward disabled=yes reject-with=\
    icmp-network-unreachable src-address-list=!Allow
add action=accept chain=forward in-interface=WG-Mikrotik-B
add action=accept chain=forward out-interface=WG-Mikrotik-B


/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface=ether1

#ENFORCE DEVICES TO USE PI-HOLE DNS

add action=dst-nat chain=dstnat dst-port=53 protocol=tcp src-address-list=\
    !DNS to-addresses=192.168.1.13 to-ports=53
add action=dst-nat chain=dstnat dst-port=53 protocol=udp src-address-list=\
    !DNS to-addresses=192.168.1.13 to-ports=53


/ip route
add disabled=yes distance=1 dst-address=192.168.1.0/24 gateway=10.10.0.1 \
    pref-src="" routing-table=main scope=30 target-scope=10
add disabled=yes distance=1 dst-address=192.168.88.0/24 gateway=10.10.0.1 \
    pref-src="" routing-table=main scope=30 target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=0.0.0.0/0 gateway=\
    172.18.0.1 pref-src="" routing-table=vpn-DO scope=30 target-scope=10
add disabled=no distance=1 dst-address=192.168.1.0/24 gateway=192.168.100.2 \
    pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10
add disabled=no distance=1 dst-address=192.168.88.0/24 gateway=192.168.100.2 \
    pref-src=0.0.0.0 routing-table=main scope=30 target-scope=10


/ip service
#ROUTER WEB LOG-IN FORCE USE SSL/HTTPS
set www disabled=yes
set www-ssl certificate=Webfig disabled=no



/routing rule
add action=lookup disabled=yes interface=l2tp-out1 routing-mark=vpn-DO \
    src-address=192.168.2.61/32 table=vpn-DO


/system clock
set time-zone-name=Asia/Hebron


/system identity
set name=MikroTik-B


/system scheduler
add comment="2025-11-18 01:23:09" disabled=yes interval=1m name=LogFilter \
    on-event=LogFilter policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup


add interval=1d name=daily-backup on-event=\
    "/system script run backup-and-email" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive start-date=\
    2020-05-16 start-time=04:00:00



add disabled=yes interval=1d name="Night Shift disable" on-event=\
    "/system/script/ run 5" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2024-03-10 start-time=06:00:00


add disabled=yes interval=1d name="Night Shift Enable" on-event=\
    "/system/script/ run 4" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2024-03-10 start-time=18:00:00


add name=telegram-on-reboot on-event="/system script run reboot-check" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup



/system script
add dont-require-permissions=yes name=LogFilter owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local myserver ([/system identity get name])\
    \n:local scheduleName \"LogFilter\"\
    \n:local bot \"718091834:AAEzW3O1lXn9jv97TDP8Gw8vOMPt5gC3p04\"\
    \n:local ChatID \"727793683\"\
    \n:local startBuf [:toarray [/log find message~\" failure\" || message~\"l\
    oop\" || message~\"down\" || message~\"fcs\" || message~\"excessive\" || m\
    essage~\"logged\"]]\
    \n\
    \n# END SETUP\
    \n\
    \n# warn if schedule does not exist\
    \n:if ([:len [/system scheduler find name=\"\$scheduleName\"]] = 0) do={\
    \n  /log warning \"[LogFilter] Alert : Schedule does not exist. Creating s\
    chedule ....\"\
    \n\
    \n /system scheduler add name=\$scheduleName interval=60s start-date=Jul/0\
    5/2019 start-time=startup on-event=LogFilter\
    \n\
    \n  /log warning \"[LogFilter] Alert : Schedule created .\"\
    \n}\
    \n\
    \n# get last time\
    \n:local lastTime [/system scheduler get [find name=\"\$scheduleName\"] co\
    mment]\
    \n# for checking time of each log entry\
    \n:local currentTime\
    \n# log message\
    \n:local message\
    \n \
    \n# final output\
    \n:local output\
    \n\
    \n:local keepOutput false\
    \n# if lastTime is empty, set keepOutput to true\
    \n:if ([:len \$lastTime] = 0) do={\
    \n  :set keepOutput true\
    \n}\
    \n\
    \n:local counter 0\
    \n# loop through all log entries that have been found\
    \n:foreach i in=\$startBuf do={\
    \n \
    \n# loop through all removeThese array items\
    \n  :local keepLog true\
    \n  :foreach j in=\$removeThese do={\
    \n#   if this log entry contains any of them, it will be ignored\
    \n    :if ([/log get \$i message] ~ \"\$j\") do={\
    \n      :set keepLog false\
    \n    }\
    \n  }\
    \n  :if (\$keepLog = true) do={\
    \n   \
    \n   :set message [/log get \$i message]\
    \n\
    \n#   LOG DATE\
    \n#   depending on log date/time, the format may be different. 3 known for\
    mats\
    \n#   format of jan/01/2002 00:00:00 which shows up at unknown date/time. \
    Using as default\
    \n    :set currentTime [ /log get \$i time ]\
    \n#   format of 00:00:00 which shows up on current day's logs\
    \n   :if ([:len \$currentTime] = 8 ) do={\
    \n     :set currentTime ([:pick [/system clock get date] 0 11].\" \".\$cur\
    rentTime)\
    \n    } else={\
    \n#     format of jan/01 00:00:00 which shows up on previous day's logs\
    \n     :if ([:len \$currentTime] = 15 ) do={\
    \n        :set currentTime ([:pick \$currentTime 0 6].\"/\".[:pick [/syste\
    m clock get date] 7 11].\" \".[:pick \$currentTime 7 15])\
    \n      }\
    \n   }\
    \n    \
    \n#   if keepOutput is true, add this log entry to output\
    \n   :if (\$keepOutput = true) do={\
    \n     :set output (\$output.\$currentTime.\" %0A%0A \".\$message.\"\\r\\n\
    \")\
    \n   }\
    \n\
    \n    :if (\$currentTime = \$lastTime) do={\
    \n     :set keepOutput true\
    \n     :set output \"\"\
    \n   }\
    \n  }\
    \n  :if (\$counter = ([:len \$startBuf]-1)) do={\
    \n   :if (\$keepOutput = false) do={    \
    \n     :if ([:len \$message] > 0) do={\
    \n        :set output (\$output.\$currentTimer.\" \".\$message.\"\\r\\n\")\
    \n      }\
    \n    }\
    \n  }\
    \n  :set counter (\$counter + 1)\
    \n}\
    \n\
    \nif ([:len \$output] > 0) do={\
    \n  /system scheduler set [find name=\"\$scheduleName\"] comment=\$current\
    Time\
    \n  /tool fetch url=\"https://api.telegram.org/bot\$bot/sendmessage\?chat_\
    id=\$ChatID&text=\$myserver%0A%0A\$output\" keep-result=no;\
    \n}"


add dont-require-permissions=yes name=backup-and-email owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    ### Modify these values to match your requirements ####\
    \n \
    \n#Your email address to receive the backups\
    \n:local toemail \"your@email.com\"\
    \n \
    \n#The From address (you can use your own address if you want)\
    \n:local fromemail \"your@email.com\"\
    \n \
    \n#A mail server your machines can send through\
    \n:local emailserver \"74.125.143.109\"\
    \n \
    \n############## Don\92t edit below this line ##############\
    \n \
    \n:local sysname [/system identity get name]\
    \n:local textfilename\
    \n:local backupfilename\
    \n:local time [/system clock get time]\
    \n:local date [/system clock get date]\
    \n:local newdate \"\";\
    \n:for i from=0 to=([:len \$date]-1) do={ :local tmp [:pick \$date \$i];\
    \n:if (\$tmp !=\"/\") do={ :set newdate \"\$newdate\$tmp\" }\
    \n:if (\$tmp =\"/\") do={}\
    \n}\
    \n#check for spaces in system identity to replace with underscores\
    \n:if ([:find \$sysname \" \"] !=0) do={\
    \n:local name \$sysname;\
    \n:local newname \"\";\
    \n:for i from=0 to=([:len \$name]-1) do={ :local tmp [:pick \$name \$i];\
    \n:if (\$tmp !=\" \") do={ :set newname \"\$newname\$tmp\" }\
    \n:if (\$tmp =\" \") do={ :set newname \"\$newname_\" }\
    \n}\
    \n:set sysname \$newname;\
    \n}\
    \n:set textfilename (\$\"newdate\" . \"-\" . \$\"sysname\" . \".rsc\")\
    \n:set backupfilename (\$\"newdate\" . \"-\" . \$\"sysname\" . \".backup\"\
    )\
    \n:execute [/export file=\$\"textfilename\"]\
    \n:execute [/system backup save name=\$\"backupfilename\"]\
    \n#Allow time for export to complete\
    \n:delay 2s\
    \n \
    \n#email copies\
    \n:log info \"Emailing backups\"\
    \n/tool e-mail send to=\$\"toemail\" from=\$\"fromemail\" server=[:resolve\
    \_\$emailserver] port=25 subject=\"[Config Backup] \$sysname \$time\" file\
    =\$\"textfilename\"\
    \n#Send as different subjects to force GMail to treat as new message threa\
    d.\
    \n:local time [/system clock get time]\
    \n/tool e-mail send to=\$\"toemail\" from=\$\"fromemail\" server=[:resolve\
    \_\$emailserver] port=587 subject=\"[Config Backup] \$sysname \$time\" fil\
    e=\$\"backupfilename\"\
    \n \
    \n#Allow time to send\
    \n:delay 10s\
    \n \
    \n#delete copies\
    \n/file remove \$textfilename\
    \n/file remove \$backupfilename"


add dont-require-permissions=yes name="enable abu lutffi" owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "ip arp enable numbers=14"


add dont-require-permissions=yes name="disable abu lutffi" owner=ADMIN \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source="ip arp disable numbers=14"


add dont-require-permissions=yes name="Ala night enable" owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "interface bridge set 0 arp=enabled"


add dont-require-permissions=yes name="Ala night disable" owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "interface bridge set 0 arp=reply-only"


add dont-require-permissions=yes name=reboot-check owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local botToken \"718091834:AAEzW3O1lXn9jv97TDP8Gw8vOMPt5gC3p04\"\
    \n\
    \n:local chatId \"727793683\"\
    \n\
    \n:local routerName [/system identity get name]\
    \n:local uptime [/system resource get uptime]\
    \n\
    \n# Delay before checking internet (to ensure router is ready)\
    \n:delay 30\
    \n\
    \n# Check if there is an internet connection (ping 8.8.8.8)\
    \n:local isOnline false\
    \n:local i 0\
    \n\
    \n# Try pinging 8.8.8.8 up to 5 times\
    \n:while (\$i < 5 && \$isOnline = false) do={\
    \n    :if ([/ping 8.8.8.8 count=1] > 0) do={\
    \n        :set isOnline true\
    \n    } else={\
    \n        :put \"No internet, retrying...\"\
    \n        :delay 5\
    \n        :set i (\$i + 1)\
    \n    }\
    \n}\
    \n\
    \n# Exit script if no internet connection\
    \n:if (\$isOnline = false) do={\
    \n    :put \"No internet connection. Skipping Telegram notification.\"\
    \n    /log warning \"No internet connection. Skipping Telegram notificatio\
    n.\"\
    \n    return\
    \n}\
    \n\
    \n# Now that we have internet, retrieve the public IP\
    \n:local publicIP [/ip cloud get public-address]\
    \n\
    \n# If public IP is empty, set it to a fallback value\
    \n:if ([:len \$publicIP] = 0) do={\
    \n    :set publicIP \"Not Available\"\
    \n}\
    \n\
    \n# Construct the message\
    \n:local message (\"\F0\9F\9A\80 Router \" . \$routerName . \" has reboote\
    d!%0AUptime before reboot: \" . \$uptime . \"%0APublic IP: \" . \$publicIP\
    )\
    \n\
    \n# Construct the URL for the Telegram API\
    \n:local url (\"https://api.telegram.org/bot\" . \$botToken . \"/sendMessa\
    ge\?chat_id=\" . \$chatId . \"&text=\" . \$message)\
    \n\
    \n# Send the message using /tool fetch\
    \n/tool fetch url=\$url mode=https http-method=get keep-result=no"


add dont-require-permissions=yes name=DVR-Down owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=DVR is Down\""


add dont-require-permissions=yes name=DVR-UP owner=ADMIN policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    tool fetch url=\"https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage\?chat_id=YOUR_CHAT_ID&text=DVR is UP\""


/tool e-mail
#Gmail Server
set certificate-verification=no from=your@email.com port=587 server=\
    74.125.143.109 tls=starttls user=your@email.com



/tool netwatch
add disabled=yes down-script=\
    "/ip/dns/set servers=8.8.8.8\
    \nip/dns/cache/flush" host=192.168.88.13 http-codes="" startup-delay=3m \
    test-script="" type=simple up-script=\
    "/ip/dns/set servers=192.168.88.13\
    \nip/dns/cache/flush"


add disabled=no down-script="/system/script/run DVR-Down" host=192.168.2.41 \
    http-codes="" interval=10s start-delay=0ms startup-delay=1m test-script=\
    "" type=icmp up-script="/system/script/run DVR-UP"


add disabled=no dns-server=192.168.1.13 down-script="/ip/dns/set servers=8.8.8\
    .8\
    \n\
    \n/ip/firewall/nat set 1,2 to-addresses=8.8.8.8\
    \n\
    \n\
    \n/ip/dns/cache/flush" host=google.com http-codes="" interval=30s name="" \
    record-type=A startup-delay=5m test-script="" timeout=2s type=dns \
    up-script="/ip/dns/set servers=192.168.1.13,8.8.8.8\
    \n\
    \n/ip/firewall/nat set 1,2 to-addresses=192.168.1.13\
    \n\
    \n/ip/dns/cache/flush"
