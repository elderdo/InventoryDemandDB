#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.9  $
#     $Date:   13 Jun 2016
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 11/20/01  Fernando F.    Initial implementation
# 08/26/02  Fernando F.    Added start end end times to script output.
# 08/26/02  Fernando F.    Removed timestamps and added chmod.
# 09/17/02  Fernando F.    Added WindowAlgo.ini as parameter and 'cd'.
# 09/23/04  ThuyPham       1.6 Added OnOrder, OnHandInvs, InRepair, InTransit, PartLocs.
# 05/25/05  ThuyPham 	     1.7 Added AmdReq.
# 06/13/16  Douglas Elder  1.9 use ...Diff.sql
#
USAGE="usage: ${0##*/} [-s 999]\n\twhere\n\t-s 999 will set the tmp_amd_spare_parts minimum # of rows (default 99999)"

if [[ $# > 0 && $1 == "?" ]]
then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts s: arguments
do
	case $arguments in
	  s) SPARE_PARTS_NEW_DATA_THRESHOLD=${OPTARG};;
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


function checkThreshold {
	if (( $1 <= $2 ))
	then
		TimeStamp=${TimeStamp:-$(date $DateStr)}
		hostname=$(hostname -s)
		errormsg="Error: the number of $3 is below the threshold ($1 <= $2) @ $TimeStamp on $hostname" 
		print "$errormsg"
		$LIB_HOME/notify.ksh -s "Threshold Error" -m "$errormsg"
		$LIB_HOME/sendPage.ksh  "$errormsg"
		exit 4
	fi
}

checkThreshold $($LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_spare_parts;")  ${SPARE_PARTS_NEW_DATA_THRESHOLD:-99999} "tmp_amd_spare_parts"

$LIB_HOME/execSqlplus.ksh sparePartsDiff
