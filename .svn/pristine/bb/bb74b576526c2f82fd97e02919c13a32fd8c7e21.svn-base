#!/bin/ksh
# vim: ts=2:sw=2:sts=2:expandtab:ff=unix:
#   $Author:   Douglas S. Elder
# $Revision:   1.18  $
#     $Date:   21 Feb 2017
# $Workfile:   replicateGold.ksh  $

# Rev 1.18 21 Feb 2017 DSE - added loadReq1SA
# Rev 1.17 05 Dec 2016 DSE - added loadTurn
# Rev 1.16 25 Apr 2016 DSE - 2nd arg not needed for loadWhse
# Rev 1.15 23 Apr 2016 DSE - added analyzeTablesIndexes so all indexes are optimized 
#                            for subsequent processing
#                            each env may have unique analyzeTablesIndexes.sql)
# Rev 1.14 17 Nov 2015 DSE - added notify.ksh and sendPage.ksh when errors occur
# Rev 1.13 31 Oct 2014 DSE - added wait and updateRamp steps
#
# Rev 1.12 added 2nd db link for loadWhse and use amd_goldsa_link for loadItemsa 
#          and added 3rd arg to execSqlplus function

USAGE="usage: ${0##*/} [-v] [-m] [-p | -s ] [-o override_file] [steps to execute] 
\nwhere
\t-m use interactive menu
\t-v verbose - report pid's
\t-o override_file - default is replicateGoldSteps.ksh
\t-p use pgoldlb - default
\t-s use sgoldlb"

if [[ "$1" = "?" ]] ; then
  print "$USAGE"
  exit 0
fi

CUR_USER=`logname`
if [[ -z $CUR_USER ]] ; then
  CUR_USER=amduser
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
  print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi


while getopts :psmvo: arguments
do
  case $arguments in
    o) STEPS_FILE=${OPTARG}
       if [[ ! -f $STEPS_FILE ]] ; then
         print -u2 "Error: $STEPS_FILE does not exist"
         exit 4
       fi ;;
    p) THE_DB_LINK=amd_pgoldlb_link;;
    s) THE_DB_LINK=amd_sgoldlb_link;;
    v) AMD_REPLICATE_GOLD_VERBOSE=Y;;
    m) AMD_REPLICATE_GOLD_MENU=Y;;
    *) print -u2 "$USAGE"
       exit 4;;
  esac
done
# OPTIND now contains a numnber representing the identity of the first
# nonswitch argument on the command line.  For example, if the first
# nonswitch argume on the command line is positional parameter $<F5>,
# OPTIND hold the number 5.
((positions_occupied_by_switches = OPTIND - 1))
# Use a shift statement to eliminate all switches and switch arguments
# from the set of positional parameters.
shift $positions_occupied_by_switches
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

THE_DB_LINK=${THE_DB_LINK:-amd_pgoldlb_link}

if [[ -z ${TimeStamp:-} ]] ; then
  TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
  TimeStamp=`print $TimeStamp | sed "s/:/_/g"`
fi

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
  export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

function execSteps {

    typeset -Z3 array
    cnt=0
    for x in `echo $* | awk -f $BIN_HOME/awkNumInput.txt`
    do
      let cnt=cnt+1
      array[$cnt]=$x
    done

    # set $* to the data in the work array
    set -s ${array[*]}

    # empty work array
    i=1
    while (( $i <= $cnt ))
    do
      array[$i]=
      let i=i+1
    done

    for x in $*
    do
      ((x=x)) # make sure x is a number with no leading zerso
      if [[ "$AMD_REPLICATE_GOLD_STEP" = "1" ]] ; then
        AMD_CUR_STEP=`printf "%02d" $x`
      fi
      if [[ "${steps[$x]}" != "exit" ]] ; then
        print "${steps[$x]} started at `date` exec'ed by $CUR_USER"
      fi
      if [[ "${steps[$x]}" = "return" || "${steps[$x]}" = "exit" ]] ; then
        AMD_EXIT=Y
        return
      else
        ${steps[$x]} 
      fi
      print "${steps[$x]} ended at `date` exec'ed by $CUR_USER"
    done

}

function mainMenu {
  PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "
  select item in "${steps[@]}" 
  do
    set  $REPLY
    execSteps $*
    if [[ "${AMD_REPLICATE_GOLD_VERBOSE:-N}" = "Y" ]]  ; then
      print "\$!=$! \$$=$$ \$PPID=$PPID"
    fi
    if [[ "${AMD_EXIT:-N}" = "Y" ]] ; then
      return
    fi
  done
}

