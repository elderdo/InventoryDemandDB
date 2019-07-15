#!/usr/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix:
#   $Author$ zf297a
# $Revision$ 1.1
#     $Date$ 15 Feb 2018
#
# $Revision$ 1.0 05 Feb 2010 10:32 Initial Rev
# $Revision$ 1.1 15 Feb 2018 DSE removed obsolete back tic's and replaced withy $(..)
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
NUM_ROWS=$($LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_dmnd_frcst_consumables ;")
if ((NUM_ROWS>0)) ; then
	$LIB_HOME/execSqlplus.ksh loadAmdDmndFrcstConsumables 
	RC=$?
	return $RC
else
	print "tmp_amd_dmnd_frcst_consumables is empty  ... load skipped"
fi
return 0
