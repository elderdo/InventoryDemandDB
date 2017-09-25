#!/bin/ksh
#   $Author$
# $Revision$
#     $Date$
# $Workfile$
#
USAGE="usage: ${0##*/} [-a] [-s step] [-d] [-w] [-o] [-n]\n
\t\t[-v] [-t 999] [-m]\n
\twhere\n
\t-a send all parts\n
\t-s step name or number (used for logname)\n
\t-d turn on debug\n
\t-w abort for warnings\n
\t-o turn off error notification\n
\t-n don't load tmp_amd_spare_parts (default is to load it)\n
\t-x don't do the sparePartDiff (default is to do it)\n
\t-v send all logs and sqlplus output to stdout for viewing\n
\t-t 999\tset the SPARE_PARTS_NEW_DATA_THRESHOLD for data\n
\t-m execute this script interactively via a menu\n
\t\twhere 999 is the min # or rows for tmp_amd_spare_parts.\n
\t\tThe default is 99999\n"

if [[ "$#" -gt "0" && "$1" = "?" ]]
then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LIB_HOME || -z $LOG_HOME ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :apdows:t:xvm arguments
do
	case $arguments in
	  m) AMD_LOADPARTS_MENU=Y;;
	  v) VIEW_STDOUT=Y;;
	  a) export SEND_ALL_PARTS=Y;;
	  p) export SEND_PARTS=Y;;
	  s) AMD_CUR_STEP=${OPTARG};;
	  w) export ABORT_FOR_WARNINGS=Y;;
	  n) export AMD_LOAD_TMP=N;;
	  x) export AMD_SPARE_PART_DIFF=N;;
	  o) AMD_ERROR_NOTIFICATION=N;;
	  t) SPARE_PARTS_NEW_DATA_THRESHOLD=${OPTARG};;
	  d) debug=Y
	     set -x ;;
	  *) print -u2 "$USAGE"
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

hostname=`uname` 
thisFile=${0##*/}

function abort {
	if [[ -a $DATA_HOME/loadSparePart.txt ]] ; then
		ADDRESSES=loadSparePart.txt
	elif [[ -a $DATA_HOME/LOADPARTSentory.txt ]] ; then
		ADDRESSES=LOADPARTSentory.txt
	else
		ADDRESSES=addresses.txt
	fi		
	$LIB_HOME/notify.ksh -a $ADDRESSES  -s "$thisFile failed at $1" -m "$thisFile has failed on $hostname at $1." 
	exit 4
}

if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=`date $DateStr`
fi

export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`

if [[ -z $AMD_CUR_STEP ]] ; then
	AMD_LOADPARTS_STEP=1
	export AMD_CUR_STEP=1
	AMD_LOADPARTS_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
else
	AMD_LOADPARTS_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${thisFile%\.*}.log
fi
SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_9999_${thisFile%\.*}Errors.log


function execSteps {

		typeset -Z3 array
		cnt=0
		for x in `echo $* | awk -f $BIN_HOME/awkNumInput.txt`
		do
			let cnt=cnt+1
			array[$cnt]=$x
		done

		# set $* to the data in the work array
		set -s ${array[*]}

		# empty work array
		i=1
		while (( $i <= $cnt ))
		do
			array[$i]=
			let i=i+1
		done

		for x in $*
		do
			((x=x)) # make sure x is a number with no leading zerso
			if [[ "$AMD_LOADPARTS_STEP" = "1" ]] ; then
				AMD_CUR_STEP=`printf "%02d" $x`
			fi
			if [[ "${steps[$x]}" != "exit" ]] ; then
				print "${steps[$x]} started at `date`"
			fi
			if [[ "${steps[$x]}" = "amd2spo" ]] ; then
				${steps[$x]} &
			else
				${steps[$x]} 
			fi
			print "${steps[$x]} ended at `date`"
		done

}

function mainMenu {
	PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "
	select item in "${steps[@]}" 
	do
		set  $REPLY
		execSteps $*
	done
}

function main {
		
	echo "$0 started at `date`" 
	let curStep=${1:-1}
	let endStep=${2:-${#steps[*]}}
	if (( $curStep > $endStep ))
	then
		print -u2 "start step must be <= end step"
		exit 4
	fi

	execSteps $curStep-$endStep
	echo "$0 ended at `date`" 
}		



function loadTmpAmdSpareParts {
	$LIB_HOME/$0.ksh ${VIEW_STDOUT:+-n}
	if (($?!=0)) ; then
		abort "$0.ksh"
	fi
}

function sparePartDiff {
		$LIB_HOME/$0.ksh $SPAREPARTDIFF_ARG
		if (($?!=0)) ; then
			abort "$0.ksh"
		fi
}

function sendPartInfo {
	$LIB_HOME/$0.ksh ${VIEW_STDOUT:+-v} $SENDPARTINFO_ARGS
	if (($?!=0)) ; then
		abort "$0.ksh"
	fi
}

function processParts {
	if [[ "$1"  = "Y" ]] ; then
		loadTmpAmdSpareParts
	fi

	if [[ "$2" = "Y" ]] ; then
		if [[ -n ${SPARE_PARTS_NEW_DATA_THRESHOLD:-} ]]	
		then
			SPAREPARTDIFF_ARG="-s $SPARE_PARTS_NEW_DATA_THRESHOLD"
		else
			SPAREPARTDIFF_ARG=
		fi
		sparePartDiff
	fi

	SENDPARTINFO_ARGS=
	if [[ "$3" = "Y" ]] ; then
		SENDPARTINFO_ARGS="-a"
	fi
	if [[ "$4" = "Y" ]] ; then
		SENDPARTINFO_ARGS="$SENDPARTINFO_ARGS -w"
	fi
	if [[ "$5" = "Y" ]] ; then
		SENDPARTINFO_ARGS="$SENDPARTINFO_ARGS -o"
	fi
	if [[ "$6" = "Y" ]] ; then
		SENDPARTINFO_ARGS="$SENDPARTINFO_ARGS -d"
	fi
	if [[ -n $7 ]] ; then
		SENDPARTINFO_ARGS="$SENDPARTINFO_ARGS -s $7"
	fi
	sendPartInfo
}

function loadTheParts {
	processParts  ${AMD_LOAD_TMP:-Y}  \
		${AMD_SPARE_PART_DIFF:-Y} \
		${SEND_ALL_PARTS:-N} \
		${ABORT_FOR_WARNINGS:-N} \
		${AMD_ERROR_NOTIFICATION:-N} \
		${debug:-N} \
		${AMD_CUR_STEP:-}
}


function checkSqlplusErrorLog {
	if [[ -f $SQLPLUS_ERROR_LOG ]] ; then
		$LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
		if (($?!=0)) ; then
			abort "loadGoldInventory or loadAmdReqs"
		fi
	fi
}

function notify {
	hostname=`hostname -s`
	$LIB_HOME/$0.ksh -a LOADPARTSentory.txt \
       		-s "$1 completed" \
		-m "$1 has completed on $hostname." 
}


if [[ "$AMD_LOADPARTS_MENU" = "Y" ]] ; then
	steps[1]=loadTmpAmdSpareParts
	steps[2]=sparePartDiff
	steps[3]=sendPartInfo
	steps[4]=exit
	steps[5]="notify $0"
	mainMenu 2>&1 | tee -a $AMD_LOADPARTS_LOG
else
	steps[1]=loadTheParts
	print "$0 starting at " `date`
	main $@ 2>&1 | tee -a $AMD_LOADPARTS_LOG
	print "$0 ending at " `date`
fi