function main {
    
  echo "$0 started at `date`" 
  let curStep=${1:-1}
  let endStep=${2:-${#steps[*]}}
  if (( $curStep > $endStep ))
  then
    print -u2 "start step must be <= end step"
    exit 4
  fi

  execSteps $curStep-$endStep
  echo "$0 ended at `date`" 
}   

function execSqlplus {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG $1 $2 $3   &
  if [[ "${AMD_REPLICATE_GOLD_VERBOSE:-N}" = "Y" ]]  ; then
    print "RC=$RC BATCH_PID=$BATCH_PID \$$=$$ \$PPID=$PPID"
  fi
}

thisFile=${0##*/}
print "$thisFile started at " `date` " with DBLink of $THE_DB_LINK"

steps[1]="execSqlplus loadPoi1 $THE_DB_LINK"
steps[2]="execSqlplus loadOrd1 $THE_DB_LINK"
steps[3]="execSqlplus loadCat1 $THE_DB_LINK" 
steps[4]="execSqlplus loadVenc $THE_DB_LINK"
steps[5]="execSqlplus loadVenn $THE_DB_LINK"
steps[6]="execSqlplus loadFedc $THE_DB_LINK"
steps[7]="execSqlplus loadRamp $THE_DB_LINK"
steps[8]="execSqlplus loadItem $THE_DB_LINK"
steps[9]="execSqlplus loadMils $THE_DB_LINK"
steps[10]="execSqlplus loadChgh $THE_DB_LINK"
steps[11]="execSqlplus loadReq1 $THE_DB_LINK"
steps[12]="execSqlplus loadRsv1 $THE_DB_LINK"
steps[13]="execSqlplus loadTmp1 $THE_DB_LINK"
steps[14]="execSqlplus loadPrc1 $THE_DB_LINK"
steps[15]="execSqlplus loadMlit $THE_DB_LINK"
steps[16]="execSqlplus loadNsn1 $THE_DB_LINK"
steps[17]="execSqlplus loadIsgp $THE_DB_LINK"
steps[18]="execSqlplus loadUse1 $THE_DB_LINK"
steps[19]="execSqlplus loadOrdv $THE_DB_LINK"
steps[20]="execSqlplus loadWhse $THE_DB_LINK"
steps[21]="execSqlplus loadItemsa amd_goldsa_link"
steps[22]="execSqlplus loadReq1SA"
steps[23]="execSqlplus loadUims $THE_DB_LINK"
steps[24]="execSqlplus loadCgvt $THE_DB_LINK"
steps[25]="execSqlplus loadLvls $THE_DB_LINK"
steps[26]="execSqlplus loadTrhi $THE_DB_LINK"
steps[27]="execSqlplus loadTurn $THE_DB_LINK"
steps[28]="wait"
steps[29]="execSqlplus updateRamp"
steps[30]="execSqlplus analyzeTablesIndexes"
steps[31]="return"

THIS_FILE=`basename $0`
THIS_FILE_NO_EXT=`echo $THIS_FILE | sed 's/\..\{3\}$//'`
STEPS_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}Steps.ksh
if [[ -f $STEPS_FILE ]] ;  then
  # override steps
  print "$CUR_USER is executing script and overriding steps wiht ${STEP_FILE}" 2>&1 | tee -a $AMD_REPLICATE_GOLD_LOG
  cat $STEPS_FILE 2>&1 | tee -a $AMD_REPLICATE_GOLD_LOG
  . $STEPS_FILE
  print "$CUR_USER is renaming override script $STEPS_FILE to ${STEPS_FILE}.bku" 
  mv $STEPS_FILE ${STEPS_FILE}.bku
fi


SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log

if [[ -z $AMD_CUR_STEP ]] ; then
  AMD_REPLICATE_GOLD_STEP=1
  export AMD_CUR_STEP=1
  AMD_REPLICATE_GOLD_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
else
  AMD_REPLICATE_GOLD_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${thisFile%\.*}.log
fi

if [[ "$AMD_REPLICATE_GOLD_MENU" = "Y" ]] ; then
  mainMenu 2>&1 | tee -a $AMD_REPLICATE_GOLD_LOG
else
  if (($#>0)) ; then
    execSteps $* | tee -a $AMD_REPLICATE_GOLD_LOG
  else
    main $@ 2>&1 | tee -a $AMD_REPLICATE_GOLD_LOG
  fi
fi

ps -elf | grep amduser | tee -a $AMD_REPLICATE_GOLD_LOG
wait

print "$thisFile ending at " `date` " with DBLink of $THE_DB_LINK"

if [[ -a $SQLPLUS_ERROR_LOG ]] ; then
  if [[ -e /tmp/msg ]] ; then
    rm /tmp/msg
  fi
  $LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG > /tmp/msg
  if (($?!=0)) ; then
    $LIB_HOME/notify.ksh -s "replicateGold.ksh Error(s)" -m `cat /tmp/msg`
    $LIB_HOME/sendPage.ksh  "replicateGold.ksh Error(s)"
    rm /tmp/msg
    exit 4
  fi
fi

