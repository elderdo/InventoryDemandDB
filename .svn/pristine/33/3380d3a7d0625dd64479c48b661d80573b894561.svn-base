#!/usr/bin/ksh
USAGE="analyzePostPorcess.ksh [-a] [-c] [-s start_time | -n | -p]\n
\t\twhere\n
\t\t-a shows the avg run time\n
\t\t-c creates a comma separated output\n
\t\t-s start_time is the log's time stamp - the default is 10 AM\n
\t\t-n get all c17 log files with none as part of the filename\n
\t\t-p get all c17 log files with complete as part of the filename\n"

if [[ "$1" = "?" ]] ; then
	print $USAGE
	return 4
fi

while getopts :acdnps: arguments
do
        case $arguments in
          c) CSV=Y ;;
          a) SHOW_AVG=Y ;;
          n) NONE=Y ;;
          p) COMPLETE=Y ;;
          d) debug=Y 
	     set -x ;;
          s) START=$(printf "%02d" ${OPTARG}) ;;
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

START=${START:-10} # default start time
NONE=${NONE:-}  
COMPLETE=${COMPLETE:-}  
if [[ "$NONE" = "Y" ]] ; then
	START=??
	RUNTYPE="*none*"
elif [[ "$COMPLETE" = "Y" ]] ; then
	START=??
	RUNTYPE="*complete*"
fi

CSV=${CSV:-N} 
SHOW_AVG=${SHOW_AVG:-N} 

sed -n -e '/environment = /p' \
	-e '/end of tactics_/p' \
	-e '/^tactics   [A-Z][a-z][a-z] /p' \
	20??????${START}*c17*${RUNTYPE:-} | awk -v CSV=$CSV -v SHOW_AVG=$SHOW_AVG -f tacticsRun.awk 



#tactics   Mon Mar 23 12:15:37 CDT 2009
#end of tactics_metrics.sql   Mon Mar 23 12:54:15 CDT 2009
#tactics   Tue Mar 24 12:15:36 CDT 2009
#end of tactics_metrics.sql   Tue Mar 24 12:55:08 CDT 2009
#tactics   Wed Mar 25 12:16:48 CDT 2009
#end of tactics_metrics.sql   Wed Mar 25 13:00:04 CDT 2009
#tactics   Thu Mar 26 12:16:56 CDT 2009
#end of tactics_metrics.sql   Thu Mar 26 12:57:09 CDT 2009

#environment = prod machine = gpstl103   Mon Sep 14 12:17:03 CDT 2009
#end of tactics_metrics.sql   Mon Sep 14 12:51:24 CDT 2009
#environment = prod machine = gpstl103   Tue Sep 15 12:15:47 CDT 2009
#end of tactics_metrics.sql   Tue Sep 15 12:43:14 CDT 2009
#environment = prod machine = gpstl103   Wed Sep 16 12:15:56 CDT 2009
#end of tactics_metrics.sql   Wed Sep 16 12:45:02 CDT 2009
#environment = prod machine = gpstl103   Thu Sep 17 05:18:59 CDT 2009
#end of tactics_metrics.sql   Thu Sep 17 05:51:44 CDT 2009
#environment = prod machine = gpstl103   Fri Sep 18 12:16:30 CDT 2009

