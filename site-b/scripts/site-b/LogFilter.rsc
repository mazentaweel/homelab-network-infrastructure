# /system script "LogFilter" (sanitized)
:local myserver ([/system identity get name])
:local scheduleName "LogFilter"
:local bot "<TELEGRAM_BOT_TOKEN>"
:local ChatID "<TELEGRAM_CHAT_ID>"
:local startBuf [:toarray [/log find message~" failure" || message~"loop" || message~"down" || message~"fcs" || message~"excessive" || message~"logged"]]

# END SETUP

# warn if schedule does not exist
:if ([:len [/system scheduler find name="$scheduleName"]] = 0) do={
  /log warning "[LogFilter] Alert : Schedule does not exist. Creating schedule ...."

 /system scheduler add name=$scheduleName interval=60s start-date=Jul/05/2019 start-time=startup on-event=LogFilter

  /log warning "[LogFilter] Alert : Schedule created ."
}

# get last time
:local lastTime [/system scheduler get [find name="$scheduleName"] comment]
# for checking time of each log entry
:local currentTime
# log message
:local message
 
# final output
:local output

:local keepOutput false
# if lastTime is empty, set keepOutput to true
:if ([:len $lastTime] = 0) do={
  :set keepOutput true
}

:local counter 0
# loop through all log entries that have been found
:foreach i in=$startBuf do={
 
# loop through all removeThese array items
  :local keepLog true
  :foreach j in=$removeThese do={
#   if this log entry contains any of them, it will be ignored
    :if ([/log get $i message] ~ "$j") do={
      :set keepLog false
    }
  }
  :if ($keepLog = true) do={
   
   :set message [/log get $i message]

#   LOG DATE
#   depending on log date/time, the format may be different. 3 known formats
#   format of jan/01/2002 00:00:00 which shows up at unknown date/time. Using as default
    :set currentTime [ /log get $i time ]
#   format of 00:00:00 which shows up on current day's logs
   :if ([:len $currentTime] = 8 ) do={
     :set currentTime ([:pick [/system clock get date] 0 11]." ".$currentTime)
    } else={
#     format of jan/01 00:00:00 which shows up on previous day's logs
     :if ([:len $currentTime] = 15 ) do={
        :set currentTime ([:pick $currentTime 0 6]."/".[:pick [/system clock get date] 7 11]." ".[:pick $currentTime 7 15])
      }
   }
    
#   if keepOutput is true, add this log entry to output
   :if ($keepOutput = true) do={
     :set output ($output.$currentTime." %0A%0A ".$message."\r\
")
   }

    :if ($currentTime = $lastTime) do={
     :set keepOutput true
     :set output ""
   }
  }
  :if ($counter = ([:len $startBuf]-1)) do={
   :if ($keepOutput = false) do={    
     :if ([:len $message] > 0) do={
        :set output ($output.$currentTimer." ".$message."\r\
")
      }
    }
  }
  :set counter ($counter + 1)
}

if ([:len $output] > 0) do={
  /system scheduler set [find name="$scheduleName"] comment=$currentTime
  /tool fetch url="https://api.telegram.org/bot$bot/sendmessage?chat_id=$ChatID&text=$myserver%0A%0A$output" keep-result=no;
}
