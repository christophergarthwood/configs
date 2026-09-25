# NETWORKING

[TOC]

## SSH TUNNEL

`ssh -L 8080:<remote-addr-of-server>:80 <username>@<remote-addr> -N`

`ssh -L 8080:192.168.100.30:80 gdit@10.160.24.1 -N`

`ssh -fY remotehost /usr/bin/wmaker`

For spray directly:

```
xhost +remotehost
ssh -f remotehost /usr/bin/wmaker
 ?-display localmachine:1
```

The first option, if your remote SSH server supports it, uses a locally defined DISPLAY that then gets tunneled to your local side over SSH. The second option allows remotehost to send X data directly to your local display, then runs Window Maker there but displays it locally. Now, all your desktop actions are done on the remote machine, not locally. 

## FIREWALLD

[Firewall Refernece](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7)

1. List everything that is open

+ `firewall-cmd --list-all`

+ `firewall-cmd --get-active-zone`

+ `firewall-cmd --list-all-zones | less`

2. Cmds below are for runtime, if permanent change is desired use "--permanent"

  1. Remove port or service

	  Example: `firewall-cmd --zone=public --remove-port=80/tcp`

  2. or if  you know the name of the service

	  Example: `firewall-cmd --zone=public --remove-service=http`

  3. Then reload for the change to take place

 	  Example: `firewall-cmd --reload`

  4. To find out if you change "took"

	Example: `firewall-cmd --zone=<zone> --query-port=80/tcp`

    OR

	Example: `firewall-cmd --zone=<zone> --query-service=http`

## SERVICE MANAGEMENT

```
sudo systemctl start firewalld.service
firewall-cmd --state
systemctl (start | stop | restart) firewalld.service
```

## ZONES

`block dmz drop external home internal public trusted work`


## FIREWALL TESTS

You'll see a message notating success, if nothing comes back you're blocked:

+ `nc -vz bitbucket.di2e.net <port>`
+ `nc -vz bitbucket.di2e.net 443`
+ `nc -vz bitbucket.di2e.net 7999`

## TCPDUMP

+ `sudo tcpdump -i eth14 host 10.160.24.134 and port 443 -n -vvv -A`
+ `sudo tcpdump -i eth14 host 10.160.24.134 -n -vvv -A`
+ `sudo tcpdump -i lo port 8010 -n -vvv -A`

## NETWORK ROUTES

```
#!/bin/sh
route del -net 10.0.0.0 netmask 255.0.0.0 dev eth0
route add -net 10.160.24.0 netmask 255.255.254.0 eth0
route add default gw 10.160.25.254
sudo route add -net 192.168.0.0 netmask 255.255.0.0 gw 10.160.24.187
```

