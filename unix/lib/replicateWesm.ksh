#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.2  $
#     $Date:   20 Feb 2009 12:35:26  $
# $Workfile:   replicateWesm.ksh  $

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi


if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
	export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

print "$0 started at " `date`
thisFile=${0##*/}
SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadL11  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadActiveNiins  &

wait

print "$0 ending at " `date`

if [[ -a $SQLPLUS_ERROR_LOG ]] ; then
	$LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
	RetCd=$?
	if [[ "$RetCd" != "0" ]]; then
		exit 4
	fi
fi

