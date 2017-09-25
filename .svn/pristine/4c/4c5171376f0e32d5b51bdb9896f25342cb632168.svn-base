#   $Author:   zf297a  $
# $Revision:   1.7  $
#     $Date:   04 Nov 2014  $
# $Workfile:   replicateGoldInventoryTables.ksh  $
# Rev 1.7 DSE 11/4/2014 added updateRamp step

USAGE="usage: ${0##*/} [-p | -s ] 
\nwhere
\t-p use pgoldlb - default
\t-s use sgoldlb"

if [[ "$1" = "?" ]] ; then
	print "$USAGE"
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi
while getopts : arguments
do
	case $arguments in
	  p) THE_DB_LINK=amd_pgoldlb_link;;
	  s) THE_DB_LINK=amd_sgoldlb_link;;
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

THE_DB_LINK=${THE_DB_LINK:-amd_pgoldlb_link}

if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
	export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

thisFile=${0##*/}
print "$0 started at " `date`
SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadItem $THE_DB_LINK &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadItemsa pgoldsa  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadMlit $THE_DB_LINK  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadOrd1 $THE_DB_LINK  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadOrdv $THE_DB_LINK  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadRamp $THE_DB_LINK  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadReq1 $THE_DB_LINK  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadTmp1 $THE_DB_LINK  &

wait

$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG updateRamp


if [[ -a $SQLPLUS_ERROR_LOG ]] ; then
	$LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
	if (($?!=0)) ; then
		exit 4
	fi
fi

print "$0 ending at " `date`
