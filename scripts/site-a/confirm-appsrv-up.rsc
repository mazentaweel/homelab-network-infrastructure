# /system script "confirm-appsrv-up" (sanitized)
:if ([/tool netwatch get [find host="10.0.11.90"] status] = "up") do={
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=App%20Server%20is%20UP" keep-result=no
}
:do { /system scheduler remove [find name="nw-up-appsrv"] } on-error={}
