# /system script "confirm-dvr-up" (sanitized)
:global nwWasDownDvr
:if ([/tool netwatch get [find host="10.0.20.41"] status] = "up") do={
    :if ($nwWasDownDvr = true) do={
        /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=DVR%20is%20UP" keep-result=no
        :set nwWasDownDvr false
    }
}
:do { /system scheduler remove [find name="nw-up-dvr"] } on-error={}
