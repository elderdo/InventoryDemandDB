#!/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   12 Aug 2016
# $Workfile:   loadAmdBenchStock.ksh
#

. /apps/CRON/AMD/lib/amdconfig.ksh

for f in $DATA_HOME/benchstock/*.csv
do
  dos2unix $f
  $LIB_HOME/execSqlldr.ksh -f $f $SRC_HOME/amd_benchstock2.ctl
  if [ "$?" = "0" ] ; then
    mv $f archive/$(basename $f)
    echo "loaded amd_benchstock with $f"
  else
    echo "Error: unable to load amd_benchstock with $f"
    exit 4
  fi
done
