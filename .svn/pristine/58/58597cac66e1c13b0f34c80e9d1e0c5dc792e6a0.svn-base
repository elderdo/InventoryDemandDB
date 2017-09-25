#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.9  $
#     $Date:   24 Oct 2013
# $Workfile:   sparePartDiff.ksh  $
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
# 10/24/13  DouglasElder   Fixed checkThreshold and made sure arg's are numeric
#
USAGE="usage: ${0##*/} [-s 999]\n\twhere\n\t-s 999 will set the tmp_amd_spare_parts minimum # of rows (default 99999)"

if [[ $# > 0 && $1 = "?" ]]
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
        # make sure there are 3 arguments
        if (($#!=3))
        then
                print "Error - checkThreshold was not invoked with $# arguments (3 are required): $*"
                exit 4
        fi
        # make sure the arguments are numbers
        if echo $1 | egrep -q '^[0-9]+$'; then
                if echo $2 | egrep -q '^[0-9]+$'; then
                        # everything is ok
                        :
                else
                        print "Error - checkThreshold was not invoked with 2 numbers: $1 $2 $3"
                        exit 4
                fi
        else
                print "Error - checkThreshold was invoked with $# arguments (2 numbers are required): $1 $2 $3"
                exit 4
        fi

	if (( $1 <= $2 ))
	then
		TimeStamp=${TimeStamp:-`date $DateStr`}
		hostname=`hostname -s`
		errormsg="Error: the number of $3 is below the threshold ($1 <= $2) @ $TimeStamp on $hostname" 
		print "$errormsg"
		$LIB_HOME/notify.ksh -s "Threshold Error" -m "$errormsg"
		$LIB_HOME/sendPage.ksh  "$errormsg"
		exit 4
	fi
}

checkThreshold `$LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_spare_parts;"`  ${SPARE_PARTS_NEW_DATA_THRESHOLD:-99999} "tmp_amd_spare_parts"

$LIB_HOME/execJavaApp.ksh SparePart
