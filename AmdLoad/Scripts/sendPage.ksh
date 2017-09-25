#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.2  $
#     $Date:   18 May 2010 18:30 $
# $Workfile:   sendPage.ksh  $
USAGE="usage: ${0##*/} [-d data_directory] [-p phone_file] [-t phone number] [-b] [-o] message
\t-d directory where data can be stored
\t-p name of file with phone numbers
\t\n\t-t a phone number to send to (overrides -p file)
\t-b turn on debug mode
\t-o do not send message instead send to stdout
\tthe message to be sent - is not required has a default message"

if [[ $# > 0 && "$1" = "?" ]]
then
	print $USAGE
	exit 0
fi

PROVIDER=${PROVIDER:-messaging.sprintpcs.com} # define default provider

hostname=`uname -n`

function abort {
	print -u2 ${1:-"$0 failed"}
	print -u2 $USAGE
	print -u2 "ERROR: $0 aborted"
	print "ERROR: $0 aborted"
	exit ${2:-4}
}

UNVAR=${UNVAR:-}

if [[ -n $UNVAR && -a $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CrON/AMD/lib/amdconfig.ksh failed"
	fi
	print "Using $UNVAR for amdconfig.ksh"
elif [[ -a /apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. /apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -a ./amdconfig.ksh ]]
then
	. ./amdconfig.ksh 
	if (( $? > 0 ))
	then
		abort "./amdconfig failed"
	fi
else
	abort "Cannot find amdconfig.ksh"
fi

if [[ -z $TimeStamp ]]
then
	TimeStamp=`date $DateStr`
fi


function abort {
	print -u2 ${1:-"$0 failed"}
	print -u2 $USAGE
	print -u2 "ERROR: $0 aborted"
	print "ERROR: $0 aborted"
	exit ${2:-4}
}

function SendPage  {
	PIN=$1
	MESG=${2:-this is a test message}
	ct=`expr $PIN : '^[0,2-9][0-9]\{9\}@.*\....$'`
	if ((ct>0)) ; then
		ADDR=$PIN
	else
		ADDR=${PIN}@${PROVIDER}
	fi		

	if [[ "$AMD_NOTIFY" = "N" ]] ; then
		print "$ADDR"
		print "$MESG"
		return 0
	fi

	mailx $ADDR << EOF
	$MESG
EOF
}

UNVAR=${UNVAR:-}

if [[ -a $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CrON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -a /apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. /apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
else
	. amdconfig.ksh 
	if (( $? > 0 ))
	then
		abort `which amdconfig.ksh` failed
	fi
fi

while getopts :od:p:t: arguments
do
	case $arguments in
	  o) AMD_NOTIFY=N;;
	  t) TO=$OPTARG;;
	  p) PHONE_FILE=$OPTARG;;
	  b) set -x;;
	  d) DATA_HOME=$OPTARG;;
	  :) print "You forgot to enter a filename for $OPTARG"
	     exit 4;;
	  \?) print "$OPTARG is not a valid switch."
	     print "$USAGE"
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

message=${1:-An unspecified event occured on $hostname @ $TimeStamp}

if [[ -z $TO ]]
then
	PHONE_FILE=${PHONE_FILE:-"$DATA_HOME/pagerNumbers.txt"}
	if [[ -f $PHONE_FILE ]]
	then
		{ while read phoneNum; do
			SendPage $phoneNum "$message"
		  done } < $PHONE_FILE
	else
		print "$PHONE_FILE not defined"
	fi
else
	SendPage $TO "$message"
fi

exit 0
