#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.00  $
#     $Date:   08 Oct 2013
# $Workfile:   sendSpoParts.ksh  $
#
#
USAGE="usage: ${0##*/} [-m] [-s 999] [-o step_override_file]\n
\twhere\n
\t-m use a menu to execute the steps\n
\t-o step override file - defaults is sendSpoPartsSteps.ksh\n"

if [[ $# > 0 && $1 = "?" ]]
then
	print $USAGE
	exit 0
fi

CUR_USER=`logname`
if [[ -z $CUR_USER ]] ; then
	CUR_USER=amduser
fi


while getopts :mo: arguments
do
	case $arguments in
	  m) AMD_SPOPART_MENU=Y;;
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

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
  export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

# don't cause an exit for an error until converted to Spo 8
abort() {
	errmsg="sendSpoParts:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	#exit 4
	return 0
}

execSqlplus() {
	STEP=${AMD_CUR_STEP:-$SUBSTEP}
	LOG_NAME="$LOG_HOME/${TimeStamp}_${STEP:+${STEP}_}${XSTEP:+${XSTEP}_}${0}_${1}.log"
	$LIB_HOME/execSqlplus.ksh -l $LOG_NAME $1
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}

sendPartData() {
	STEP=${AMD_CUR_STEP:-$SUBSTEP}
	LOG_NAME="$LOG_HOME/${TimeStamp}_${STEP:+${STEP}_}${XSTEP:+${XSTEP}_}${0}_${1}.log"
	$LIB_HOME/sendToSpo.ksh -l $LOG_NAME $1 > $LOG_NAME 2>&1
	if (($?!=0)) ; then
		#abort "$0 failed for $1"
		print "$0 failed for $1"
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
				XSTEP=`printf "%02d" $x`
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
	print "sendSpoParts.ksh's main started at `date` exec'ed by $CUR_USER" 
	execSteps 1-${#steps[*]}
	print "sendSpoParts.ksh's main ended at `date` exec'ed by $CUR_USER" 
		
}

steps[1]="execSqlplus updateSpoPrimePart"
steps[2]="sendPartData SpoPart"
steps[3]="sendPartData UserPart"
steps[4]="sendPartData PartPlannedPart"
steps[5]="sendPartData PartMtbf"
steps[6]="sendPartData PartCausalType"
steps[7]="sendPartData BomDetail"
steps[8]=return

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

chmod 644 $LOG_HOME/WinDiff.log* 

