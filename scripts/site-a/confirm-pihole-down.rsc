# /system script "confirm-pihole-down" (sanitized)
:if ([/tool netwatch get [find host="fb.com"] status] = "down") do={
/ip dns set servers=8.8.8.8
/ip firewall nat set [find comment~"DNS-redirect-Pihole"] to-addresses=8.8.8.8
/ip dns cache flush
/tool wol mac=<MAC> interface=bridge
/tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=PiHole%20is%20Down" keep-result=no
}
:do { /system scheduler remove [find name="nw-down-pihole"] } on-error={}
