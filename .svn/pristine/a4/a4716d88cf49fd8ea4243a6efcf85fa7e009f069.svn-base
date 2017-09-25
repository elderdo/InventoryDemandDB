#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.11  $
#     $Date:   20 Feb 2009 12:35:48  $
# $Workfile:   sendPartInfo.ksh  $
#
USAGE="usage: ${0##*/} [-a] [-t] [-s step] [-d] [-e] [-w] [-o] [-v]
\twhere\n
\t-a send all parts
\t-t use the tee command for remsh step
\t-s step name or number (used for logname)
\t-d turn on debug
\t-w abort for warnings
\t-e show enqueue messages
\t-v view log of the remote shell
\t-o turn off error notification"

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $SRC_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi


while getopts :ats:dewov arguments
do
	case $arguments in
	  v) VIEW_PARTINFO_LOG=Y;;
	  a) export SEND_ALL_PARTS=Y;;
	  t) REMOTE_TEE=Y ;;
	  s) AMD_CUR_STEP=${OPTARG};;
	  e) showRunEnqueueDebug=Y;;
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

	if [[ "${SEND_ALL_PARTS:-N}" = "Y" ]] ; then
        	$LIB_HOME/execSqlplus.ksh -e $LOG_NAME ${VIEW_PARTINFO_LOG:+-n} $baseFile 
		print "sending all parts" >> $LOG_NAME
	fi

	if [[ "$REMOTE_TEE" = "N" ]]
	then
		$LIB_HOME/execRemoteShell.ksh sendPartInfo.ksh >> $LOG_NAME
	else
		$LIB_HOME/execRemoteShell.ksh sendPartInfo.ksh | tee -a $LOG_NAME
	fi

	if [[ "$VIEW_PARTINFO_LOG" = "Y" ]] ; then
		cat $LOG_NAME
	fi

	if [[ "${showRunEnqueueDebug:-}" = "Y" ]] ; then
		$LIB_HOME/checkforerrors.ksh $LOG_NAME
   		if (($?!=0)) ; then
		   exit 4
   		fi
	else
		# filter out debug errors from sendPartInfo
		sed '/ESCMC17V2/d' $LOG_NAME > /tmp/sendPartInfo.log
		$LIB_HOME/checkforerrors.ksh /tmp/sendPartInfo.log
   		if (($?!=0)) ; then
		   exit 4
   		fi
	fi


	grep "enqueued successfully" $LOG_NAME  
	if  (($? != 0 )) 
	then
		if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then
			PARTINFO_MSG="Failed"
		else
			PARTINFO_MSG="Warning"
		fi
		PARTINFO_MSG="${PARTINFO_MSG}: there were no records enqueued for PartInfo"
		print "AMD Loader $PARTINFO_MSG at $TimeStamp"		
		if [ "${AMD_ERROR_NOTIFICATION:-}" = "Y" ]
		then
			if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then # only send a page when aborting
				$LIB_HOME/sendPage.ksh  "$thisFile $PARTINFO_MSG at $TimeStamp"		
			fi
			# notify.ksh uses data/addresses.txt for the list of email recipients
			# -s is the subject
			# -m is for the message body
			hostname=`uname -n`
			$LIB_HOME/notify.ksh -s "$thisFile $PARTINFO_MSG on $hostname" -m "$0 $PARTINFO_MSG on $hostname. No records enqueued" $LOG_NAME
		fi

		if [[ "${ABORT_FOR_WARNINGS:-N}" = "Y" ]] ; then 
			exit 4
		fi
	fi

	print "$0 ending at " `date`
