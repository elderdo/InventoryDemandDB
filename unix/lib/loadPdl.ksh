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

# set Globals var's
HOME=/apps/CRON/AMD
LIB=$HOME/lib
SRC=$HOME/src
BIN=$HOME/bin
PATH=$LIB:$BIN:$PATH
DATA=$HOME/data
. $LIB/pdlenv.ksh
ECHO=
DEBUG=N
STEP=1
SUBSTEP=1
END_STEP=7
AMDENV=$LIB/amdenv.ksh
AMDCONFIG=$LIB/amdconfig.ksh

sourceScript() {
  typeset SCRIPT=$1
  if [ -e $SCRIPT ] ; then
    . $SCRIPT
  fi
}
sourceScript $AMDENV
sourceScript $AMDCONFIG

if [ -e $LIB/pdlenv.ksh ] ; then
  . $LIB/pdlenv.ksh
else
  2>&1 echo "Cannot find $LIB/pdlenv.ksh"
  exit 4
fi

while getopts dehms:u: arguments
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
    u) SUBSTEP=$OPTARG;;
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
  $ECHO rm -f $DATAFILE
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


loadPdlTables() {
  if (($#!=2)) ; then
    2>&1 echo "loadPdlTAbles requires 2 arguments"
    return 4
  fi
  typeset CONNECTION_STRING=$1
  typeset LOG=$2
  typeset RC=0
  typeset CNT=0

  echo "loadPdlTables started at $(date)"


  for sql in load_NSN_TO_PART load_RBL_DRCT load_RBL_PARENT_NSNS \
             load_RBL_XCB_ITEM_DATA load_RBL_XE4_ADJUSTED_STOCK_LEVEL
  do
    ((CNT=CNT+1))
    if [ $SUBSTEP -eq $CNT ] && [ $RC = 0 ] ; then
      echo "$sql:"
      cat -n $SRC/$sql.sql
      $ECHO execSqlplus.ksh $OPT -c $CONNECTION_STRING \
                                  -l $LOG $sql
      RC=$?
      if [ $RC -ne 0 ] ; then
        2>&1 echo "Failed to run $sql - RC=$RC"
        break
      fi
      ((SUBSTEP=SUBSTEP+1))
    fi
  done

  echo "loadPdlTables started at $(date)"

  return $RC

}

menu() {
  echo "1. get MILS data from PGOLD"
  echo "2. delete C17 data from PDL.GOLD_MILS_STAGE"
  echo "3. load MILS data to pdl.GOLD_MILS_STAGE"
  echo "4. get CAT1 data from PGOLD"
  echo "5. delete C17 data from PDL.GOLD_CAT1_STAGE"
  echo "6. load CAT1 data to pdl.GOLD_CAT1_STAGE"
  echo "7. load PDL tables using existing views"
  echo "SubSteps: "
  echo "  1. load NSN_TO_PART" 
  echo "  2. load RBL_DRCT" 
  echo "  3. load RBL_PARENT_NSNS" 
  echo "  4. load RBL_XCB_ITEM_DATA" 
  echo "  5. load RBL_XE4_ADJUSTED_STOCK_LEVEL" 
}

main() {
  typeset CAT1DAT=$DATA/cat1.txt
  typeset MILSDAT=$DATA/mils.txt
  typeset RC=0
  echo "main: started at $(date)"


  if [ $STEP -eq 1 ] ; then
    # show the entire script
    [ "$DEBUG" == "Y" ] && cat -n $0 && echo "..." && echo "....."
    runSqlplus getMils $MILSDAT $LOG
    RC=$?
    if [ ! -s $MILSDAT ] ; then
      2>&1 echo $MILSDAT is empty
      [ "$ECHO" == "" ] && RC=4
    fi  
    
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  if [ $STEP -eq 2 ] && [ $RC -eq 0 ] ; then
    # arg 2 is an empty string since there is no data file when
    # deleting, but optional 4th argument is the 
    # connection string for PDL
    runSqlplus pdl_mils_delete "" $LOG $PDLCONN
    RC=$?
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  if  [ $STEP -eq 3 ] && [ $RC -eq 0 ] ; then
    loadData $PDLCONN mils $MILSDAT
    RC=$?
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  if [ $STEP -eq 4 ] && [ $RC -eq 0 ] ; then
    runSqlplus getCat1 $CAT1DAT $LOG
    RC=$?
    if [ ! -s $CAT1DAT ] ; then
      2>&1 echo $CAT1DAT is empty
      RC=4
    fi
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  if [ $STEP -eq 5 ] && [ $RC -eq 0 ] ; then
    runSqlplus pdl_cat1_delete "" $LOG $PDLCONN
    RC=$?
    if [ ! -s $CAT1DAT ] ; then
      2>&1 echo $CAT1DAT is empty
      RC=4
    fi
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi

  if [ $STEP -eq 6 ] && [ $RC -eq 0 ] ; then
    loadData $PDLCONN cat1 $CAT1DAT
    RC=$?
    if [ $STEP -ne $END_STEP ] && [ $RC -eq 0 ] ; then
      ((STEP=STEP+1))
    fi
  fi
  if [ $STEP -eq 7 ] && [ $RC -eq 0 ] ; then
    loadPdlTables $PDLCONN $LOG
  fi
  echo "main: ended at $(date)"
  return $RC
}



usage() {
  echo ""
  echo "loadPdl.ksh [ -d -e -h -m -s n -u n ]"
  echo "where -d turns on debug"
  echo "      -e echos the step instead of executing it"
  echo "         good for debugging" 
  echo "      -h shows this message"
  echo "      -m shows the menu of steps"
  echo "      -s n start execution with step n"
  echo "         where n is 1 to 7"
  echo "         if n is a range like 2-3"
  echo "         then only step 2 and 3 are executed"
  echo "         if n is a range like 2-2"
  echo "         then only step 2 is executed"
  echo "      -u n start execution at substep n for step 7 loadPdlTables"
  echo ""
}


# check for range
case $STEP in
      1|2|3|4|5) OK=Y;;
  [1-5]-[1-5]) NUM1=$(echo $STEP | cut -d"-" -f1)
               NUM2=$(echo $STEP | cut -d"-" -f2)
               if [ $NUM1 -le $NUM2 ] ; then
                 STEP=$NUM1
                 END_STEP=$NUM2
               else
                 2>&1 echo "Bad range $STEP"
                 usage
                 exit 4
               fi ;;
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
