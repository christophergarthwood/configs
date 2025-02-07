#!/usr/bin/bash

# The layers in the TCP/IP network model, in order, include:
# Layer 5: Application
# Layer 4: Transport
# Layer 3: Network/Internet
# Layer 2: Data Link
# Layer 1: Physical
# Reference: https://www.redhat.com/sysadmin/beginners-guide-network-troubleshooting-linux


the_tools=( net-tools iftop vnstat iptraf hping3 dstat slum bmon nmap )
sudo apt install nmap
clear;
echo " ";
echo "################################";
echo "Installing minimal network debugging tools."
for the_tool in ${the_tools[@]}
do
    sudo apt install "${the_tool}";
    status=$?
    if [ "${status}" -ne 0 ];
    then
        echo "...successfully installed ${the_tool}";
    fi
done
echo "Tool installation complete.";
echo "################################";
echo " ";

export target_name="www.google.com";
echo "Establishing target NAME [${target_name}]";
export target_ip="8.8.8.8";
echo "Establishing target IP [${target_ip}]";
sudo ufw disable;
echo "...firewall disabled";
echo " ";

echo "################################";
echo "Layer1: The Physical Layer";
echo " ";
sudo ip link set eth0 up;
ip addr | grep eth0;
echo "...etho UP";
echo "...etho status";
sudo ip -s link show eth0
echo "...etho details";
sudo ethtool eth0
echo "################################";
echo " ";

echo "################################";
echo "Layer2: The data link layer";
echo " ";
sudo ip neighbor show
echo "################################";
echo " ";

echo "################################";
echo "Layer 3: The network/internet layer";
echo " ";
sudo ip -br address show
echo "...ping ${target_ip}";
ping -c 4 "${target_ip}"
echo "DNS check";
echo "...ping ${target_name}";
ping -c 4 "${target_name}";
echo "...DNS settings.";
cat /etc/resolv.conf
echo "...tracing route of ${target_ip}";
traceroute -4 "${target_ip}"
echo "...tracing route of ${target_name}";
traceroute -4 "${target_name}"
echo "...routing table";
sudo ip route show;
echo "...nslookup ${target_name}";
sudo nslookup "${target_name}";
echo "################################";
echo " ";

echo "################################";
echo "Layer 4: The transport layer";
echo " ";
echo "...show all potential data exchanges";
#sudo ss -tunlp4
sudo netstat -tulnp
echo "################################";
echo " ";

