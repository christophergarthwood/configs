#!/usr/bin/bash

# Give the owner exclusive access to the directory
if ! [ -d ~/.ssh ];
then
    echo "ERROR: ~/.ssh not found, unable to align permissions.";
    echo "Aborting...";
    exit 1;
fi
chmod 700 ~/.ssh

# Set private keys and configuration to owner read/write only
chmod 600 ~/.ssh/id_* ~/.ssh/authorized_keys ~/.ssh/config 2>/dev/null

# Allow public keys to be readable by others
chmod 644 ~/.ssh/*.pub ~/.ssh/known_hosts 2>/dev/null

echo "Finished setting permissions for your ~/.ssh folder.";
