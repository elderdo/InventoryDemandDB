#!/bin/ksh
# vim: ff=unix:ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
#   $Author:   zf297a  $
# $Revision:   1.15  $
#     $Date:   04 Sep 2009 22:59:40  $
# $Workfile:   AmdLoad1.ksh  $
# rev 1.13 04 Sep 2009 
# rev 1.14 21 Feb 2012 - made loadPsms a foreground process so deadlock does not occur
# rev 1.15 24 Jan 2017 - add analyzeTmpAmdSpareParts
# rev 1.16 19 Mar 2017 - fixed function execSqlplus
# rev 1.17 03 Aug 2017 - fixed function abort to say AmdLoad1.ksh failed 
#                        vs AmdLoad2.ksh failed

USAGE="usage: ${0##*/} [-m] [-f] [-d] [-o override_file]  [startStep endStep ]\n\n
\twhere\n
\t-m will enable a selection menu\n
\t-f run all sqlplus steps in the foreground (default is background)\n
\t-o override file - default is data/AmdLoad1Steps.ksh\n
\t-d enables debug\n"

if [[ "$#" -gt "0" && "$1" = "?" ]] ; then
	print $USAGE
	exit 0
fi

CUR_USER=`logname`
if [[ -z $CUR_USER ]] ; then
	CUR_USER=amduser
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

abort() {
	errmsg="AmdLoad1.ksh Failed"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}


while getopts :mndfo: arguments
do
	case $arguments in
	  m) AMD_USE_AMDLOAD1_MENU=Y;;
	  o) STEPS_FILE=${OPTARG}
	     if [[ ! -f $STEPS_FILE ]] ; then
		     print -u2 "Error: $STEPS_FILE does not exist"
		     exit 4
	     fi ;;
	  f) AMD_FOREGROUND=Y;;
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
				${steps[$x]} 
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
	echo "main started at `date`" 
	execSteps 1-${#steps[*]}
	echo "main ended at `date`" 
		
}

function checkForErrors {
	if [[ -a $SQLPLUS_ERROR_LOG ]] ; then
		$LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
		if (($?!=0)) ; then
			exit 4
		fi
	fi
}

if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
	export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

print "$0 started at " `date`
thisFile=${0##*/}

SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log

function execSqlplus {
	print "$0.ksh $1 started at `date` exec'ed by $CUR_USER"
	if [[ -n $2 || "${AMD_FOREGROUND:-N}" = "Y" ]] ; then
		$LIB_HOME/execSqlplus.ksh -t -e $SQLPLUS_ERROR_LOG $1  
		RC=$?
		if (($RC!=0)) ; then
			print "$0 $1 had an error"
		fi
	else
		$LIB_HOME/execSqlplus.ksh -t -e $SQLPLUS_ERROR_LOG $1   &
	fi
}

# loadGold creates tmp_amd_spare_parts which is input to loadMain
# so it must complete first
steps[1]="execSqlplus loadGold -f"
steps[2]="execSqlplus loadPsms -f"
steps[3]="execSqlplus loadMain"
steps[4]="execSqlplus loadWecm"
steps[5]="execSqlplus analyzeTmpAmdSpareParts"
steps[6]=return

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
	

if [[ "${AMD_USE_AMDLOAD1_MENU:-N}" = "Y" ]] ; then
	mainMenu 
else
	if (( $# > 0 )) ; then
		execSteps $* 
	else
		main
	fi
fi
wait
checkForErrors
print "$0 ending at " `date`
