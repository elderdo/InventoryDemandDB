#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.18  $
#     $Date:   Mar 24 2006 15:03:04  $
# $Workfile:   loadAll.ksh  $
# This scripts reads all the data contained in AMD and writes it to the tmp_a2a
# tables.
USAGE="usage: ${0##*/} [-d | -i | -p] [-s startStep] [-e endStep] [-m] [-a app_home_directory] [-b]\n\twhere -d  is AMDD\n\t-i AMDI\n\t-p is AMDP\n\t-s is the start step (default is 1)\n\t-e is the end step (default 15)\nt-m will display a menu for startStep and endStep\n\t-a app_home_directory defaults to /home/escmc172\n\t-b debug mode" # switch arguments
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"loadAll.ksh failed"}
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
			if [[ ${curScript%/loadAll.ksh} = "." ]]
			then
				curScript=`pwd`/loadAll.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/loadAll.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/loadAll.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/loadAll.ksh) export myenv=crp ;;
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

while getopts :dipe:s:mba: arguments
do
	case $arguments in
	  b) set -x;;
	  m) menu=Y;;
	  d) AMD_DATABASE=amdd;;
	  a) AMD_HOME=${OPTARG};;
	  e) endStep=${OPTARG};;
	  s) startStep=${OPTARG};;
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

startStep=${startStep:-}
endStep=${endStep:-}
if [[ ${menu:-N} = Y ]]
then
	PS3='select start step? '
	select step in SpoUsers RespAssetMgr PartInfo \
		OrderInfo RepairInfo InTransits InvInfo RepairInvInfo BackorderInfo location_part_leadtime \
		location_part_override BomDetail part_loc_forecasts part_factors demand
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
		print $REPLY
	done	
	print start step = $startStep end step = $endStep
fi
AMD_DATABASE=${AMD_DATABASE:-}
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
	abort "AMD_DATABASE not defined"
fi

if [[ ! -z $startStep ]]
then
	if (( $startStep < 1 || $startStep > 15 ))
	then
		abort "startStep must be from 1 to 15"
	fi
fi

if [[ ! -z $endStep ]]
then
	if (( $endStep < 1 || $endStep > 15 ))
	then
		abort "endStep must be from 1 to 15"
	fi
fi

if [[ ! -z $startStep && ! -z $endStep ]]
then
	if (( $startStep > $endStep ))
	then
		abort "startStep must be <= $endStep"
	fi
fi

sqlplus -s bsrm_loader/fromnewyork@${AMD_DATABASE} <<EOF
set echo off feedback off
set serveroutput on size 100000
whenever sqlerror exit sql.sqlcode
begin
	a2a_pkg.loadAll(startStep => ${startStep:-1}, endStep => ${endStep:-15} ) ;
end ;
/
quit
EOF
