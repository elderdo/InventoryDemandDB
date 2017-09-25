#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.22  $
#     $Date:   12 May 2008 10:17:22  $
# $Workfile:   amd2spo.ksh  $
# This script creaates xml from the amd tmp_a2a tables, 
# sends it to the spo via the MQSeries message queue, 
# archives the xml files to a time_stamped tar file, 
# and deletes any tar file older than 365 days.
# -p is for AMDP 
# -i is for AMDI 
# -d is for AMDD this is the default
USAGE="usage: ${0##*/} [-h] [-o] [-p | -i | -d]  [-x xml_home_directory]
[-t days_old] [-a app_directory] [-b]
\t-h displays this message
\t\t\"?\" displays this message if it is the only argument
\t-p is for amdp
\t-i is for amdi
\t-d is for amdd
\t-o will turn off sending of error messages
\t-b debug mode"

if [[ $# -eq 1 && "$1" = "?" ]]
then
	print "$USAGE"
	exit 0
fi

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	errorMsg="${1:-'amd2spo.ksh failed'}"
	print -u2 "${errorMsg}"
	print "${errorMsg}"
	print -u2 "$USAGE"
	if [[ ${NOTIFY_IS_OFF:-N} = "N" ]] ; then
		sendErrorMsg.ksh amd2spo.ksh "${1:-'amd2spo.ksh failed'}" "${1:-'amd2spo.ksh failed'} - amd2spo.ksh was aborted on $hostName for the $AMD_SPO_ENV environment."
	fi
	exit ${2:-4}
}

UNVAR=${UNVAR:-}
AMD_HOME=${AMD_HOME:-}
if [[ -z $AMD_HOME ]]
then
	conifgFile=
	LB_HOME=/apps/CRON/AMD
	if [[ -a ${UNVAR}${LB_HOME}/lib/amdconfig.ksh ]]
	then
		configFile=${UNVAR}${LB_HOME}/lib/amdconfig.ksh
	elif [[ -a ${LB_HOME}/lib/amdconfig.ksh ]]
	then
		configFile=${LB_HOME}/lib/amdconfig.ksh
	else
		STL_HOME=/home/escmc172
		AMD_SPO_ENV=${AMD_SPO_ENV:-}
		if [[ -z $AMD_SPO_ENV ]]
		then
			curScript=`which $0`
			if [[ ${curScript%/amd2spo.ksh} = "." ]]
			then
				curScript=`pwd`/amd2spo.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/amd2spo.ksh) export AMD_SPO_ENV=dev ;;
			 $STL_HOME/bin/prd/amd2spo.ksh) export AMD_SPO_ENV=prd ;;
			 $STL_HOME/bin/crp/amd2spo.ksh) export AMD_SPO_ENV=crp ;;
			 *) abort "Unable to set AMD_SPO_ENV"
			esac
		fi
		if [[ -a ${STL_HOME}/bin/$AMD_SPO_ENV/amdconfig.ksh ]]
		then
			configFile=${STL_HOME}/bin/$AMD_SPO_ENV/amdconfig.ksh 
		else
			abort "Cannot find amdconfig.ksh"
		fi
	fi
	. $configFile
fi
# command line arguments take priority over amdconfig.ksh files
# both dev and crp are on the same machine, so the AMD_SPO_ENV variable must be set
OPTIND=1
while getopts :l:opidx:t:bha: arguments
do
	case $arguments in
	  o) NOTIFY_IS_OFF=Y;;
	  h) print "$USAGE"
	     exit 0 ;;
	  b) set -x
	     debugMode=-b;;
	  i) iniFile=XmlAmdI.ini
	     AMD_SPO_ENV=crp
	     export AMD_SPO_ENV;; 
	  p) iniFile=XmlAmdP.ini
	     AMD_SPO_ENV=prd
	     export AMD_SPO_ENV;;
	  d) iniFile=XmlAmdD.ini
	     AMD_SPO_ENV=dev
	     export AMD_SPO_ENV;;
	  a) AMD_HOME=$OPTARG;;
	  l) LIST_LOG=Y ;;
	  x) XML_HOME=$OPTARG;;
	  t) DAYS_OLD=`echo $OPTARG | awk '/^[0-9]+$/'`
             if [[ -z $DAYS_OLD ]] ; then
		     abort "The -t option must have a numeric value"
	     fi ;;
	  :) print -u2 "You forgot to enter an argument for $OPTARG"
	     exit 4;;
	  \?) print -u2 "$OPTARG is not a valid switch."
	     print -u2 "$USAGE"
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

function checkDirectory {
	if [[ ! -a $1 ]]
	then
		abort "$1 does not exist"
	else
		if [[ ! -r $1 ]]
		then
			abort "$1 is not readable by $curUser $belongingTo"
		else
			if [[ ! -d $1 ]]
			then
				abort "$1 is not a directory"
			fi
		fi
	fi
}

debugMode=${debugMode:-}
iniFile=${iniFile:-}
if [[ -z $iniFile ]]
then
	if [[ -z $AMD_SPO_ENV ]]
	then
		abort "AMD_SPO_ENV is not set to dev, prd, or crp"
	fi
	case $AMD_SPO_ENV in
		prd) iniFile=XmlAmdP.ini ;;
		dev) iniFile=XmlAmdD.ini ;;
		crp) iniFile=XmlAmdI.ini ;;
		*) abort "AMD_SPO_ENV must be set to dev, crp, or prd" ;;
	esac
fi	

DAYS_OLD=${DAYS_OLD:-365}
LIST_LOG=${LIST_LOG:-N}

FileTimeStamp=`print ${TimeStamp} | sed 's/:/_/g'`
createXml.ksh -i $iniFile $debugMode 2>&1 > $LOG_HOME/${FileTimeStamp}_createXml.log
rc=$?
if [[ -a $LOG_HOME/${FileTimeStamp}_createXml.log ]]
then
	if [[ $LIST_LOG = Y ]]
	then
		cat $LOG_HOME/${FileTimeStamp}_createXml.log
	fi
	chgrp dstagelb $LOG_HOME/${FileTimeStamp}_createXml.log
	chmod g+r $LOG_HOME/${FileTimeStamp}_createXml.log
fi
if (( $rc > 0 ))
then
	abort "createXml.ksh failed"
fi

sendXml.ksh $debugMode 2>&1 > $LOG_HOME/${FileTimeStamp}_sendXml.log
rc=$?
if [[ -a $LOG_HOME/${FileTimeStamp}_sendXml.log ]]
then
	if [[ $LIST_LOG = Y ]]
	then
		cat $LOG_HOME/${FileTimeStamp}_sendXml.log ]]
	fi
	chgrp dstagelb $LOG_HOME/${FileTimeStamp}_sendXml.log
	chmod g+r $LOG_HOME/${FileTimeStamp}_sendXml.log
	grep -i "enqueued successfully" $LOG_HOME/${FileTimeStamp}_sendXml.log
	if (( $? == 0 ))
	then
		print "enqueued successfully a2a transactions"
	fi
fi
if (( $rc > 0 ))
then
	abort "sendXml.ksh failed"
fi
archive.ksh $debugMode
if (( $? > 0 ))
then
	abort "archive.ksh failed"
fi
find $ARCH_HOME -name \*.gz  -mtime $DAYS_OLD -exec rm -f '{}' \;
if (( $? > 0 ))
then
	abort "archive clean up failed"
fi
# get rid of log files that are older than 30 days
find $LOG_HOME -name \*.log  -mtime 30 -exec rm -f '{}' \;
if (( $? > 0 ))
then
	abort "log clean up failed"
fi
