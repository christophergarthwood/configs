# **FIND Frequently Asked Questions (FAQ)**

## FIND and TAR

[TOC]

### Find Content and then Tar results

`find . -type f -print0 | tar czvf backup.tar.gz --null -T - find . -type f ( -iname ".rc" -o -iname ".env" ) -print0 | tar cvfz ~/user_dirs/cwood/RC.tgz --null -T -`

`find . -type f -print0 | tar czvf backup.tar.gz --null -T -`

`find . -type f \( -iname "*.rc" -o -iname "*.env" \) -print0 | tar cvfz ~/user_dirs/cwood/RC.tgz --null -T -`

### Find and then run multiple processes splitting the load 

`find . -name '*.log' -mtime +3 -print0 | xargs -0 -P 4 bzip2`

### Tar Improved - more efficient
`tar -Igzip -xvf ./myTar.tgz ./someFiles`

### Find Files Modified Yesterday and Copy them

`find -type f -name "merged*.nc" -mtime -1 -print -exec cp {} ~/Downloads ;`

### Find Executables and then delete them

`find ./ -type f -print | xargs file $1 | grep executable | cut -d: -f1 | xargs rm -rf $1`

## Find Largest Folder In Your $HOME (or anywhere)
du -xhd1 "$HOME" 2>/dev/null | sort -hr

## FInd Breakout of Folder Sizes

`find "$HOME" -xdev -type f -printf '%s\t%p\n' 2>/dev/null | sort -nr | head -50 | numfmt --field=1 --to=iec  `
