#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.7  $
#     $Date:   13 Oct 2009 18:01 $
# $Workfile:   execSqlldr.ksh  $
#
USAGE="usage: ${0##*/} [-c connection_string | -s ] [-f datafile] [-d] [-l logfile] ctl [errorlog]
\nwhere
\t-s use the spo connection string
\n\t\t(defaults to amd's connection string)
\n\t-c connection_string is the OracleUserid@TNSNAME/password
\n\t-l log file
\n\t-f datafile is the input file for sqlldr
\n\t-d turns on debug
\n\tctl is the ctl file that gets executed
\n\terrorlog is the name of an optional file to create 
\n\t\twhen sqlldr has an error - used when concurrent loads occur"

if [[ "$1" == "?" || "$#" == "0" ]] ; then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $SRC_HOME || -z $LOG_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :ndsf:c:l: arguments
do
	case $arguments in
	  f) SQLLDR_DATA_FILE=${OPTARG};;
	  c) THE_CONNECTION_STRING=${OPTARG};;
	  l) THE_LOG_FILE=${OPTARG};;
	  s) THE_CONNECTION_STRING=$DB_CONNECTION_STRING_FOR_SPO;;
	  d) debug=Y
	     set -x ;;
	  *) print -u2 $USAGE
	     exit 4;;
	esac
done
# OPTIND now contains a numnber representing the identity of the first
# nonswitch argument on the command line.  For example, if the first
# nonswitch argume on the command line is positional parameter $<F5>,
# OPTIND hold the number 5.
((positions_occupied_by_switches = OPTIND - 1))
# Use a shift statement to eliminate all switches and switch arguments
# from the set of positional parameters.
shift $positions_occupied_by_switches
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

if (($#>2)) ; then
	print "USAGE"
	exit 4
fi

if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
	TimeStamp=$(print $TimeStamp | sed "s/:/_/g")
fi

# default to the AMD Connection String
THE_CONNECTION_STRING=${THE_CONNECTION_STRING:-$DB_CONNECTION_STRING}

if [[ -n $SQLLDR_DATA_FILE ]] ; then
	# prefix with the keyword and equal sign
	SQLLDR_DATA_FILE_NAME=$(basename $SQLLDR_DATA_FILE)
	SQLLDR_DATA_FILE_NAME=$(print $SQLLDR_DATA_FILE_NAME | sed "s/\./_/g")
	SQLLDR_DATA_FILE="data=$SQLLDR_DATA_FILE"
	SQLLDR_FILE=${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${SQLLDR_DATA_FILE_NAME}
else
	SQLLDR_INFILE=$($LIB_HOME/getInfile.ksh $SRC_HOME/${1}.ctl)
	SQLLDR_FILE=$(basename $SQLLDR_INFILE)
	SQLLDR_FILE=${SQLLDR_FILE%\.*}
	SQLLDR_FILE=${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${SQLLDR_FILE}
fi

if [[ "$debug" == "Y" ]] ; then
	print "SQLLDR_FILE=$SQLLDR_FILE"
	print "SQLLDR_DATA_FILE=$SQLLDR_DATA_FILE"
	print "SQLLDR_DATA_FILE_NAME=$SQLLDR_DATA_FILE_NAME"
	print "$LOG_HOME/${SQLLDR_FILE}.log"
fi

# the -l option takes precedence
# over the global env variable EXEC_SQLLDR_LOG
if [[ -z ${THE_LOG_FILE:-} ]] ; then
	if [[ -n ${EXEC_SQLLDR_LOG:-} ]] ; then
		THE_LOG_FILE=$EXEC_SQLLDR_LOG
	else
		# default log file
		THE_LOG_FILE=$LOG_HOME/${SQLLDR_FILE}.log
	fi
fi

sqlldr $THE_CONNECTION_STRING \
	control=$SRC_HOME/${1}.ctl ${SQLLDR_DATA_FILE:-} \
	rows=10000 readsize=10000000 bindsize=10000000 \
	log=/tmp/${SQLLDR_FILE}.log \
	bad=$LOG_HOME/${SQLLDR_FILE}.bad
RC=$?

cat /tmp/${SQLLDR_FILE}.log >> $THE_LOG_FILE

if [[ -e $LOG_HOME/${SQLLDR_FILE}.bad ]] ; then
	chmod 644 $LOG_HOME/${SQLLDR_FILE}.bad
	chgrp amd $LOG_HOME/${SQLLDR_FILE}.bad 
fi		
if [[ -e $LOG_HOME/${SQLLDR_FILE}.log ]] ; then
	chmod 644 $LOG_HOME/${SQLLDR_FILE}.log
	chgrp amd $LOG_HOME/${SQLLDR_FILE}.log
fi		


case $RC in
	0) return $RC ;;
	1) print -u2 "$(date): sqlldr failed for $1"
	   if [[ -n ${2:-} && -f ${2:-} ]] ; then
		print "Error: sqlldr exit code = $RC" >>$2
	   fi
	   exit $RC ;;
  	2) print -u2 "$(date): all or some records rejected for sqlldr for $1" 
	   return $RC ;;
	3) print -u2 "$(date): sqlldr had a fatal error with $1"
	   if [[ -n ${2:-} && -f ${2:-} ]] ; then
		print "Error: sqlldr exit code = $RC" >>$2
	   fi
	   exit $RC ;;
esac

