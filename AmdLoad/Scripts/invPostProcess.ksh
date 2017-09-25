#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   23 Sep 2010 17:10  $
# $Workfile:   invPostProcess.ksh  $
#
USAGE="usage: ${0##*/} [-d] [-o] [-p] [-s step] [-v] [-w] 
\twhere
\t\t-d turn on debug
\t\t-o turn off error notification
\t\t-p process parts (default is to only send inventory) 
\t\t-s step name or number (used for logname)
\t\t-v view log 
\t\t-w abort for warnings"

if [[ "${1:-}" = "?" ]] ; then
	print "$USAGE"
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $SRC_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi


while getopts :ts:dewovp arguments
do
	case $arguments in
	  p) PROCESS_PARTS=Y;;
	  v) VIEW_PARTINFO_LOG=Y;;
	  s) AMD_CUR_STEP=${OPTARG};;
	  w) export ABORT_FOR_WARNINGS=Y;;
	  o) AMD_ERROR_NOTIFICATION=N;;
	  d) debug=Y
	     set -x ;;
	  *) print -u2 "$USAGE"
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

	print "$0 starting at " `date`

	thisFile=${0##*/}
	baseFile=${thisFile%\.*}

	if [[ -z ${TimeStamp:-} ]] ; then
		export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
	else
		export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
	fi

	LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${baseFile}.log"


	LOADINVENTORY_ARGS=
	if [[ "${VIEW_PARTINFO_LOG:-}" = "Y" ]] ; then
		LOADINVENTORY_ARGS="$LOADINVENTORY_ARGS -v"
	fi

	if [[ "${PROCESS_PARTS:-}" = "Y" ]] ; then
		LOADINVENTORY_ARGS="$LOADINVENTORY_ARGS -p"
	fi

	if [[ "${debug:-}" = "Y" ]] ; then
		LOADINVENTORY_ARGS="$LOADINVENTORY_ARGS -d"
	fi

	loadInventory.ksh $LOADINVENTORY_ARGS >> "$LOG_NAME" 
	RC=$?
	$LIB_HOME/checkforerrors.ksh $LOG_NAME
   	if (($?!=0 || $RC!=0)) ; then

		if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then
			PARTINFO_MSG="Failed"
		else
			PARTINFO_MSG="Warning"
		fi

		if [ "${AMD_ERROR_NOTIFICATION:-}" = "Y" ]
		then
			if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then # only send a page when aborting
				$LIB_HOME/sendPage.ksh  "$thisFile $PARTINFO_MSG at $TimeStamp"		
			fi
			hostname=`uname -n`
			$LIB_HOME/notify.ksh -s "$thisFile $PARTINFO_MSG on $hostname" \
			       	-m "$0 $PARTINFO_MSG on $hostname." $LOG_NAME
		fi

		if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then 
			exit 4
		fi
	fi

	print "$0 ending at " `date`
