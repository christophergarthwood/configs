MEMORY DUMP
	#memory dump
	sudo dmidecode --type memory

COMPILER INSIGHT IN EXECUTABLE / BINARY / LIBRARY / LIBRARIES
objdump --full-contents --section=.comment <yourprogram>
ldd <yourprogram>
ldd -v <yourprogram>
ldd -u <yourprogram> #show unused libraries
objdump -p <yourprogram>
readelf -d <yourprogram>
strace -e trace=open,openat <yourprogram>
$ pidof <yourprogram>
$ lsof -p <yourprogram_pid> |grep mem

STRACE | TRACK EXECUTABLE
#example of watching a wget and seeing what the address is reaching out to.
strace -f -e trace=network wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz > 2>&1 | grep sin_addr

CPU UTILIZATION / NUMBER OF CORES / CORE ASSIGNMENT
lscpu

PROCESS CONTROL
To start a new process which should execute only in one core, you can use taskset command.

taskset -c 0 executable

To monitor the existing process's CPU affinity, you can use this command:

taskset -cp $(pgrep -f executable)

note that the executable identity you will pass to this command can be './executable' if you started it that way.
