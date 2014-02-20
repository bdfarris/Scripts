#!/bin/bash -x
#add to cron to check every 5 minutes
#*/5 * * * * /path/to/script.sh >/dev/null 2>&1

RESTART="/path-to-start-script"
PGREP="/usr/bin/pgrep -f"
PROCESS="processname-beware if multiple processes with name"
#MAIL="/usr/bin/mailx"
#ADDRESS="bfarris@spireon.com"

# find ssh tunnel pid
$PGREP "${PROCESS}"

if [ $? -ne 0 ] # 
then
	# restart ssh
	#echo "process not running"
	$RESTART
	#$MAIL -s "SERVICE Restarted" $ADDRESS
fi

