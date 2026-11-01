# /system script "host-2-up" (sanitized)
:do { /system scheduler remove [find name="nw-down-host2"] } on-error={}
:do { /system scheduler remove [find name="nw-up-host2"] } on-error={}
/system scheduler add name="nw-up-host2" start-time=([/system clock get time] + 00:00:10) interval=0 on-event="/system script run confirm-host2-up"
