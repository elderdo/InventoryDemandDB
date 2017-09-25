#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.2  $
#     $Date:   Mar 24 2006 15:03:04  $
# $Workfile:   loadAllandSend.ksh  $
# This scripts reads all the data contained in AMD and writes it to the tmp_a2a
# tables. It then creates the xml and sends it to the spo
USAGE="usage: $0 [-d | -i | -p] [-s startDate] [-e endDate] [-m] [-a app_home_directory] [-b] [-d log_directory] [-x xml_directory] [-q queue_name]\n\twhere -d  is AMDD\n\t-i AMDI\n\t-p is AMDP\n\t-s is the start step (default is 1)\n\t-e is the end step (default 14)\nt-m will display a menu for startStep and endStep" # switch arguments
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"loadAllandSend.ksh failed"}
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
			if [[ ${curScript%/loadAllandSend.ksh} = "." ]]
			then
				curScript=`pwd`/loadAllandSend.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/loadAllandSend.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/loadAllandSend.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/loadAllandSend.ksh) export myenv=crp ;;
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

while getopts :q:mx:se:a:ipdl:b arguments
do
	case $arguments in
	  s) start_date=$OPTARG;;
	  e) end_date=$OPTARG;;
	  b) set -x
	     debugMode=-b;;
	  a) AMD_HOME=$OPTARG;;
	  m) menu=Y;;
	  l) LOG_HOME=$OPTARG;;
	  x) XML_HOME=$OPTARG;;
	  q) queuename=$OPTARG ;;
	  i) iniFile=XmlAmdI.ini;;
	  p) iniFile=XmlAmdP.ini;;
	  d) iniFile=XmlAmdD.ini;;
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
args=$* # capture current position param's because subsequent .profile could override them
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

queuename=${queuename:-LBC17V2} # default not to queue xml file
export queuename


if [[ -z $iniFile ]]
then
	case $myenv in
		prd) iniFile=XmlAmdP.ini ;;
		dev) iniFile=XmlAmdD.ini ;;
		crp) iniFile=XmlAmdI.ini ;;
	esac
fi	
export iniFile

start_date=${start_date:-} 
end_date=${end_date:-} 
if [[ -n $start_date ]]
then
	if [[ -n $end_date ]]
	then
		loadA2AByDate.ksh -f $start_date -t $end_date
	else
		loadA2AByDate.ksh  -f $start_date
	fi
else
	loadAll.ksh 
fi
if (( $? == 0 ))
then
	amd2spo.ksh 
fi
