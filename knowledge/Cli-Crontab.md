# **Frequently Asked Questions (FAQ)**

[TOC]

### Crontab

All cronjobs for CTG 80.7 are documented with the data harvesters (take your pick on location) coupled with some system admin jobs.

[CTG 80.7 CronJobs](https://web.git.mil/ctg807/applications/harvesters)

#### Time Formula

```
* * * * *
| | | | |
| | | | +-- Day of the Week (0-7, where 0 and 7 are Sunday, or use names MON-SUN)
| | | +---- Month (1-12 or names JAN-DEC)
| | +------ Day of the Month (1-31)
| +-------- Hour (0-23)
+---------- Minute (0-59)
```

#### Special Keywords

You can also use special strings that replace all five fields for convenience:

+ @reboot : Run once after system reboot.
+ @yearly : Run once a year (0 0 1 1 *).
+ @monthly: Run once a month (0 0 1 * *).
+ @weekly : Run once a week (0 0 * * 0).
+ @daily : Run once a day (0 0 * * *).
+ @hourly : Run once an hour (0 * * * *).

#### How to Manage Cron Jobs

View existing jobs: Use `crontab -l`.
Edit jobs: Use `crontab -e` to open the editor.
Remove all jobs: Use `crontab -r` (use the -i option for a confirmation prompt).

#### Run a specific command after reboot.
```
@reboot /path/to/job
```

Run a specific command after reboot and a period of time (5 minutes, calculated in seconds).
```
@reboot sleep 300 && /path/to/job
```

#### Example CRONJOB 

```
MAILTO=christopher.wood@nrlssc.navy.mil 
#m h dom mon dow command 
30 07 * * * /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm_cron.sh -e /projects/tods-rt/tods_operational/tods_repo/tods_cs/src/ofm.env > /projects/tods-rt/tods_operational/logs/ofm_cron.log 2>&1
```

#### Reference: 

+ https://crontab.guru/
+ [Crontab Generator](https://crontab-generator.org)

