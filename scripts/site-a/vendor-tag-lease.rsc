# /system script "vendor-tag-lease" (sanitized)
:if ($leaseBound=1) do={
    :local mac $leaseActMAC
    :local ip $leaseActIP
    :local lease [/ip dhcp-server lease find mac-address=$mac]
    :if ([:len $lease] > 0) do={
      :local cmt [/ip dhcp-server lease get $lease comment]
      :if ($cmt = "") do={
        :local vendor "unknown vendor"
        :do {
          :local result [/tool fetch url="https://api.macvendors.com/$mac" as-value output=user check-certificate=yes]
          :set vendor ($result->"data")
        } on-error={
          :set vendor "vendor lookup failed"
        }
        /ip dhcp-server lease set $lease comment=$vendor
        :local body "{\"chat_id\":\"<TELEGRAM_CHAT_ID>\",\"text\":\"New device auto-tagged on MikroTik\\
MAC: $mac\\
Vendor: $vendor\\
IP: $ip\"}"
        :do {
          /tool fetch url="https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage" http-method=post http-header-field="Content-Type: application/json" http-data=$body output=none check-certificate=yes
        } on-error={}
      }
    }
  }
