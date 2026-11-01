# /system script "host-1-down" (sanitized)
:do { /system scheduler remove [find name="nw-up-host1"] } on-error={}
:do { /system scheduler remove [find name="nw-down-host1"] } on-error={}
/system scheduler add name="nw-down-host1" start-time=([/system clock get time] + 00:01:00) interval=0 on-event="/system script run confirm-host1-down"
