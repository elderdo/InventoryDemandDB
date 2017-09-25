#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   16 May 2008 10:22:32  $
# $Workfile:   sendPartInfo.ksh  $
# This script creaates xml from the amd tmp_a2a_part_info table, 
# and sends it to the spo via the MQSeries message queue, 
# archives the xml files to a time_stamped tar file 
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

createXml.ksh PartInfo_DEL PartInfo
sendXml.ksh PartInfo_DEL PartInfo
archive.ksh
