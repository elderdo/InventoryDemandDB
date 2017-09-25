#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.4  $
#     $Date:   08 Jan 2008 14:34:22  $
# $Workfile:   WindowAlgo.ksh  $
#
#SCCSID: WindowAlgo.ksh  1.8  Modified: 09/17/02 09:18:51
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 11/20/01  Fernando F.    Initial implementation
# 01/09/02  Fernando F.    Changed java1.2 to java1.3.
# 07/30/02  Fernando F.    Added paths to jar's and zip's.
# 08/05/02  Fernando F.    Added logger classes to CLASSPATH.
# 08/26/02  Fernando F.    Added start end end times to script output.
# 08/26/02  Fernando F.    Removed timestamps and added chmod.
# 09/17/02  Fernando F.    Added WindowAlgo.ini as parameter and 'cd'.
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

export JRE=/opt/java1.4/jre
export CLASSPATH=$JRE/lib:$LIB_HOME/WindowAlgo.jar:$LIB_HOME/ojdbc14.jar:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME:.

cd $BIN_HOME
$JRE/bin/java SparePart $LIB_HOME/WindowAlgo.ini
chmod 666 $LOG_HOME/WinDiff.log*
