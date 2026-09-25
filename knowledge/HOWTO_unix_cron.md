# CRONTAB

[TOC]

## BASICS

crontab (short for "cron table") is a Linux/Unix system file used to schedule and automate tasks. These automated tasks are called cron jobs.A background process named crond (the cron daemon) wakes up every minute, checks your crontab file, and runs any script or command that is scheduled for that exact time.

## FOCUSED ACTIONS

Run a command after reboot:

`@reboot /path/to/job`

Run a command after reboot 5 minutes later:

`@reboot sleep 300 && /path/to/job`

## EXAMPLE CRONJOB

```
#min hour day month command
MAILTO=christopher.wood@nrlssc.navy.mil
30 07 * * * /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm_cron.sh -e /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm.env > /projects/tods-rt/tods_operational/logs/ofm_cron.log 2>&1
```

## The CRONTAB SYNTAX

```
 .---------------- minute (0 - 59)
 |  .------------- hour (0 - 23, 24-hour format)

 |  |  .---------- day of month (1 - 31)
 |  |  |  .------- month (1 - 12)
 |  |  |  |  .---- day of week (0 - 6, Sunday to Saturday)
 |  |  |  |  |
 *  *  *  *  *  /path/to/command
```

### Allowed Values

+ **Minute:** 0 to 59

+ **Hour:** 0 to 23 (e.g., 8 for 8 AM, 20 for 8 PM)

+ **Day of Month:** 1 to 31

+ **Month:** 1 to 12

+ **Day of Week:** 0 to 6 (where 0 is Sunday). 

Note: Some Linux systems also accept 7 as Sunday.

### Special Characters

You can make schedules incredibly flexible using these four operators:

+ `*` (Asterisk): Means "every" or "any". A `*` in the hour field means "every hour".
+ `,` (Comma): Creates a list of discrete values. 1,15 in the day field means the 1st and 15th.
+ `-` (Hyphen): Defines a range of values. 9-17 in the hour field means hourly from 9 AM through 5 PM.
+ `/` (Slash): Specifies intervals/steps. \*/10 in the minute field means "every 10 minutes".

### Essential Crontab Commands

You manage your automation entirely using the crontab utility in your terminal:

+ **crontab -e** Opens your personal crontab file in a text editor (like nano). Add your lines here, save, and exit to apply them.

+ **crontab -l** all your active cron jobs so you can read them without changing anything.

+ **crontab -ri** Prompts you before wiping out your entire crontab schedule. (Avoid using -r alone, as it deletes everything instantly without warning)

### MAILING RESULTS

Example 1:

`@daily /path/to/script.sh && echo "The daily backup completed successfully." | mail -s "Backup Success" user@example.com`

Example 2:

`0 2 * * * /path/to/script.sh 2>&1 | mail -s "Cron Job Log: Database Update" user@example.com`

Example 3:

Make a more robust script:

```
#!/bin/bash

# Define details
EMAIL="user@example.com"
LOGFILE="/tmp/cron_job.log"

# Run the task and save all output to a log file
/path/to/your/actual_script.sh > $LOGFILE 2>&1

# Check if the task succeeded or failed
if [ $? -eq 0 ]; then
    SUBJECT="SUCCESS: Cron Job Finished"
    BODY="The task completed without errors. See attached log summary."
else
    SUBJECT="FAILURE: Cron Job Crashed"
    BODY="The task failed. Please check the log below immediately."
fi

# Send the email with the log file content as the body
(echo "$BODY"; echo "-------------------"; cat $LOGFILE) | mail -s "$SUBJECT" "$EMAIL"

# Clean up local log
rm $LOGFILE
```

and then:

`@weekly /path/to/wrapper_script.sh`

### \@ SHORTCUTS

The 8 Standard \@ Shortcuts

Instead of writing five numbers, you simply type the shortcut followed by your command.

|Shortcut|Numerical Equivalent|What it Does|
|--------|--------------------|------------|
|@yearly (or @annually)|0 0 1 1 * | Runs once a year at midnight on January 1st.|
|@monthly              |0 0 1 * * | Runs once a month at midnight on the 1st of the month.|
|@weekly               |0 0 * * 0 | Runs once a week at midnight on Sunday.|
|@daily (or @midnight) |0 0 * * * |Runs once a day at midnight (00:00).|
|@hourly               |0 * * * * |Runs once an hour at the top of the hour (e.g., 1:00, 2:00).|
|@reboot               |N/A       |Runs exactly once when the system boots up.|

### Gotchas

+ Always use absolute paths for both your scripts and commands (e.g., use /usr/bin/python3 instead of just python3)

+ If your script fails, cron tries to email the output locally, which often goes unnoticed. Prevent this by redirecting outputs to a log file:0 2 * * * /path/to/script.sh >> /var/log/myscript.log 
