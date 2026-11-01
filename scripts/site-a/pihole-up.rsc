# /system script "pihole-up" (sanitized)
:do { /system scheduler remove [find name="nw-down-pihole"] } on-error={}
:do { /system scheduler remove [find name="nw-up-pihole"] } on-error={}
/system scheduler add name="nw-up-pihole" start-time=([/system clock get time] + 00:00:30) interval=0 on-event="/system script run confirm-pihole-up"
