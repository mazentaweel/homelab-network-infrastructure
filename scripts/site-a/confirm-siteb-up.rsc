# /system script "confirm-siteb-up" (sanitized)
:if ([/tool netwatch get [find host="10.0.20.1"] status] = "up") do={
    /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=Site-B%20router%20VPN%20is%20UP" keep-result=no
}
:do { /system scheduler remove [find name="nw-up-siteb"] } on-error={}
