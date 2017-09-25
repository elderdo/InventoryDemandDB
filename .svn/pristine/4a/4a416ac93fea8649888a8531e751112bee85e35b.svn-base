#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   12 Nov 2009 $
# $Workfile:   loadTmpDmndFrcstConsumables.ksh  $
#
#------------------------------------------------------------------------------
# This script will process all files in the ftp folder for demand consumables
# transferring it to tmp_dmnd_frcst_consumables
#
#
USAGE="usage: ${0##*/} [-n] \n\n\twhere\n\t-n will skip the truncation of tmp_amd_dmnd_frcst_consumables\n\t-d will turn on debug"

if [[ $# > 0 && $1 = "?" ]]
then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $SRC_HOME || -z $DATA_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts nd arguments
do
	case $arguments in
	  d) debug=Y
	     set -x ;;
	  n) truncate=N
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


FTPDir=$DATA_HOME/externalforecast
MesgFile=$LOG_HOME/loadTmpDmndMsg.txt
#MesgRecpt1=laurie.compton@west.boeing.com
MesgRecpt1=
MesgRecpt2=douglas.s.elder@west.boeing.com
#MesgRecpt3=phuong-thuy.pham@boeing.com
MesgRecpt3=

theTime=`date $DateStr`;
TimeStamp=${TimeStamp:-$theTime}

function main {
	if [[ ${truncate:-Y} = Y ]]
	then
		truncateTmpAmdDmndFrcstConsumables
	fi

	ProcessList
	if ((FilesProcessed>0)) ; then

		GenStats

		genDuplicateForConsumables
	else
		print "No new files were loaded into tmp_amd_dmnd_frcst_consumables"
	fi
}

function truncateTmpAmdDmndFrcstConsumables {
	$LIB_HOME/execSqlplus.ksh ${debug:+-d}  $0
	if (($?!=0)) ; then
		exit 4
	fi;

}

function genDuplicateForConsumables {
	$LIB_HOME/execSqlplus.ksh $0
	if (($?!=0)) ; then
		exit 4
	fi;
}

function makeDir {
	mkdir $1
	if (($?==0)) ; then
		chmod 764 $1
		chgrp amd $1
	fi
}


function fileProcessed {
	PROCESSED_DIR=$FTPDir/Processed
	if [[ ! -d $PROCESSED_DIR ]] ; then
		makeDir $PROCESSED_DIR
	fi
	THE_FILE=`basename $1`
	TIME_STAMP=`date $DateStr | sed "s/:/_/g"`
	print "Moving file $1 to $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}"
	mv $1 $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}
	chmod 440 $PROCESSED_DIR/${TIME_STAMP}_${THE_FILE}
	find $PROCESSED_DIR -name "*.txt" -type f -mtime +90 -exec echo "removing file " {} \;
	find $PROCESSED_DIR -name "*.txt" -type f -mtime +90 -exec rm -f {} \;


}

