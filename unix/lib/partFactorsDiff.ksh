#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.6
#     $Date:   29 Oct 2013
# $Workfile:   partFactorsDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew	   Initial implementation
# 10/02/13  Douglas Elder  ignore import errors until Spo 8 conversion
# 10/29/13  Douglas Elder  removed all spo functions
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execJavaApp.ksh PartFactors
if (($?!=0)) ; then
	print "PartFactors failed for partFactorsDiff.ksh"
	exit 4
fi

chmod 666 $LOG_HOME/WinDiff.log*
