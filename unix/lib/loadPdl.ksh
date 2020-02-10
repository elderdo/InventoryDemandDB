#!/bin/ksh
# loadPdl.ksh
# Author: Douglas S. Elder
# Date: 08/11/2019
# Desc: get data from PGOLDLB
# for cat1 and milss, then load
# the data to PDL 
# Rev 1.0 08/11/2019
# Rev 1.0 08/11/2019 Initial Rev
# Rev 1.1 10/03/2019 added deleteData
# Rev 1.2 10/04/2019 add line numbers when display files
# Rev 1.3 02/04/2020 added switch -n m|c|b -p
# Rev 1.4 02/06/2020 consolidated steps by running independent
#                    tasks simultaneously in the background
# Rev 1.5 02/10/2020 add runrbl step and got rid of old commented
#                    out code.

# set Globals var's
HOME=/apps/CRON/AMD
LIB=$HOME/lib
SRC=$HOME/src
BIN=$HOME/bin
PATH=$LIB:$BIN:$PATH
DATA=$HOME/data
ECHO=
DEBUG=N
SKIP=
PREPROD=N
STEP=1
SUBSTEP=1
AMDENV=$LIB/amdenv.ksh
AMDCONFIG=$LIB/amdconfig.ksh

usage() {
  echo ""
  echo "loadPdl.ksh [ -d -e -h -m -n getopt -p -s n ]"
  echo "where -d turns on debug"
  echo "      -e echos the step instead of executing it"
  echo "         good for debugging" 
  echo "      -h shows this message"
  echo "      -m shows the menu of steps"
  echo "      -n getopt"
  echo "         where getopt of m skips getting Mils data"
  echo "         where getopt of c skips getting Cat1 data"
  echo "         where getopt of b skips getting both Mils and Cat1 data"
  echo "      -p will load data to prepdlr"
  echo "      -s n start execution with step n"
  echo "         where n is 1 to 7"
  echo "         if n is a range like 2-3"
  echo "         then only step 2 and 3 are executed"
  echo "         if n is a range like 2-2"
  echo "         then only step 2 is executed"
  echo ""
}

# hopefully the background tasks running at the same time
# will speed up the entire process
menu() {
  echo " all of step 1's substeps are done at the same time"
  echo " in the background"
  echo " 1. get MILS data from PGOLD"
  echo "    get CAT1 data from PGOLD"
  echo "    delete CAT1 data from DPDLR"
  echo "    delete MILS data from DPDLR"
  echo "    delete CAT1 from PREPDLR"
  echo "    delete MILS from PREPDLR"
  echo " all of step 2's substeps are done at the same time"
  echo " in the background"
  echo " 2. load MILS data to pdl.GOLD_MILS_STAGE"
  echo "    load CAT1 data to pdl.GOLD_CAT1_STAGE"
  echo "    load CAT1 for PREPDLR"
  echo "    load MILS for PREPDLR"
}

sourceScript() {
  typeset SCRIPT=$1
  if [ -e $SCRIPT ] ; then
    . $SCRIPT
  fi
}

sourceScript $AMDENV
sourceScript $AMDCONFIG

while getopts dehmn:s: arguments
do
  case $arguments in
    d) DEBUG=Y
       set -x;;
    e) ECHO="echo ";;
    h) usage
       exit 0;;
    m) menu
       exit 0;;
    p) PREPROD=Y;;
    n) SKIP=$OPTARG;;
    s) STEP=$OPTARG;;
    *) usage
       exit 4;;
  esac
done
shift $((OPTIND-1))

