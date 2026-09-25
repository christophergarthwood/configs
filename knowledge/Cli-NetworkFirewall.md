# Network & Systems Administration FAQ

## SSH & Tunneling

### How do I create an SSH tunnel to forward a local port?

To forward a local port to a remote destination through a jump host (tunneling), use the `-L` flag.

- **Syntax:** `ssh -L [LocalPort]:[TargetIP]:[TargetPort] [User]@[GatewayIP] -N`
- **Example:** Forward local port 8080 to port 80 on a target machine (192.168.100.30) via a gateway (10.160.24.1):

`ssh -L 8080:192.168.100.30:80 gdit@10.160.24.1 -N`

## Firewall Management (Firewalld)

### How do I view the current firewall configuration?

You can list all active rules, zones, and active configurations using the following commands:

- **List everything open:** `firewall-cmd --list-all`
- **Get active zones:** `firewall-cmd --get-active-zone`
- **List all zones:** `firewall-cmd --list-all-zones | less`
- **Check general status:** `firewall-cmd --state`

### How do I remove a port or service?

*Note: The commands below affect the **runtime** configuration. To make changes persist after a reboot, append the `--permanent` flag to the command.*

- **Remove a specific port:**
`firewall-cmd --zone=public --remove-port=80/tcp`

- **Remove a specific service:**
`firewall-cmd --zone=public --remove-service=http`

### How do I apply and verify changes?

After modifying rules, you must reload the firewall.

1. **Reload:** `firewall-cmd --reload`
2. **Verify Port Removal:** `firewall-cmd --zone=<zone> --query-port=80/tcp`
3. **Verify Service Removal:** `firewall-cmd --zone=<zone> --query-service=http`

### How do I manage the Firewalld service itself?

Use `systemctl` for service-level management:

`sudo systemctl start firewalld.service

Options: start | stop | restart

### What are the standard zones available?

Common zones include: `block`, `dmz`, `drop`, `external`, `home`, `internal`, `public`, `trusted`, `work`.

## Network Routing (Legacy vs. Modern)

### How do I manage routing tables?

Modern Linux distributions have deprecated `net-tools` (including `route` and `ifconfig`) in favor of the `iproute2` suite. Below is a comparison of the legacy commands provided and their modern equivalents.

| Action | Legacy Command (`route`) | Modern Command (`ip route`) |
|:-------|:-------------------------|:----------------------------|
| **Delete Route** | `route del -net 10.0.0.0 netmask 255.0.0.0 dev eth0` | `ip route del 10.0.0.0/8 dev eth0` |
| **Add Static Route** | `route add -net 10.160.24.0 netmask 255.255.254.0 eth0` | `ip route add 10.160.24.0/23 dev eth0` |
| **Add Default GW** | `route add default gw 10.160.25.254` | `ip route add default via 10.160.25.254` |
| **Route via GW** | `sudo route add -net 192.168.0.0 netmask 255.255.0.0 gw 10.160.24.187` | `sudo ip route add 192.168.0.0/16 via 10.160.24.187` |

**Quick Reference for Subnet Masks (CIDR):**

- `255.0.0.0` → `/8`
- `255.255.0.0` → `/16`
- `255.255.254.0` → `/23`
- `255.255.255.0` → `/24`

## Network Diagnostics

```
route del -net 10.0.0.0 netmask 255.0.0.0 dev eth0
route add -net 10.160.24.0 netmask 255.255.254.0 eth0
route add default gw 10.160.25.254
sudo route add -net 192.168.0.0 netmask 255.255.0.0 gw 10.160.24.187
```

### How do I check connectivity to a specific port?

Use `nc` (Netcat) to scan a specific port. If the connection is successful, you will see a success message; otherwise, it will time out or be refused.

- **Check SSL (443):** `nc -vz bitbucket.di2e.net 443`
- **Check Custom Port:** `nc -vz bitbucket.di2e.net 7999`

### How do I capture packet traffic (Tcpdump)?

Use `tcpdump` with the `-A` flag to see ASCII output (useful for reading headers).

- **Capture host traffic on specific port:**
`sudo tcpdump -i eth14 host 10.160.24.134 and port 443 -n -vvv -A`


- **Capture all traffic from host:**
`sudo tcpdump -i eth14 host 10.160.24.134 -n -vvv -A`

- **Capture loopback traffic:**
`sudo tcpdump -i lo port 8010 -n -vvv -A`

### How do I use Wget with authentication?

`wget http://windev.anteon.com:8080/NMOSW/dod/isarch/database/list/listUserSQL/asXML --http-user=dvignes --http-passwd=test3`

## X Window System

### How do I run multiple X sessions simultaneously?

You can run lightweight X sessions (without full window managers) on different display numbers (e.g., `:1`) to save RAM or run specific single-window applications like VMware or Stellarium. You can switch between them using `Ctrl-Alt-F7`, `Ctrl-Alt-F8`, etc.

- **Start a specific X display:** `startx -- :1 -bpp 24 vt8`
- **Test with xeyes:** `xeyes -display :1`
- **Start a standalone app (Explicit xinit):**

`xinit /opt/vmware/workstation/bin/vmware -- :1 &`

Or a simple terminal

`xinit /usr/bin/xterm -- :1 &`

### How do I display a remote X application locally?

There are two main methods: Tunneling (secure) or Direct Spraying (insecure/performant).

- **Method 1: SSH Tunneling (Recommended)**

Uses the local display configuration tunneled over SSH.

`ssh -fY remotehost /usr/bin/wmaker`

- **Method 2: Direct X11 Forwarding ("Spraying")**

Requires allowing the remote host permission to write to your local display using `xhost`.

#### Allow the remote host
`xhost +remotehost`

#### Run the command directed at local display

`ssh -f remotehost /usr/bin/wmaker -display localmachine:1`

### Certificates

Certificate Checking

`openssl s_client --connect <your_server:443> -cert <path to pem> -key <path to key> -CAfile <path to bundle>`
