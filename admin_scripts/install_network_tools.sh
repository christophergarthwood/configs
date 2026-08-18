#!/usr/bin/bash

if sudo -n true 2>/dev/null; then
    echo "Sudo access active (or cached)"
else
    echo "Password required or no sudo access."
fi

sudo apt-get install net-tools
sudo apt install iftop
sudo apt install vnstat
sudo apt install iptraf
sudo apt install hping3
sudo apt install dstat
sudo apt install slurm
sudo apt install bmon
sudo apt install nmap
