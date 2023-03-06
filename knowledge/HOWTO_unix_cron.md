CRONTAB
@reboot /path/to/job              #runs the command
@reboot sleep 300 && /path/to/job #runs the command after startup and 5 minutes later.

Example CRONJOB
#min hour day month command
MAILTO=christopher.wood@nrlssc.navy.mil
30 07 * * * /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm_cron.sh -e /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm.env > /projects/tods-rt/tods_operational/logs/ofm_cron.log 2>&1
