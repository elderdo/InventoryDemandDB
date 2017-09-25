#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.5  $
#     $Date:   Mar 24 2006 15:03:02  $
# $Workfile:   loadA2AByDate.ksh  $
# This scripts reads all the data greater than or equal to the specified date contained in AMD and writes it to the tmp_a2a
# tables.
USAGE="usage: $0 [-d | -i | -p] [-f fromDate] [-t toDate] [-s startStep] [-e endStep] [-m] [-a app_home_directory] [-b]\n\twhere -d  is AMDD\n\t-i is AMDI\n\t-p is AMDP\nfromDate and toDate have the format MM/DD/YYYY.\n\nThe default fromDate is 01/01/1990 and the default toDate is the current date.\nThe default startStep is 1 and the default endStep is 15\n\t-m will display a menu for startStep and endStep\n\t-a app_home_directory (default is /home/escmc172\n\t-b debug mode" # switch arguments
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"loadA2AByDate.ksh failed"}
	print -u2 $USAGE
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
		myenv=${myenv:-}
		if [[ -z $myenv ]]
		then
			curScript=`which $0`
			if [[ ${curScript%/loadA2AByDate.ksh} = "." ]]
			then
				curScript=`pwd`/loadA2AByDate.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/loadA2AByDate.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/loadA2AByDate.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/loadA2AByDate.ksh) export myenv=crp ;;
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
# command line arguments take priority over amdconfig.ksh files

while getopts :dipf:t:s:e:ma:b arguments
do
	case $arguments in
	  b) set -x;;
	  m) menu=Y;;
	  a) AMD_HOME=amdd;;
	  d) AMD_DATABASE=amdd;;
	  e) endStep=${OPTARG};;
	  s) startStep=${OPTARG};;
	  f) fromDate=${OPTARG};;
	  t) toDate=${OPTARG};;
	  i) AMD_DATABASE=amdi;;
	  p) AMD_DATABASE=amdp;;
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


if [[ $1 = \? ]]
then
	print $USAGE
	exit 4
fi

if [[ $menu = Y ]]
then
	PS3='select start step? '
	select step in SpoUsers RespAssetMgr PartInfo \
		OrderInfo RepairInfo InTransits InvInfo RepairInvInfo BackorderInfo location_part_leadtime \
		location_part_override BomDetail part_loc_forecasts part_factors
	do
		if [[ -z $startStep ]]
		then
			startStep=$REPLY
			PS3='select end step? '
			continue
		fi
		if [[ -z $endStep ]]
		then
			endStep=$REPLY
		fi

		if [[ -n $startStep && -n $endStep ]]
		then
			break
		fi
	done	
fi

if [[ -z $AMD_DATABASE ]]
then
	case $myenv in
		prd) AMD_DATABASE=AMDP;;
		crp) AMD_DATABASE=AMDI;;
		dev) AMD_DATABASE=AMDD;;
	esac
fi

if [[ -z $AMD_DATABASE ]]
then
	abort  "AMD_DATABASE not defined"
fi

if [[ ! -z $startStep ]]
then
	if (( $startStep < 1 || $startStep > 14 ))
	then
		abort "startStep must be from 1 to 14"
	fi
fi

if [[ ! -z $endStep ]]
then
	if (( $endStep < 1 || $endStep > 14 ))
	then
		abort "endStep must be from 1 to 14"
	fi
fi

if [[ ! -z $startStep && ! -z $endStep ]]
then
	if (( $startStep > $endStep ))
	then
		abort "startStep must be <= $endStep"
	fi
fi

toDate=${toDate:-`date +%d/%m/%Y`}
	
sqlplus -s bsrm_loader/fromnewyork@${AMD_DATABASE} <<EOF
set echo off feedback off
set serveroutput on size 100000
whenever sqlerror exit sql.sqlcode
declare
rc number ;
from_date varchar2(10) := '$fromDate' ;
fromDt date ;
toDt date := to_date('$toDate','MM/DD/YYYY') ;
begin
if from_date is null then
	fromDt := a2a_pkg.start_dt ;
else
	fromDt := to_date(from_date,'MM/DD/YYYY') ;
end if ;
for step in ${startStep:-1}..${endStep:-14} loop
	if step = 1 then
		amd_owner.a2a_pkg.initA2ASpoUsers ;
	elsif step = 2 then
		amd_owner.a2a_pkg.initSiteRespAssetMgr ;
	elsif step = 3 then
		amd_owner.a2a_pkg.initA2APartInfo(fromDt,toDt) ;
		amd_partprime_pkg.DiffPartToPrime ; -- set amd_sent_to_a2a.spo_prime_part_no
	elsif step = 4 then
		amd_owner.a2a_pkg.initA2AOrderInfo(fromDt,toDt) ;
	elsif step = 5 then
		amd_owner.a2a_pkg.initA2ARepairInfo(fromDt,toDt) ;
	elsif step = 6 then
		amd_owner.a2a_pkg.initA2AInTransits(fromDt,toDt) ;
	elsif step = 7 then
		amd_owner.a2a_pkg.initA2AInvInfo(fromDt,toDt) ;
	elsif step = 8 then
		amd_owner.a2a_pkg.initA2ARepairInvInfo(fromDt,toDt) ;
	elsif step = 9 then
		amd_owner.a2a_pkg.initA2ABackorderInfo(fromDt,toDt) ;
	elsif step = 10 then
		amd_owner.amd_location_part_leadtime_pkg.loadA2AByDate(fromDt,toDt) ;
	elsif step = 11 then
		amd_owner.amd_location_part_override_pkg.loadA2AByDate(fromDt,toDt) ;
	elsif step = 12 then
		amd_owner.a2a_pkg.initA2ABomDetail(fromDt,toDt) ;
	elsif step = 13 then
		amd_owner.amd_part_loc_forecasts_pkg.loadA2AByDate(fromDt,toDt) ;
	elsif step = 14 then
		amd_owner.amd_part_factors_pkg.loadA2AByDate(fromDt,toDt) ;
	end if ;
	commit ;
end loop ;
end ;
/
quit
EOF

