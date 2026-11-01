# /system script "confirm-host1-up" (sanitized)
:global nwWasDownHost1
:if ([/tool netwatch get [find host="10.0.20.29"] status] = "up") do={
    :if ($nwWasDownHost1 = true) do={
        /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=Host-1%20is%20UP" keep-result=no
        :set nwWasDownHost1 false
    }
}
:do { /system scheduler remove [find name="nw-up-host1"] } on-error={}
