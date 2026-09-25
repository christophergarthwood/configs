# **Process Control Frequently Asked Questions (FAQ)**

## UNIX PROCESS CONTROL

[TOC]

## Basics

**`ps`** or **`ps -ef | grep <some term>`** For general inquries.

**`top`** Opens an interactive, dynamic, real-time view of running processes sorted by CPU usage.

**`htop`**  A visually enhanced, modern, interactive version of top.

**`pgrep`** Searches for processes by name and returns their PIDs.

**`pstree`** Shows running processes arranged in a parent-child dependency tree structure.

Option 1: Using the pstree Command (Recommended)The pstree command is designed specifically for this purpose. By passing a specific PID, it will isolate that process and display all of its descendants.

`pstree -p <PID>`

Option 2: Using the `ps` Command (Alternative) if `pstree` is not installed on your system, you can use the standard ps utility with the --forest or f flag to create an ASCII art process tree filtered by a process group:

`ps f -g <PID>`

+ f or --forest: Draws an ASCII art tree showing the process hierarchy.

+ -g <PID>: Filters the output by the process group ID (which generally matches the leader/parent PID).


Show all processes you own by tree:

`ps uxf`

### Process Control

To start a new process which should execute only in one core, you can use taskset command.

`taskset -c 0 executable`

To monitor the existing process's CPU affinity, you can use this command:

`taskset -cp $(pgrep -f executable)`

note that the executable identity you will pass to this command can be './executable' if you started it that way.


## Job Control (Foreground & Background)

Unix shells allow you to manage multiple processes (jobs) within a single terminal session.

+ **`&`** : Placing an ampersand at the end of a command executes it immediately in the background.

Example: `sleep 100 &`

+ **`Ctrl + Z`: Suspends (pauses) the currently running foreground process.

+ **`jobs`**: Lists all active or suspended jobs started within the current shell session.

+ **`bg`**: Resumes a paused/suspended process and runs it in the background.

Example: `bg %1 (resumes job number 1)`

+ **`fg`**: Moves a background or paused job into the foreground terminal window.

Example: `fg %1`

+ **`nohup`**: Runs a command immune to terminal hangups, allowing background processes to continue running even if you log out.

+ **`disown`**: Removes a job from the shell’s job table so it won't close when the terminal closes.

## Terminating Processes (Sending Signals)

When you need to stop an application or clear a frozen process, you send it an operating system signal:

+ **`kill`**: Sends a specific signal to a process using its PID.

+ **`kill <PID>`**: Sends SIGTERM (Signal 15), politely requesting the app to save and shut down.

+ **`kill -9 <PID>`**: Sends SIGKILL (Signal 9), forcing the kernel to instantly terminate the process.

+ **`killall`**: Terminates all processes matching a specific name rather than a PID number.

Example: `killall firefox`

+ **`pkill`**: Uses regular expressions and criteria (like user ownership) to signal matching processes.

+ **`Ctrl + C`**: Sends a SIGINT interrupt signal to immediately kill the process running in your active foreground window.

## Memory (RAPID ACCESS MEMORY - RAM)
	
Memory dump:

`sudo dmidecode --type memory`

Available RAM:

`free -h`

### Clearing Swap Memory
2 well known ways to clear swap memory: 
1) Turn off swap memory, wait 30sec and turn swap memory back on 
2) Reboot entire machine

1) Steps & Commands for Turning Memory On and Off
`swapoff -a`
After command complete's, wait about 30 seconds to allow swap to reset. then turn swap memory back on
`swapon -a`
### Compiler Insight In Executable / Binary / Library 
`objdump --full-contents --section=.comment ldd ldd -v ldd -u #show unused libraries objdump -p readelf -d strace -e trace=open,openat $ pidof $ lsof -p <yourprogram_pid> |grep mem`


### GPU Memory:

`nvidia-smi`

## COMPILER INSIGHT IN EXECUTABLE / BINARY / LIBRARY / LIBRARIES

```
objdump --full-contents --section=.comment <yourprogram>
ldd <yourprogram>
ldd -v <yourprogram>
ldd -u <yourprogram> #show unused libraries
objdump -p <yourprogram>
readelf -d <yourprogram>
strace -e trace=open,openat <yourprogram>
pidof <yourprogram>
lsof -p <yourprogram_pid> |grep mem
```

## STRACE | TRACK EXECUTABLE

Example of watching a wget and seeing what the address is reaching out to.

`strace -f -e trace=network wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz > 2>&1 | grep sin_addr`

## CPU UTILIZATION / NUMBER OF CORES / CORE ASSIGNMENT

`lscpu`

## PROCESS CONTROL

To start a new process which should execute only in one core, you can use taskset command.

`taskset -c 0 executable`

To monitor the existing process's CPU affinity, you can use this command:

`taskset -cp $(pgrep -f executable)`

Note that the executable identity you will pass to this command can be './executable' if you started it that way.

## PROCESS PRIORITY

You can influence how much CPU time a process receives relative to others by tweaking its "niceness" score (ranging from -20 highest priority to 19 lowest priority):

+ **`nice`**: Launches a brand new command with a customized scheduling priority.

Example: `nice -n 10 long_script.sh ` runs it at a lower priority.

+ **`renice`**: Alters the scheduling priority of a process that is already running.

Example: `renice -n 5 -p 1234`

