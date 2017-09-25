#!/bin/ksh
# vim:ts=2:sw=2:autoindent=2:sts=2:expandtab:smartindent:
# loadFdw.ksh
# Author: Douglas S. Elder
# Date: 07/08/2017
# Desc: load FDW data into AMD's amd_repair_cost_detail

. /apps/CRON/AMD/lib/amdenv.ksh
. /apps/CRON/AMD/lib/amdconfig.ksh
TimeStamp=$(date +%Y%m%d%H_%M_%S)
LOG=$LOG_HOME/${TimeStamp}_FDW.log

function main {
  CURDIR=$(pwd)
  cnt=0
  cd $DATA_HOME/FDW
  if [[ -e *csv ]] ; then
    for f in *.csv
    do
      chmod 770 $f
      dos2unix $f
      $LIB_HOME/execSqlldr.ksh -l $LOG -f $DATA_HOME/FDW/$f amdrepaircostdetail
      if (($?==0)) ; then
        mv $DATA_HOME/FDW/$f $DATA_HOME/FDW/processed/$f
        ((cnt=cnt+1))
      fi
    done
    echo Processed $cnt files for FDW
  fi
  cd $CURDIR
  return $cnt
}

main > $LOG
if (($?==0)) ; then
  rm $LOG
else
  mv $LOG $DATA_HOME/FDW/processed/${TimeStamp}_FDS.log
fi
