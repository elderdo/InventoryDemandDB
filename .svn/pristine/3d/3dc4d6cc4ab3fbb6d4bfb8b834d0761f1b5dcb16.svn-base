#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.5  $
#     $Date:   10 Jul 2009 17:47:44  $
# $Workfile:   locPartLeadtimeDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew	   Initial implementation
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execJavaApp.ksh LocationPartLeadtime 
if (($?!=0)) ; then
	print -u2 "execJavaApp.ksh failed for LocationPartLeadtime"
	print  "execJavaApp.ksh failed for LocationPartLeadtime"
	exit 4
fi
chmod 666 $LOG_HOME/WinDiff.log*
