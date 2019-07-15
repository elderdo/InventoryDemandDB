#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.6
#     $Date:   13 Jun 2016
#
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew	   Initial implementation
# 07/10/09  D. Elder   Revision:   1.5
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execSqlplus.ksh locationPartLeadtimeDiff 
if (($?!=0)) ; then
	print -u2 "execSqlplus.ksh failed for locationPartLeadtimeDiff"
	print  "execSqlplus.ksh failed for locationPartLeadtimeDiff"
	exit 4
fi
