#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   25 Sep 2008 13:18:32  $
# $Workfile:   testAmdUse1Update.ksh  $
#
#
. ../lib/amdconfig.ksh
$LIB_HOME/execSqlplus.ksh TestAmdUse1Update
if (($?!=0)) ; then
	print "TestAmdUse1Update failed"
else
	vi /tmp/AmdUse1Output.txt
fi

