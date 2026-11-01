# /system script "host-1-up" (sanitized)
:do { /system scheduler remove [find name="nw-down-host1"] } on-error={}
:do { /system scheduler remove [find name="nw-up-host1"] } on-error={}
/system scheduler add name="nw-up-host1" start-time=([/system clock get time] + 00:00:10) interval=0 on-event="/system script run confirm-host1-up"
