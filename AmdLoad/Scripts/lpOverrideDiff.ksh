#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   09 Jan 2008 00:08:06  $
# $Workfile:   lpOverrideDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew	   Initial implementation
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

export JRE=/opt/java1.3/jre
export CLASSPATH=$JRE/lib:$LIB_HOME/WindowAlgo.jar:$LIB_HOME/ojdbc14.jar:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME:.

cd $BIN_HOME
$JRE/bin/java LpOverride $LIB_HOME/WindowAlgo.ini
chmod 666 $LOG_HOME/WinDiff.log*
