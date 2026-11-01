# /system script "DVR-Down" (sanitized)
:do { /system scheduler remove [find name="nw-up-dvr"] } on-error={}
:do { /system scheduler remove [find name="nw-down-dvr"] } on-error={}
/system scheduler add name="nw-down-dvr" start-time=([/system clock get time] + 00:01:00) interval=0 on-event="/system script run confirm-dvr-down"
