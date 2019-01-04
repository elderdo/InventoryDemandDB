#!/bin/ksh
#   vim: ts=2 sw=2 sts=2 et 
#   $Author:   Douglas S. Elder
# $Revision:   1.75
#     $Date:   14 Sep 2017
# $Workfile:   main_amd_loader.ksh  $
#
# rev 1.53 douglas.s.elder@boeing.com added step number to failure messages
# rev 1.54 douglas.s.elder@boeing.com made the trimmedPostProcessing step
#          a background process
# rev 1.55 douglas.s.elder@boeing.com add the stepname to the step number msg's
# rev 1.56 douglas.s.elder@boeing.com filter out all spo import errors until spo 8 conversion
# rev 1.57 douglas.s.elder@boeing.com made sendSpoUser a bacground process
# rev 1.58 douglas.s.elder@boeing.com moved all spo functions to sendSpoData
# rev 1.59 douglas.s.elder@boeing.com use nohup for sendSpoData.ksh to make sure
# it keeps going even when executed interactively
# rev 1.60 douglas.s.elder@boeing.com removed Spo step
# rev 1.61 douglas.s.elder@boeing.com removed DO_SQLLDR_FOR_SPO and related -g and -k command line options
#          and added carriage returns to some USAGE text
#          and added a space before and after left and right bracket in USAGES statements (otherwise it does not always print right)
#          and eliminated double quotes around the $USAGE variable otherwise the print gets double spaced
# rev 1.62 douglas.s.elder@boeing.com removed truncateInterfaceBatch which was for SPO
# rev 1.63 douglas.s.elder@boeing.com added Oracle's analyze as the last step
# rev 1.64 douglas.s.elder@boeing.com changed amdAnalyze to use analyzeTablesIndexes.sql
# rev 1.65 douglas.s.elder@boeing.com for partFactorsDiff use -c opt for checkforerrors.ksh so
# rev 1.66 douglas.s.elder@boeing.com for pairsAndParts.ksh make sure to abort when there is an error
# rev 1.67 douglas.s.elder@boeing.com for partLocForecastDiff.ksh use checkforerrors.ksh with the -c case sensitive switch
# rev 1.68 douglas.s.elder@boeing.com added analyze after replicate steps
# rev 1.69 5/18/17 douglas.s.elder@boeing.com create bssm files both ways
#                                     via views and with old queries
#                                     then compare the two
# rev 1.70 5/18/17 douglas.s.elder@boeing.com added -k dir option to
#                                     override the default of bssm.
#                                     The bssm flat files created via views
#                                     are written to this directory.
#                                     used ksh -n main... to clean up obsolete script commands
# rev 1.71 5/19/17 douglas.s.elder@boeing.com fixed number of steps - had  2
#                                             step 28's, made the 2nd 28 into
#                                             step 29 and step 29 into step 30 
# rev 1.72 5/19/17 douglas.s.elder@boeing.com added BSSM_DIR=bssm
#                                                   so it has an initial value
#                                                   which can be overridden
#                                                   via -k dir
# rev 1.73 5/21/17 douglas.s.elder@boeing.com corrected -o argument for genBssmFiles.ksh
#                                             for genBssmFiles.ksh, added 
#                                             check for the -c commad_file 
#                                             to make sure the command file 
#                                             exists, got rid of obsolete
#                                             -gt and just tested to see if 
#                                             the number of args was not zero
# rev 1.74 9/14/17 douglas.s.elder@boeing.com eliminated mkdir and rm of bssm files
#                                             created by genBssmFiles.ksh since it
#                                             does those commands
# rev 1.75 9/14/17 douglas.s.elder@boeing.com add addiitonal debugging to bssmFlatFiles
#
USAGE="usage: ${0##*/} [ -m ] [ -d ] [ -h ] [ -l logHomedir ] [ -s srcHomedir ] [ -b binHomedir ]
[ -i libHome  ] [ -c commandFile ]  [ -n ] [ -x ] [ -t 999 ] [ -a REPLICATE ] [ -w REPLICATE_WESM ]
[ -e AMDLOAD1 ] [ -f AMDLOAD2 ] [ -u ] [ -o ] [ -q ] [ -v ] [ -r ] [ -k dir ] [ -y ] [ -z ] [ startStep endStep  ]\n\n
\twhere\n
\t-m will enable a selection menu\n
\t-c commandFile allows for a file of step names to be processed.\n
\t-d enables debug\n
\t-n signals not to use the tee command\n
\t-x show runEnqueue debug errors\n
\t-t 999\tset the SPARE_PARTS_NEW_DATA_THRESHOLD for data\n
\t\twhere 999 is the min # or rows for tmp_amd_spare_parts.\n
\t\tThe default is 99999\n
\t-a REPLICATE where REPLICATE is the file containing\n
\t\tthe sql for the ReplicateGold step\n
\t-w REPLICATE_WESM where REPLICATE_WESM is the file containing\n
\t\tthe sql for the ReplicateWesm step\n
\t-e AMDLOAD1\twhere AMDLOAD1 is the file for step AmdLoad1\n
\t-f AMDLOAD2\twhere AMDLOAD2 is the file for step AmdLoad2\n
\t-j abort job for all errors or warnings\n
\t-k dir - default is bssm\n
\t-o\tturn off notification via email\n
\t-q\tquit sending all email and pager notifications\n
\t-v\tSend notification that the Bssm Flat Files have been created\n
\t\tdefault is to NOT send notification\n
\t-r\tsend remsh output to stdout via a tee\n
\t\tdefault is to send stdout for remsh to a log file\n
\t-y\tdo not be strict when executing steps: ie run them even if they\n
\t\tcompleted previously\n
\t-z\tuse sgoldlb as the GOLD data source\n
\t\tdefault is pgoldlb\n
\tstartStep can be from 1 to 27\n
\t\tdefault is 1\n
\tendStep must be >= startStep & <= 27\n
\t\tdefault is 27"

