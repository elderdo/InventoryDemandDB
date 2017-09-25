#!/usr/bin/ksh
# vim: ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.26
#     $Date:   20 Jan 2014
# $Workfile:   loadInventory.ksh  $
#
# Rev 1.23 DouglasElder make spo related inv a separate step
# Rev 1.24 DouglasElder issue warnings only if trimTactics.ksh fails
# Rev 1.25 removed all Spo related steps
# Rev 1.26 deleted step invSpoData and tacticalPostProcess
#          and replace spoPartDiff with pairsAndParts
#          
USAGE="usage: ${0##*/} [ -p] [-s step] [-d] [-w] [-o] [-n] [-z] [-g]\n
\t\t[-v] [-t 999] [-m] [-x]\n
\twhere\n
\t-g get pgoldlb data - default\n
\t-z get sgoldlb data\n
\t-p send parts that have changed \n
\t-s step name or number (used for logname)\n
\t-d turn on debug\n
\t-w abort for warnings\n
\t-o turn off error notification\n
\t-n don't load tmp_amd_spare_parts (default is to load it)\n
\t-x don't do the pairsAndParts.ksh (default is to do it)\n
\t-v send all logs and sqlplus output to stdout for viewing\n
\t-t 999\tset the SPARE_PARTS_NEW_DATA_THRESHOLD for data\n
\t-m execute this script interactively via a menu\n
\t\twhere 999 is the min # or rows for tmp_amd_spare_parts.\n
\t\tThe default is 99999\n"

if [[ "$#" -gt "0" && "$1" = "?" ]]
then
  print $USAGE
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

if [[ -z $LIB_HOME || -z $LOG_HOME ]] ; then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :pdows:t:xvmzg arguments
do
  case $arguments in
    g) THE_DB_LINK=amd_pgoldlb_link;;
    z) THE_DB_LINK=amd_sgoldlb_link;;
    m) AMD_LOADINV_MENU=Y;;
    v) VIEW_STDOUT=Y;;
    p) export SEND_PARTS=Y;;
    s) AMD_CUR_STEP=${OPTARG};;
    w) export ABORT_FOR_WARNINGS=Y;;
    n) export AMD_LOAD_TMP=N;;
    x) export AMD_SPARE_PART_DIFF=N;;
    o) AMD_ERROR_NOTIFICATION=N;;
    t) SPARE_PARTS_NEW_DATA_THRESHOLD=${OPTARG};;
    d) debug=Y
       set -x ;;
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

