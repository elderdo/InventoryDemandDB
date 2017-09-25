#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.18
#     $Date:   20 Jun 2016
# $Workfile:   checkforerrors.ksh  $
#
# SCCSID: checkforerrors.ksh  1.6  Modified: 07/09/02 09:35:10
#
# CheckForErrors.ksh
#
# This script will grep the file passed in for certain error patterns
# and if it finds a match then it will page someone and send an email.
#
# Date      By             History
# 10/17/00  Fernando F.    Initial implementation
# 11/20/01  Fernando F.    Added Thuy to be paged.
# 07/05/02  Fernando F.    Added additional pattern check for failure.
# 07/09/02  Fernando F.    Added additional pattern check for diff failure.
# 09/22/13  Elder D.       Fixed ATTACHMENT2 assignment
# 03/20/14  Elder D.       added -m message mod and -s subject args
# 03/21/14  Elder D.       1.16 added -p phone numbers for  error text messages
# 06/16/16  Elder D.       1.17 added -c command line opt to make search case sensitive
# 06/20/16  Elder D.       1.18 added function to doNOtify
#

USAGE="usage: ${0##*/} [ -a addr_file ] [ -c ] [ -p ] [ -n ] [ -d ] [ -g grep_pattern_file ] [ -l libdir ]
[ -s   subject ] [ -m message mod ] [ -t text phone numbers ] file
\n\twhere
\n\t-a addr_file sets the address file used by notify.ksh
\n\t-c make grep case sensitive ( default is insensitive for checkForErrors.ksh )
\n\t-p turns off paging
\n\t-n turns off email notification
\n\t-g grep_pattern_file of errors to check for
\n\t\tdefault is data/checkForErrorsGrepPatterns.txt
\n\t-m message mod the start of the error message that 
\n\t\tis issued for errors
\n\t-s subject the suject of the error message
\n\t-t phone numbers file of phone_number@provider's used to send text messages
\n\t-d turns on debuging
\n\tand file is the file to be scanned for errors\n"

if [[ "$#" -gt "0" && "$1" = "?" ]]
then
	print $USAGE
	exit 0
fi

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh


if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=`date $DateStr | sed "s/:/_/g"`
fi
hostname=`hostname -s`

if [[ "$( tty )" = 'not a tty' ]]
then
    STDIN_DATA_PRESENT=1
else
    STDIN_DATA_PRESENT=0
fi

# default to case insensitive
GREP_CASE=-i
while getopts :cdpna:g:l:m:t:s: arguments
do
	case $arguments in
	  a) ADDR_FILE=$OPTARG;;
	  c) GREP_CASE=;;
	  s) SUBJECT=$OPTARG;;
	  l) LIB_HOME=$OPTARG;;
	  m) MESSAGE_MOD=$OPTARG;;
	  g) GREP_PATTERN_FILE=$OPTARG;;
	  p) AMD_SEND_PAGE=N;;
	  n) AMD_ERROR_NOTIFICATION=N;;
	  t) PHONENUMS=$OPTARG;;
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

if (($#<1 && $STDIN_DATA_PRESENT==0)) ; then
	print $USAGE
	exit 4
fi

if [[ -n ${AMD_CUR_STEP:-} ]] ; then
	STEPINFO=" at step $AMD_CUR_STEP"
fi 

function doNotify {
        if [[ -z ${SUBJECT:-} ]] ; then
          SUBJECT="AMD Load Failed for ENV=$AMDENV on $hostname ${STEPINFO:-}" 
        fi

	THE_MESSAGE="$1"
	if [[ -n ${ErrorLogFile:-} ]] ; then
		ATTACHMENT2=/tmp/`basename $ErrorLogFile`
		# use awk to convert a Unix text file to a Windows text file
		awk 'sub("$", "\r")' $ErrorLogFile > $ATTACHMENT2
	fi

	# allow for paging to be turned off for testing
	if [[ "${AMD_SEND_PAGE:-Y}" = "Y" ]] ; then
		if [[ -n ${TimeStamp:-} ]] ; then 
			TIMESTAMP_INFO=" at $TimeStamp"
		fi
		if [[ -z $PHONENUMS ]] ; then
	          SENDOPT=	
		else
		  SENDOPT="-p $PHONENUMS"
		fi
		$LIB_HOME/sendPage.ksh ${SENDOPT} "${SUBJECT}"
	fi

	if [[ -n ${TimeStamp:-} && -f $LOG_HOME/${TimeStamp}_amd_loader.log ]] ;then
		# use awk to convert a Unix text file to a Windows text file
		awk 'sub("$", "\r")' $LOG_HOME/${TimeStamp}_amd_loader.log > /tmp/${TimeStamp}_amd_loader.log
		ATTACHMENT1=/tmp/${TimeStamp}_amd_loader.log
		TIMESTAMP_INFO=" for log time stamp of ${TimeStamp}"
	fi	

	# notify.ksh uses data/addresses.txt for the list of email recipients
	# -s is the subject
	# -m is for the message body

	if [[ -n ${ADDR_FILE:-} ]] ; then
		if [[ -f ${ADDR_FILE:-} ]] ; then
			ADDR_FILE_ARG=" -a $ADDR_FILE "
		else
			print -u2 "$ADDR_FILE does not exist using default data/addresses.txt" 
		fi
	fi

	if [[ "${debug:-}" = "Y" ]] ; then
		NOTIFY_DEBUG=-b
	else
		NOTIFY_DEBUG=
	fi
        
        if [[ -z ${MESSAGE_MOD:-} ]] ; then 
          MESSAGE_MOD="amd_loader.ksh Failed for ENV=$AMDENV on $hostname${TIMESTAMP_INFO:-}. " 
        fi

  	$LIB_HOME/notify.ksh ${ADDR_FILE_ARG:-} ${NOTIFY_DEBUG:-} \
		-s "$SUBJECT" \
		-m "$MESSAGE_MOD $THE_MESSAGE" \
                ${ATTACHMENT1:-} ${ATTACHMENT2:-}
}



if [[ "$STDIN_DATA_PRESENT" = "1" ]]
then
    ErrorLogFile=
    GET_STDIN="cat - |"
    ERROR_SOURCE="stdin"

else
    ErrorLogFile="$1"
    GET_STDIN=
    ERROR_SOURCE="$1"
fi


GREP_PATTERN_FILE=${GREP_PATTERN_FILE:-$DATA_HOME/checkForErrorsGrepPatterns.txt}

if [[ -f $GREP_PATTERN_FILE ]] ; then
	RetStr=`eval "$GET_STDIN grep $GREP_CASE -f $GREP_PATTERN_FILE $ErrorLogFile"`
else
	
	doNotify "checkforerrors.ksh: $GREP_PATTERN_FILE does not exist."
	print -u2 "For ENV=$AMDENV on $hostname ${TIMESTAMP_INFO:-} checkforerrors.ksh: $GREP_PATTERN_FILE does not exist."
	return 2
fi


if (($?==0)) ; then

  # allow notification to be turned off for running tests via the 
  # AMD_ERROR_NOTIFICATION  environment variable

  if [[ "${AMD_ERROR_NOTIFICATION:-Y}" = "Y" ]] ; then
	doNotify "Text found: $RetStr"
  fi

  print -u2 "`date`: For ENV=$AMDENV AMD Load Failed on $hostname${TIMESTAMP_INFO:-}${STEPINFO:-}. $0 found error text:
\n\t$RetStr
\n\tin $ERROR_SOURCE"

  return 1

else 
  return 0
fi
