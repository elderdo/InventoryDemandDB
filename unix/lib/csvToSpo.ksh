#!/usr/bin/ksh
# This script will allow importing of
# properly formated csv files into
# spo tables
# It assumes that the current batch #
# needs to be updated
# $Author:   zf297a  $
# $Revision:   1.3  $
# $Date:   03 Aug 2009 09:07:54  $
#
USAGE="Usage: csvToSpo.ksh [-m] csvfilename [spotable]\n
\t-m will present the user with a list of spo table
\tcsvfilename must exist in the $DATA_HOME directory
\t\tif csvfilename <> spotable then spotable.csv is created from\n 
\t\tcsvfilename\n
\tspotable defaults to LpOverride, but if specified\n
\t\tit must exist in the spoTables array\n"

print "$0 started at `date`"

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=`date +%Y%m%d`
fi

DEBUG_PRINT=

while getopts :md arguments
do
	case $arguments in
	  m) CSV_TO_SPO_MENU=Y;;
	  d) debug=Y
	     DEBUG_PRINT=print
	     set -x ;;
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



spoTables[1]=LpDemand
spoImportTables[1]=X_IMP_LP_DEMAND
spoTables[2]=LpOnHand
spoImportTables[2]=X_IMP_LP_ON_HAND
spoTables[3]=ConfirmedRequest
spoImportTables[3]=X_IMP_CONFIRMED_REQUEST
spoTables[4]=ConfirmedRequestLine
spoImportTables[4]=X_IMP_CONFIRMED_REQUEST_LINE
spoTables[5]=LpInTransit
spoImportTables[5]=X_IMP_LP_IN_TRANSIT
spoTables[6]=LpBackorder
spoImportTables[6]=X_IMP_LP_BACKORDER
spoTables[7]=LpOverride
spoImportTables[7]=X_IMP_LP_OVERRIDE
spoTables[8]=SpoUser
spoImportTables[8]=X_IMP_SPO_USER
spoTables[9]=UserUserType
spoImportTables[9]=X_IMP_USER_USER_TYPE
spoTables[10]=LpAttribute
spoImportTables[10]=X_IMP_LP_ATTRIBUTE
spoTables[11]=LpDemandForecast
spoImportTables[11]=X_IMP_LP_DEMAND_FORECAST
spoTables[12]=SpoPart
spoImportTables[12]=X_IMP_PART
spoTables[13]=UserPart
spoImportTables[13]=X_IMP_USER_PART
spoTables[14]=PartPlannedPart
spoImportTables[14]=X_IMP_PART_PLANNED_PART
spoTables[15]=PartMtbf
spoImportTables[15]=X_IMP_PART_MTBF
spoTables[16]=PartCausalType
spoImportTables[16]=X_IMP_Part_CAUSAL_TYPE
spoTables[17]=BomDetail
spoImportTables[17]=X_IMP_BOM_DETAIL
spoTables[18]=NetworkPart
spoImportTables[18]=X_IMP_NETWORK_PART

function tableMenu {
	PS3="select n for the table to be sent or hit return to re-display menu? "

	select item in "${spoTables[@]}"
	do
		SPO_TABLE=$item
		IMPORT_TABLE=${spoImportTables[$REPLY]}
		return
	done
}




function cleanImportTables {
	print "`date` $0 started"
	$DEBUG_PRINT $LIB_HOME/execSqlplus.ksh -s $1
	if (($?!=0)) ; then
		print  "$0 failed for csvToSpo.ksh"
		exit 4
	fi
	print "`date` $0 ended"
}

function createBatch {
	print "`date` $0 started"
	$DEBUG_PRINT $LIB_HOME/execJavaApp.ksh SpoBatch $IMPORT_TABLE > /tmp/batch.txt
	if (($?!=0)) ; then
		print  "$0 failed for csvToSpo.ksh"
		exit 4
	fi
	BATCH_NUM=`sed 's/.*=//' /tmp/batch.txt`
	print "`date` $0 ended"
}

