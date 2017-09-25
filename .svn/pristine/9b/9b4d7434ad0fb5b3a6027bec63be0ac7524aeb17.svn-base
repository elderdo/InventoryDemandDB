#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.10  $
#     $Date:   28 Jan 2009 07:53:26  $
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
#

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

DATAFILE=$DATA_HOME/mtbrpn.dat

$LIB_HOME/execSqlldr.ksh amd_rmads_source_tmp
RC=$?
if (($RC!=0)) ; then
	if (($RC==2)) ; then
		SQLLDR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}amd_rmads_source_tmp.log
		grep -c "ORA-00001: unique constraint (AMD_OWNER.AMD_RMADS_SOURCE_TMP_PK) violated" $SQLLDR_LOG
		if (($?==0)) ; then
			if [[ -a $DATA_HOME/warnings.txt ]] ; then
				hostname=`uname -n`
				MSG="AMD Load of RMADS data on $hostname"
				REJECTED=$(grep -i "Total logical records rejected:" $SQLLDR_LOG)
				$LIB_HOME/execSqlplus.ksh sendWarningMsg \
					"$MSG for step $0${AMD_CUR_STEP:+ / AMD_STEP=$AMD_CUR_STEP} had duplicate records: $REJECTED" 
			fi
		else
			exit 4
		fi
	else
		exit 4
	fi
fi

