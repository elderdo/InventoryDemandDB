#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   13 Jun 2013
# $Workfile:   dmndFrcstConsumablesDiff.ksh  $
#
# $Revision:   1.5  14 Oct 2009 
# $Revision:   1.6  13 Jun 2013
# $Revision:   1.7  15 Feb 2018 removed obsolete back tic's
#                               replaced with $(..)
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
NUM_ROWS=$($LIB_HOME/oraCheck.ksh "select count(*) from tmp_amd_dmnd_frcst_consumables ;")
if ((NUM_ROWS>0)) ; then
	$LIB_HOME/execSqlplus.ksh dmndFrcstConsumablesDiff 
	RC=$?
	return $RC
else
	print "tmp_amd_dmnd_frcst_consumables is empty  ... diff skipped"
fi
return 0
