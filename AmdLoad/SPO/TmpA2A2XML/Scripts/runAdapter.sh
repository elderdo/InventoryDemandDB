#!/bin/sh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   31 Jan 2007 08:59:28  $
# $Workfile:   runAdapter.sh  $

# Validate options and associated arguments.
# Standard error is directed to null to suppress the getopts error message.



#Let's see if I'm already running
USER=escmc172
#SCRIPT=runAdapter.sh
SCRIPT=escmv2.adapters.receiving.

if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 1 ];then
#then I'm already running, ABORT this run
echo "***** ABORTING $SCRIPT *****"
echo "***** $SCRIPT IS ALREADY RUNNING *****"
echo
exit 3
fi

#I am clear to execute.
echo "***** Clear to Excecute script *****"

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"runAdapter.sh failed"}
	print -u2 $USAGE
	print -u2 "ERROR: runAdapter.sh aborted"
	print "ERROR: runAdapter.sh aborted"
	sendErrorMsg.ksh runAdapter.sh "${1:-'runAdapter.sh failed'}" "${1:-'runAdapter.sh failed'} - runAdapter.sh was aborted on $hostName for the $myenv environment."
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
			if [[ ${curScript%/runAdapter.sh} = "." ]]
			then
				curScript=`pwd`/runAdapter.sh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/runAdapter.sh) export myenv=dev ;;
			 $STL_HOME/bin/prd/runAdapter.sh) export myenv=prd ;;
			 $STL_HOME/bin/crp/runAdapter.sh) export myenv=crp ;;
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


DBG=""
QUEUE=""
mySID=""

while getopts :dq:i: option 2> /dev/null
do
  case $option in
    d) DBG="-d";;
    q) QUEUE="${OPTARG}";;
    i) myOSID="${OPTARG}";;
    ?) echo "\nUsage: $0 -q QUEUE [-i ORACLE_INSTANCE] [-d] debug mode\n"
       return 2;;
  esac
done

export DBG
export QUEUE
export myOSID

if [ "$TERM" = "" ]
then
  . /home/escmc172/.profile
fi

if [ "$QUEUE" = "" ]
  then
    echo "\nYou must provide a value for QUEUE."
    echo "\nUsage: $0 -q QUEUE [-i ORACLE_INSTANCE] [-d] debug mode\n"
    return 2
fi

if [ "$myOSID" != "" ]
  then
    ORACLE_SID=$myOSID; export $ORACLE_SID
fi

PFILE="EscmAdapter"$QUEUE".properties"

FileTimeStamp=`print ${TimeStamp} | sed 's/:/_/g'`
LOGFILE=${LOG_HOME}/${FileTimeStamp}_runAdapter_${QUEUE}_output.txt

env | grep MQ

echo "starting adapter $LOGFILE"
#java applint.adapters.receiving.Adapter -p $PFILE -t $DBG  >> $LOGFILE
#java applint.adapters.receiving.Adapter -p $PFILE $DBG  >> $LOGFILE
java escmv2.adapters.receiving.Adapter -p $PFILE $DBG  >> $LOGFILE
return $?
