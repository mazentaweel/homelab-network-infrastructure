# /system script "wg-s2s-watchdog" (sanitized)
:local ifaceName "WG-SiteB";
  :local peerName "SiteB-To-SiteA";
  :local fwComment "WG-S2S-Listen";
  :local schedName "wg-s2s-watchdog-sched";
  :local staleThreshold 00:02:30;
  :local recoverThreshold 00:00:30;
  :local actionCooldown 00:15:00;
  :local alertCooldown 00:15:00;
  :local wanCheckIp 8.8.8.8;
  :local tgToken "<TELEGRAM_BOT_TOKEN>";
  :local tgChat "<TELEGRAM_CHAT_ID>";

  # --- state persistence ---
  # :global vars do NOT survive between separate scheduler-triggered runs
  # on this RouterOS build (confirmed 2026-08-30 via
  # /system script environment print staying empty across runs, which is
  # why the watchdog got stuck logging consecutive=1 forever and never
  # escalated to the evidence-gate/bounce logic during the 2026-08-30
  # outage). Fix: pack fails,lastAttempt,lastAlert into the scheduler's
  # own comment field instead -- same pattern the LogFilter script on
  # this router already uses successfully for its own state.
  :local fails 0;
  :local lastAttempt 00:00:00;
  :local lastAlert 00:00:00;
  :local raw [/system scheduler get [find name=$schedName] comment];
  :if ([:len $raw] > 0) do={
    :local p1 [:find $raw ","];
    :if ([:typeof $p1] != "nothing") do={
      :set fails [:tonum [:pick $raw 0 $p1]];
      :local rest [:pick $raw ($p1+1) [:len $raw]];
      :local p2 [:find $rest ","];
      :if ([:typeof $p2] != "nothing") do={
        :set lastAttempt [:totime [:pick $rest 0 $p2]];
        :set lastAlert [:totime [:pick $rest ($p2+1) [:len $rest]]];
      };
    };
  };

  :local peer [/interface/wireguard/peers find name=$peerName];
  :if ([:len $peer] = 0) do={
    :log error "WG-Watchdog: peer not found, aborting";
    /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: SiteB-To-SiteA peer not found -- watchdog cannot run, check router config" keep-result=no;
    :error "peer not found";
  };

  :local lh [/interface/wireguard/peers get $peer last-handshake];
  :local upNow [/system resource get uptime];

  :if ($lh < $staleThreshold) do={
    :set fails 0;
    /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");
  } else={
    :set fails ($fails + 1);
    /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");
    :log warning "WG-Watchdog: stale handshake lh=$lh consecutive=$fails";

    :if ($fails >= 2) do={

      :local wanUp false;
      :if ([/ping $wanCheckIp count=3] > 0) do={ :set wanUp true };

      :local homeIp [/interface/wireguard/peers get $peer endpoint-address];
      :local homeUp false;
      :if ([:len $homeIp] > 0) do={
        :if ([/ping $homeIp count=3] > 0) do={ :set homeUp true };
      };

      :log info "WG-Watchdog: evidence wanUp=$wanUp homeIp=$homeIp homeUp=$homeUp";

      :if ($wanUp = false) do={
        :local sinceAlert ($upNow - $lastAlert);
        :if ($lastAlert = 00:00:00 || $sinceAlert >= $alertCooldown) do={
          :log warning "WG-Watchdog: work WAN appears down, not a tunnel issue";
          /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: work's own internet appears down (cannot ping $wanCheckIp) -- NOT a tunnel issue, check work's WAN. Leaving WG config untouched." keep-result=no;
          :set lastAlert $upNow;
          /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");
        };
      } else={
        :if ($homeUp = false) do={
          :local sinceAlert ($upNow - $lastAlert);
          :if ($lastAlert = 00:00:00 || $sinceAlert >= $alertCooldown) do={
            :log warning "WG-Watchdog: ambiguous, home unreachable via ICMP too";
            /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: handshake stale ($lh), work's WAN is up, but cannot confirm cause -- home ($homeIp) unreachable via ICMP too. Ambiguous, leaving WG config untouched. Check manually." keep-result=no;
            :set lastAlert $upNow;
            /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");
          };
        } else={
          :local sinceAttempt ($upNow - $lastAttempt);
          :if ($lastAttempt != 00:00:00 && $sinceAttempt < $actionCooldown) do={
            :log info "WG-Watchdog: confirmed signature but in action-cooldown, skipping (sinceAttempt=$sinceAttempt)";
          } else={
            :local wgIface [/interface/wireguard find name=$ifaceName];
            :if ([:len $wgIface] = 0) do={
              :log error "WG-Watchdog: interface not found, aborting bounce";
              :error "interface not found";
            };

            :local fwRule [/ip/firewall/filter find where comment=$fwComment];
            :if ([:len $fwRule] = 0) do={
              :log error "WG-Watchdog: firewall rule not found, aborting bounce";
              :error "firewall rule not found";
            };

            :log warning "WG-Watchdog: confirmed NAT-corruption signature (wanUp + homeUp, WG still stale), attempting port bounce";
            /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: confirmed signature (work WAN up, home $homeIp reachable via ICMP, WG still stale at $lh) -- attempting port bounce" keep-result=no;

            :set lastAttempt $upNow;
            /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");

            :local curPort [/interface/wireguard get $wgIface listen-port];
            :local tempPort ($curPort + 1);

            /interface/wireguard set $wgIface listen-port=$tempPort;
            /ip/firewall/filter set $fwRule dst-port=$tempPort;
            :log info "WG-Watchdog: bounced port $curPort -> $tempPort, waiting";
            :delay 100;

            /interface/wireguard set $wgIface listen-port=$curPort;
            /ip/firewall/filter set $fwRule dst-port=$curPort;
            :log info "WG-Watchdog: reverted to $curPort, verifying";
            :delay 15;

            :local lh2 [/interface/wireguard/peers get $peer last-handshake];
            :if ($lh2 < $recoverThreshold) do={
              :log info "WG-Watchdog: recovery SUCCESS lh=$lh2";
              /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: RECOVERED (last-handshake=$lh2)" keep-result=no;
            } else={
              :log error "WG-Watchdog: recovery FAILED lh=$lh2";
              /tool fetch url="https://api.telegram.org/bot$tgToken/sendMessage" http-method=post http-data="chat_id=$tgChat&text=WG watchdog: port bounce did NOT recover tunnel (last-handshake=$lh2). Manual check needed." keep-result=no;
            };

            :set fails 0;
            /system scheduler set [find name=$schedName] comment=("$fails" . "," . "$lastAttempt" . "," . "$lastAlert");
          };
        };
      };
    };
  };
