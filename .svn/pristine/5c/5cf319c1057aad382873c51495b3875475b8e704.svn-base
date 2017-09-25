#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   Sep 29 2006 10:44:52  $
# $Workfile:   inspectErrors.ksh  $
# 
# Scan a set of log files for errors 
# and for every log with errors vi the file
#
# Date		By		History
# -----------	--------------	-----------------------------------------
# 09/29/06	Elder, Douglas 	Initial implementation.
# 

USAGE="usage: ${0##*/} logFilePrefix"

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

if [[ -z $1 ]]
then
	print -u2 "You must enter a log prefix - 20060928 for example"
	exit 4
fi

for log in $LOG_HOME/$1*
do
	grep -i -q -e "ORA-" -e "Error:" -e "failed" $log
	if (( $? == 0 ))
	then
		vi $log
	fi
done