runSqlplus() {

  if [ "$DEBUG" == "Y" ] ; then
    set -x
    OPT=-d
  else
    OPT=
  fi

  if (($#<3 || $#>4)) ; then
    2>&1 echo "runSqlplus: needs 3 to 4 arguments SQLSCRIPT DATAFILE LOG [ DBCONNSTRING ]"
    2>&1 echo " where DATAFILE can be an empty string """" and DBCONNSTRING is optionals"
    2>&1 echo "       the DBCONNSTRING defaults to AMD's DB connection string"
    return 4
  fi

  typeset SQLSCRIPT=$1
  typeset DATAFILE=$2

  typeset LOG=$3
  typeset RC=0
  if (($#==4)) ; then
    OPT="-c $4"
  fi

  echo "runSqlplus ($SQLSCRIPT $DATAFILE $LOG) started at $(date)"
  if [[ "$DATAFILE" != "" && -f "$DATAFILE" ]] ; then
    $ECHO rm -f $DATAFILE
  fi
  # display the SQL*Plus script on the log
  echo "$SQLSCRIPT:"
  echo ""
  cat -n ${SRC}/${SQLSCRIPT}.sql

  # NOTE: when invoking execSqlplus.ksh with $OPT
  # never quote it or an empty string will be treated
  # as a positional parameter and cause getopts to work
  # incorrectly, since it expects all switches to come first
  # followed by positional arguments!!!
  echo execSqlplus.ksh $OPT -l $LOG $SQLSCRIPT $DATAFILE
  $ECHO execSqlplus.ksh $OPT -l $LOG $SQLSCRIPT $DATAFILE
  RC=$?
  if [ $RC -eq 0 ] ; then
    echo $DATAFILE
    $ECHO wc -l $DATAFILE
  else
    2>&1 echo "execSqlplus.ksh ended with a RC=$RC"

  fi 
  echo "runSqlplus ($SQLSCRIPT $DATAFILE $LOG) ended at $(date)"
  return $RC
}

loadData() {

  if [ "$DEBUG" == "Y" ] ; then
    set -x 
    OPT=-d
  else
    OPT=
  fi

  if (($#!=3)) ; then
    2>&1 echo "loadData needs 3 arguments: $1 $2 $3"
    return 4
  fi
  typeset CONNECTION_STRING=$1
  typeset SQLLOADER=$2
  typeset DATAFILE=$3
  typeset RC=0

  echo "loadData ($SQLLOADER $DATAFILE) started at $(date)"
  cat -n ${SRC}/${SQLLOADER}.ctl
  $ECHO execSqlldr.ksh $OPT  -c $CONNECTION_STRING \
                      -l $LOG -f $DATAFILE $SQLLOADER
  RC=$?
  if ((RC!=0)) ; then
    2>&1 echo "execSqlldr ended with a RC=$RC"
  fi 
  echo "loadData ($SQLLOADER $DATAFILE) ended at $(date)"
  return $RC
}

runrbl() {

  typeset RC=0
  typeset RBLSERVER=spmqa.vmpc1.cloud.boeing.com
  typeset SPMQA_ACCT=spmadmin
  typeset RBLBIN=/home/spmadmin/bin
  typeset RBL=$RBLBIN/runrbl.sh
  typeset XRG="export XARG=bamp4321 "
  typeset CMD="ssh -q ${SPMQA_ACCT}@${RBLSERVER} $XARG $RBL"

  $CMD
  RC=$?
  return $RC

}

main() {
  typeset CAT1DAT=$DATA/cat1.txt
  typeset MILSDAT=$DATA/mils.txt
  typeset RC=0
  echo "main: started at $(date)"


  if [ $STEP -eq 1 ] ; then
    # show the entire script
    [ "$DEBUG" == "Y" ] && cat -n $0 && echo "..." && echo "....."
    if [[ "$SKIP" == "m" || "$SKIP" == "b" ]] ; then
      RC=0
    else
      runSqlplus getMils $MILSDAT $LOG &
      runSqlplus getCat1 $CAT1DAT $LOG &
      . $LIB/pdlenv.ksh
      runSqlplus pdl_mils_delete "" $LOG $PDLCONN &
      runSqlplus pdl_cat1_delete "" $LOG $PDLCONN &
      . $LIB/pdlpre.ksh
      runSqlplus pdl_mils_delete "" $LOG $PDLCONN &
      runSqlplus pdl_cat1_delete "" $LOG $PDLCONN &
      wait
    fi
    RC=$?
    if [ ! -s $MILSDAT ] ; then
      2>&1 echo $MILSDAT is empty
      [ "$ECHO" == "" ] && RC=4
    fi  
    if [ ! -s $CAT1DAT ] ; then
      2>&1 echo $CAT1DAT is empty
      [ "$ECHO" == "" ] && RC=4
    fi  
    
    if [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi


  if  [ $STEP -eq 2 ] && [ $RC -eq 0 ] ; then
    . $LIB/pdlenv.ksh
    loadData $PDLCONN mils $MILSDAT &
    loadData $PDLCONN cat1 $CAT1DAT &
    . $LIB/pdlpre.ksh
    loadData $PDLCONN mils $MILSDAT &
    loadData $PDLCONN cat1 $CAT1DAT &
    wait
    RC=$?
    if [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  echo "main: ended at $(date)"
  return $RC
}





# check for range
case $STEP in
   1|2|3|4|5|7|8|9|10) OK=Y;;
                    *) usage
                       exit 4;;
esac

SRC=${SRC_HOME:-/apps/CRON/AMD/src}
LOG=${LOG_HOME:-/apps/CRON/AMD/log}/$(date +%Y%m%d_%H%M%S)_loadPdl.log
main 2>&1 >> $LOG
RC=$?
case $RC in
  0) STATUS="was SUCCESSFUL";;
  *) STATUS="FAILED";;
esac
SUBJECT="loadPdl $STATUS"
$LIB/notify.ksh -s "$SUBJECT" \
      -m "$SUBJECT" $LOG
exit $RC
