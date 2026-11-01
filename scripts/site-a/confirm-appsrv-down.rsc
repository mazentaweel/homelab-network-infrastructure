# /system script "confirm-appsrv-down" (sanitized)
:if ([/tool netwatch get [find host="10.0.11.90"] status] = "down") do={
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=App%20Server%20is%20Down" keep-result=no
}
:do { /system scheduler remove [find name="nw-down-appsrv"] } on-error={}
