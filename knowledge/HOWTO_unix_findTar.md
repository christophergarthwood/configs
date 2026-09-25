# FIND and TAR

[TOC]

## FIND / TAR

`find . -type f -print0 | tar czvf backup.tar.gz --null -T -`

`find . -type f \( -iname "*.rc" -o -iname "*.env" \) -print0 | tar cvfz ~/user_dirs/cwood/RC.tgz --null -T -`

## FIND / RUN MULTIPLE PROCESSES

`find . -name '*.log' -mtime +3 -print0 | xargs -0 -P 4 bzip2`

## TAR IMPROVED

More efficient due to methods used.

`tar -Igzip -xvf ./myTar.tgz ./someFiles` 

## FIND FILES MODIFIED YESTERDAY AND COPY

`find -type f -name "merged*.nc" -mtime -1 -print -exec cp {} ~/Downloads \`;

## FIND EXECUTABLES AND DELETE

`find ./ -type f -print | xargs file $1 | grep executable | cut -d: -f1 | xargs rm -rf $1`

## FIND LARGEST FOLDER IN YOUR HOME (OR ANYWHERE)
du -xhd1 "$HOME" 2>/dev/null | sort -hr

## FIND BREAKOUT OF FOLDER SIZES

`find "$HOME" -xdev -type f -printf '%s\t%p\n' 2>/dev/null | sort -nr | head -50 | numfmt --field=1 --to=iec  `
