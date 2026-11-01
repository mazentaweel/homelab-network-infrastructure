# /system script "confirm-host1-down" (sanitized)
:global nwWasDownHost1
:if ([/tool netwatch get [find host="10.0.20.29"] status] = "down") do={
    :set nwWasDownHost1 true
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=Host-1%20is%20Down" keep-result=no
}
:do { /system scheduler remove [find name="nw-down-host1"] } on-error={}
