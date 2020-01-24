#!/bin/ksh
# loadRblTables.ksh
# Author: Douglas S. Elder
# Date: 08/27/2019
# Desc: get data from PGOLDLB
# for cat1 and milss, then load
# the data to AMD RBL 

execSqlplus () {
  if (($#!=3)) ; then
    2>&1 echo "execSqlplus requires 3 arguments"
  fi
  typeset CONNECTION_STRING=$1
  typeset LOG=$2
  typeset SQL=$3
  typeset RC=0
  typeset CNT=0

  echo "execSqlplus started at $(date)"

  $ECHO $LIB/execSqlplus.ksh $OPT -c $CONNECTION_STRING \
                                  -l $LOG $SQL
  RC=$?
  if [ $RC -ne 0 ] ; then
    2>&1 echo "Failed to run $SQL - RC=$RC"
  fi

  echo "execSqlplus ended at $(date)"

  return $RC

}

menu() {
  echo "  1. load RBL_XCB_ITEM_DATA" 
  echo "  2. load RBL_XE4_ADJUSTED_STOCK_LEVEL" 
  echo "  3. load MILS_XE4" 
}

LIB_HOME=/apps/CRON/AMD/lib
LIB=$LIB_HOME
. $LIB_HOME/DB_CONNECTION_STRING

main() {
  typeset RC=0
  echo "main: started at $(date)"

  if [ $STEP -eq 1 ] ; then
    $ECHO execSqlplus $DB_CONNECTION_STRING $LOG load_amd_rbl_xcb
    RC=$?
  fi
  if [ $RC -eq 0 ] ; then
    ((STEP++))
  fi
  if  [ $STEP -eq 2 ] && [ $RC -eq 0 ] ; then
    $ECHO execSqlplus $DB_CONNECTION_STRING $LOG load_amd_rbl_xe4
    RC=$?
  fi
  if [ $RC -eq 0 ] ; then
    ((STEP++))
  fi
  if [ $STEP -eq 3 ] && [ $RC -eq 0 ] ; then
    $ECHO execSqlplus $DB_CONNECTION_STRING $LOG load_amd_mils_xe4
  fi
  echo "main: ended at $(date)"
  return $RC
}

LIB=${LIB_HOME:-/apps/CRON/AMD/lib}
if [ -e  $LIB/amdenv.ksh ] ; then
  . /apps/CRON/AMD/lib/amdenv.ksh
else
  2>&1 echo "Cannot find $LIB/amdenv.ksh"
  exit 4
fi
if [ -e $LIB/amdconfig.ksh ] ; then
  . /apps/CRON/AMD/lib/amdconfig.ksh
else
  2>&1 echo "Cannot find $LIB/amdconfig.ksh"
  exit 4
fi

STEP=1
DEBUG=N
ECHO=

usage() {
  echo ""
  echo "loadRblTables.ksh [ -d -e -h -m -s n  ]"
  echo "where -d turns on debug"
  echo "      -e echos the step instead of executing it"
  echo "         good for debugging" 
  echo "      -h shows this message"
  echo "      -m shows the menu of steps"
  echo "      -s n start execution with step n"
  echo "         where n is 1 to 2"
  echo ""
}

OPT=
while getopts dehms: arguments
do
  case $arguments in
    d) DEBUG=Y
       OPT=-d
       set -x;;
    e) ECHO="echo ";;
    h) usage
       exit 0;;
    m) menu
       exit 0;;
    s) STEP=$OPTARG;;
    u) SUBSTEP=$OPTARG;;
    *) usage
       exit 4;;
  esac
done
shift $((OPTIND-1))

# check for range
case $STEP in
      1|2) OK=Y;;
        *) usage
           exit 4;;
esac

SRC=${SRC_HOME:-/apps/CRON/AMD/src}
LOG=${LOG_HOME:-/apps/CRON/AMD/log}/$(date +%Y%m%d_%H%M%S)_loadRblTables.log
main 2>&1 >> $LOG
RC=$?
case $RC in
  0) STATUS="was SUCCESSFUL";;
  *) STATUS="FAILED";;
esac
SUBJECT="loadRblTables $STATUS"
$LIB/notify.ksh -s "$SUBJECT" \
      -m "$SUBJECT" $LOG
exit $RC
