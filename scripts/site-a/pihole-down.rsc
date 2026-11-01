# /system script "pihole-down" (sanitized)
:do { /system scheduler remove [find name="nw-up-pihole"] } on-error={}
:do { /system scheduler remove [find name="nw-down-pihole"] } on-error={}
/system scheduler add name="nw-down-pihole" start-time=([/system clock get time] + 00:00:30) interval=0 on-event="/system script run confirm-pihole-down"
