#!/bin/ksh
# vim:ts=2:sw=2:sts=2:et:autoindent:smartindent:ff=unix:
# loadTmpAmdSpareParts.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.8  $
#     $Date:   20 Feb 2009 13:06:28  $
# Rev 1.8  20 Feb 2009
# Rev 1.9  15 Feb 2018 DSE replaced back tic's with $(...) and = with ==
#                          and obsolete -a with -e 
#
USAGE="usage: ${0##*/} [-p | -s ] 
\nwhere
\t-p use pgoldlb - default
\t-s use sgoldlb"

if [[ "$1" == "?" ]] ; then
	print "$USAGE"
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts : arguments
do
	case $arguments in
	  p) THE_DB_LINK=pgoldlb;;
	  s) THE_DB_LINK=sgoldlb;;
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

THE_DB_LINK=${THE_DB_LINK:-pgoldlb}

print "$0 starting at " $(date)
# forward any args to execSqlplus.ksh
$LIB_HOME/execSqlplus.ksh loadCat1 $THE_DB_LINK $@
if (($?!=0)) ; then
	exit 4
fi

$LIB_HOME/execSqlplus.ksh loadGold $@
if (($?!=0)) ; then
	exit 4
fi

thisFile=${0##*/}
baseFile=${thisFile%\.*}
SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_${baseFile}Errors.log
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadMain $@  &
$LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG loadPsms $@  &

wait

if [[ -e $SQLPLUS_ERROR_LOG ]] ; then
	$LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
	if (($?!=0)) ; then
		exit 4
	fi
fi

print "$0 ending at " $(date)
