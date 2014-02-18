#!/bin/bash -x
#add to cron to check every 5 minutes
#*/5 * * * * /path/to/script.sh >/dev/null 2>&1

RESTART="/root/sshtunnel_to_savvis.sh"
PGREP="/usr/bin/pgrep -f"
PROCESS="ssh -f"
#MAIL="/usr/bin/mailx"
#ADDRESS="bfarris@spireon.com"

# find ssh tunnel pid
$PGREP "${PROCESS}"

if [ $? -ne 0 ] # if ssh -f -L 3307:192.168.20.185:3306 root@192.168.10.3 -N not running 
then
	# restart ssh
	#echo "process not running"
	$RESTART
	#$MAIL -s "SERVICE Restarted" $ADDRESS
fi

