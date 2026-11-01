# /system script "DVR-UP" (sanitized)
:do { /system scheduler remove [find name="nw-down-dvr"] } on-error={}
:do { /system scheduler remove [find name="nw-up-dvr"] } on-error={}
/system scheduler add name="nw-up-dvr" start-time=([/system clock get time] + 00:00:10) interval=0 on-event="/system script run confirm-dvr-up"
