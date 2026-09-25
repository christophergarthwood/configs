# **SSH Tokens Frequently Asked Questions (FAQ)**

[TOC]

### Generating Your SSH Key Pair on Windows 11 🔑

First, you'll need to generate an SSH key pair (a public and a private key) on your Windows 11 machine. 
You can do this using the OpenSSH client, which is included in Windows.
Step	Command	Description
Open Command Prompt or PowerShell	
#### ssh-keygen
##### `ssh-keygen -t rsa -b 4096`	{This command initiates the key generation process.}

 -t rsa specifies the RSA algorithm, and -b 4096 sets the key strength to 4096 bits for better security. 
Choose a file location	(Press Enter)	The system will prompt you to choose a location to save the key. 
Pressing Enter accepts the default location, which is typically C:\Users\YourUserName\.ssh\. 
 
Set a passphrase	(Optional)	You'll be asked to create a passphrase to protect your private key. 
                                While optional, it is highly recommended for security. 
 
If you choose not to use one, just press Enter.
 
This process creates two files in your .ssh directory:
•	id_rsa: This is your private key and should be kept secret.
•	id_rsa.pub: This is your public key, which you will deploy to your RHEL 8 server. 


### Deploying Your Public Key to the RHEL 8 Server 🚀

Now, you need to copy your public key to the RHEL 8 server. This will authorize your Windows 11 machine to connect without a password.
Step	Command	Description
Copy the Public Key	
#### scp
##### `scp $env:USERPROFILE\.ssh\id_rsa.pub user@your_server_ip:/tmp/`	
This command securely copies your public key to the the tmp folder.  The authorized_keys file on your RHEL 8 server is not created. 
 
If the .ssh directory or authorized_keys file doesn't exist, you'll need to create them on the server first. 
Set Permissions (on the RHEL 8 server)
#### ssh

```
ssh user@your_server_ip
mkdir .ssh
cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh 
chmod 600 ~/.ssh/authorized_keys	
```

It's crucial to set the correct permissions for the .ssh directory and the authorized_keys file to ensure security.  

Typically you want the permissions to be:

## Important mode setting

| Item | Sample	| Numeric | Bitwise |
| :--  | :---   | :--- | :--- |
| SSH folder	       | ~/.ssh	                | 700	       | drwx------        |
| Public key	       | ~/.ssh/id_rsa.pub      | 644	       | -rw-r--r--        |
| Private key          | ~/.ssh/id_rsa	        | 600	       | -rw-------        |
| Authorized Keys      | ~/.ssh/authorized_keys | 600	       | -rw-------        |
| Config	       | ~/.ssh/config          | 600	       | -rw-------        |
| Home folder          | ~	                | 755 at most  | drwxr-xr-x at most |

If you do not have the ssh-copy-id command on your Windows machine you can use the following PowerShell command to achieve the same result: 
##### `type $env:USERPROFILE\.ssh\id_rsa.pub | ssh user@your_server_ip "cat >> .ssh/authorized_keys"` 

### Connecting to Your RHEL 8 Server 🖥️
12:23 PM 3/2/2026With your public key deployed, you can now connect to your RHEL 8 server from Windows 11 using SSH.
Step	Command	Description
Open Command Prompt or PowerShell	
#### testing ssh
##### `ssh user@your_server_ip`	
This command will initiate the SSH connection. 
Enter Passphrase	(If you set one)	If you secured your private key with a passphrase, you will be prompted to enter it now. 
 
If the connection is successful, you will be logged into your RHEL 8 server's command line without needing to enter your user password.

