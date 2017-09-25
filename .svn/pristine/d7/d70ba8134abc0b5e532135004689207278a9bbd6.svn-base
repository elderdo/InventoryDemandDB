#!/usr/bin/ksh
#   $Author$ zf297a
# $Revision$ 1.0
#     $Date$ 05 Feb 2010 10:32
#
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
NUM_ROWS=`$LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_dmnd_frcst_consumables ;"`
if ((NUM_ROWS>0)) ; then
	$LIB_HOME/execSqlplus.ksh loadAmdDmndFrcstConsumables 
	RC=$?
	return $RC
else
	print "tmp_amd_dmnd_frcst_consumables is empty  ... load skipped"
fi
return 0
