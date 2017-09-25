#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   13 Jun 2013
# $Workfile:   dmndFrcstConsumablesDiff.ksh  $
#
# $Revision:   1.5  14 Oct 2009 
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
NUM_ROWS=`$LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_dmnd_frcst_consumables ;"`
if ((NUM_ROWS>0)) ; then
	$LIB_HOME/execJavaApp.ksh DmndFrcstConsumables
	$LIB_HOME/execSqlplus.ksh dmndFrcstConsumablesDiff 
	RC=$?
	return $RC
else
	print "tmp_amd_dmnd_frcst_consumables is empty  ... diff skipped"
fi
return 0
