FIND / TAR
find . -type f -print0 | tar czvf backup.tar.gz --null -T -
find . -type f \( -iname "*.rc" -o -iname "*.env" \) -print0 | tar cvfz ~/user_dirs/cwood/RC.tgz --null -T -

FIND / RUN MULTIPLE PROCESSES
find . -name '*.log' -mtime +3 -print0 | xargs -0 -P 4 bzip2

TAR IMPROVED
tar -Igzip -xvf ./myTar.tgz ./someFiles #more efficient

FIND FILES MODIFIED YESTERDAY AND COPY
find -type f -name "merged*.nc" -mtime -1 -print -exec cp {} ~/Downloads \;

FIND EXECUTABLES AND DELETE
find ./ -type f -print | xargs file $1 | grep executable | cut -d: -f1 | xargs rm -rf $1
