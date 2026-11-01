# /system script "confirm-dvr-down" (sanitized)
:global nwWasDownDvr
:if ([/tool netwatch get [find host="10.0.20.41"] status] = "down") do={
    :set nwWasDownDvr true
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=DVR%20is%20Down" keep-result=no
}
:do { /system scheduler remove [find name="nw-down-dvr"] } on-error={}
