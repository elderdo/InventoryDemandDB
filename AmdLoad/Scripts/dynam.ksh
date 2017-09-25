#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   20 Jun 2008 08:55:06  $
# $Workfile:   dynam.ksh  $
# Use this as a template to construct the DynamSql step


function DynamSql
{
	if [[ -a  $DATA_HOME/dynam.sql ]]
	then
		fSize=`wc -l < $DATA_HOME/dynam.sql`
		if (( ${fSize:-0} > 0 ))
		then
			LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_amd_dynam.log"
			if [[ -a $DATA_HOME/DYNAM_DB_CONNECTION_STRING ]]
			then
				. $DATA_HOME/DYNAM_DB_CONNECTION_STRING
			fi
			DB_CONNECTION_STRING=${DYNAM_DB_CONNECTION_STRING:-$DB_CONNECTION_STRING}
			cd $DATA_HOME
			sqlplus $DB_CONNECTION_STRING @$DATA_HOME/dynam.sql > $LOG_NAME 2>&1
			$LIB_HOME/checkforerrors.ksh $LOG_NAME
			RetCd=$?
			if [ "$RetCd" != "0" ]; then
				exit
			fi;
			# restore current working directory
			cd $BIN_HOME
			# everything is ok make sure this does not automatically
			# get run again
			mv $DATA_HOME/dynam.sql $DATA_HOME/moreRecentDynam.sql
		fi
	fi
}

