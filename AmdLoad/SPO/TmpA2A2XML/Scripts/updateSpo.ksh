#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.8  $
#     $Date:   15 Dec 2008 10:37:12  $
# $Workfile:   updateSpo.ksh  $
# This script invokes the stored procedure that will process the xml data 
# for data systems
USAGE="usage: ${0##*/} [-p | -i | -d]  [-a app_directory] [-b]\n\twhere -p is for prd\n\t-i is for crp\n\t-d is for dev\n\t-b debug mode"

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"updateSpo.ksh failed"}
	print ${1:-"updateSpo.ksh failed"}
	print -u2 $USAGE
	sendErrorMsg.ksh updateSpo.ksh "${1:-'updateSpo.ksh failed'}" "${1:-'updateSpo.ksh failed'} - updateSpo.ksh was aborted on $hostName for the $AMD_SPO_ENV environment."
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
			if [[ ${curScript%/updateSpo.ksh} = "." ]]
			then
				curScript=`pwd`/updateSpo.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/updateSpo.ksh) export AMD_SPO_ENV=dev ;;
			 $STL_HOME/bin/prd/updateSpo.ksh) export AMD_SPO_ENV=prd ;;
			 $STL_HOME/bin/crp/updateSpo.ksh) export AMD_SPO_ENV=crp ;;
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
UPDATE_SPO_LOGFILE=${LOG_HOME}/${FileTimeStamp}_updateSpo.txt
debugMode=${debugMode:-}
iniFile=${iniFile:-}
if [[ -z $iniFile ]]
then
	if [[ -z $AMD_SPO_ENV ]]
	then
		abort "AMD_SPO_ENV is not set to dev, prd, or crp"
	fi
	if [[ -z $DB_CONNECTION_STRING_FOR_SPO ]] ; then
		abort "DB_CONNECTION_STRING_FOR_SPO is not set"
	fi
fi	


print "pr_imp starting for the $AMD_SPO_ENV environment at " `date`
#sqlplus /nolog > $UPDATE_SPO_LOGFILE 2>&1 << EOF
sqlplus /nolog  << EOF
set echo off
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE
connect $DB_CONNECTION_STRING_FOR_SPO 

set time on
set timing on
set echo on

prompt spoc17v2.pr_imp() ;
exec spoc17v2.pr_imp() ;

-- get rid of erroneous deletes
delete from escmc17v2.transaction where substr(message,1,53) = 'ORA-20001: Corresponding Part record does not exist: '
and record like '%<TRANACT>D</TRANACT>%' ;
commit ;

exit 0
EOF
if (($?!=0)) ; then
	print "pr_imp('T') starting for the $AMD_SPO_ENV environment at " `date`
	sqlplus /nolog << EOF
set echo off
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE
connect $DB_CONNECTION_STRING_FOR_SPO 
set time on
set timing on
set echo on
set serveroutput on size 100000

prompt spoc17v2.pr_imp('T') ;
exec spoc17v2.pr_imp('T') ;

exit 0
EOF
	print "pr_imp('T') ending for the $AMD_SPO_ENV environment at " `date`
else
	print "pr_imp ending for the $AMD_SPO_ENV environment at " `date`
fi

