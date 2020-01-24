#!/bin/ksh
# loadAmdBenchStock.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   11 Jul 2019
#
#  Rev     Date     By    Desc
#  1.0     07/11/19 DSE   load Warner Robins Demands
#

if (($#>0)) && [[ "$1" == "-d" ]] ; then
  set -x
  DEBUGOPT=-x
else
  DEBUGOPT=
fi
. /apps/CRON/AMD/lib/amdconfig.ksh
$LIB_HOME/loadFlatFile.ksh $DEBUGOPT \
  -c amdWarneRobinsDemands \
  -d Warner_Robins_Demands
exit $?
