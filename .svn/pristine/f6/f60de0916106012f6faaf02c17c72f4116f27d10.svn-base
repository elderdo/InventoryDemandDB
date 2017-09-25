#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.4  $
#     $Date:   10 Feb 2010 15:30  $
# $Workfile:   sendToSpo.ksh  $
#
#
USAGE="usage: ${0##*/} [-d] [-k] [-l log] [-n] [-f filter_data] [-w] SpoTran\n
\twhere\n
\t-d turn on debug\n
\t-k keep the import error log\n
\t-l log specify log name for execSqlplus.ksh\n
\t-n do not do pr_imp for spo\n
\t-f filter_data filter out of the csv file all records with the given text\n
\t-w issue warnings only for import errors\n
\tSpoTran is the java app, sqlplus, and sqlldr script to get data into the SPO tables"

if [[ "$debug" = "Y" ]] ; then
	set -x
fi

if [[ $# > 0 && $1 = "?" ]]
then
	print $USAGE
	exit 0
fi


while getopts :df:kl:nw arguments
do
	case $arguments in
	  f) FILTER=Y 
	     FILTER_DATA="$OPTARG" ;;
	  d) debug=Y
	     set -x;;
          l) LOG_NAME="$OPTARG" ;;
	  k) KEEP_IMP_ERR=Y ;;
	  n) DO_PR_IMP=N ;;
	  w) WARNINGS=Y ;;
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


export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $DATA_HOME || -z $DB_CONNECTION_STRING_FOR_SPO ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

abort() {
	errmsg="sendToSpo:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}

execJavaApp() {
	$LIB_HOME/execJavaApp.ksh $1 $2
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}

cleanImportTables() {
	if [[ -n "$LOG_NAME" ]] ; then
		LOGOPT="-l $LOG_NAME"
	fi
	$LIB_HOME/execSqlplus.ksh -s ${LOGOPT:-} $1
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi		
}

loadImportTable() {
	DO_SQLLDR_FOR_SPO=${DO_SQLLDR_FOR_SPO:-Y}
	if [[ "$DO_SQLLDR_FOR_SPO" = "Y" ]] ; then
		$LIB_HOME/execSqlldr.ksh -s $1
		if (($?!=0)) ; then
			abort "$0 failed for $1"
		fi
	fi
}


importToSpo() {
	if [[ -n "$LOG_NAME" ]] ; then
		LOGOPT="-l $LOG_NAME"
	fi
	if [[ "${DO_PR_IMP:-Y}" = "Y" ]] ; then
		$LIB_HOME/execSqlplus.ksh ${LOGOPT:-} -s -m "Importing $1 to Spo at $(date)" -n  pr_imp 
		if (($?!=0)) ; then
			$LIB_HOME/execSqlplus.ksh ${LOGOPT:-} -s pr_imp_with_debug 
			if (($?!=0)) ; then
				abort "$0 failed for pr_imp_with_debug"
			fi
		fi
	else
		print "Import of $1 to Spo has been queued up at $(date)"
	fi
}

checkForImportErrors() {
	if [[ -f $SRC_HOME/${1}ImportErrors.sql ]] ; then
		$LIB_HOME/execSqlplus.ksh ${LOGOPT:-} -s ${1}ImportErrors
		if (($?!=0)) ; then
			if [[ "${WARNINGS:-N}" = "Y" ]] ; then
				print "Warning: $0 detected import errors for $1"
			else
				abort "$0 detected import errors for $1"
			fi
		fi
		if [[ -z ${TimeStamp:-} ]] ; then
			TimeStamp=`date +%Y%m%d`
		fi
		if [[ "${KEEP_IMP_ERR:-N}" = "N" ]] ; then
			rm $LOG_HOME/${TimeStamp}*${1}ImportErrors.log
		fi
	fi
}

filterCsv() {
	grep -v "$2" $DATA_HOME/$1.csv > /tmp/$1.csv
	cp /tmp/$1.csv $DATA_HOME/$1.csv
}


sendSpoData() {
	cleanImportTables $1
	execJavaApp $1

	if [[ "${FILTER:-N}" = "Y" ]] ; then
		filterCsv $1 $FILTER_DATA
	fi

	if [[ -f $DATA_HOME/$1.csv && -s $DATA_HOME/$1.csv ]] ; then
		loadImportTable $1
		importToSpo $1
		checkForImportErrors $1
	else
		rm $DATA_HOME/$1.csv
	fi
}


sendSpoData $1

if [[ -O $LOG_HOME/WinDiff.log ]] ; then
	chmod 644 $LOG_HOME/WinDiff.log* 
else
	rm -f $LOG_HOME/WinDiff.log*
fi