if [[ "$debug" == "Y" ]] ; then
  set -x
fi

if [[ "$#" != "0" && "$1" == "?" ]] ; then
  print $USAGE
  exit 0
fi

# import common definitions
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

BSSM_DIR=$DATA_HOME

CUR_USER=$(logname)
if [[ -z $CUR_USER ]] ; then
  CUR_USER=amduser
fi


while getopts :jk:rqovxnmdl:s:b:i:c:t:a:e:f:w:zy arguments
do
  case $arguments in
    a) REPLICATE=${OPTARG};;
    w) REPLICATE_WESM=${OPTARG};;
    e) AMDLOAD1=${OPTARG};;
    f) AMDLOAD2=${OPTARG};;
    j) export ABORT_FOR_WARNINGS=Y;;
    k) BSSM_DIR=$OPTARG;;
    t) SPARE_PARTS_NEW_DATA_THRESHOLD=${OPTARG};;
    l) LOG_HOME=${OPTARG};;
    s) SRC_HOME=${OPTARG};;
    b) BIN_HOME=${OPTARG};;
    i) LIB_HOME=${OPTARG};;

    c) COMMAND_FILE=${OPTARG} 
       if [[ ! -e $COMMAND_FILE ]] ; then
         echo $COMMAND_FILE does not exist
         exit 4
       fi;;

    m) AMD_USE_MENU=Y;;
    n) NO_TEE=Y;;
    x) showRunEnqueueDebug=Y;;
    o) AMD_ERROR_NOTIFICATION=N
       AMD_NOTIFY=N;;
    q) AMD_NOTIFY=N;;
    v) AMD_BSSMFLATFILE_NOTIFY=Y;;
    r) REMOTE_TEE=Y ;;
    w) ESCM_HOME=${OPTARG} ;;
    z) THE_DB_LINK=sgoldlb ;;
    y) STRICT=N ;;
    d) debug=Y
       set -x ;;
    *) print -u2 $USAGE
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

STRICT=${STRICT:-Y} # when = Y only run steps that have not yet completed

export TimeStamp=$(date $DateStr | sed "s/:/_/g")

export AMD_CUR_STEP=1
export AMD_LOADER_LOG=$LOG_HOME/${TimeStamp}_99_amd_loader.log

hostname=$(hostname -s)

function abort {
  errmsg="AMD Load Failed for $AMDENV at step $THE_CUR_STEP ( $AMD_CUR_STEP )"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  if [[ "${AMD_ERROR_NOTIFICATION:-Y}" == "Y" ]] ; then
    $LIB_HOME/notify.ksh -s "$errmsg on $hostname" -h more.txt \
      -m " $errmsg on $hostname. $1" 
    $LIB_HOME/sendPage.ksh  "$errmsg $1"    
  fi
  exit 4
}

