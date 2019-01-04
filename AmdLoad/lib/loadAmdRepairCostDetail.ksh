#!/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   12 Aug 2016
# $Workfile:   loadAmdRepairCostDetail.ksh
#

. /apps/CRON/AMD/lib/amdconfig.ksh


for f in $DATA_HOME/fdw/*.csv
do
  $LIB_HOME/execSqlplus.ksh truncateAmdRepairCostDetail
  if [ "$?" != "0" ] ; then
    echo "Error: unable to truncate amd_repair_cost_detail"
    exit 4
  fi
  dos2unix $f
  $LIB_HOME/execSqlldr.ksh -f $f $SRC_HOME/amdrepaircostdetail.ctl
  if [ "$?" = "0" ] ; then
    mv $f archive/$(basename $f)
    echo "loaded amd_repair_cost_detail with $f"
  else
    echo "Error: unable to load amd_repair_cost_detail with $f"
    exit 4
  fi
done
