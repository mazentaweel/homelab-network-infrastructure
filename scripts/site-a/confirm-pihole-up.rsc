# /system script "confirm-pihole-up" (sanitized)
:if ([/tool netwatch get [find host="fb.com"] status] = "up") do={
/ip dns set servers=10.0.11.13,8.8.8.8
/ip firewall nat set [find comment~"DNS-redirect-Pihole"] to-addresses=10.0.11.13
/ip dns cache flush
/tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage?chat_id=<TELEGRAM_CHAT_ID>&text=PiHole%20is%20Up" keep-result=no
}
:do { /system scheduler remove [find name="nw-up-pihole"] } on-error={}