function recordStartOfStep {
  $LIB_HOME/execSqlplus.ksh -r startStep $1
  RC=$?
  if [[ "$RC" == 4 ]] ; then
    print "$(date): $1 already completed for this job " 
    if [[ "$STRICT" == "N" ]] ; then
      print "but you are running it again. Aborting and restarting"
      $LIB_HOME/execSqlplus.ksh -r abortStep $1
      if (($?==0)) ; then
        $LIB_HOME/execSqlplus.ksh -r startStep $1
        RC=$?
      fi
    else
      print "Use the -y option to re-execute steps"
      RC=8
    fi
  fi
  return $RC
}

function recordEndOfStep {
  $LIB_HOME/execSqlplus.ksh -r endStep $1
  return $?
}

function recordStep {
  THE_CUR_STEP=$1

  case $THE_CUR_STEP in
    "header" | "StartJob" | "bssmFlatFiles" | \
    "archive" | "footer" | "exit")  RC=0;;

    *) 
    recordStartOfStep $THE_CUR_STEP
    RC_4_START_STEP=$?
    if [[ "${STRICT:-Y}" == "Y" ]] ; then
      # by checking for a return code of 8 then you don't really need a job to run any step
      if [[ "$RC_4_START_STEP" == "0" || "$RC_4_START_STEP" == "8"  ]] then
        print "$THE_CUR_STEP started at $(date)"
        $THE_CUR_STEP
        print "$THE_CUR_STEP ended at $(date)"
        recordEndOfStep $THE_CUR_STEP
        RC=$?
      fi
    else
      print "$THE_CUR_STEP started at $(date)"
      $THE_CUR_STEP
      print "$THE_CUR_STEP ended at $(date)"
      recordEndOfStep $THE_CUR_STEP
      RC=$?
    fi ;;

  esac

  return $RC
}

function execSteps {

    #echo debug: execSteps start
    typeset -Z3 array
    cnt=0
    for x in $(echo $* | awk -f $BIN_HOME/awkNumInput.txt)
    do
      let cnt=cnt+1
      array[$cnt]=$x
    done

    # set $* to the data in the work array
    set -s ${array[*]}

    # empty work array
    i=1
    while (( i <= cnt ))
    do
      array[$i]=
      let i=i+1
    done


    for x in $*
    do
      ((x=x)) # make sure x is a number with no leading zerso
      AMD_CUR_STEP=$(printf "%02d" $x)
      THE_CUR_STEP=${steps[$x]}
      if [[ "${RECORDING_STEPS:-N}" == "Y" ]] ; then
        recordStep $THE_CUR_STEP
      else
        case $THE_CUR_STEP in
          "header" | "footer" | "exit") 
            print "${x}. $THE_CUR_STEP executed at $(date)"
            $THE_CUR_STEP ;;

          "sendSpoData") 
            print "${x}. $THE_CUR_STEP started in the background at $(date)"
	    cd $LOG_HOME	
            $THE_CUR_STEP ;;

          *)  print "${x}. $THE_CUR_STEP started at $(date)"
            $THE_CUR_STEP
            print "${x}. $THE_CUR_STEP ended at $(date)" ;;
        esac
      fi
    done
    #echo debug: execSteps end

}

function mainMenu {
  PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "
  select item in ${steps[*]}
  do
    #echo debug: REPLY=$REPLY
    set  $REPLY
    #echo debug: Parms=$*
    execSteps $*
  done
}

function main
{
    
  echo "main started at $(date)" 
  let curStep=${1:-1}
  let endStep=${2:-${#steps[*]}}
  if (( curStep > endStep ))
  then
    print -u2 "start step must be <= end step"
    exit 4
  fi
  execSteps ${curStep}-${endStep}
  echo "main ended at $(date)" 
    
}


function StartJob
{
  $LIB_HOME/execSqlplus.ksh -r $0 >> $AMD_LOADER_LOG 2>&1
  START_JOB_RC=$?

  case $START_JOB_RC in
    0) print "Starting new job" ;;
    4) print "Restarting job" 
       if [[ "$STRICT" == "Y" ]] ; then
         print "Previously completed steps will not be reexecuted"
       else
         print "Rerunning previously completed steps"
       fi ;;
    *) abort "$0 error."   ;;
  esac

}

