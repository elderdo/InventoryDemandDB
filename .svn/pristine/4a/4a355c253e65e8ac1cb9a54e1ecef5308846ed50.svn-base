#!/usr/bin/ksh
#   $Author$ Douglas S. Elder
# $Revision$ 1.1
#     $Date$ 3/17/2010
#
USAGE="scanLog.ksh [-m start_month] [-d start_day] [-y start_year] [-x ]\n
\t\twhere\n
\t\t-x turns on debug\n
\t\t-m start_month is the log's month time stamp - the default is ??\n
\t\t-d start_day is the log's day time stamp - the default is ??\n
\t\t-y start_year is the log's year time stamp - the default is 2???\n"

if [[ "$1" = "?" ]] ; then
	print $USAGE
	return 4
fi

while getopts :xy:d:m: arguments
do
        case $arguments in
          x) debug=Y 
	     set -x ;;
          m) MONTH=$(printf "%02d" ${OPTARG} 2> /dev/null)
		if (($?!=0)) ; then
			MONTH=${OPTARG}
		fi ;;
          d) DAY=$(printf "%02d" ${OPTARG}) ;;
          y) YEAR=$(printf "%04d" ${OPTARG}) ;;
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

MONTH=${MONTH:-??} 
DAY=${DAY:-??} 
YEAR=${YEAR:-2???} 

grep cleanTraceTables ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep replicateGold ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep replicateWesm ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep processL67 ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep truncateAmd ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep loadDmndFrcstConsumables ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep dmndFrcstConsumablesDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep loadRmads ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep AmdLoad1 ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep loadSpoUsers ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep plannersDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep sendSpoUser ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep spoPartDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep AmdLoad2 ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep invDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep partFactorsDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep partLocForecastsDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep locPartLeadtimeDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep AmdLoad3 ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep locPartOverrideDiff ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep DynamSql ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep DynamSqlPostProcess ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep trimmedPostProcessing ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep bssmFlatFiles ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
grep archive ${YEAR}${MONTH}${DAY}*amd_loader* | perl calcTimeDiff.pl
