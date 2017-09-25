#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   18 Jun 2008 13:06:28  $
# $Workfile:   sendSpoUser.ksh  $
# This script creaates xml from the amd tmp_a2a_spo_user table, 
# and sends it to the spo via the MQSeries message queue, 
# archives the xml files to a time_stamped tar file 
hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	errorMsg="${1:-'${0} failed'}"
	print -u2 "${errorMsg}"
	print "${errorMsg}"
	print -u2 "$USAGE"
	if [[ ${NOTIFY_IS_OFF:-N} = "N" ]] ; then
		sendErrorMsg.ksh ${0} "${1:-'${0} failed'}" "${1:-'${0} failed'} - ${0} was aborted on $hostName for the $AMD_SPO_ENV environment."
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
			if [[ ${curScript%/${0}} = "." ]]
			then
				curScript=`pwd`/${0}
			fi
			case $curScript in
			 $STL_HOME/bin/dev/${0}) export AMD_SPO_ENV=dev ;;
			 $STL_HOME/bin/prd/${0}) export AMD_SPO_ENV=prd ;;
			 $STL_HOME/bin/crp/${0}) export AMD_SPO_ENV=crp ;;
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

createXml.ksh SpoUser
sendXml.ksh SpoUser 
archive.ksh