function cleanTraceTables
{
  $LIB_HOME/execSqlplus.ksh $0 >> $AMD_LOADER_LOG 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
}

function replicateGold
{
  case ${THE_DB_LINK:-amd_pgoldlb_link} in
    amd_pgoldlb_link) LINK_OPT=-p ;;
    amd_sgoldlb_link) LINK_OPT=-s ;;
  esac

  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/replicateGold.ksh $LINK_OPT > $LOG_NAME 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
}

function replicateWesm
{
   LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
   $LIB_HOME/replicateWesm.ksh > $LOG_NAME 2>&1
   if (($?!=0)) ; then
  abort "$0 error." 
   fi
}

function processL67
{
   LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
   $LIB_HOME/amd_LoadFtpFile.ksh L67 >$LOG_NAME 2>&1
   RC=$?
   $LIB_HOME/checkforerrors.ksh $LOG_NAME
   if (($?!=0 || RC!=0)) ; then
     print "Warning: $0 ended without a return code of zero"
   fi
}

function processGDSS
{
   LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
   $LIB_HOME/amd_LoadFtpFile.ksh GDSS >$LOG_NAME 2>&1
   RC=$?
   $LIB_HOME/checkforerrors.ksh $LOG_NAME
   if (($?!=0 || RC!=0)) ; then
     print "Warning: $0 ended without a return code of zero"
   fi
}


function truncateAmd
{
  $LIB_HOME/execSqlplus.ksh $0 >> $AMD_LOADER_LOG 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
}

function loadTmpDmndFrcstConsumables {
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  ${debug:+ksh -x} $LIB_HOME/loadTmpDmndFrcstConsumables.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
     print "Warning: $0 ended without a return code of zero"
    fi
}

function loadAmdDmndFrcstConsumables {
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/${0}.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}

  
function AmdLoad1
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/AmdLoad1.ksh ${debug:+-d} > $LOG_NAME 2>&1
    if (($?!=0)) ; then
     abort "$0 error."
    fi
}
    

function plannersDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/plannersDiff.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}

function pairsAndParts
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"

  param="${SPARE_PARTS_NEW_DATA_THRESHOLD:+-s $SPARE_PARTS_NEW_DATA_THRESHOLD}"

  $LIB_HOME/pairsAndParts.ksh $param ${debug:+-d} >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh -n $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
      abort "$0 error."
      print "$0 error."
    fi
}


function AmdLoad2
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/AmdLoad2.ksh ${debug:+-d} > $LOG_NAME 2>&1
  if (($?!=0)) ; then
      abort "$0 error."
  fi
}
      
function invDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/invDiff.ksh ${debug:+-d} >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
  if (($?!=0 || RC!=0)) ; then
      abort "$0 error."
  fi
}


function partFactorsDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/partFactorsDiff.ksh >$LOG_NAME 2>&1
  RC=$?
  # make sure the check is case sensitive to not to pick of
  # code containing error:
  $LIB_HOME/checkforerrors.ksh -c $LOG_NAME
  if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}

function partLocForecastsDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/partLocForecastsDiff.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh -c $LOG_NAME
  if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}


function locPartLeadtimeDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/locPartLeadtimeDiff.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
  if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}



function AmdLoad3
{
  $LIB_HOME/execSqlplus.ksh $0 >> $AMD_LOADER_LOG 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
}

if [[ -e $DATA_HOME/dynam.ksh ]] ; then
  . $DATA_HOME/dynam.ksh
else
function DynamSql
{
  return
}
fi

if [[ -e $DATA_HOME/dynamPostProcess.ksh ]] ; then
  . $DATA_HOME/dynamPostProcess.ksh
else
function DynamSqlPostProcess
{
  return
}
fi


function locPartOverrideDiff
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/locPartOverrideDiff.ksh >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh -n $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
     #abort "$0 error."
     print "$0 error."
    fi
  # send warning info to only people interested
  if [[ -e $DATA_HOME/warnings.txt ]] ; then
    grep -q "rows with overriden quantities=" $LOG_NAME
    if (($?==0)) ; then
      hostname=$(hostname -s)
      MSG="AMD Load of locPartOverrideDiff data on $AMDENV@$hostname had quantities that were too big"
      $LIB_HOME/execSqlplus.ksh sendWarningMsg \
        "$MSG for step $0${AMD_CUR_STEP:+ / AMD_STEP=$AMD_CUR_STEP} had quantities too large"
    fi
  fi
}

