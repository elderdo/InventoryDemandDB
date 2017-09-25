#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   25 Jun 2007 12:39:22  $
# $Workfile:   dbConnectionString.ksh  $
# This script creates a connection string for the SPO
USAGE="usage: ${0##*/} [-p | -i | -d]  [-a app_directory] [-b]\n\twhere -p is for prd\n\t-i is for crp\n\t-d is for dev\n\t-b debug mode"

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"dbConnectionString.ksh failed"}
	print ${1:-"dbConnectionString.ksh failed"}
	print -u2 $USAGE
	sendErrorMsg.ksh dbConnectionString.ksh "${1:-'dbConnectionString.ksh failed'}" "${1:-'dbConnectionString.ksh failed'} - dbConnectionString.ksh was aborted on $hostName for the $AMD_SPO_ENV environment."
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
			if [[ ${curScript%/dbConnectionString.ksh} = "." ]]
			then
				curScript=`pwd`/dbConnectionString.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/dbConnectionString.ksh) export AMD_SPO_ENV=dev ;;
			 $STL_HOME/bin/prd/dbConnectionString.ksh) export AMD_SPO_ENV=prd ;;
			 $STL_HOME/bin/crp/dbConnectionString.ksh) export AMD_SPO_ENV=crp ;;
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
while getopts :pidx:t:ba: arguments
do
	case $arguments in
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
	  x) XML_HOME=$OPTARG;;
	  t) DAYS_OLD=$OPTARG;;
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

FileTimeStamp=`print ${TimeStamp} | sed 's/:/_/g'`
UPDATE_SPO_LOGFILE=${LOG_HOME}/${FileTimeStamp}_dbConnectionString.txt
debugMode=${debugMode:-}
iniFile=${iniFile:-}
if [[ -z $iniFile ]]
then
	if [[ -z $AMD_SPO_ENV ]]
	then
		abort "AMD_SPO_ENV is not set to dev, prd, or crp"
	fi
	case $AMD_SPO_ENV in

		prd) DB_CONNECTION_STRING_FOR_SPO=c17devlpr/c17devlpr@STL_ESCMPD01 
		DB_CONNECTION_STRING_FOR_AMD=bsrm_loader/fromnewyork@AMDP ;;
		
		dev)  DB_CONNECTION_STRING_FOR_SPO=c17devlpr/c17devlpr@STL_TESCM
		DB_CONNECTION_STRING_FOR_AMD=bsrm_loader/fromnewyork@AMDD ;;

		crp) DB_CONNECTION_STRING_FOR_SPO=c17devlpr/hthurston@STLS_ESCMDEV 
		DB_CONNECTION_STRING_FOR_AMD=bsrm_loader/fromnewyork@AMDI ;;

		*) abort "AMD_SPO_ENV must be set to dev, crp, or prd" ;;
	esac
fi	

