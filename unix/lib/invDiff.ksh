#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.19
#     $Date:   16 Jan 2014
# $Workfile:   invDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 11/20/01  Fernando F.    Initial implementation
# 01/09/02  Fernando F.    Changed java1.2 to java1.3.
# 07/30/02  Fernando F.    Added paths to jar's and zip's.
# 08/05/02  Fernando F.    Added logger classes to CLASSPATH.
# 08/26/02  Fernando F.    Added start end end times to script output.
# 08/26/02  Fernando F.    Removed timestamps and added chmod.
# 09/17/02  Fernando F.    Added WindowAlgo.ini as parameter and 'cd'.
# 09/23/04  ThuyPham       Added OnOrder, OnHandInvs, InRepair, InTransit, PartLocs.
# 05/25/05  ThuyPham 	   Added AmdReq.
# 10/02/13  Douglas Elder  ignore spo import errors until Spo 8 conversion
# 10/29/13  Douglas Elder  removed all spo funcions
# 01/16/14  Douglas Elder  rev 1.19 removed DB_CONNECTION_STRING_FOR_SPO test
#
USAGE="usage: ${0##*/} [ -m ] [ -d ] [ -o ]
\n\twhere
\n\t-m will enable a selection menu
\n\t-o\tturn off notification via email
\n\t-d enables debug\n"

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LIB_HOME || -z $SRC_HOME || -z $LOG_HOME || -z $DATA_HOME  ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :mdo arguments
do
	case $arguments in
	  m) export AMD_INVDIFF_MENU=Y;;
	  o) export AMD_ERROR_NOTIFICATION=N
	     export AMD_NOTIFY=N;;
	  d) export debug=Y
	     set -x ;;
	  *) print -u2 $USAGE
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
	AMD_INVDIFF_STEP=1
	export AMD_CUR_STEP=1
	AMD_INVDIFF_LOG=$LOG_HOME/${TimeStamp}_99_invDiff.log
else
	AMD_INVDIFF_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_invDiff.log
fi


function abort {
	print "$1"
	exit 4
}

function execJavaDiffApp {
	$LIB_HOME/execJavaApp.ksh $1 $2
	if (($?!=0)) ; then
		abort "execJavaApp.ksh $1 $2 failed for invDiff's $0"
	fi
}


function truncateInterfaceBatch {
	$LIB_HOME/execSqlplus.ksh -s truncateInterfaceBatch
	if (($?!=0)) ; then
		abort "$0 failed for invDiff.ksh $1"
	fi
}


steps[1]="execJavaDiffApp OnOrder"
steps[2]="execJavaDiffApp OnHandInvs"
steps[3]="execJavaDiffApp OnHandInvsSum"
steps[4]="execJavaDiffApp InRepair"
steps[5]="execJavaDiffApp RepairInvsSum"
steps[6]="execJavaDiffApp InTransit"
steps[7]="execJavaDiffApp InTransitSum"
steps[8]="execJavaDiffApp AmdReqs $LIB_HOME/WindowAlgo.ini"
steps[9]="execJavaDiffApp Backorder"
steps[10]="execJavaDiffApp BackorderSpoSum"
steps[11]="execJavaDiffApp Rsp"
steps[12]="execJavaDiffApp RspSum"
steps[13]="exit"

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
			if [[ "$AMD_INVDIFF_STEP" = "1" ]] ; then
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
if [[ "$AMD_INVDIFF_MENU" = "Y" ]] ; then
	mainMenu | tee -a "$AMD_INVDIFF_LOG"
else
	main $@ | tee -a "$AMD_INVDIFF_LOG"
fi

chmod 666 $LOG_HOME/WinDiff.log* 
chmod 666 $AMD_INVDIFF_LOG

print "$0 ending at " `date`
