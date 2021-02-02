#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.03
#     $Date:   15 Feb 2018
#
# Rev 1.01 DouglasElder changed start/end messages to have this file name
# Rev 1.02 DouglasElder 06/03/16 use ...Diff.sql
# Rev 1.03 DouglasElder 02/15/18 use == vs = and use (( )) for numeric compares
#

HOME=/apps/CRON/AMD
DATA=$HOME/data
if [[ -f "$DATA/debug.txt" ]] ; then
  DEBUG=$(cat $DATA/debug.txt)
else
  DEBUG=N
fi

USAGE="usage: ${0##*/} [-m] [-s 999] [-o step_override_file]\n
\twhere\n
\t-m use a menu to execute the steps\n
\t-o step override file - defaults is pairsAndPartsSteps.ksh\n
\t-s 999 will set the tmp_amd_spare_parts minimum # of rows (default 99999)"

if [[ $# > 0 && $1 == "?" ]]
then
	print $USAGE
	exit 0
fi

CUR_USER=$(logname) 2> /dev/null
if [[ -z $CUR_USER ]] ; then
	CUR_USER=amduser
fi


while getopts "dms:o:" arguments
do
	case $arguments in
	  d) DEBUG=Y;set -x;;
	  m) AMD_SPOPART_MENU=Y;;
	  s) SPARE_PARTS_NEW_DATA_THRESHOLD=${OPTARG};;
	  o)   STEPS_FILE=${OPTARG}
	     if [[ ! -f $STEPS_FILE ]] ; then
		     print -u2 "Error: $STEPS_FILE does not exist"
		     exit 4
	     fi ;; 
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


export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $DATA_HOME || -z $DB_CONNECTION_STRING_FOR_SPO ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

function abort {
	errmsg="spoPartDiff:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}

function execSqlplus {
  [[ "$DEBUG" == "Y" ]] && set -x 
	$LIB_HOME/execSqlplus.ksh $1
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}

function checkThreshold {
  [[ "$DEBUG" == "Y" ]] && set -x 
	AMD_COUNT=$($LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_spare_parts;")  
	AMD_THRESHOLD=${SPARE_PARTS_NEW_DATA_THRESHOLD:-99999} 
	AMD_TABLE="tmp_amd_spare_parts"

	if (( AMD_COUNT <= AMD_THRESHOLD ))
	then
		TimeStamp=${TimeStamp:-$(date $DateStr)}
		hostname=$(hostname -s)
		errormsg="Error: the number of $AMD_TABLE is below the threshold ($AMD_COUNT <= $AMD_THRESHOLD) @ $TimeStamp on $hostname" 
		print "$errormsg"
		$LIB_HOME/notify.ksh -s "Threshold Error" -m "$errormsg"
		$LIB_HOME/sendPage.ksh  "$errormsg"
		exit 4
	fi
}

function execSteps {
  [[ "$DEBUG" == "Y" ]] && set -x 

		typeset -Z3 array
		cnt=0
		for x in $(echo $* | awk -f $BIN_HOME/awkNumInput.txt)
		do
			let cnt=cnt+1
			array[$cnt]=$x
		done

		# set $* to the data in the work array
		set -s ${array[*]}

		# empty work array
		i=1
		while (( i <= cnt ))
		do
			array[$i]=
			let i=i+1
		done

		for x in $*
		do
			((x=x)) # make sure x is a number with no leading zerso
			if [[ "${steps[$x]}" == "return" || "${steps[$x]}" == "exit" ]] ; then
				AMD_EXIT=Y
				return
			else
				print "${steps[$x]} started at $(date)"
				${steps[$x]} 
				print "${steps[$x]} ended at $(date)"
			fi
		done

}

function mainMenu {
  [[ "$DEBUG" == "Y" ]] && set -x 
	PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "

	select item in "${steps[@]}"
	do
		set  $REPLY
		execSteps $*
		if [[ "${AMD_EXIT:-N}" == "Y" ]] ; then
			return
		fi
	done
}

function main {
  [[ "$DEBUG" == "Y" ]] && set -x 
	print "${THIS_FILE}'s main started at $(date) exec'ed by $CUR_USER" 
	execSteps 1-${#steps[*]}
	print "${THIS_FILE}'s main ended at $(date) exec'ed by $CUR_USER" 
		
}

steps[1]="checkThreshold"
steps[2]="execSqlplus truncRblPairs"
steps[3]="execSqlplus sparePartsDiff"
steps[4]="execSqlplus updateCostToRepairOffBase"
steps[5]="execSqlplus loadRblPairs"
steps[6]=return

THIS_FILE=$(basename $0)
THIS_FILE_NO_EXT=$(echo $THIS_FILE | sed 's/\..\{3\}$//')
STEPS_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}Steps.ksh
if [[ -f $STEPS_FILE ]] ;  then
	# override steps
	print "$CUR_USER is executing script and overriding steps wiht ${STEP_FILE}" 2>&1 
	cat $STEPS_FILE 2>&1 
	. $STEPS_FILE
	print "$CUR_USER is renaming override script $STEPS_FILE to ${STEPS_FILE}.bku" 
	mv $STEPS_FILE ${STEPS_FILE}.bku
fi

if [[ "${AMD_SPOPART_MENU:-N}" == "Y" ]] ; then
	mainMenu 
else
	if (( $# > 0 )) ; then
		execSteps $* 
	else
		main
	fi
fi

chmod 644 $LOG_HOME/WinDiff.log* 

