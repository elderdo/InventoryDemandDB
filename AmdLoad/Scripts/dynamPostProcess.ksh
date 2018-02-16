#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   20 Jun 2008 08:49:34  $
# $Workfile:   dynamPostProcess.ksh  $
# Used as a template to create the dynamic step that follows the
# updating of the SPO data
# $Revision:   1.1  20 Jun 2008 08:49:34  $
# $Revision:   1.2  15 Feb 2018 replaced obsolete -a with -e
#                               replaced obsolete back tics with $(...)

function DynamSqlPostProcess
{
	if [[ -e  $DATA_HOME/dynamPostProcess.sql ]]
	then
		fSize=$(wc -l < $DATA_HOME/dynamPostProcess.sql)
		if (( fSize > 0 ))
		then
			LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_amd_dynamPostProcess.log"
			if [[ -e $DATA_HOME/DYNAM_DB_CONNECTION_STRING ]]
			then
				. $DATA_HOME/DYNAM_DB_CONNECTION_STRING
			fi
			DB_CONNECTION_STRING=${DYNAM_DB_CONNECTION_STRING:-$DB_CONNECTION_STRING}
			sqlplus $DB_CONNECTION_STRING @$DATA_HOME/dynamPostProcess.sql >$LOG_NAME 2>&1
			$LIB_HOME/checkforerrors.ksh $LOG_NAME
			RetCd=$?
			if [ "$RetCd" != "0" ]; then
				exit
			fi;
		fi
	fi
}

