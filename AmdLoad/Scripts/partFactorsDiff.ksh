#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.7
#     $Date:   13 Jun 2016
#
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew	   Initial implementation
# 10/02/13  Douglas Elder  1.5 ignore import errors until Spo 8 conversion
# 10/29/13  Douglas Elder  1.6 removed all spo functions
# 06/13/16  Douglas Elder  1.7 use ...Diff.sql
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execJavaApp.ksh PartFactors
$LIB_HOME/execSqlplus.ksh partFactorsDiff
if (($?!=0)) ; then
	print "partFactorsDiff failed for partFactorsDiff.ksh"
	exit 4
fi
