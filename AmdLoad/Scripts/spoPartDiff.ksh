#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.31  $
#     $Date:   20 Jun 2016
#     $File:   spoPartDiff.ksh
#
# Rev 1.29 Douglas Elder 10/02/13 ignore spo import errors until Spo 8 conversion
# Rev 1.30 Douglas Elder 06/13/16 use ...Diff.sql
# Rev 1.31 Douglas Elder 06/20/16 added debug command line opt and 
#                                 set -x in function
#
USAGE="usage: ${0##*/} [ -d ] [ -m ] [ -s 999 ] [ -o step_override_file ]\n
\twhere\n
\t-d turn on debug\n
\t-m use a menu to execute the steps\n
\t-o step override file - defaults is spoPartDiffSteps.ksh\n
\t-s 999 will set the tmp_amd_spare_parts minimum # of rows (default 99999)"

if [[ $# > 0 && $1 = "?" ]]
then
	print $USAGE
	exit 0
fi

CUR_USER=`logname`
if [[ -z $CUR_USER ]] ; then
	CUR_USER=amduser
fi


DEBUG=

while getopts :dms:o: arguments
do
	case $arguments in
	  d) DEBUG=Y;;
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

function abort() {
  if [[ "$DEBUG" = "Y" ]] ; then
    set -x
  fi
	errmsg="spoPartDiff:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}

function execSqlplus() {
	$LIB_HOME/execJavaApp.ksh $1
}

function execSqlplus() {
	$LIB_HOME/execSqlplus.ksh $1
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}

sendPartData() {
	$LIB_HOME/sendToSpo.ksh $1
	if (($?!=0)) ; then
		#abort "$0 failed for $1"
		print "$0 failed for $1"
	fi
}

function checkThreshold {
	AMD_COUNT=`$LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_spare_parts;"`  
	AMD_THRESHOLD=${SPARE_PARTS_NEW_DATA_THRESHOLD:-99999} 
	AMD_TABLE="tmp_amd_spare_parts"

	if (( $AMD_COUNT <= $AMD_THRESHOLD ))
	then
		TimeStamp=${TimeStamp:-`date $DateStr`}
		hostname=`hostname -s`
		errormsg="Error: the number of $AMD_TABLE is below the threshold ($AMD_COUNT <= $AMD_THRESHOLD) @ $TimeStamp on $hostname" 
		print "$errormsg"
		$LIB_HOME/notify.ksh -s "Threshold Error" -m "$errormsg"
		$LIB_HOME/sendPage.ksh  "$errormsg"
		exit 4
	fi
}

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
			if [[ "${steps[$x]}" = "return" || "${steps[$x]}" = "exit" ]] ; then
				AMD_EXIT=Y
				return
			else
				print "${steps[$x]} started at `date`"
				${steps[$x]} 
				print "${steps[$x]} ended at `date`"
			fi
		done

}

function mainMenu {
	PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "

	select item in "${steps[@]}"
	do
		set  $REPLY
		execSteps $*
		if [[ "${AMD_EXIT:-N}" = "Y" ]] ; then
			return
		fi
	done
}

function main
{
	print "spoPartDiff.ksh's main started at `date` exec'ed by $CUR_USER" 
	execSteps 1-${#steps[*]}
	print "spoPartDiff.ksh's main ended at `date` exec'ed by $CUR_USER" 
		
}

steps[1]="checkThreshold"
steps[2]="execSqlplus truncRblPairs"
steps[3]="execJavaApp SparePart"
steps[4]="execSqlplus sparePartDiff"
steps[5]="execSqlplus updateCostToRepairOffBase"
steps[6]="execSqlplus loadRblPairs"
steps[7]="execSqlplus updateSpoPrimePart"
steps[8]="sendPartData SpoPart"
steps[9]="sendPartData UserPart"
steps[10]="sendPartData PartPlannedPart"
steps[11]="sendPartData PartMtbf"
steps[12]="sendPartData PartCausalType"
steps[13]="sendPartData BomDetail"
steps[14]="sendPartData NetworkPart"
steps[15]=return

THIS_FILE=`basename $0`
THIS_FILE_NO_EXT=`echo $THIS_FILE | sed 's/\..\{3\}$//'`
STEPS_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}Steps.ksh
if [[ -f $STEPS_FILE ]] ;  then
	# override steps
	print "$CUR_USER is executing script and overriding steps wiht ${STEP_FILE}" 2>&1 
	cat $STEPS_FILE 2>&1 
	. $STEPS_FILE
	print "$CUR_USER is renaming override script $STEPS_FILE to ${STEPS_FILE}.bku" 
	mv $STEPS_FILE ${STEPS_FILE}.bku
fi

if [[ "${AMD_SPOPART_MENU:-N}" = "Y" ]] ; then
	mainMenu 
else
	if (( $# > 0 )) ; then
		execSteps $* 
	else
		main
	fi
fi
