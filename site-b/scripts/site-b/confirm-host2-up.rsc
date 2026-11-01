# /system script "confirm-host2-up" (sanitized)
:global nwWasDownHost2
:if ([/tool netwatch get [find host="10.0.20.30"] status] = "up") do={
    :if ($nwWasDownHost2 = true) do={
        /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=Host-2%20is%20UP" keep-result=no
        :set nwWasDownHost2 false
    }
}
:do { /system scheduler remove [find name="nw-up-host2"] } on-error={}
