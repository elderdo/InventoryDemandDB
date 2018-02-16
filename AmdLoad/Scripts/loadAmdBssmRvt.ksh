#!/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   12 Aug 2016
# $Workfile:   loadAmdBssmRvt.ksh
#

. /apps/CRON/AMD/lib/amdconfig.ksh

for f in $DATA_HOME/rvt/*.csv
do
  dos2unix $f
  $LIB_HOME/execSqlldr.ksh -f $f amd_bssm_rvt
  if [ "$?" = "0" ] ; then
    mv $f archive/$(basename $f)
    echo "loaded amd_bssm_rvt with $f"
  else
    echo "Error: unable to load amd_bssm_rvt with $f"
    exit 4
  fi
done
