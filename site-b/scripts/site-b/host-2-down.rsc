# /system script "host-2-down" (sanitized)
:do { /system scheduler remove [find name="nw-up-host2"] } on-error={}
:do { /system scheduler remove [find name="nw-down-host2"] } on-error={}
/system scheduler add name="nw-down-host2" start-time=([/system clock get time] + 00:01:00) interval=0 on-event="/system script run confirm-host2-down"
