# **Unix Frequently Asked Questions (FAQ)**


[TOC]

## Python

Install Packages locally: --user

Example Path Configuration:

```
export SITEDIR=$(python -m site --user-site)
export PYTHON_DIR=python2.6
export PYTHON_PATH=$PYTHON_PATH:/usr/lib/python2.6/site-packages/:~/.local/lib/python2.6/site-packages/
```
Keep in mind this package is past EOL.
https://share.google/6aa2V7KrP8Zd85rsg

## Grep

Strips pattern, parts http into new lines and removes everything behind the final double-quote

`cat guard-duty | grep downloads | sed s/http/\\\nhttp/g | sed s/\".*//g > ../guard.txt`

#use \r while in vi

## SELinux
`$chcon -u system_u -t auditd_etc_t ./audit.rules`
getenforce
Note if ssh token login fail it is because the SELinux tags needs to be repaired.
restorecon -vR /home1/
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/using_selinux/writing-a-custom-selinux-policy_using-selinux

## Unix Error Codes

[Error Codes](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/errnos/)

`cat  /usr/include/asm-generic/errno.h`

## Unix Verison
{The OS release}
+ `lsb_release -a`
+ `more /etc/redhat-release`
{The Kernel version}
+ `uname -a`

## wget example

`wget http://windev.anteon.com:8080/NMOSW/dod/isarch/database/list/listUserSQL/asXMLwget --http-user=dvignes --http-passwd=test3`

## X WINDOW

```
startx -- :1 -bpp 24 vt8
xeyes -display :1
```

## Storage (Temporary)

Save file in /dev/shm (memory only), lose content after reboot.

`free -h > /dev/shm/free_memory.txt;`

## Who is online?

Find out who else is logged in, especially before starting something like a shutdown

`who -au | grep -vi LOGIN |  sed -e /^$/d`

## YUM

`yum --exclude=openscada* --exclude=httpd* --exclude=mod_ssl* --exclude=kernel* --exclude=java* --exclude=maven*`

### YUM useful packages (personal)

```
yum -y install epel-release
yum -y groupinstall "X Window System"
yum -y install lightdm
yum -y install cinnamon
yum -y install gcc ssh audit nmap ntop logwatch tcpdump sysstat iptraf strace htop syslog aide screen yum-plugin-priorities filezilla* *terminal* cups-pdf dconf-editor nano p7zip* unrar wget bluefish geany zip svn git vlc feh ristretto
systemctl set-default graphic.target
rm '/etc/systemd/system/default.target'
ln -s /usr/lib/systemd/system/graphical.target /etc/systemd/system/default
systemctl isolate graphical.target
```
The YUM command is now dnf.  In RHEL8 it will rewrite your yum command to dnf.

## Shell Local Logic

command2 is executed if, and only if, command1 returns an exit status of zero. 

`command1 && command2`

command2 is executed if and only if command1 returns a non-zero exit status.  

`command1 || command2` 

The return status of AND and OR lists is the exit status of the last command executed in the list. 

The $? is the return code of your last command.


## RETVAL

RETVAL is a system variable, -eq is testing equality.

`[ $RETVAL -eq 0 ] && touch /var/lock/subsys/$sname`

## Shell Record Session

Save all content printed on terminal to file.

```
#mkfifo hardcopy
script session_log.txt
```

Log and show to the screen.

```
#overwrite the output file
your_command | tee session_log.txt

#or append the results
your_command | tee -a session_log.txt
```

## Shell - Is it Interactive?

Is this Shell Interactive?

`[ -z "$PS1" ] && echo "Noop" || echo "Yes"`

## Curl 

Download a Script on the CLI.

`curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py`

The wget is a simple way to fetch fail to your currernt system. 
The curl command is more flexible can pass user name and password word and public key. It treat the order of the options as how it processes.

## Logging and Redirect

