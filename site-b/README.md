# Site B: branch office

## 8. Site-to-site WireGuard plus an auto-recovery watchdog

**Problem.** The branch office needs constant access to the core site's resolver and app server, but
its internet link sits behind an ISP ONT with **double NAT**, and the tunnel kept dying for hours at a time.

**What I built and debugged.**
- A WireGuard site-to-site link with the **branch as initiator** (it's behind NAT, so it dials out
  with a 25 s keepalive), the core site as responder, plus road-warrior peers on the core router.
- I fixed three bring-up faults:
  1. `responder=yes` was set on *both* peers, so neither side ever started a handshake.
  2. RouterOS doesn't create routes from `allowed-address`, so I added static routes for the remote subnets.
  3. Decapsulated traffic landed in the core router's **forward** chain with no accept rule.
- I root-caused the recurring outages from the tunnel's own counters: the branch's `tx` kept
  climbing (keepalives sent) while the core's `rx` stayed frozen, and ICMP between the two public IPs
  still worked. The cause was a **corrupted UDP NAT entry in the upstream ONT**. The keepalives kept
  that entry alive forever. Moving to a new source port forces a fresh NAT entry.
- I wrote a **RouterOS watchdog** on the branch router (every 90 s):
  - A stale handshake on 2 consecutive checks triggers evidence-gathering. The watchdog bounces the
    listen port **only if** its own WAN is up **and** the core site's public IP answers ICMP.
    Otherwise it only sends an alert, because a bounce can't fix a WAN outage.
  - It keeps the firewall rule's port in sync on every bounce, and it uses separate 15-minute
    cooldowns for alerts and actions.
  - It sends Telegram messages on detection, success and failure.

**Result (with the failures included).**
- Outages logged: 2026-06-13, 2026-06-18 (~1 h 41 m), 2026-08-18 (~2 h), 2026-08-29/30 (~14 h).
- A code review **before the first real outage** found a re-entrancy bug: a 115 s bounce ran inside
  a 90 s scheduler interval, so two runs could overlap. I fixed it before it ever fired.
- The ~14 h outage exposed a deeper bug. On this RouterOS build, `:global` variables did **not**
  survive between scheduler-triggered runs, so the failure counter reset every tick. The result was
  **964+ runs and zero recovery attempts**. I moved the state into the scheduler object's own comment
  field and verified that state carries over between real scheduler runs.
- **Open:** the recovery branch hasn't been exercised end-to-end by a real outage since that fix.
  That outage also showed that bouncing *back* to the old port can restore the handshake without
  restoring data flow, so the revert logic is under review.

```routeros
/system scheduler
add name=wg-s2s-watchdog-sched interval=1m30s on-event="/system script run wg-s2s-watchdog" \
    policy=read,write,test,sensitive comment=0,00:10:00,00:05:00   # <- persisted state: fails,lastAttempt,lastAlert
```
Full script: [`scripts/site-b/wg-s2s-watchdog.rsc`](scripts/site-b/wg-s2s-watchdog.rsc)

## 9. Isolated user pool and VPN-bypass prevention

**Problem.** A shared user segment (~70 devices) must have internet only. It must not reach the
office LAN or the core site, and it must not route around the DNS policy with a VPN.

**What I built.**
- **Isolation:** the user pool can reach the core site's Pi-hole on port 53 and the internet,
  nothing else. Client-to-client traffic and router input are dropped as well.
- **VPN bypass, 3 layers** (I describe this as raising the bar, not airtight; a personal VPS on an odd port still gets through):
  1. Common VPN protocol ports are blocked (UDP 1194/51820/500/4500/1701, TCP 1194/1723, GRE).
  2. A **10,849-CIDR** commercial-VPN address list (public X4BNet feed), rebuilt weekly by a cron job.
  3. 36 VPN-provider domains are blocked at the Pi-hole for this group only.
- **Per-subnet DNS identity:** both branch subnets crossed the tunnel as the *same* source IP, so
  the Pi-hole couldn't apply different policies to them. Two SNAT rules give each subnet its own
  tunnel address. An **hourly drift check** alerts on Telegram if the client mapping or the SNAT rule
  order changes (it alerts on state transitions only).

**Result.** I proved the old policy had never applied, using the Pi-hole's real query log, and fixed
it without touching the filter chain. I verified each layer with a temporary test client.

```routeros
/ip firewall filter
add action=accept chain=forward src-address=10.0.21.0/24 dst-address=10.0.11.13 dst-port=53 protocol=udp
add action=drop   chain=forward src-address=10.0.21.0/24 dst-address=10.0.0.0/8
add action=drop   chain=forward src-address=10.0.21.0/24 dst-address-list=VPN-Providers out-interface=ether1
/ip firewall nat
add action=src-nat chain=srcnat src-address=10.0.21.0/24 out-interface=WG-SiteB to-addresses=10.99.0.1
add action=src-nat chain=srcnat src-address=10.0.20.0/24 out-interface=WG-SiteB to-addresses=10.99.0.11
```

## 10. Branch monitoring

- Netwatch with debounced Telegram up/down alerts for the DVR and two critical workstations.
- A boot-notification script: after a reboot it waits until the internet is reachable, then reports the router name and uptime.
- The scheduled config backup (see case 6) also runs here.
<!-- NOTE: a LogFilter log-digest script exists but its scheduler is DISABLED in the 2026-08-30 export - not claimed as active. -->

## 11. 3-2-1 backup for the office accounting server (described only, no configs)

- **Copy 1:** the Windows accounting server makes its own backup **daily** (Windows Task Scheduler).
- **Copy 2:** the backup is copied to a share on the NAS.
- **Copy 3 (off-site):** a script on a Linux host uploads it to S3-compatible object storage
  (DigitalOcean Spaces via `s3cmd`, with its credentials file kept out of the repo) and also copies it
  to a separate network drive.
- After a successful upload, the script moves the file to a "backed up to cloud" folder, applies
  **7-day retention** to the cloud copies, and sends a Telegram success or failure alert.
