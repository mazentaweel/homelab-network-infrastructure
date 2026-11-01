# /system script "server-test-up" (sanitized)
:do { /system scheduler remove [find name="nw-down-appsrv"] } on-error={}
:do { /system scheduler remove [find name="nw-up-appsrv"] } on-error={}
/system scheduler add name="nw-up-appsrv" start-time=([/system clock get time] + 00:00:30) interval=0 on-event="/system script run confirm-appsrv-up"
