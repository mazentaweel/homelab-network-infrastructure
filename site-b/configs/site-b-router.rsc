# RouterOS 7 export (sanitized)
# software id = <REDACTED>
#
# model = <ROUTER_MODEL>
# serial number = <REDACTED>
# [VPN-Providers] 10849 CIDR entries collapsed. Populated weekly from the public X4BNet lists_vpn feed (output/vpn/ipv4.txt) by an external refresh job.
# [/ip firewall nat] 2 inbound port-forward (dst-nat) rules removed for publication.
/interface bridge
add admin-mac=<MAC> arp=reply-only auto-mac=no comment=defconf dhcp-snooping=yes name=bridge port-cost-mode=short
/interface ethernet
set [ find default-name=sfp1 ] advertise="10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
/interface wireguard
add listen-port=<WG_PORT_B> mtu=1420 name=WG-SiteB
/interface list
add comment=defconf name=WAN
add comment=defconf include=dynamic name=LAN
# [/interface lte apn] LTE APN removed for publication
/ip pool
add name=default-dhcp ranges=10.0.20.10-10.0.20.254
add name=users ranges=10.0.21.2-10.0.21.254
/ip dhcp-server
add address-pool=default-dhcp interface=bridge lease-time=1d name=defconf
# [/ip smb users] SMB users removed for publication
/ppp profile
add change-tcp-mss=yes local-address=10.0.21.1 name=VPN remote-address=users
/queue tree
add comment="Total WAN upload shaper" max-limit=95M name=WAN-upload packet-mark=no-mark parent=global
add comment="General traffic  lower priority" limit-at=20M max-limit=95M name=bulk-traffic packet-mark=no-mark parent=WAN-upload
/queue type
add kind=fq-codel name=fq-codel-wg
/queue tree
add comment="WireGuard VPN  highest priority" limit-at=20M max-limit=95M name=WG-priority packet-mark=wg-tunnel parent=WAN-upload priority=1 queue=fq-codel-wg
add comment="VoIP inside WG tunnel" limit-at=10M max-limit=95M name=WG-voip packet-mark=wg-tunnel parent=WG-priority priority=1
add comment="RDP inside WG tunnel" limit-at=10M max-limit=95M name=WG-rdp packet-mark=wg-tunnel parent=WG-priority priority=2
add comment="SSH inside WG tunnel" limit-at=5M max-limit=95M name=WG-ssh packet-mark=wg-tunnel parent=WG-priority priority=3
/routing table
add disabled=no fib name=vpn-cloud
/system script
add dont-require-permissions=yes name=LogFilter owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local myserver ([/system identity get name])\n:local scheduleName \"LogFilter\"\n:local bot \"<TELEGRAM_BOT_TOKEN>\"\n:local ChatID \"<TELEGRAM_CHAT_ID>\"\n:local startBuf [:toarray [/log find message~\" failure\" || message~\"loop\" || message~\"down\" || message~\"fcs\" || message~\"excessive\" || message~\"logged\"]]\n\n# END SETUP\n\n# warn if schedule does not exist\n:if ([:len [/system scheduler find name=\"\$scheduleName\"]] = 0) do={\n  /log warning \"[LogFilter] Alert : Schedule does not exist. Creating schedule ....\"\n\n /system scheduler add name=\$scheduleName interval=60s start-date=Jul/05/2019 start-time=startup on-event=LogFilter\n\n  /log warning \"[LogFilter] Alert : Schedule created .\"\n}\n\n# get last time\n:local lastTime [/system scheduler get [find name=\"\$scheduleName\"] comment]\n# for checking time of each log entry\n:local currentTime\n# log message\n:local message\n \n# final output\n:local output\n\n:local keepOutput false\n# if lastTime is empty, set keepOutput to true\n:if ([:len \$lastTime] = 0) do={\n  :set keepOutput true\n}\n\n:local counter 0\n# loop through all log entries that have been found\n:foreach i in=\$startBuf do={\n \n# loop through all removeThese array items\n  :local keepLog true\n  :foreach j in=\$removeThese do={\n#   if this log entry contains any of them, it will be ignored\n    :if ([/log get \$i message] ~ \"\$j\") do={\n      :set keepLog false\n    }\n  }\n  :if (\$keepLog = true) do={\n   \n   :set message [/log get \$i message]\n\n#   LOG DATE\n#   depending on log date/time, the format may be different. 3 known formats\n#   format of jan/01/2002 00:00:00 which shows up at unknown date/time. Using as default\n    :set currentTime [ /log get \$i time ]\n#   format of 00:00:00 which shows up on current day's logs\n   :if ([:len \$currentTime] = 8 ) do={\n     :set currentTime ([:pick [/system clock get date] 0 11].\" \".\$currentTime)\n    } else={\n#     format of jan/01 00:00:00 which shows up on previous day's logs\n     :if ([:len \$currentTime] = 15 ) do={\n        :set currentTime ([:pick \$currentTime 0 6].\"/\".[:pick [/system clock get date] 7 11].\" \".[:pick \$currentTime 7 15])\n      }\n   }\n    \n#   if keepOutput is true, add this log entry to output\n   :if (\$keepOutput = true) do={\n     :set output (\$output.\$currentTime.\" %0A%0A \".\$message.\"\\r\\n\")\n   }\n\n    :if (\$currentTime = \$lastTime) do={\n     :set keepOutput true\n     :set output \"\"\n   }\n  }\n  :if (\$counter = ([:len \$startBuf]-1)) do={\n   :if (\$keepOutput = false) do={    \n     :if ([:len \$message] > 0) do={\n        :set output (\$output.\$currentTimer.\" \".\$message.\"\\r\\n\")\n      }\n    }\n  }\n  :set counter (\$counter + 1)\n}\n\nif ([:len \$output] > 0) do={\n  /system scheduler set [find name=\"\$scheduleName\"] comment=\$currentTime\n  /tool fetch url=\"https://api.telegram.org/bot\$bot/sendmessage\?chat_id=\$ChatID&text=\$myserver%0A%0A\$output\" keep-result=no;\n}"
add dont-require-permissions=yes name=backup-and-email owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#### Modify these values to match your requirements ####\n:local toemail \"<EMAIL>\"\n\n############## Script Logic ##############\n:local sysname [/system identity get name]\n:local time [/system clock get time]\n:local date [/system clock get date]\n\n# Format date to remove slashes\n:local newdate \"\"\n:for i from=0 to=([:len \$date]-1) do={ \n    :local tmp [:pick \$date \$i]\n    :if (\$tmp != \"/\" && \$tmp != \"-\") do={ :set newdate \"\$newdate\$tmp\" }\n}\n\n# Replace spaces in identity with underscores\n:local cleanName \"\"\n:for i from=0 to=([:len \$sysname]-1) do={ \n    :local tmp [:pick \$sysname \$i]\n    :if (\$tmp != \" \") do={ :set cleanName \"\$cleanName\$tmp\" } else={ :set cleanName \"\$cleanName_\" }\n}\n:set sysname \$cleanName\n\n:local textfilename \"\$newdate-\$sysname.rsc\"\n:local backupfilename \"\$newdate-\$sysname.backup\"\n\n# Generate files\n/export file=\$textfilename\n/system backup save name=\$backupfilename\n\n# Dynamic wait until backup files physically populate local storage\n:local timeout 0\n:while ([/file find name=\$backupfilename] = \"\" && \$timeout < 15) do={\n    :delay 1s\n    :set timeout (\$timeout + 1)\n}\n\n:log info \"Emailing backups...\"\n\n# FIX: Removed square brackets entirely to guarantee parser compatibility\n:local rscSubject (\"Config Backup RSC - \" . \$sysname . \" \" . \$time)\n:local binSubject (\"Config Backup BIN - \" . \$sysname . \" \" . \$time)\n\n# First Email (.rsc)\n/tool e-mail send to=\$toemail subject=\$rscSubject file=\$textfilename\n:delay 5s\n\n# Second Email (.backup)\n/tool e-mail send to=\$toemail subject=\$binSubject file=\$backupfilename\n\n# Allow 30 seconds for outbound transfer to finish before purging files\n:delay 30s\n\n# Clean files from local disk\n/file remove [find name=\$textfilename]\n/file remove [find name=\$backupfilename]\n:log info \"Backup script execution finished successfully.\"\n"
add dont-require-permissions=yes name=reboot-check owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local botToken \"<TELEGRAM_BOT_TOKEN>\"\n\n:local chatId \"<TELEGRAM_CHAT_ID>\"\n\n:local routerName [/system identity get name]\n:local uptime [/system resource get uptime]\n\n# Delay before checking internet (to ensure router is ready)\n:delay 30\n\n# Check if there is an internet connection (ping 8.8.8.8)\n:local isOnline false\n:local i 0\n\n# Try pinging 8.8.8.8 up to 5 times\n:while (\$i < 5 && \$isOnline = false) do={\n    :if ([/ping 8.8.8.8 count=1] > 0) do={\n        :set isOnline true\n    } else={\n        :put \"No internet, retrying...\"\n        :delay 5\n        :set i (\$i + 1)\n    }\n}\n\n# Exit script if no internet connection\n:if (\$isOnline = false) do={\n    :put \"No internet connection. Skipping Telegram notification.\"\n    /log warning \"No internet connection. Skipping Telegram notification.\"\n    return\n}\n\n# Now that we have internet, retrieve the public IP\n:local publicIP [/ip cloud get public-address]\n\n# If public IP is empty, set it to a fallback value\n:if ([:len \$publicIP] = 0) do={\n    :set publicIP \"Not Available\"\n}\n\n# Construct the message\n:local message (\"\F0\9F\9A\80 Router \" . \$routerName . \" has rebooted!%0AUptime before reboot: \" . \$uptime . \"%0APublic IP: \" . \$publicIP)\n\n# Construct the URL for the Telegram API\n:local url (\"https://api.telegram.org/bot\" . \$botToken . \"/sendMessage\?chat_id=\" . \$chatId . \"&text=\" . \$message)\n\n# Send the message using /tool fetch\n/tool fetch url=\$url mode=https http-method=get keep-result=no"
add dont-require-permissions=yes name=DVR-Down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-dvr\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-dvr\"] } on-error={}\r\n/system scheduler add name=\"nw-down-dvr\" start-time=([/system clock get time] + 00:01:00) interval=0 on-event=\"/system script run confirm-dvr-down\""
add dont-require-permissions=yes name=DVR-UP owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-dvr\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-dvr\"] } on-error={}\r\n/system scheduler add name=\"nw-up-dvr\" start-time=([/system clock get time] + 00:00:10) interval=0 on-event=\"/system script run confirm-dvr-up\""
add dont-require-permissions=yes name=host-1-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-host1\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-host1\"] } on-error={}\r\n/system scheduler add name=\"nw-up-host1\" start-time=([/system clock get time] + 00:00:10) interval=0 on-event=\"/system script run confirm-host1-up\""
add dont-require-permissions=yes name=host-2-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-host2\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-host2\"] } on-error={}\r\n/system scheduler add name=\"nw-down-host2\" start-time=([/system clock get\_time] + 00:01:00) interval=0 on-event=\"/system script run confirm-host2-down\""
add dont-require-permissions=yes name=host-2-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-down-host2\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-up-host2\"] } on-error={}\r\n/system scheduler add name=\"nw-up-host2\" start-time=([/system clock get time] + 00:00:10) interval=0 on-event=\"/system script run confirm-host2-up\""
add dont-require-permissions=yes name=host-1-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":do { /system scheduler remove [find name=\"nw-up-host1\"] } on-error={}\r\n:do { /system scheduler remove [find name=\"nw-down-host1\"] } on-error={}\r\n/system scheduler add name=\"nw-down-host1\" start-time=([/system clock get\_time] + 00:01:00) interval=0 on-event=\"/system script run confirm-host1-down\""
add dont-require-permissions=yes name=confirm-dvr-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownDvr\r\n:if ([/tool netwatch get [find host=\"10.0.20.41\"] status] = \"down\") do={\r\n    :set nwWasDownDvr true\r\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=DVR%20is%20Down\" keep-result=no\r\n}\r\n:do { /system scheduler remove [find name=\"nw-down-dvr\"] } on-error={}"
add dont-require-permissions=yes name=confirm-dvr-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownDvr\r\n:if ([/tool netwatch get [find host=\"10.0.20.41\"] status] = \"up\") do={\r\n    :if (\$nwWasDownDvr = true) do={\r\n        /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=DVR%20is%20UP\" keep-result=no\r\n        :set nwWasDownDvr false\r\n    }\r\n}\r\n:do { /system scheduler remove [find name=\"nw-up-dvr\"] } on-error={}"
add dont-require-permissions=yes name=confirm-host1-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownHost1\r\n:if ([/tool netwatch get [find host=\"10.0.20.29\"] status] = \"down\") do={\r\n    :set nwWasDownHost1 true\r\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Host-1%20is%20Down\" keep-result=no\r\n}\r\n:do { /system scheduler remove [find name=\"nw-down-host1\"] } on-error={}"
add dont-require-permissions=yes name=confirm-host1-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownHost1\r\n:if ([/tool netwatch get [find host=\"10.0.20.29\"] status] = \"up\") do={\r\n    :if (\$nwWasDownHost1 = true) do={\r\n        /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Host-1%20is%20UP\" keep-result=no\r\n        :set nwWasDownHost1 false\r\n    }\r\n}\r\n:do { /system scheduler remove [find name=\"nw-up-host1\"] } on-error={}"
add dont-require-permissions=yes name=confirm-host2-down owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownHost2\r\n:if ([/tool netwatch get [find host=\"10.0.20.30\"] status] = \"down\") do={\r\n    :set nwWasDownHost2 true\r\n    /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Host-2%20Down\" keep-result=no\r\n}\r\n:do { /system scheduler remove [find name=\"nw-down-host2\"] } on-error={}"
add dont-require-permissions=yes name=confirm-host2-up owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global nwWasDownHost2\r\n:if ([/tool netwatch get [find host=\"10.0.20.30\"] status] = \"up\") do={\r\n    :if (\$nwWasDownHost2 = true) do={\r\n        /tool fetch url=\"https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage\?chat_id=<TELEGRAM_CHAT_ID>&text=Host-2%20is%20UP\" keep-result=no\r\n        :set nwWasDownHost2 false\r\n    }\r\n}\r\n:do { /system scheduler remove [find name=\"nw-up-host2\"] } on-error={}"
add comment="Evidence-gated auto-recovery for WG site-to-site tunnel (v2: checks WAN + home reachability before bouncing the port). State (fails,lastAttempt,lastAlert) persisted in the wg-s2s-watchdog-sched scheduler's comment\_field -- :global vars don't survive between scheduler-triggered runs on this build." dont-require-permissions=no name=wg-s2s-watchdog owner=admin policy=read,write,test,sensitive source="\r\n  :local ifaceName \"WG-SiteB\";\r\n  :local peerName \"SiteB-To-SiteA\";\r\n  :local fwComment \"WG-S2S-Listen\";\r\n  :local schedName \"wg-s2s-watchdog-sched\";\r\n  :local staleThreshold 00:02:30;\r\n  :local recoverThreshold 00:00:30;\r\n  :local actionCooldown 00:15:00;\r\n  :local alertCooldown 00:15:00;\r\n  :local wanCheckIp 8.8.8.8;\r\n  :local tgToken \"<TELEGRAM_BOT_TOKEN>\";\r\n  :local tgChat \"<TELEGRAM_CHAT_ID>\";\r\n\r\n  # --- state persistence ---\r\n  # :global vars do NOT survive between separate scheduler-triggered runs\r\n  # on this RouterOS build (confirmed 2026-08-30 via\r\n  # /system script environment print staying empty across runs, which is\r\n  # why the watchdog got stuck logging consecutive=1 forever and never\r\n  # escalated to the evidence-gate/bounce logic during the 2026-08-30\r\n  # outage). Fix: pack fails,lastAttempt,lastAlert into the scheduler's\r\n  # own comment field instead -- same pattern the LogFilter script on\r\n  # this router already uses successfully for its own state.\r\n  :local fails 0;\r\n  :local lastAttempt 00:00:00;\r\n  :local lastAlert 00:00:00;\r\n  :local raw [/system scheduler get [find name=\$schedName] comment];\r\n  :if ([:len \$raw] > 0) do={\r\n    :local p1 [:find \$raw \",\"];\r\n    :if ([:typeof \$p1] != \"nothing\") do={\r\n      :set fails [:tonum [:pick \$raw 0 \$p1]];\r\n      :local rest [:pick \$raw (\$p1+1) [:len \$raw]];\r\n      :local p2 [:find \$rest \",\"];\r\n      :if ([:typeof \$p2] != \"nothing\") do={\r\n        :set lastAttempt [:totime [:pick \$rest 0 \$p2]];\r\n        :set lastAlert [:totime [:pick \$rest (\$p2+1) [:len \$rest]]];\r\n      };\r\n    };\r\n  };\r\n\r\n  :local peer [/interface/wireguard/peers find name=\$peerName];\r\n  :if ([:len \$peer] = 0) do={\r\n    :log error \"WG-Watchdog: peer not found, aborting\";\r\n    /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: SiteB-To-SiteA peer not found -- watchdog cannot run, check router config\" keep-result=no;\r\n    :error \"peer not found\";\r\n  };\r\n\r\n  :local lh [/interface/wireguard/peers get \$peer last-handshake];\r\n  :local upNow [/system resource get uptime];\r\n\r\n  :if (\$lh < \$staleThreshold) do={\r\n    :set fails 0;\r\n    /system scheduler set [find name=\$schedName] comment=(\"\$fails\" .\_\",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n  } else={\r\n    :set fails (\$fails + 1);\r\n    /system scheduler set [find name=\$schedName] comment=(\"\$fails\" .\_\",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n    :log warning \"WG-Watchdog: stale handshake lh=\$lh consecutive=\$fails\";\r\n\r\n    :if (\$fails >= 2) do={\r\n\r\n      :local wanUp false;\r\n      :if ([/ping \$wanCheckIp count=3] > 0) do={ :set wanUp true };\r\n\r\n      :local homeIp [/interface/wireguard/peers get \$peer endpoint-address];\r\n      :local homeUp false;\r\n      :if ([:len \$homeIp] > 0) do={\r\n        :if ([/ping \$homeIp count=3] > 0) do={ :set homeUp true };\r\n      };\r\n\r\n      :log info \"WG-Watchdog: evidence wanUp=\$wanUp homeIp=\$homeIp homeUp=\$homeUp\";\r\n\r\n      :if (\$wanUp = false) do={\r\n        :local sinceAlert (\$upNow - \$lastAlert);\r\n        :if (\$lastAlert = 00:00:00 || \$sinceAlert >= \$alertCooldown) do={\r\n          :log warning \"WG-Watchdog: work WAN appears down, not a tunnel issue\";\r\n          /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: work's own internet appears down (cannot ping \$wanCheckIp) -- NOT a tunnel issue, check work's WAN. Leaving WG config untouched.\" keep-result=no;\r\n          :set lastAlert \$upNow;\r\n          /system scheduler set [find name=\$schedName] comment=(\"\$fails\" . \",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n        };\r\n      } else={\r\n        :if (\$homeUp = false) do={\r\n          :local sinceAlert (\$upNow - \$lastAlert);\r\n          :if (\$lastAlert = 00:00:00 || \$sinceAlert >= \$alertCooldown) do={\r\n            :log warning \"WG-Watchdog: ambiguous, home unreachable via ICMP too\";\r\n            /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: handshake stale (\$lh), work's WAN is up, but cannot confirm cause -- home\_(\$homeIp) unreachable via ICMP too. Ambiguous, leaving WG config untouched. Check manually.\" keep-result=no;\r\n            :set lastAlert \$upNow;\r\n            /system scheduler set [find name=\$schedName] comment=(\"\$fails\" . \",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n          };\r\n        } else={\r\n          :local sinceAttempt (\$upNow - \$lastAttempt);\r\n          :if (\$lastAttempt != 00:00:00 && \$sinceAttempt < \$actionCooldown) do={\r\n            :log info \"WG-Watchdog: confirmed signature but in action-cooldown, skipping (sinceAttempt=\$sinceAttempt)\";\r\n          } else={\r\n            :local wgIface [/interface/wireguard find name=\$ifaceName];\r\n            :if ([:len \$wgIface] = 0) do={\r\n              :log error \"WG-Watchdog: interface not found, aborting bounce\";\r\n              :error \"interface not found\";\r\n            };\r\n\r\n            :local fwRule [/ip/firewall/filter find where comment=\$fwComment];\r\n            :if ([:len \$fwRule] = 0) do={\r\n              :log error \"WG-Watchdog: firewall rule not found, aborting bounce\";\r\n              :error \"firewall rule not found\";\r\n            };\r\n\r\n            :log warning \"WG-Watchdog: confirmed NAT-corruption signature (wanUp + homeUp, WG still stale), attempting port bounce\";\r\n            /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: confirmed signature (work WAN up, home \$homeIp reachable via ICMP, WG still stale at \$lh) -- attempting port bounce\" keep-result=no;\r\n\r\n            :set lastAttempt \$upNow;\r\n            /system scheduler set [find name=\$schedName] comment=(\"\$fails\" . \",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n\r\n            :local curPort [/interface/wireguard get \$wgIface listen-port];\r\n            :local tempPort (\$curPort + 1);\r\n\r\n            /interface/wireguard set \$wgIface listen-port=\$tempPort;\r\n            /ip/firewall/filter set \$fwRule dst-port=\$tempPort;\r\n            :log info \"WG-Watchdog: bounced port \$curPort -> \$tempPort, waiting\";\r\n            :delay 100;\r\n\r\n            /interface/wireguard set \$wgIface listen-port=\$curPort;\r\n            /ip/firewall/filter set \$fwRule dst-port=\$curPort;\r\n            :log info \"WG-Watchdog: reverted to \$curPort, verifying\";\r\n            :delay 15;\r\n\r\n            :local lh2 [/interface/wireguard/peers get \$peer last-handshake];\r\n            :if (\$lh2 < \$recoverThreshold) do={\r\n              :log info \"WG-Watchdog: recovery SUCCESS lh=\$lh2\";\r\n              /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: RECOVERED (last-handshake=\$lh2)\" keep-result=no;\r\n            } else={\r\n              :log error \"WG-Watchdog: recovery FAILED lh=\$lh2\";\r\n              /tool fetch url=\"https://api.telegram.org/bot\$tgToken/sendMessage\" http-method=post http-data=\"chat_id=\$tgChat&text=WG watchdog: port bounce did NOT recover tunnel (last-handshake=\$lh2). Manual check needed.\" keep-result=no;\r\n            };\r\n\r\n            :set fails 0;\r\n            /system scheduler set [find name=\$schedName] comment=(\"\$fails\" . \",\" . \"\$lastAttempt\" . \",\" . \"\$lastAlert\");\r\n          };\r\n        };\r\n      };\r\n    };\r\n  };\r\n"
/interface bridge port
add bridge=bridge comment=defconf ingress-filtering=no interface=ether2 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether3 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether4 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether5 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether6 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether7 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether8 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether9 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether10 internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=sfp1 internal-path-cost=10 path-cost=10
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set max-neighbor-entries=8192
/interface l2tp-server server
set default-profile=VPN use-ipsec=yes
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1 list=WAN
add interface=WG-SiteB list=LAN
/interface wireguard peers
add allowed-address="10.99.0.5/32,10.0.11.0/24,10.0.10.0/24,10.0.20.0/24,10.0.21.0/24,10.0.253.0/24" client-allowed-address=::/0 interface=WG-SiteB name=Admin-Phone persistent-keepalive=25s public-key="<WG_KEY>" responder=yes
add allowed-address=10.99.0.2/32,10.0.11.0/24,10.0.10.0/24 endpoint-address=198.51.100.10 endpoint-port=<WG_PORT> interface=WG-SiteB name=SiteB-To-SiteA persistent-keepalive=25s public-key="<WG_KEY>"
/ip address
add address=10.0.20.1/24 comment=defconf interface=bridge network=10.0.20.0
add address=10.0.21.1/24 interface=bridge network=10.0.21.0
add address=10.99.0.1/24 interface=WG-SiteB network=10.99.0.0
add address=10.99.0.11 comment="Office/mgmt LAN (10.0.20.x) Pi-hole identity - added 2026-08-24" interface=WG-SiteB network=10.99.0.11
# [/ip arp] static ARP table (per-device MACs) removed for publication
# [/ip cloud] DDNS settings removed for publication
/ip dhcp-client
add add-default-route=no comment=defconf interface=ether1 name=ether1 use-peer-dns=no
# [/ip dhcp-server lease] static DHCP leases (per-device MACs/names) removed for publication
/ip dhcp-server network
add address=10.0.20.0/24 comment=defconf dns-server=10.0.11.13,8.8.8.8 gateway=10.0.20.1
add address=10.0.21.0/24 comment="users pool" dns-server=10.0.11.13,8.8.8.8 gateway=10.0.21.1
/ip dns
set allow-remote-requests=yes servers=10.0.11.13,8.8.8.8
/ip dns static
add address=10.0.10.1 disabled=yes name=router.lan type=A
/ip firewall address-list
add address=10.0.11.0/24 comment="Admin Home Sec LAN" list=LAN
add address=10.0.20.0/24 comment=LAN list=LAN
add address=10.99.0.0/24 comment="Admin Lan" list=LAN
add address=10.0.10.1 comment="Admin Home Main LAN" list=LAN
add address=<SITE_DDNS> list=LAN
add address=10.0.11.0/24 list=mgmt
add address=10.0.20.0/24 list=mgmt
add address=10.0.30.0/24 disabled=yes list=mgmt
add address=10.0.10.0/24 list=mgmt
add address=10.0.20.41 list=Allow
add address=10.0.20.2 list=Allow
add address=10.0.20.28 list=Allow
add address=10.0.20.59 list=Allow
add address=10.0.20.61 list=Allow
add address=10.0.20.62 list=Allow
add address=10.0.20.19 list=Allow
add address=10.0.20.5 list=Allow
add address=10.0.20.49 list=Allow
add address=10.0.20.18 list=Allow
add address=10.0.20.65 list=Allow
add address=10.0.20.23 list=Allow
add address=10.0.20.33 list=Allow
add address=10.0.20.11 list=Allow
add address=10.0.20.28 list=DNS
add address=10.0.20.59 list=DNS
add address=10.0.20.200 comment=Client-1 list=Allow
add address=10.0.20.63 list=Allow
add address=10.0.20.46 list=Allow
add address=10.0.20.10 list=Allow
add address=10.0.20.27 list=Allow
add address=10.0.20.51 list=Allow
add address=10.0.20.16 list=Allow
add address=10.0.20.37 list=Allow
add address=10.0.20.29 list=Allow
add address=10.0.20.60 list=Allow
add address=10.0.253.1 comment=LAN list=LAN
add address=10.99.0.0/24 list=mgmt
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
add action=accept chain=forward in-interface=WG-SiteB
add action=accept chain=forward out-interface=WG-SiteB
add action=drop chain=input src-address=10.0.21.0/24
add action=drop chain=forward dst-address=10.0.21.0/24 src-address=10.0.21.0/24
add action=accept chain=forward dst-address=10.0.11.13 dst-port=53 protocol=tcp src-address=10.0.21.0/24
add action=accept chain=forward dst-address=10.0.11.13 dst-port=53 protocol=udp src-address=10.0.21.0/24
add action=drop chain=forward dst-address=10.0.0.0/8 src-address=10.0.21.0/24
add action=drop chain=forward comment="Block known VPN provider IPs (Site B) 2026-08-23" dst-address-list=VPN-Providers out-interface=ether1 src-address=10.0.21.0/24
add action=drop chain=forward comment="Block VPN ports UDP (Site B) 2026-08-23" dst-port=1194,51820,500,4500,1701 out-interface=ether1 protocol=udp src-address=10.0.21.0/24
add action=drop chain=forward comment="Block VPN ports TCP (Site B) 2026-08-23" dst-port=1194,1723 out-interface=ether1 protocol=tcp src-address=10.0.21.0/24
add action=drop chain=forward comment="Block PPTP GRE (Site B) 2026-08-23" out-interface=ether1 protocol=gre src-address=10.0.21.0/24
add action=accept chain=forward out-interface=ether1 src-address=10.0.21.0/24
add action=accept chain=input in-interface=WG-SiteB
add action=accept chain=input src-address-list=LAN
add action=accept chain=input src-address-list=mgmt
add action=accept chain=input in-interface-list=LAN
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=accept chain=input dst-port=<WG_PORT> protocol=udp
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=input comment="drop l2tp brute forcers" in-interface=ether1 src-address-list=l2tp_blacklist
add action=add-src-to-address-list address-list=l2tp_blacklist address-list-timeout=1d chain=input connection-state=new src-address-list=l2tp_stage6
add action=add-src-to-address-list address-list=l2tp_stage6 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage5
add action=add-src-to-address-list address-list=l2tp_stage5 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage4
add action=add-src-to-address-list address-list=l2tp_stage4 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage3
add action=add-src-to-address-list address-list=l2tp_stage3 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage2
add action=add-src-to-address-list address-list=l2tp_stage2 address-list-timeout=1m chain=input connection-state=new src-address-list=l2tp_stage1
add action=add-src-to-address-list address-list=l2tp_stage1 address-list-timeout=1m chain=input connection-state=new src-address-list=!LAN
add action=accept chain=input comment=ICMP/Ping protocol=icmp
add action=accept chain=input comment="L2TP/IPSec VPN" disabled=yes dst-port=500,1701,4500 in-interface=ether1 protocol=udp
add action=accept chain=input comment="PPTP VPN" disabled=yes dst-port=1723 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="PPTP VPN" disabled=yes in-interface=ether1 protocol=gre
add action=accept chain=input comment=WG-S2S-Listen dst-port=<WG_PORT_B> in-interface=ether1 protocol=udp
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=accept chain=input src-address-list=LAN
add action=accept chain=forward comment="Allow DoT TCP for DNS-list" dst-port=853 protocol=tcp src-address-list=DNS
add action=accept chain=forward comment="Allow DoT UDP for DNS-list" dst-port=853 protocol=udp src-address-list=DNS
add action=drop chain=forward comment="Block DoT TCP" dst-port=853 protocol=tcp
add action=drop chain=forward comment="Block DoT UDP" dst-port=853 protocol=udp
/ip firewall mangle
add action=mark-routing chain=prerouting disabled=yes dst-address=10.0.10.4 new-routing-mark=main src-address=10.0.20.61
add action=mark-routing chain=prerouting comment=Client-1 disabled=yes new-routing-mark=vpn-cloud src-address=10.0.20.200
add action=mark-packet chain=output comment="WG tunnel out" dst-port=<WG_PORT> new-packet-mark=wg-tunnel protocol=udp
add action=mark-packet chain=prerouting comment="WG tunnel in" new-packet-mark=wg-tunnel protocol=udp src-port=<WG_PORT>
add action=change-dscp chain=forward comment="VoIP SIP+RTP  DSCP EF (highest)" dst-port=5060,5061,10000-20000 new-dscp=46 protocol=udp
add action=change-dscp chain=forward comment="RDP  DSCP AF41" dst-port=3389 new-dscp=34 protocol=tcp
add action=change-dscp chain=forward comment="SSH  DSCP AF21" dst-port=22 new-dscp=18 protocol=tcp
add action=change-dscp chain=output comment="WireGuard tunnel  DSCP CS5" dst-port=<WG_PORT> new-dscp=40 protocol=udp
/ip firewall nat
add action=src-nat chain=srcnat comment="SNAT Work user-pool to .1 for Pi-hole client separation - 2026-08-24" out-interface=WG-SiteB src-address=10.0.21.0/24 to-addresses=10.99.0.1
add action=src-nat chain=srcnat comment="SNAT office-mgmt-LAN to .11 for Pi-hole client separation - 2026-08-24" out-interface=WG-SiteB src-address=10.0.20.0/24 to-addresses=10.99.0.11
add action=masquerade chain=srcnat comment=WG-MASQ out-interface=WG-SiteB
add action=dst-nat chain=dstnat comment=DNS-redirect-Pihole-TCP dst-port=53 protocol=tcp src-address-list=!DNS to-addresses=10.0.11.13 to-ports=53
add action=dst-nat chain=dstnat comment=DNS-redirect-Pihole-UDP dst-port=53 protocol=udp src-address-list=!DNS to-addresses=10.0.11.13 to-ports=53
add chain=dstnat comment="Redirect DoT TCP to Pi-hole" dst-port=853 protocol=tcp to-addresses=10.0.11.13 to-ports=53
add chain=dstnat comment="Redirect DoT UDP to Pi-hole" dst-port=853 protocol=udp to-addresses=10.0.11.13 to-ports=53
add chain=dstnat comment="Redirect DoH to Pi-hole" dst-address-list=DoH-Servers dst-port=443 protocol=tcp to-addresses=10.0.11.13 to-ports=53
add action=masquerade chain=srcnat comment="defconf: masquerade WAN" ipsec-policy=out,none out-interface=ether1
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add check-gateway=ping disabled=no distance=2 dst-address=0.0.0.0/0 gateway=10.0.253.1%ether1 routing-table=main scope=30 target-scope=10 vrf-interface=ether1
add comment=WG-SITEA-USERS distance=1 dst-address=10.0.10.0/24 gateway=WG-SiteB
add comment=WG-SITEA-SERVERS distance=1 dst-address=10.0.11.0/24 gateway=WG-SiteB
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set www-ssl certificate=Webfig disabled=no port=<MGMT_PORT>
/ip ssh
set password-authentication=yes
/ipv6 nd
set [ find default=yes ] advertise-dns=yes
/ppp secret
add name=<USERNAME> profile=VPN
/routing bfd configuration
add disabled=no
/routing rule
add action=lookup disabled=yes interface=*F routing-mark=vpn-cloud src-address=10.0.20.61/32 table=vpn-cloud
# [/system clock] time zone removed (location) for publication
/system identity
set name=Router-B
/system package update
set channel=long-term
/system scheduler
add comment="2025-11-18 01:23:09" disabled=yes interval=1m name=LogFilter on-event=LogFilter policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
add interval=4w2d name=backup on-event="/system script run backup-and-email" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive start-date=2020-05-16 start-time=04:00:00
add name=telegram-on-reboot on-event="/system script run reboot-check" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
add comment=0,00:10:00,00:05:00 interval=1m30s name=wg-s2s-watchdog-sched on-event="/system script run wg-s2s-watchdog" policy=read,write,test,sensitive start-date=2026-08-18 start-time=20:33:11
/tool e-mail
set certificate-verification=no from=<EMAIL> port=587 server=<SMTP_SERVER> tls=starttls user=<EMAIL>
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool netwatch
add disabled=yes down-script="/ip/dns/set servers=8.8.8.8\nip/dns/cache/flush" host=10.0.10.13 http-codes="" startup-delay=3m test-script="" type=simple up-script="/ip/dns/set servers=10.0.10.13\nip/dns/cache/flush"
add disabled=no down-script="/system/script/run DVR-Down" host=10.0.20.41 http-codes="" interval=15s start-delay=0ms startup-delay=1m test-script="" timeout=3s type=icmp up-script="/system/script/run DVR-UP"
add disabled=no dns-server=10.0.11.13 down-script="/ip dns set servers=8.8.8.8\n/ip firewall nat set [find comment~\"DNS-redirect-Pihole\"] to-addresses=8.8.8.8\n/ip dns cache flush" host=google.com http-codes="" interval=30s name="" record-type=A startup-delay=5m test-script="" timeout=2s type=dns up-script="/ip dns set servers=10.0.11.13,8.8.8.8\n/ip firewall nat set [find comment~\"DNS-redirect-Pihole\"] to-addresses=10.0.11.13\n/ip dns cache flush"
add disabled=no down-script="/system/script/run \"host-1-down\"" host=10.0.20.29 interval=15s start-delay=0ms startup-delay=1m test-script="" timeout=3s type=icmp up-script="/system/script/run \"host-1-up\""
add disabled=no down-script="/system/script/run \"host-2-down\"" host=10.0.20.30 interval=15s start-delay=0ms startup-delay=1m test-script="" timeout=3s type=icmp up-script="/system/script/run \"host-2-up\""

