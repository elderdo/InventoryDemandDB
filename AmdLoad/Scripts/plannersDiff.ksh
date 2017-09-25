#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.16  $
#     $Date:   13 Jun 2016
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
# 05/25/05  ThuyPham 	     1.12 Added AmdReq.
# 10/24/13  DouglasElder   1.13 Make sure values compared by checkThreshold are numeric
# 10/25/13  DouglasElder   1.14 use explicit path for sql files
# 08/31/15  DouglasElder   1.15 Fixed checkThreshold message
# 06/13/16  DouglasElder   1.16 used ...Diff.sql
#
USAGE="usage: ${0##*/} [-u 999] [-p 999] [-l 999]\n
\twhere\n
\t-u 999 will set the User minimum # of rows (default 10)\n
\t-p 999 will set the Planner minimum # of rows (default 10)\n
\t-l 999 will set the Planner Logons minimum # of rows (default 10)\n
\t-m will enable a selection menu\n"


if [[ "$#" -gt "0" && "$1" = "?" ]] ; then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh


debug=

while getopts :mu:p:l:d arguments
do
	case $arguments in
	  d) debug=-d
             set -x ;;
	  m) AMD_USE_PLANNERSDIFF_MENU=Y;;
	  u) USERS_NEW_DATA_THRESHOLD=${OPTARG};;
	  p) PLANNERS_NEW_DATA_THRESHOLD=${OPTARG};;
	  l) PLANNER_LOGONS_NEW_DATA_THRESHOLD=${OPTARG};;
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

abort() {
	errmsg="plannersDiff.ksh Failed"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}

function execSteps {
  if [[ "$debug" = "-d" ]] ; then
    set -x
  fi

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
  if [[ "$debug" = "-d" ]] ; then
    set -x
  fi
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
  if [[ "$debug" = "-d" ]] ; then
    set -x
  fi
	echo "main started at `date`" 
	execSteps 1-${#steps[*]}
	echo "main ended at `date`" 
		
}

function checkThreshold {
  if [[ "$debug" = "-d" ]] ; then
    set -x
  fi
	# make sure there are 3 arguments
        if (($#!=3))
        then
                print -u2 "checkThreshold was invoked with $# arguments instead of 3: $*"
                return 4
        fi
	# make sure the arguments are numbers
        if echo $1 | egrep -q '^[0-9]+$'; then
                if echo $2 | egrep -q '^[0-9]+$'; then
                        # everything is ok
                        :
                else
                        print -u2 "checkThreshold was not invoked with 2 numbers: $*"
                        return 4
                fi
        else
                print -u2 "checkThreshold was invoked with $# arguments (2 numbers are required): $*"
                return 4
        fi

	if (( $1 <= $2 ))
	then
		TimeStamp=${TimeStamp:-`date $DateStr`}
		hostname=`uname -n`
		errormsg="Error: the number of $3 is below the threshold ($1 <= $2) @ $TimeStamp on $hostname" 
		# don't write any error message to stdout or stderr so the load will continue
		$LIB_HOME/notify.ksh -m "$errormsg"
		$LIB_HOME/sendPage.ksh  "$errormsg"
		return 4
	fi
}

function execDiff {
  if [[ "$debug" = "-d" ]] ; then
    set -x
  fi
	print "$0 started for $1 with a minimum input of $2 at `date`"
	checkThreshold `$LIB_HOME/oraCheck.ksh "@$SRC_HOME/${1}.sql"` "$2" "$1"
	
	if (($?!=0)) ; then
		abort "checkThreshold failed for $1: the input had less than 10 records"
	fi

        case $1 in
          Users) SQL=usersDiff ;;
          Planner) SQL=plannerDiff ;;
          PlannerLogons) SQL=plannerLogonsDiff ;;
          *) exit 4;;
        esac

	$LIB_HOME/execSqlplus.ksh $debug $SQL  
	if (($?!=0)) ; then
		abort "$0 failed for execSqlplus.ksh $1"
	fi
	print "$0 for $1 ended at `date`"
}

print "$0 starting at " `date`


steps[1]="execDiff Users ${USERS_NEW_DATA_THRESHOLD:-10}"
steps[2]="execDiff Planner ${PLANNERS_NEW_DATA_THRESHOLD:-10}"
steps[3]="execDiff PlannerLogons  ${PLANNER_LOGONS_NEW_DATA_THRESHOLD:-10}"
steps[4]=return

if [[ "${AMD_USE_PLANNERSDIFF_MENU:-N}" = "Y" ]] ; then
	mainMenu 
else
	if (( $# > 0 )) ; then
		execSteps $* 
	else
		main
	fi
fi

chmod 666 $LOG_HOME/WinDiff.log*
print "$0 ending at " `date`
exit 0
