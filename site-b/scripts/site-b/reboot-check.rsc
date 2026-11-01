# /system script "reboot-check" (sanitized)
:local botToken "<TELEGRAM_BOT_TOKEN>"

:local chatId "<TELEGRAM_CHAT_ID>"

:local routerName [/system identity get name]
:local uptime [/system resource get uptime]

# Delay before checking internet (to ensure router is ready)
:delay 30

# Check if there is an internet connection (ping 8.8.8.8)
:local isOnline false
:local i 0

# Try pinging 8.8.8.8 up to 5 times
:while ($i < 5 && $isOnline = false) do={
    :if ([/ping 8.8.8.8 count=1] > 0) do={
        :set isOnline true
    } else={
        :put "No internet, retrying..."
        :delay 5
        :set i ($i + 1)
    }
}

# Exit script if no internet connection
:if ($isOnline = false) do={
    :put "No internet connection. Skipping Telegram notification."
    /log warning "No internet connection. Skipping Telegram notification."
    return
}

# Now that we have internet, retrieve the public IP
:local publicIP [/ip cloud get public-address]

# If public IP is empty, set it to a fallback value
:if ([:len $publicIP] = 0) do={
    :set publicIP "Not Available"
}

# Construct the message
:local message ("\F0\9F\9A\80 Router " . $routerName . " has rebooted!%0AUptime before reboot: " . $uptime . "%0APublic IP: " . $publicIP)

# Construct the URL for the Telegram API
:local url ("https://api.telegram.org/bot" . $botToken . "/sendMessage?chat_id=" . $chatId . "&text=" . $message)

# Send the message using /tool fetch
/tool fetch url=$url mode=https http-method=get keep-result=no