function saveBadData {
	BAD_DATA_DIR=$FTPDir/BadData
	if [[ ! -d $BAD_DATA_DIR ]] ; then
		makeDir $BAD_DATA_DIR
	fi
	THE_FILE_BASENAME=`basename $1`
	THE_FILE=${THE_FILE_BASENAME%\.*} # remove file extension
	TIME_STAMP=`date $DateStr | sed "s/:/_/g"`
	print "Moving file $LOG_HOME/*${THE_FILE}*.bad to $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.bad"
	mv $LOG_HOME/*${THE_FILE}*.bad $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.bad
	chmod 440 $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.bad
	print "Moving file $LOG_HOME/*${THE_FILE}*.log to $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.log"
	mv $LOG_HOME/*${THE_FILE}*.log $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.log
	chmod 440 $BAD_DATA_DIR/${TIME_STAMP}_${THE_FILE}.log
	# get rid of any file older than 90 days
	find $BAD_DATA_DIR -name "*.bad" -type f -mtime +90 -exec echo "removing file " {} \;
	find $BAD_DATA_DIR -name "*.bad" -type f -mtime +90 -exec rm -f {} \;
	find $BAD_DATA_DIR -name "*.log" -type f -mtime +90 -exec echo "removing file " {} \;
	find $BAD_DATA_DIR -name "*.log" -type f -mtime +90 -exec rm -f {} \;
}

function sendWarningMsg {

	if (($#==0)) ; then
		print "loadTmpDmndFrcstConsumables.ksh sendWarningMsg: missing required param"
		exit 4
	fi

	THE_FILE_BASENAME=`basename $1`
	THE_FILE=${THE_FILE_BASENAME%\.*} # remove file extension

	SQLLDR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${THE_FILE}.log

	if [[ -a $DATA_HOME/warnings.txt ]] ; then
		hostname=`uname -n`
		MSG="Load of $TARGET_TABLE data for $AMDENV on $hostname"
		print "Scanning log file $SQLLDR_LOG for reject count"
		REJECTED=$(grep -i "Total logical records rejected:" $SQLLDR_LOG)
		$LIB_HOME/execSqlplus.ksh \
			-e $LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}warning.log \
			sendWarningMsg \
			"$MSG had $REJECTED rejected records. Review the data at $FtpDir/BadData"
	fi

}

#
# Process file retreived in above list.
#
function ProcessList {
	TARGET_TABLE="tmp_amd_dmnd_frcst_consumables"
	# process most recent files first
	FilesProcessed=0
	for InFile in `ls -t $FTPDir/*.*`
	do
		DmndFile=${InFile%\.*} # remove file extension
	
		if [[ -f $InFile ]]
		then
			print "`date`: removing previous log/bad files for $InFile"
			THE_FILE=`basename $InFile`
			THE_FILE=${THE_FILE%\.*} # remove file extension
			rm -f $LOG_HOME/*${THE_FILE}*
			print "`date`: Loading file $InFile to $TARGET_TABLE"
			((FilesProcessed=$FilesProcessed+1))
			$LIB_HOME/execSqlldr.ksh -f $InFile $TARGET_TABLE
			RC=$?
			case $RC in
				0) print "`date`: loaded $TARGET_TABLE successfully with $InFile"
				   fileProcessed $InFile ;;
				1) print "`date`: sqlldr failed while loading $TARGET_TABLE with $InFile"
				   exit $RC ;;
			  	2) print "`date`: all or some records rejected while loading $TARGET_TABLE with $InFile"
				   sendWarningMsg $InFile
				   fileProcessed $InFile
				   saveBadData $InFile ;;
				3) print "`date`: sqlldr had a fatal error trying to load $TARGET_TABLE with $InFile"
				   exit $RC ;;
			esac
		elif [[ -d $InFile ]]
		then
			DmndFile=	# directory - do nothing
		else
			print "ERROR: Unable to load $DmndFile to tmp_dmnd_frcst_consumables."
		fi;

	done
}


#
# Collect stats then email notification.
#
function GenStats {
	rm -f $MesgFile

	for InFile in `ls -t $FTPDir/*.*`
	do
		WK_LOG_FILE=`basename $InFile`
		WK_LOG_FILE=`print $WK_LOG_FILE | sed "s/\./_/g"`
		WK_LOG_FILE=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${WK_LOG_FILE}.log
		(if [[ -f $WK_LOG_FILE ]] ; then
			awk -v FileName=$InFile \
				'BEGIN{DupRec=0}
				/ORA-00001:/{
						DupRec=DupRec+1;
					}
				/Rows successfully loaded./{
						GoodRec=$1
					}
				/not loaded due to data errors./{
						ErrorRec=$1
					}
				/WHEN clauses were failed/{
						Discard=$1
					}
				/Total logical records read:/{
						TotalRec=$5
					}
				END {
					printf("Processed %s: %d loaded, %d error(s), %d duplicate(s).  ",FileName,GoodRec,ErrorRec-DupRec,DupRec)
					if (Discard==TotalRec)
					{
						printf("File is empty.")
					}
					printf("\n")
				}' $WK_LOG_FILE
		fi; ) >> $MesgFile

	done

	if [ -s $MesgFile ]
	then
	#	mailx -s "DmndFrcstConsumables Load Notification" -r loadTmpDmndFrcstConsumables $MesgRecpt1 $MesgRecpt2 $MesgRecpt3 <$MesgFile
		cat $MesgFile
	fi
}


main $*
return 0