Reference:[Shell Logging](http://www.cubicrace.com/2016/03/efficient-logging-mechnism-in-shell.html)

Reference:[Output to Syslog](http://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/)_

Add to the top of your script:

`exec 1> >(tee -a YOURLOGFILE) 2>&1`

or

`exec 1> >(logger -s -t $(basename $0)) 2>&1`

or

Only problem is the script below will get output out of sync since it's using two different processes to log;

```
#!/bin/bash

TOTAL direction: ./test_msgs.sh &> ./output.txt

exec 1> >(logger -s -t $(basename $0) 2>&1)
exec 2> >(logger -s -t $(basename $0))
echo "writing to stdout"
echo "writing to stderr" >&2
```

## Bash Variables

Reference:[Bash Vars](https://stackoverflow.com/questions/673055/correct-bash-and-shell-script-variable-capitalization/42290320#42290320)

Use all caps and underscores for exported variables and constants. Use a common prefix whenever applicable so that related variables stand out.

Examples:

**Exported variables with a common prefix:** *JOB_HOME JOB_LOG JOB_TEMP JOB_RUN_CONTROL*
**Constants:** *PI MAX_FILES OK ERROR WARNING*

Use "snake case" (all lowercase and underscores) for all variables that are scoped to a single script or a block.

**Examples:** *input_file first_value max_amount num_errors*

Mixed case when local variable has some relationship with an environment variable, like: old_IFS old_HOME

Use a leading underscore for "private" variables and functions. This is especially relevant if you ever write a shell library where functions within a library file or across files need to share variables, without ever clashing with anything that might be similarly named in the main code.

Examples: _debug _debug_level _current_log_file

Never use camel case. This will make sure we don't run into bugs caused by case typos.

Examples: inputArray thisLooksBAD, numRecordsProcessed, veryInconsistent_style

## Bash Good Practices

Let script exit if a command fails.
```
set -o errexit 
#OR
set -e
```

Let script exit if an unsed variable is used
```
set -o nounset
#OR
set -u
```

Use = for string comparisons.

Use $(command) instead of backticks.

Double quote "${my_var}" variables and curly brace for local vars.

Add || true to commands that allow you to fail.

Set xtrace to for debugging
```
set -o xtrace
OR
set -x
```

Portability of scripts:

`#!/usr/bin/env bash is more portable then #!/bin/bash`

Use :- if you want to test variables that could be undeclared. For instance:

`if [ "${NAME:-}" = "Kevin" ]`

will set $NAME to be empty if it's not declared. You can also set it to noname like so:

`if [ "${NAME:-noname}" = "Kevin" ]`


## Unix Shell History

Reference:[CLI History](https://www.thegeekstuff.com/2008/08/15-examples-to-master-linux-command-line-history/)

Display timestamp using ***HISTTIMEFORMAT***:
`export HISTTIMEFORMAT='%F %T '`

Search the history using Control+R.

Repeat previous command quickly using 4 different methods.

+  Use the up arrow to view the previous command and press enter to execute it.
+  Type !! and press enter from the command line
+  Type !-1 and press enter from the command line.
+  Press Control+P will display the previous command, press enter to execute it

Repeat command from History.

`!#`

Execute previous command that starts with a specific word.
`!ps`

Control the total number of lines in the history using HISTSIZE:
`export HISTSIZE=450`
`export HISTFILESIZE=450`

Change the history file name using HISTFILE:
`export  HISTFILE=$HOME/.audit/session.`date +'%Y%m%d-%H%M%S%N'``

Eliminate the continuous repeated entry from history using HISTCONTROL.

`export HISTCONTROL=erasedups`

Force history not to remember a particular command using HISTCONTROL.

`export HISTCONTROL=ignorespace`

Clear all the previous history using option -c.

`history -c`

Disable the usage of history using HISTSIZE:

`export HISTSIZE=0`

Ignore specific commands from the history using HISTIGNORE:

`export HISTIGNORE="pwd:ls:ls -ltr:"`

## Shell Differences

Reference: [Shelll Functions](http://hyperpolyglot.org/unix-shells#functions)

## Shell Templates

+ [Script Style](http://teaching.idallen.com/cst8177/13w/notes/000_script_style.html)
+ [Boilerplate Tempalte](https://natelandau.com/boilerplate-shell-script-template/)
 
## Code Reference (Recipes)

Reference:[Recipes](https://github.com/ActiveState/code)

## SVN (Subversion) Log

Show descending values, last 10 only.

`svn log -r HEAD:1 -l 10`


## Git log

Reference: [Git Log Tutorial](https://www.atlassian.com/git/tutorials/git-log)

```
git log --graph --oneline --decorate
#limit output
git log --graph --oneline --decorate -10
```

Some Alias examples:

```
# Useful for monthly reports
alias git_report="git log --graph --decorate --pretty=format:'%C(yellow)%h %Cred%cr %Cblue(%an)%C(cyan)%d%Creset %s' --abbrev-commit |head -40";

alias git_list="git log --all --oneline --graph --decorate";

alias git_fetch_list="git fetch && git log --all --oneline --decorate --graph";

alias git_publish="push -u origin head";

alias git_pullBranches="git fetch && git switch -C ${1} origin/${1} && echo \"Pulled\""

#deploySandbox = push origin head:sandbox
alias git_refresh="git stash && git fetch && git switch -C ${1} origin/${1} && git switch - && git stash pop"

#alias git_openChangedFiles="pathToRoot=$(git rev-parse --show-toplevel); allPaths=$(git diff  --name-only \"${1:-origin/development}\") ; if [ ${#allPaths} -ne 0 ] ; then  echo 'opening...'; echo \"$allPaths\"; code $allPaths ; else echo 'No changes found' ; fi ; #"
```

## Git SSL Issues

+ http.slCAPath or http.sslCAInfo. Adam Spiers's answer gives some great examples. This is the most secure solution to the question.

+ To disable TLS/SSL verification for a single git command try passing -c to git with the proper config variable, or use Flow's answer:
  + `git -c http.sslVerify=false clone https://example.com/path/to/git`
+ To disable SSL verification for a specific repository, if the repository is completely under your control, you can try:
  + `git config http.sslVerify false`
+ There are quite a few SSL configuration options in git. From the man page of git config:
  + http.sslVerify - Whether to verify the SSL certificate when fetching or pushing over HTTPS.
Can be overridden by the GIT_SSL_NO_VERIFY environment variable.
  + http.sslCAInfo - File containing the certificates to verify the peer with when fetching or pushing
over HTTPS. Can be overridden by the GIT_SSL_CAINFO environment variable.
  + http.sslCAPath - Path containing files with the CA certificates to verify the peer with when
fetching or pushing over HTTPS.  Can be overridden by the GIT_SSL_CAPATH environment variable.
+ A few other useful SSL configuration options:
  + http.sslCert - File containing the SSL certificate when fetching or pushing over HTTPS.
Can be overridden by the GIT_SSL_CERT environment variable.
  + http.sslKey - File containing the SSL private key when fetching or pushing over HTTPS.
Can be overridden by the GIT_SSL_KEY environment variable.
  + http.sslCertPasswordProtected - Enable git's password prompt for the SSL certificate. Otherwise OpenSSL will
prompt the user, possibly many times, if the certificate or private key is encrypted.  Can be overridden by the GIT_SSL_CERT_PASSWORD_PROTECTED environment variable.

## Compiler insight in executable, binary, library, libraries   

```
objdump --full-contents --section=.comment <yourprogram>
ldd <yourprogram>
ldd -v <yourprogram>
ldd -u <yourprogram> #show unused libraries
objdump -p <yourprogram>
readelf -d <yourprogram>
strace -e trace=open,openat <yourprogram>
$ pidof <yourprogram>
$ lsof -p <yourprogram_pid> |grep mem
```


## SHOPT, Globbing

[Bash Extended Globbing](https://www.linuxjournal.com/content/bash-extended-globbing)

## Hardware, CPU Info

```
cat /proc/cpuinfo
$ cat /proc/cpuinfo | grep 'vendor' | uniq		#view vendor name
$ cat /proc/cpuinfo | grep 'model name' | uniq		#display model name
$ cat /proc/cpuinfo | grep processor | wc -l		#count the number of processing units
$ cat /proc/cpuinfo | grep 'core id'			#show individual cores	
nproc #number of cpus
lscpu
Running 32 or 64 bit? getconf LONG_BIT
```

## File extensions

Single column list of files, reverse order of string, cut first element out (extension), sort uniquely and reverse string (which is now only the extension) again.

`ls -1 | rev | cut -d'.' -f 1 | unique -u |  rev`

## HPC modules

Show all modules in a sorted single column

` module list 2>&1 |  cut -c-150 | cut -c5-150 | sort`

## HPC Subversion
```
module load costinit
module load subversion
```

## STrace, watch an executable

Example of watching a wget and seeing what the address is reaching out to.

`strace -f -e trace=network wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz  2>&1 | grep sin_addr`

## Julian Date

```
date +%j -d 1/10/2016       #given the date
date +%j                    #for today
```

## VIM search and replace

All spaces in a file replaced with a caret (delimiter), while inside the VIM editor.

`:%s![^ ]\zs \+!^!g`

## Summation of a Datafile with a bunch of numbers

`awk '{s+=$1} END {print s}' mydatafile`
