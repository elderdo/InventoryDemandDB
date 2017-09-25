#!/bin/sh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   31 Jan 2007 08:59:28  $
# $Workfile:   runEnqueue.sh  $
# Validate options and associated arguments.
# Standard error is directed to null to suppress the getopts error message.

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"runEnqueue.sh failed"}
	print -u2 $USAGE
	print -u2 "ERROR: runEnqueue.sh aborted"
	print "ERROR: runEnqueue.sh aborted"
	sendErrorMsg.ksh runEnqueue.sh "${1:-'runEnqueue.sh failed'}" "${1:-'runEnqueue.sh failed'} - runEnqueue.sh was aborted on $hostName for the $myenv environment."
	exit ${2:-4}
}


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
		myenv=${myenv:-}
		if [[ -z $myenv ]]
		then
			curScript=`which $0`
			if [[ ${curScript%/runEnqueue.sh} = "." ]]
			then
				curScript=`pwd`/runEnqueue.sh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/runEnqueue.sh) export myenv=dev ;;
			 $STL_HOME/bin/prd/runEnqueue.sh) export myenv=prd ;;
			 $STL_HOME/bin/crp/runEnqueue.sh) export myenv=crp ;;
			 *) abort "Unable to set myenv"
			esac
		fi
		if [[ -a ${STL_HOME}/bin/$myenv/amdconfig.ksh ]]
		then
			configFile=${STL_HOME}/bin/$myenv/amdconfig.ksh 
		else
			abort "Cannot find amdconfig.ksh"
		fi
	fi
	. $configFile
fi

while getopts :dq:i: OPTION 2> /dev/null
do
  case $OPTION in
    d) DBG="-d";;
    q) QUEUE="ESCM."${OPTARG}".INPT"
       PROP="${OPTARG}";;
    i) INFILE=${OPTARG};;
    ?) echo "\nUsage: $0 -q QUEUE -i INFILE [-d]\n"
       return 2;;
  esac
done

if [ "$QUEUE" = "" -o "$INFILE" = "" ]
  then
    echo "\nYou must provide a value for QUEUE and INFILE."
    echo "\nUsage: $0 -q QUEUE -i INFILE [-d]\n"
    exit 2
fi
FileTimeStamp=`print ${TimeStamp} | sed 's/:/_/g'`
ESCMLOGFILE=${LOG_HOME}/${FileTimeStamp}_runEnqueue_${QUEUE}.txt

echo "java -Xms32m -Xmx256m escmv2.adapters.sending.STLEnqueueXML -client -h $MQHOST -c $MQCHANNEL -p $MQPORT -m $MQMGR -q $QUEUE -i $INFILE -e $PROPDIR/Escmv2LBSSL.properties -a $PROPDIR/EscmAdapter"${PROP}".properties -l $ESCMLOGFILE $DBG"
java -Xms32m -Xmx256m escmv2.adapters.sending.STLEnqueueXML -client -h $MQHOST -c $MQCHANNEL -p $MQPORT -m $MQMGR -q $QUEUE -i $INFILE -e $PROPDIR/Escmv2LBSSL.properties -a $PROPDIR/EscmAdapter"${PROP}".properties -l $ESCMLOGFILE $DBG
rc="$?"
if [[ -f $ESCMLOGFILE ]] 
then
	chgrp dstagelb $ESCMLOGFILE
fi
if [ "$rc" -eq 0 ]
  then
    echo "Records enqueued successfully!"
else
    abort "ERROR enqueuing records!"
fi
