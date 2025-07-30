#!/usr/bin/env ksh

export ISO_8601=$(date +'%Y%m%d');
export command_rsync="/usr/bin/rsync";
export source="/var/opt/gitlab/git-data/";
export destination="/scratch/GIT_BACKUPS/git-data/";
export destination_log="/scratch/GIT_BACKUPS/${ISO_8601}_backup.log";

echo "Executing backup of 'bare' repositories from Git Lab";
echo "...$command_rsync -avz ${source} ${destination}";
#$command_rsync -avz --progress "${source}" "${target}" | tee -i -a "${destination_log}"
$command_rsync -avz --progress "${source}" "${target}"

status=$?;
if [ "${status}" -ne 0 ];
then
    echo "WARNING: Unsuccessful ${command_rsync} execution.";
    echo "WARNING: Please inspect ${destination_log} for insight as to what might have occurred.";
    echo "ERROR: Aborting backups.";
    exit 2;
else
    echo "SUCCESS, backup completed."
    echo "See ${destination_log} for details about the backup.";
fi