function updateCsvFileWithBatch {
	print "`date` $0 started"
	# make a backups of csv files since they are going to be updated
	cp -f $DATA_HOME/$CSV_FILE.csv $DATA_HOME/${TimeStamp}_$CSV_FILE.csv
	cp -f $DATA_HOME/$SPO_TABLE.csv $DATA_HOME/${TimeStamp}_$SPO_TABLE.csv
	sed "s/,[0-9]*$/,${BATCH_NUM}/" $DATA_HOME/$CSV_FILE.csv > /tmp/work.csv
	# the final csv file must have the same name as the talbe
	# per the convention used by the sqlldr control file
	$DEBUG_PRINT cp -f /tmp/work.csv $DATA_HOME/$SPO_TABLE.csv
	print "`date` $0 ended"
}

function loadImportTable {
	print "`date` $0 started"
	$DEBUG_PRINT $LIB_HOME/execSqlldr.ksh -s $1
	rc=$?
	case "$rc" in
		0) print "sqlldr executed without errors $0/csvToSpo.ksh" ;;
		1) print  "sqlldr failed $0/csvToSpo.ksh"
		   exit $rc ;;
		2) print "sqlldr had warings $0/csvToSpo.ksh"
		   exit $rc ;;
		3) print "sqlldr encountered a fatal error $0/csvToSpo.ksh"
		   exit $rc ;;
		*) print "sqlldr had an unexpected return code $0/csvToSpo.ksh"
		   exit $rc ;;
   	esac		   
	print "`date` $0 ended"
}

function sendToSpo {
	print "`date` $0 started"
	$DEBUG_PRINT $LIB_HOME/execSqlplus.ksh -s pr_imp
	if (($?!=0)) ; then
		print  "$0 failed for csvToSpo.ksh"
		exit 4
	fi
	print "`date` $0 ended"
}

function checkForImportErrors {
	print "`date` $0 started"
        if [[ -f $SRC_HOME/${1}ImportErrors.sql ]] ; then
                $DEBUG_PRINT $LIB_HOME/execSqlplus.ksh -s ${1}ImportErrors
                if (($?!=0)) ; then
                        print "$0 detected import errors for $1"
			exit 4
                fi
                rm $LOG_HOME/${TimeStamp}*${1}ImportErrors.log
	else
		print "$SRC_HOME/${1}ImportErrors.sql does not exist"
        fi
	print "`date` $0 ended"
}

function getTableNames {
	cnt=0
	for item in ${spoTables[*]}
	do	
		((cnt=cnt+1))
		if [[ "$1" = "$item" ]] ; then
			SPO_TABLE=$item
			IMPORT_TABLE=${spoImportTables[$cnt]}
			break
		fi
	done
}

if (($#==0)) ; then
	tableMenu
	CSV_FILE=$SPO_TABLE 
elif (($#==1)) ; then
	CSV_FILE=$1
	if [[ "$CSV_TO_SPO_MENU" = "Y" ]] ; then
		tableMenu
	else		
		getTableNames $1
		if [[ -z $SPO_TABLE ]] ; then
			IMPORT_TABLE=X_IMP_LP_OVERRIDE
			SPO_TABLE=LpOverride
		fi
	fi
elif (($#==2)) ; then
	CSV_FILE=$1
	getTableNames $2
fi

if [[ -z $IMPORT_TABLE || -z $SPO_TABLE || -z $CSV_FILE ]] ; then
	print  "$USAGE"
	exit 4
fi	
# make sure import table name is all upper case
IMPORT_TABLE=`print $IMPORT_TABLE | tr "[a-z]" "[A-Z]"`

if [[ ! -f $DATA_HOME/$CSV_FILE.csv ]] ; then
	print  "$DATA_HOME/$CSV_FILE.csv does not exist"
	if [[ -z $debug ]] ; then
		exit 4
	fi
fi

if [[ ! -f $SRC_HOME/$SPO_TABLE.sql ]] ; then
	print "$SRC_HOME/$SPO_TABLE.sql does not exist"
	exit 4
fi

print "Using import table $IMPORT_TABLE ..."
print "and csv file $DATA_HOME/$CSV_FILE.csv..."
print "to load spo table $SPO_TABLE"

cleanImportTables $SPO_TABLE
createBatch
if [[ -z $BATCH_NUM && "$debug" = "N" ]] ; then
	print  "batch num not created"
	exit 4
fi
updateCsvFileWithBatch $CSV_FILE
loadImportTable $SPO_TABLE
sendToSpo 
checkForImportErrors $SPO_TABLE

print "$0 ended at `date`"