function loadLRU_Breakdown
{
  $LIB_HOME/execSqlplus.ksh $0
}

function loadRmads
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/amd_LoadRmads.ksh ${debug:+-d}  >$LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
    if (($?!=0 || RC!=0)) ; then
     abort "$0 error."
    fi
}

function bssmFlatFiles
{
  if [[ $debug == "Y" ]] ; then
    set -x
    KSH_X="ksh -x "
  else
    KSH_X=
  fi
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"


  $KSH_X $LIB_HOME/amd_bssmFlatFiles.ksh  >$LOG_NAME 2>&1
  $LIB_HOME/checkforerrors.ksh $LOG_NAME
  if (($?!=0)) ; then
   abort "$0 error."
  fi
  $KSH_X $LIB_HOME/genBssmFiles.ksh -o $BSSM_DIR  >>$LOG_NAME 2>&1
  $KSH_X $LIB_HOME/compare.ksh > $LOG_HOME/compare_${TimeStamp}_${AMD_CUR_STEP}.log  2>&1

  if [[ $AMD_BSSMFLATFILE_NOTIFY == Y  ]]
  then
    $LIB_HOME/notify.ksh -a bssmNotify.txt  \
        -s "Bssm Flat Files have been created on $hostname" \
        -m "$0 Bssm Flat Files have been created on $hostname." \
        $LOG_NAME \
        $(ls -t $LOG_HOME/*compare* | head -n 1)
  fi
}


function archive 
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP}_${0}.log"
  $LIB_HOME/archive.ksh >> $LOG_NAME 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
  if [[ ! -s $LOG_NAME ]] ; then
    rm -f $LOG_NAME
  fi
}

function amdAnalyze 
{

  if [ "$debug" = "Y" ] ; then
    opt=-d
  else
    opt=
  fi

  $LIB_HOME/execSqlplus.ksh $opt analyzeTablesIndexes >> $AMD_LOADER_LOG 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
}

function EndJob
{
  if [[ "$debug" == "Y" ]] ; then
    set -x
  fi

  $LIB_HOME/execSqlplus.ksh $0 >> $AMD_LOADER_LOG 2>&1
  if (($?!=0)) ; then
    abort "$0 error."
  fi
  if [[ "$AMD_NOTIFY" == "Y" ]] ; then
    awk 'sub("$", "\r")' $AMD_LOADER_LOG > /tmp/${TimeStamp}_${AMD_CUR_STEP}_amd_loader.log 

    $LIB_HOME/sendWarnings.ksh -a endJobNotify.txt
    WRC=$?
    RC=$($LIB_HOME/oraCheck.ksh "select count(*) from amd_load_warnings where last_update_dt > amd_batch_pkg.getLastStartTime;")
    if [[ $RC == 0 || $WRC != 0 ]] ; then 
      $LIB_HOME/notify.ksh -a endJobNotify.txt \
        -s "AMD Load Finished on $AMDENV@$hostname" \
        -m "AMD Load finished on $AMDENV@$hostname without warnings." \
        /tmp/${TimeStamp}_${AMD_CUR_STEP}_amd_loader.log 
    fi

    if [[ -e $DATA_HOME/more.txt ]] ; then
      $LIB_HOME/notify.ksh -a more.txt -s "AMD Load Finished on $AMDENV@$hostname" \
        -m "$0 finished on $hostname. $(cat /tmp/${TimeStamp}_${AMD_CUR_STEP}_amd_loader.log)"
    fi
  else
    print "AMD Load Finished on $hostname"
  fi
}




function header
{
  print "********************************************************" 
  print "* Start Date & Time: $(date) exec'ed by $CUR_USER" 
  print "********************************************************"
  print "Log time in ALL filenames will be: ${TimeStamp}." 
  
}



function footer
{
  print "\n" 
  print "********************************************************"
  print "* End Date & Time: $(date) exec'ed by $CUR_USER"
  print "********************************************************"
}

function checkStepName {
  cnt=1
  while (( cnt <= ${#steps[*]} ))
  do
    if [[ "${steps[$cnt]}" == "$1" ]] ; then
      return
    fi
    let cnt=cnt+1
  done
  # it is ok to execute external scripts via command file
  if [[ -x $1 ]] ; then
    print  "executing script $1"
  else
    print -u2 "$1 is an invalid step"
  fi
    abort "$0 error."
}

# load step array
steps[1]=header
steps[2]=StartJob
steps[3]=cleanTraceTables
steps[4]=replicateGold
steps[5]=replicateWesm
steps[6]=amdAnalyze
steps[7]=processL67
# no longer needed - 12/05/2006 DSE steps[5]=processGDSS
steps[8]=truncateAmd
steps[9]=loadTmpDmndFrcstConsumables
steps[10]=loadAmdDmndFrcstConsumables
steps[11]=loadRmads
steps[12]=AmdLoad1
steps[13]=plannersDiff
steps[14]=pairsAndParts
steps[15]=AmdLoad2
steps[16]=invDiff
steps[17]=partFactorsDiff
steps[18]=partLocForecastsDiff
steps[19]=locPartLeadtimeDiff
steps[20]=AmdLoad3
steps[21]=locPartOverrideDiff
steps[22]=loadLRU_Breakdown
steps[23]=DynamSql
steps[24]=DynamSqlPostProcess
steps[25]=EndJob
steps[26]=bssmFlatFiles
steps[27]=archive
steps[28]=footer
steps[29]=amdAnalyze
steps[30]=exit

  showRunEnqueueDebug=${showRunEnqueueDebug:-N}
  REMOTE_TEE=${REMOTE_TEE:-N}

  if [[ "$REMOTE_TEE" == "N" ]] ; then
    remoteLog="2>&1"
  else
    remoteLog="| tee"
  fi

  export AMD_NOTIFY=${AMD_NOTIFY:-Y}
  export AMD_BSSMFLATFILE_NOTIFY=${AMD_BSSMFLATFILE_NOTIFY:-N}
  if [ $AMD_NOTIFY = N ]
  then
    AMD_ERROR_NOTIFICATION=N
  fi

  export AMD_ERROR_NOTIFICATION=${AMD_ERROR_NOTIFICATION:-Y}

  # NOTE: the load is currently not scheduled for dev
  # or integrated test, but the way the code is written
  # cancelation can be tested in all environments

  if [ -a /tmp/cancelAMDLoad ]
  then
    rm /tmp/cancelAMDLoad
    print "The AMD load on $AMDENV@$hostname was canceled" \
      | tee -a "$AMD_LOADER_LOG"
    if [[ "$AMDENV" == "prod" ]] ; then
      WILL_RUN="It will run at its next scheduled time."
    fi
    $LIB_HOME/notify.ksh -a endJobNotify.txt \
      -s "The AMD Load was canceled on $AMDENV@$hostname" \
      -m "The AMD Load was canceled on $AMDENV@$hostname. ${WILL_RUN:-}" 
    return 0
  fi


  if [[ "$AMD_USE_MENU" == "Y" ]] ; then
    header
    if [[ "$NO_TEE" == "Y" ]] ; then
      mainMenu >> "$AMD_LOADER_LOG"

    else
      mainMenu | tee -a "$AMD_LOADER_LOG"
    fi
  else
    if [[ -n $COMMAND_FILE && -f $COMMAND_FILE ]] ; then
      # remove all lines beginning with a #
      sed '/^\#/d' $COMMAND_FILE | while read step
      do
        checkStepName $step
        if [[ "${step}" != "exit" ]] ; then
          print "${steps} started at $(date)"
        fi
        $step | tee -a "$AMD_LOADER_LOG"
        print "$step ended at  $(date)"
      done 
    else
      if (( $# > 0 ))
      then
        if [[ "$NO_TEE" == "Y" || "$CUR_USER" == "amduser" ]] ; then
          execSteps $* >> "$AMD_LOADER_LOG"
        else
          execSteps $* | tee -a "$AMD_LOADER_LOG"
        fi
      else
        if [[ "$NO_TEE" == "Y" || "$CUR_USER" == "amduser" ]] ; then
          main $@ >> "$AMD_LOADER_LOG"
        else
          main $@ | tee -a "$AMD_LOADER_LOG"
        fi
      fi
    fi
  fi


return 0
