#!/bin/ksh
# Author: Douglas S. Elder
# Date: 01/19/2012
# Desc: This script scans an
# import error log file for LpDemand or LpOverride and
# issues warnings were appropriate
# Req Arg 1: The import transaction
# Req Arg 2: The import error log file
# Optional switch: -s The output script  - default /tmp/sendWarnings.sql
# Optional switch: -t The text to search for - default Parent key exception INS *1806

USAGE="Usage: scanForMissingLocations.ksh -d -s output_script -t search_txt import_tran log_file"

if [[ -z $DATA_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

SQL_SCRIPT=/tmp/sendWarnings.sql
SEARCH_TEXT="INS *1806"

while getopts :ds:t: arguments
do
	case $arguments in
	d) debug=Y
	   set -x ;;
	s) SQL_SCRIPT="$OPTARG" ;;
	t) SEARCH_TEXT="$OPTARG" ;;
	*) print -u2 "$USAGE"
	   exit 4 ;;
	esac
done
((positions_occupied_by_switches = OPTIND - 1))
shift $positions_occupied_by_switches

scanImportLog() {
	# determine import error log 
	ERROR_LOG=$2
	if [[ -f $ERROR_LOG && -s $ERROR_LOG ]] ; then
		rm /tmp/sendWarnings.sql
		# create a script to send warnings for missing locations
		for location in `grep "$3"  $ERROR_LOG | cut -f 1 | sort | uniq`
		do
		  print "exec amd_warnings_pkg.insertWarningMsg(pData_line_no => 10, \
			pData_line => '$1', \
			pWarning => 'Warning: Location $location is in AMD but not in SPO');" >> \
			$SQL_SCRIPT
		done
		# run the script if it was created
		if [[ -f $SQL_SCRIPT && -s $SQL_SCRIPT ]] ; then
			print "exit" >> $SQL_SCRIPT
			$LIB_HOME/execSqlplus.ksh -x /tmp sendWarnings
		fi
		rm $SQL_SCRIPT
	fi
}

if (($#<2)) ; then
	print "$USAGE"
	if [[ "${debug:-N}" = "N" ]] ; then
		exit 4
	fi
fi

IMPORT_TRAN=${1:-LpOverride} # defaults for testing with debug
LOG_FILE=${2:-${LOG_HOME}/2012010218_00_00_22_LpOverrideImportErrors.log} # default for testing with debug

scanImportLog $IMPORT_TRAN $LOG_FILE $SEARCH_TEXT
