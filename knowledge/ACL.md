# Access Control Lists

[TOC]

How to Use ACLs in a STIG'd Environment
When you implement ACLs, you are adding a layer of control. The best way to justify this to an auditor is to demonstrate that you are improving security.


## Using ACL
 
The acl require the mount point to have acl option added to the mount point.  Check the /etc/mtab file to verify it is there.  It is because the ACL must be set as mount point option. I really think simply setting the o (world) to umask 2 AKA chmod o+rx for the directory and o+r for files. This setting is within STIG rules.

### Set the ACL

# Instead of ACL simple do world readable 
## `find /app1 -type d -exec chmod o+rx {} +`

## `find /app1 -type f -exec chmod o+r {} +`

### This is not needed.

### Add user to group

#### `usermod -aG scan username`

### How to set/remove ACL with setfacl (-m adds -r removes -R all subfolders)

## Set folder (repeat if new folder are added)

### `find /app1/*tomcat/ -type d -exec setfacl -d -m g:scan:r-x {} +`

## Set files (repeat if new files are added)

### `find /opt/*tomcat/ -type f -exec setfacl -d -m g:scan:r-- {} +`

### Verify the ACL with getfacl

## Remove ACL

### `setfacl -Rbk /app1/apache-t*`

#### `getfacl /app1/tomcat`

### Show who is in group
#### `groups scan`

### Verify the group exists

#### `getent group scan`


<div align="center" style="margin: 20px 0; padding: 10px; background-color: #f0f0f0; border: 2px solid #999;"> <strong style="font-size: 72px; color: #666;"> <H1>DRAFT</H1> </strong> </div>
