#!/usr/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix:
# dynam.ksh  $
#   $Author:   Douglas S. Elder
# $Revision:   1.2
#     $Date:   20 Jun 2008 08:55:06  $
# Use this as a template to construct the DynamSql step
# $Revision:   1.1  20 Jun 2008 08:55:06  $
# $Revision:   1.2  20 Jun 2008 replaced obsolete -a with -e


function DynamSql
{
	if [[ -e  $DATA_HOME/dynam.sql ]]
	then
		fSize=$(wc -l < $DATA_HOME/dynam.sql)
		if (( fSize > 0 ))
		then
			LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_amd_dynam.log"
			if [[ -e $DATA_HOME/DYNAM_DB_CONNECTION_STRING ]]
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

