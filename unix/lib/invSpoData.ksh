#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.01
#     $Date:   02 Nov 2013
# $Workfile:   invSpoData.ksh  $
# Rev 1.01 DouglasElder fixed step numbering
USAGE="usage: ${0##*/} [-m] [-d] [-o]
\twhere\n
\t-m will enable a selection menu\n
\t-o\tturn off notification via email\n
\t-d enables debug\n"

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LIB_HOME || -z $SRC_HOME || -z $LOG_HOME || -z $DATA_HOME || -z $DB_CONNECTION_STRING_FOR_SPO ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :mdo arguments
do
	case $arguments in
	  m) export INVSPO_MENU=Y;;
	  o) export AMD_ERROR_NOTIFICATION=N
	     export AMD_NOTIFY=N;;
	  d) export debug=Y
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

if [[ -z $TimeStamp ]] ; then
	if [[ -z $DateStr ]] ; then
		export TimeStamp=`date +%Y%m%d%H_%M_%S`
	else
		export TimeStamp=`date $DateStr | sed "s/:/_/g"`
	fi
else
	TimeStamp=`print $TimeStamp | sed "s/:/_/g"`	
fi

if [[ -z $AMD_CUR_STEP ]] ; then
	INVSPO_STEP=1
	INVSPO_LOG=$LOG_HOME/${TimeStamp}_99_invSpoData.log
else
	INVSPO_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_invSpoData.log
fi

abort() {
	print "$1"
	exit 4
}

queueSpoDataForImporting() {

	# using the -n option for sendToSpo.ksh
       	# will make sure that the data is 
	# just queued to the spoc17v2.interface_batch
	# and the spoc17v2.x_ import tables

	$LIB_HOME/sendToSpo.ksh -n  $1
	if (($?!=0)) ; then
		#abort "$0 failed for sendToSpo.ksh $1"
		print "$0 failed for sendToSpo.ksh $1"
	fi
}

importSpoData() {
	$LIB_HOME/execSqlplus.ksh -s pr_imp
	if (($?!=0)) ; then
		#abort "$0 failed for invSpoData.ksh $1"
		print "$0 failed for invSpoData.ksh $1"
	fi
}

steps[1]="queueSpoDataForImporting LpOnHand"
steps[2]="queueSpoDataForImporting ConfirmedRequest"
steps[3]="queueSpoDataForImporting ConfirmedRequestLine"
steps[4]="queueSpoDataForImporting LpInTransit"
steps[5]="queueSpoDataForImporting LpBackorder"
steps[6]="importSpoData" # run pr_imp and process all the queued data

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
			# update curent step when executing this script
			export INVSPO_STEP=`printf "%02d" $x`

			if [[ "${steps[$x]}" != "exit" ]] ; then
				print "${steps[$x]} started at `date`"
			fi

			${steps[$x]} 
			if (($?!=0)) ; then
				abort "${steps[$x]} error."
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

print "$0 starting at " `date`
if [[ "$INVSPO_MENU" = "Y" ]] ; then
	mainMenu | tee -a "$INVSPO_LOG"
else
	main $@ | tee -a "$INVSPO_LOG"
fi

chmod 666 $LOG_HOME/WinDiff.log* 
chmod 666 $INVSPO_LOG

print "$0 ending at " `date`

