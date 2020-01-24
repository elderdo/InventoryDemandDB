#!/bin/ksh
# getRblInput.ksh
# Author: Douglas S. Elder
# Date: 09/04/2019
# Desc: get the file for the Fortran rbl.exe


getData() {

  if [ "$DEBUG" == "Y" ] ; then
    set -x
    OPT=-d
  else
    OPT=
  fi

  if (($#!=2)) ; then
    2>&1 echo "getData: needs 2 arguments $1 $2 $3"
    return 4
  fi

  typeset SQLSCRIPT=$1
  typeset LOG=$2
  typeset RC=0
  echo "getData ($SQLSCRIPT) started at $(date)"
  $ECHO rm -f $RBLFILE
  # display the SQL*Plus script on the log
  echo "$SQLSCRIPT:"
  echo ""
  $ECHO $LIB/execSqlplus.ksh $OPT -c $PDLCONN \
          -l $LOG $SQLSCRIPT 
  RC=$?
  if [ $RC -eq 0 ] ; then
    echo $RBLFILE
    wc -l $RBLFILE
  else
    2>&1 echo "execSqlplus.ksh ended with a RC=$RC"

  fi 
  echo "getData ($SQLSCRIPT $DATAFILE) ended at $(date)"
  return $RC
}

menu() {
  echo "1. get MILS data from PGOLD"
  echo "2. load MILS data to pdl.GOLD_MILS_STAGE"
  echo "3. get CAT1 data from PGOLD"
  echo "4. load CAT1 data to pdl.GOLD_CAT1_STAGE"
  echo "5. load PDL tables using existing views"
  echo "SubSteps: "
  echo "  1. load NSN_TO_PART" 
  echo "  2. load RBL_DRCT" 
  echo "  3. load RBL_PARENT_NSNS" 
  echo "  4. load RBL_XCB_ITEM_DATA" 
  echo "  5. load RBL_XE4_ADJUSTED_STOCK_LEVEL" 
}
LIB_HOME=/apps/CRON/AMD/lib
LIB=$LIB_HOME
. $LIB_HOME/pdlenv.ksh

main() {
  typeset RC=0
  echo "main: started at $(date)"


  if [ $STEP -eq 1 ] ; then
    RBLFILE=/apps/CRON/AMD/data/INPUT.txt
    $ECHO getData $GETRBLINPUT  $LOG
    RC=$?
    if [ ! -s $RBLFILE ] ; then
      2>&1 echo $RBLFILE is empty
      RC=4
    fi  
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

if [ -e $LIB/pdlenv.ksh ] ; then
  . $LIB/pdlenv.ksh
else
  2>&1 echo "Cannot find $LIB/pdlenv.ksh"
  exit 4
fi

STEP=1
SUBSTEP=1
END_STEP=1
DEBUG=N
GETRBLINPUT=getRblInput
ECHO=

usage() {
  echo ""
  echo "getRblInput.ksh [ -d -e -h -m -s n  ]"
  echo "where -d turns on debug"
  echo "      -e echos the step instead of executing it"
  echo "         good for debugging" 
  echo "      -h shows this message"
  echo "      -m shows the menu of steps"
  echo "      -s n start execution with step n"
  echo "         where n is 1 to 5"
  echo "         if n is a range like 2-3"
  echo "         then only step 2 and 3 are executed"
  echo "         if n is a range like 2-2"
  echo "         then only step 2 is executed"
  echo ""
}

while getopts dehms: arguments
do
  case $arguments in
    d) DEBUG=Y
       set -x;;
    e) ECHO="echo ";;
    h) usage
       exit 0;;
    m) menu
       exit 0;;
    s) STEP=$OPTARG;;
    *) usage
       exit 4;;
  esac
done
shift $((OPTIND-1))

# check for range
case $STEP in
      1) OK=Y;;
  *) usage
     exit 4;;
esac

SRC=${SRC_HOME:-/apps/CRON/AMD/src}
LOG=${LOG_HOME:-/apps/CRON/AMD/log}/$(date +%Y%m%d_%H%M%S)_getRblInput.log
main 2>&1 >> $LOG
RC=$?
case $RC in
  0) STATUS="was SUCCESSFUL";;
  *) STATUS="FAILED";;
esac
SUBJECT="getRblInput $STATUS"
$LIB/notify.ksh -s "$SUBJECT" \
      -m "$SUBJECT" $LOG
exit $RC
