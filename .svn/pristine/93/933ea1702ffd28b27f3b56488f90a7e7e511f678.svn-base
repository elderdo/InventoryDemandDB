#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   30 Jan 2009 16:41:06  $
# $Workfile:   sendWarnings.ksh  $
USAGE="usage: ${0##*/} [-a addr_file] [-f from] [-t recipient addresses] [-c cc addresses_file] [-C cc addresses] [-s subject] [-m message] [-b] [-o]  [file1 file2....]
\t-d data_directory - directory where data can be stored
\t-a addr_file file used to get a list of recipients
\t-f from sender's id
\t-t addres@boeing.com,address@boeing.com ... a list of recipients
\t-c cc address_file a file containing a list of cc recipients
\t-h bcc address_file a file containing a list of bcc recipients
\t-C me@boeing.com,you@boeing.com,... a list of cc recipients
\t-s subject for the email
\t-m message to be sent
\t-b turn on debug
\t-o do not send a message just print it to stdout
\t [file1 file2...] optional file attachments"

if [[ $# > 0 && "$1" = "?" ]]
then
	print $USAGE
	exit 0
fi

hostname=`hostname -s`

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
		abort "$UNVAR/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
	print "Using $UNVAR for amdconfig"
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

OPTIND=1
while getopts :h:of:c:a:bt:C:s:m: arguments
do
	case $arguments in
	  o) AMD_NOTIFY=N;;
	  m) MSG=$OPTARG;;
	  f) FROM=$OPTARG;;
	  t) TO=$OPTARG;;
	  c) CC_FILE=$OPTARG;;
	  h) BCC_FILE=$OPTARG;;
	  C) CC=$OPTARG;;
	  s) SUBJ=$OPTARG;;
	  a) ADDR_FILE=$OPTARG;;
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

if [[ -n $LOGNAME ]] ; then
	if [[ -a /home/amd/amduser/${LOGNAME} ]] ; then
		USER_HOME=/home/amd/amduser/${LOGNAME}
		if [[ -a ${USER_HOME}${DATA_HOME}/${ADDR_FILE:-"addresses.txt"} ]] ; then
			DATA_HOME=${USER_HOME}${DATA_HOME} 
		fi
	fi
fi

if [[ -z $TO ]]
then
	ADDR_FILE=${ADDR_FILE:-"warnings.txt"}
	if [[ -a $DATA_HOME/$ADDR_FILE ]]
	then
		{ while read emailAddr; do
			if [[ -z $SEND_TO ]] ; then
				SEND_TO="${emailAddr}"
			else
				if [[ -n $emailAddr ]] ; then
					SEND_TO="${SEND_TO};${emailAddr}"
			 	fi
			fi
		  done } < $DATA_HOME/$ADDR_FILE
		if [[ -n $SEND_TO ]] ; then
			$LIB_HOME/execSqlplus.ksh emailWarnings "$SEND_TO" \
		    	  "AMD Load for $AMDENV@`hostname` finished with Warnings"
			  if (($?!=0)) ; then
				  return 4
			  fi
		fi
	else
		abort "$ADDR_FILE does not exist"
	fi
fi

