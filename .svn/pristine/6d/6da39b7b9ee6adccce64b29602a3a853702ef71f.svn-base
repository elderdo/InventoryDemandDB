#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.13  $
#     $Date:   15 Oct 2009 11:14 $
# $Workfile:   amd_LoadRmads.ksh  $
#
# SCCSID: amd_LoadRmads.ksh  1.4  Modified: 12/05/01 11:16:49
#                                                                             
# Date      By               History
# --------  ---------------  --------------------------------------
# 11/21/01  Fernando F.      Initial implementation.
# 11/26/01  Fernando F.      Moved TimeStamp to front of file.
# 11/29/01  Fernando F.      Fixed control filename.
# 12/05/01  Fernando F.      Fixed logfile name.
# 10/08/09  Elder D.         Fixed logfile name used by sqlldr.
# 10/15/09  Elder D.         moved processed file and the log
#			     for bad data to an RMADS data directory
#

USAGE="usage: ${0##*/} [-d] \n\n\twhere\n\t-d will turn on debug"


export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $SRC_HOME || -z $DATA_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

if (($#==1)) ; then
	TimeStamp=$1
else
	if [[ -z $TimeStamp ]] ; then
		export TimeStamp=$(date +%Y%m%d%H_%M_%S)
	fi
fi

while getopts d arguments
do
	case $arguments in
	  d) debug=Y
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

function makeDir {
	mkdir $1
	if (($?==0)) ; then
		chmod 764 $1
		chgrp amd $1
	fi
}


function fileProcessed {
	PROCESSED_DIR=$RMADS_DATA/Processed
	if [[ ! -d $PROCESSED_DIR ]] ; then
		makeDir $PROCESSED_DIR
	fi
	THE_FILE=`basename $1`
	TIME_STAMP=`date $DateStr | sed "s/:/_/g"`
	print "Moving file $1 to $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}"
	mv $1 $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}
	chmod 440 $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}
	find $PROCESSED_DIR -name "*${THE_FILE}" -type f -mtime +90 -exec echo "removing file " {} \;
	find $PROCESSED_DIR -name "*${THE_FILE}" -type f -mtime +90 -exec rm -f {} \;


}

function saveBadData {
	BAD_DATA_DIR=$RMADS_DATA/BadData
	if [[ ! -d $BAD_DATA_DIR ]] ; then
		makeDir $BAD_DATA_DIR
	fi
	THE_FILE_BASENAME=`basename $1`
	THE_FILE=${THE_FILE_BASENAME%\.*} # remove file extension
	TIME_STAMP=`date $DateStr | sed "s/:/_/g"`
	print "Moving file $LOG_HOME/*${THE_FILE}*.bad to $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.bad"
	mv $LOG_HOME/*${THE_FILE}*.bad $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.bad
	print "Moving file $LOG_HOME/*${THE_FILE}*.log to $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.log"
	mv $LOG_HOME/*${THE_FILE}*.log $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.log
	chmod 440 $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.*
	# get rid of any file older than 90 days
	find $BAD_DATA_DIR -name "*.bad" -type f -mtime +90 -exec echo "removing file " {} \;
	find $BAD_DATA_DIR -name "*.bad" -type f -mtime +90 -exec rm -f {} \;
	find $BAD_DATA_DIR -name "*.log" -type f -mtime +90 -exec echo "removing file " {} \;
	find $BAD_DATA_DIR -name "*.log" -type f -mtime +90 -exec rm -f {} \;
}

function sendWarningMsg {

	SQLLDR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${THE_INFILE}.log

	if [[ -a $DATA_HOME/warnings.txt ]] ; then
		hostname=`uname -n`
		MSG="Load of $TARGET_TABLE data for $AMDENV on $hostname"
		REJECTED=$(grep -i "Total logical records rejected:" $SQLLDR_LOG)
		$LIB_HOME/execSqlplus.ksh \
			-e $LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}warning.log \
			sendWarningMsg \
			"$MSG had $REJECTED rejected records. Review the data at $RMADS_DATA/BadData"
	fi

}

function execSqlldr {
	$LIB_HOME/execSqlldr.ksh ${debug:+-d} amd_rmads_source_tmp
	RC=$?
	case $RC in
		0) print "`date`: loaded $TARGET_TABLE successfully with $SQLLDR_INFILE"
		   fileProcessed $SQLLDR_INFILE ;;
		1) print "`date`: sqlldr failed while loading $TARGET_TABLE with $SQLLDR_INFILE"
		   exit $RC ;;
	  	2) print "`date`: all or some records rejected while loading $TARGET_TABLE with $SQLLDR_INFILE"
		   sendWarningMsg 
		   fileProcessed $SQLLDR_INFILE
		   saveBadData $SQLLDR_INFILE ;;
		3) print "`date`: sqlldr had a fatal error trying to load $TARGET_TABLE with $SQLLDR_INFILE"
		   exit $RC ;;
	esac
}


TARGET_TABLE=amd_rmads_source_tmp
# determine the sqlldr infile from the ctl
SQLLDR_INFILE=`$LIB_HOME/getInfile.ksh $SRC_HOME/amd_rmads_source_tmp.ctl`

if [[ -f $SQLLDR_INFILE ]] ; then
	THE_INFILE=`basename $SQLLDR_INFILE`
	# remove the file extension
	THE_INFILE=${THE_INFILE%\.*}
	# get rid of any old log or bad file for this data
	print "Removing files $LOG_HOME/*${THE_INFILE}*"
	rm -f $LOG_HOME/*${THE_INFILE}*	
	RMADS_DATA=$DATA_HOME/RMADS
	if [[ ! -d $RMADS_DATA ]] ; then
		makeDir $RMADS_DATA
	fi
	execSqlldr
else
	print "There is no RMADS data file named $SQLLDR_INFILE for $TARGET_TABLE"
fi



