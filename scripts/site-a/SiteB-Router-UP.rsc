# /system script "SiteB-Router-UP" (sanitized)
:do { /system scheduler remove [find name="nw-down-siteb"] } on-error={}
:do { /system scheduler remove [find name="nw-up-siteb"] } on-error={}
/system scheduler add name="nw-up-siteb" start-time=([/system clock get time] + 00:00:30) interval=0 on-event="/system script run confirm-siteb-up"
