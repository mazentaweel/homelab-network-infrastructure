# /system script "confirm-host2-down" (sanitized)
:global nwWasDownHost2
:if ([/tool netwatch get [find host="10.0.20.30"] status] = "down") do={
    :set nwWasDownHost2 true
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=Host-2%20Down" keep-result=no
}
:do { /system scheduler remove [find name="nw-down-host2"] } on-error={}
