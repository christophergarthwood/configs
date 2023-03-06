SSH TUNNEL
	ssh -L 8080:<server-ip-address>:80 <username>@<remote-addr> -N
	ssh -L 8080:192.168.100.30:80 gdit@10.160.24.1 -N

FIREWALLD
	#https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7
	#list everything that is open
	firewall-cmd --list-all
	firewall-cmd --get-active-zone
	firewall-cmd --list-all-zones | less

	#Cmds below are for runtime, if permanent change is desired use "--permanent"
	#remove port or service
	firewall-cmd --zone=public --remove-port=80/tcp
	#or if  you know the name of the service
	firewall-cmd --zone=public --remove-service=http

	#then reload for the change to take place
 	firewall-cmd --reload

	#to find out if you change "took"
	firewall-cmd --zone=<zone> --query-port=80/tcp

	firewall-cmd --zone=<zone> --query-service=http

    #service management
	sudo systemctl start firewalld.service
	firewall-cmd --state
	systemctl (start | stop | restart) firewalld.service

	#zones
	block dmz drop external home internal public trusted work

FIREWALL TESTS
 #you'll see a message notating success, if nothing comes back you're blocked
 nc -vz bitbucket.di2e.net 443
 nc -vz bitbucket.di2e.net 7999

TCPDUMP
	sudo tcpdump -i eth14 host 10.160.24.134 and port 443 -n -vvv -A
	sudo tcpdump -i eth14 host 10.160.24.134 -n -vvv -A
	sudo tcpdump -i lo port 8010 -n -vvv -A

NETWORK ROUTES
	#!/bin/sh
	route del -net 10.0.0.0 netmask 255.0.0.0 dev eth0
	route add -net 10.160.24.0 netmask 255.255.254.0 eth0
	route add default gw 10.160.25.254
	sudo route add -net 192.168.0.0 netmask 255.255.0.0 gw 10.160.24.187

WGET
	http://windev.anteon.com:8080/NMOSW/dod/isarch/database/list/listUserSQL/asXMLwget --http-user=dvignes --http-passwd=test3 

X WINDOW
	startx -- :1 -bpp 24 vt8
	xeyes -display :1

	Run Multiple X Sessions Simultaneously
	On most PCs, you can start more than one X session and switch between them with Ctrl-Alt-F7 and Ctrl-Alt-F8, for example. Why would you do this? Well, some X applications don't really need a full-blown window manager gobbling up your precious RAM and CPU. For example, VMware Workstation and Stellarium are two applications that I use (rarely simultaneously, by the way) that don't need anything but a display. I don't need cut and paste with Stellarium, and VMware is basically a display manager in itself. In addition, just playing with X in this way makes you understand the interrelationships between X, your window manager and your applications. 

	Start your X engine (aka implicit xinit). You probably just use startx, and it reads your .xinitrc file and, doing what it's told, thereby launches X on the first available console, complete with window manager. This is probably display :0. 

	Start your X2 engine (aka explicit xinit). From a terminal, you can launch another X server on your machine:

	xinit /opt/vmware/workstation/bin/vmware
	 ?-display :1 -- :1 &
	The first argument taken by xinit is the path for the client that will be launched. It must be an absolute path starting at /. Everything after the -- is passed to the X server. Read the xinit(1) man page a bit for more fine examples. 

	Fire off your local X server:
	xinit /usr/bin/xterm -- :1 &
	This yields a vanilla X session with merely an xterm runningno window manager. Now, you need to add permissions to this window session for the remote host. You can tunnel the connection through SSH if your network is insecure, but there's a distinct performance hit. If your network is secure, you can simply do xhost +remotehost and spray directly to your X server. 

	For tunneled SSH: 
	ssh -fY remotehost /usr/bin/wmaker
	For spray directly:
	xhost +remotehost
	ssh -f remotehost /usr/bin/wmaker
	 ?-display localmachine:1
	The first option, if your remote SSH server supports it, uses a locally defined DISPLAY that then gets tunneled to your local side over SSH. The second option allows remotehost to send X data directly to your local display, then runs Window Maker there but displays it locally. Now, all your desktop actions are done on the remote machine, not locally. 