hostname=`uname` 
thisFile=${0##*/}

abort() {
  $LIB_HOME/notify.ksh -a loadInventory.txt  -s "$thisFile failed at $1" -m "$thisFile has failed on $hostname at $1." 
  exit 4
}

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=`date $DateStr`
fi

export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`

if [[ -z $AMD_CUR_STEP ]] ; then
  AMD_LOADINV_STEP=1
  export AMD_CUR_STEP=1
  AMD_LOADINV_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
else
  AMD_LOADINV_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${thisFile%\.*}.log
fi

# have all sqlldr output go to this log
export EXEC_SQLLDR_LOG=$AMD_LOADINV_LOG

SQLPLUS_ERROR_LOG=$LOG_HOME/${TimeStamp}_9999_${thisFile%\.*}Errors.log


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
      if [[ "$AMD_LOADINV_STEP" = "1" ]] ; then
        AMD_CUR_STEP=`printf "%02d" $x`
      fi
      if [[ "${steps[$x]}" != "exit" ]] ; then
        print "${steps[$x]} started at `date` exec'ed by $CUR_USER"
      fi
      if [[ "${steps[$x]}" = "amd2spo" ]] ; then
        ${steps[$x]} &
      else
        ${steps[$x]} 
      fi
      if (($?!=0)) ; then
        abort "${steps[$x]} error."
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



function loadTmpAmdSpareParts {
  case ${THE_DB_LINK:-amd_pgoldlb_link} in
    amd_pgoldlb_link) LINK_OPTION=-p ;;
    amd_sgoldlb_link) LINK_OPTION=-s ;;
  esac
  $LIB_HOME/$0.ksh $LINK_OPTION ${VIEW_STDOUT:+-n}
  if (($?!=0)) ; then
    abort "$0.ksh"
  fi
}

function pairsAndParts {
    $LIB_HOME/$0.ksh $pairsAndParts_ARG
    if (($?!=0)) ; then
      abort "$0.ksh"
    fi
}

function processParts {
  if [[ "$1"  = "Y" ]] ; then
    loadTmpAmdSpareParts
  fi

  if [[ "$2" = "Y" ]] ; then
    if [[ -n ${SPARE_PARTS_NEW_DATA_THRESHOLD:-} ]] 
    then
      pairsAndParts_ARG="-s $SPARE_PARTS_NEW_DATA_THRESHOLD"
    else
      pairsAndParts_ARG=
    fi
    pairsAndParts
  fi

}

function checkIfSendingParts {
  if [[ "${SEND_PARTS:-}" = "Y" || "${SEND_ALL_PARTS:-}" = "Y" ]] ; then
    processParts  ${AMD_LOAD_TMP:-Y}  \
      ${AMD_SPARE_PART_DIFF:-Y} 
  fi
}

function replicateGoldInventoryTables {
  $LIB_HOME/$0.ksh
  if (($?!=0)) ; then
    abort "$0.ksh"
  fi
}

function loadOnHandInvs {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function loadInRepair {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function loadOnOrder {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function loadInTransits {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function loadRsp {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function loadGoldInventory {
  loadOnHandInvs
  loadInRepair
  loadOnOrder
  loadInTransits
  loadRsp
}

function loadAmdReqs {
  $LIB_HOME/execSqlplus.ksh -e $SQLPLUS_ERROR_LOG ${VIEW_STDOUT:+-n} $0  &
}

function invDiff {

  wait # make sure that all concurrent processes are done
  checkSqlplusErrorLog

  $LIB_HOME/invDiff.ksh
  if (($?!=0)) ; then
    abort "invDiff.ksh"
  fi
}


function checkSqlplusErrorLog {
  if [[ -f $SQLPLUS_ERROR_LOG ]] ; then
    $LIB_HOME/checkforerrors.ksh $SQLPLUS_ERROR_LOG
    if (($?!=0)) ; then
      abort "loadGoldInventory or loadAmdReqs"
    fi
  fi
}

function notify {
  hostname=`uname -n`
  $LIB_HOME/$0.ksh -a loadInventory.txt \
          -s "$1 completed" \
    -m "$1 has completed on $hostname." 
}



rename() {
  print "$CUR_USER is renaming $1 to ${1}.bku" 
  mv $1 ${1}.bku
}

doOverride() 
{
  for file in $STEPS_FILE $OVERRIDE_FILE ; do
    if [[ -f $file ]] ;  then
      print "$CUR_USER is executing script " \
        "and overriding with " \
        "${file}" 2>&1 
      cat $file 2>&1 
      . $file
      rename $file
    fi
  done
}
 
THIS_FILE=`basename $0`
THIS_FILE_NO_EXT=`echo $THIS_FILE | sed 's/\..\{3\}$//'`
STEPS_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}Steps.txt
OVERRIDE_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}_override.txt
DO_NOT_EXECUTE_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}_noexec.txt
if [[ -f $DO_NOT_EXECUTE_FILE ]] ; then
  DO_NOT_EXECUTE=Y
  rename $DO_NOT_EXECUTE_FILE
fi

if [[ "$AMD_LOADINV_MENU" = "Y" ]] ; then
  steps[1]=loadTmpAmdSpareParts
  steps[2]=pairsAndParts
  steps[3]=replicateGoldInventoryTables
  steps[4]=loadOnHandInvs
  steps[5]=loadInRepair
  steps[6]=loadOnOrder
  steps[7]=loadInTransits
  steps[8]=loadRsp
  steps[9]=loadAmdReqs
  steps[10]=invDiff
  steps[11]=exit

  doOverride

  # execute the steps using a menu
  mainMenu 2>&1 | tee -a $AMD_LOADINV_LOG
else
  # set the steps to run
  steps[1]=checkIfSendingParts
  steps[2]=replicateGoldInventoryTables
  steps[3]=loadGoldInventory
  steps[4]=loadAmdReqs
  steps[5]=invDiff
  steps[6]="notify $0"
  steps[7]=exit

  doOverride

  # execute the steps 
  print "$0 starting at " `date`
  if [[ "${DO_NOT_EXECUTE:-N}" = "N"  ]] ; then
    main $@ 2>&1 | tee -a $AMD_LOADINV_LOG
  else
    print "loadInventory.ksh was intentionally not executed"
  fi
  print "$0 ending at " `date`
fi
