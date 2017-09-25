#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   16 Jan 2014
# $Workfile:   amdconfig.ksh  $
#
# SCCSID: amdconfig.ksh  1.15  Modified: 12/17/01 16:33:23
#
# Date      By            History
# 08/20/00  Fernando F.   Initial implementation
# 05/25/01  A.M.Shinsato  Modified to work from various platforms.
#                         Include /usr/local/bin to search path.
# 07/06/01  Fernando F.   Added AMDENV variable to denote environment
# 07/13/01  Fernando F.   Fixed transposed ORACLE_SID's for hs1077 and hs1051
# 12/17/01  Fernando F.   Changed setting of ORACLE_SID to V817 because load
#                         is running on app server not db server.
# 12/17/01  Fernando F.   Put back DB_CONNECTION_STRING source.
# 09/21/13  Elder D.      Use ORACLE_HOME & ORACLE_SID env varialbes
#                         added ORACLE_HOME to the PATH env variable 
# 01/16/14  Elder D.      rev 1.6 removed DB_CONNECTION_STRING_FOR_SPO
#
# DateStr is used for the AMD load to create the log file names.
# DO NOT PUT THESE TOGETHER due to conflicts with the SCCS check-in proc.
#
DateStr="+%Y"
DateStr="$DateStr%m%d%H:%M:%S"


PATH=$PATH:/usr/local/bin
export PATH

## Set up environment variables for AMD specific directories.
AMD_HOME="$UNVAR/apps/CRON/AMD"
BIN_HOME="$AMD_HOME/bin"; export BIN_HOME
SRC_HOME="$AMD_HOME/src"; export SRC_HOME
export SQLPATH=$SRC_HOME
LIB_HOME="$AMD_HOME/lib"; export LIB_HOME
LOG_HOME="$AMD_HOME/log"; export LOG_HOME
DATA_HOME="$AMD_HOME/data"; export DATA_HOME
ARCH_HOME="$DATA_HOME/archive"; export ARCH_HOME
CSV_HOME="$DATA_HOME"; export CSV_HOME
	        
#EXPORT_MAP_FILE="$AMD_HOME/log/export_map_by_table_`date $DateStr`.txt"
DATE_TIME="`date $DateStr`"

# defines environment, dev, it, prod
. $AMD_HOME/lib/amdenv.ksh

. $LIB_HOME/DB_CONNECTION_STRING

# Set according to environment
export ORACLE_SID=db0093p1
export ORACLE_ASK=NO

export ORAENV_ASK=NO
export ORACLE_HOME=/opt/oracle/app/oracle/product/12.1.0/client_1
export PATH=$ORACLE_HOME/bin:$PATH
