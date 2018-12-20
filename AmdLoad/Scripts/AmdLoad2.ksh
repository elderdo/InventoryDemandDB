#!/usr/bin/ksh
# vim: ts=2:sw=2:sts=2:et:autoindent:smartindent:
#   Author:   Douglas S. Elder
# Revision:   1.29
#     Date:   19 Apr 2018
#     File:   AmdLoad2.ksh

# Rev 1.29 19 Apr 2018 fixed checkForErrors arguments to have the correct ranges
# Rev 1.28 01 Feb 2018 turned on loadSanAntonio data TFS 52919
#                      renamed loadBascUkDemands to loadDepotDemands
# Rev 1.27 19 Dec 2017 turned off loadSanAntonio data TFS 48244
# Rev 1.26 28 Aug 2017 added loadWarnerRobinsDemands
# Rev 1.25 02 Aug 2017 added loadSanAntonioDemands
#                      performed ksh -x AmdLoad2.ksh scan
#                      and replaced obsolete code with
#                      current ksh standard code:
#                      `   ` replaced with $(   )
#                      = replaced with ==
#                      -a replaced with -e
#                      eliminated $'s from numeric expressions
# Rev 1.24 19 Mar 2017 fixed function execSqlplus
# Rev 1.23 29 Oct 2013 removed all spo functions
# Rev 1.22 ignore spo import errors until converted to Spo 8
# Rev 1.21 make sure the logs for the sqlplus scripts are
#          scanned for errors
# Rev 1.20 added step 10 to load amd_demands
# and changed the name of step 5 to loadAmdBssmSourceTmpAmdDemands

# Rev 1.19 removed amdDemandA2A step

USAGE="Usage: ${0##*/} [-h] [-m] [-o] [-f] [-d] [-s step_file]  [startStep endStep ]\n\n
\twhere\n
\t-h displays this message\n
\t-m will enable a selection menu\n
\t-o turn off notification via email\n
\t-f run all sqlplus steps in the foreground (default is background)\n
\t-s step file for overriding the steps - default is AmdLoad2Steps.ksh\n
\t-d enables debug\n"

if [[ $# > 0 && "$1" == "-h" ]] ; then
  print $USAGE
  exit 0
fi

CUR_USER=$(logname)
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

abort() {
  errmsg="AmdLoad2.ksh Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  exit 4
}


while getopts :mndfos: arguments
do
  case $arguments in
    m) AMD_USE_AMDLOAD2_MENU=Y;;
    s)  STEPS_FILE=${OPTARG}
       if [[ ! -f $STEPS_FILE ]] ; then
         print -u2 "Error: $STEPS_FILE does not exist"
         exit 4
       fi ;;
    o) AMD_ERROR_NOTIFICATION=N;;
    f) AMDLOAD2_FOREGROUND=Y;;
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

# look throgh the stesp array
# for sqlplus steps
# and scan their logs for errors
function checkSqlplusErrors {

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

    foundError=0
    for x in $*
    do
      ((x=x)) # make sure x is a number with no leading zerso
      if [[ "$AMD_AMDLOAD2_STEP" == "1" ]] ; then
        AMD_CUR_STEP=$(printf "%02d" $x)
      fi
      func=$(echo ${steps[$x]} | cut -d" " -f1)
      if [[ ! -z $func && "$func" == "execSqlplus" ]] ; then
        sqlscript=$(echo ${steps[$x]} | cut -d" " -f2)
        if [[ ! -z $sqlscript && -f $SRC_HOME/$sqlscript.sql ]] ; then
          # scan the log file associated with this script
          # using the current TimeStamp
                      if [[ ${AMD_ERROR_NOTIFICATION:-Y} == "N" ]] ; then
                              CHECK4ERROROPT=-n
                      fi                        
          for log in $(ls $LOG_HOME/${TimeStamp}*${sqlscript}*.log)
          do
            if [[ -f $log ]] ; then
              $LIB_HOME/checkforerrors.ksh ${CHECK4ERROROPT:-} $LOG_HOME/${TimeStamp}*${sqlscript}*.log
              if (($?!=0)) ; then
                foundError=1
              fi
            fi
          done

        fi
      fi
    done
    if ((foundError!=0)) ; then
      exit 4
    fi
}

function execSteps {

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
      if [[ "$AMD_AMDLOAD2_STEP" == "1" ]] ; then
        AMD_CUR_STEP=$(printf "%02d" $x)
      fi

      case ${steps[$x]} in
        "return" | "exit")
          AMD_EXIT=Y
          return ;;
        "sendToSpo")
          ${steps[$x]} & ;;
        *)
          ${steps[$x]} ;;
       esac

    done

}

function mainMenu {
  PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "

  select item in "${steps[@]}"
  do
    set  $REPLY
    execSteps $*
    if [[ "${AMD_EXIT:-N}" == "Y" ]] ; then
      return
    fi
  done
}

function main
{
  echo "main started at $(date)" 
  execSteps 1-${#steps[*]}
  echo "main ended at $(date)" 
    
}

function checkForErrors {
  if [[ -e $AMDLOAD2_ERROR_LOG ]] ; then
    if [[ ${AMD_ERROR_NOTIFICATION:-Y} == "N" ]] ; then
      CHECK4ERROROPT=-n
    fi                        
    $LIB_HOME/checkforerrors.ksh ${CHECK4ERROROPT:-} $AMDLOAD2_ERROR_LOG
    if (($?!=0)) ; then
      exit 4
    fi
  fi
}

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
  export TimeStamp=$(print "$TimeStamp" | sed "s/:/_/g")
fi

print "$0 started at " $(date)
thisFile=${0##*/}

AMDLOAD2_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log


function execSqlplus {
  if [[ "${AMDLOAD2_FOREGROUND:-N}" == "Y" ]] ; then
    print "$0.ksh $1 started at $(date)"
    $LIB_HOME/execSqlplus.ksh -e $AMDLOAD2_ERROR_LOG $1  
    RC=$?
    print "$0.ksh $1 ended at $(date)"
    if ((RC!=0)) ; then
      abort "$0 failed for $1"
    fi
  else
    print "$0.ksh $1 started in background at $(date)"
    $LIB_HOME/execSqlplus.ksh -e $AMDLOAD2_ERROR_LOG $1   &
  fi
}


steps[1]="execSqlplus loadLatestRblRun"
steps[2]="execSqlplus loadCurrentBackOrder"
steps[3]="execSqlplus loadTempNsns"
steps[4]="execSqlplus autoLoadSpareNetworks"
steps[5]="execSqlplus loadAmdBssmSourceTmpAmdDemands"
steps[6]="execSqlplus loadFmsDemands"
steps[7]="execSqlplus loadWarnerRobinsDemands"
steps[8]="execSqlplus loadDepotDemands"
steps[9]="execSqlplus loadSanAntonioDemands"
steps[10]=wait
steps[11]="checkSqlplusErrors 1-9"
steps[12]="execSqlplus loadAmdDemandsTable"
steps[13]="execSqlplus loadGoldInventory"
steps[14]="execSqlplus loadAmdPartLocations"
steps[15]=wait
steps[16]="checkSqlplusErrors 12-14"
steps[17]="execSqlplus loadAmdBaseFromBssmRaw"
steps[18]="execSqlplus updateAmdAllBaseCleaned"
steps[19]="execSqlplus loadAmdReqs"
steps[20]="execSqlplus loadTmpAmdPartFactors"
steps[21]="execSqlplus loadTmpAmdPartLocForecasts_Add"
steps[22]="execSqlplus loadTmpAmdLocPartLeadTime"
steps[23]=wait
steps[24]="checkSqlplusErrors 17-22"
steps[24]=return

THIS_FILE=$(basename $0)
THIS_FILE_NO_EXT=$(echo $THIS_FILE | sed 's/\..\{3\}$//')
STEPS_FILE=$DATA_HOME/${THIS_FILE_NO_EXT}Steps.ksh
if [[ -f $STEPS_FILE ]] ;  then
  # override steps
  print "$CUR_USER is executing script and overriding steps wiht ${STEP_FILE}" 2>&1 
  cat $STEPS_FILE 2>&1 
  . $STEPS_FILE
  print "$CUR_USER is renaming override script $STEPS_FILE to ${STEPS_FILE}.bku" 
  mv $STEPS_FILE ${STEPS_FILE}.bku
fi


if [[ "${AMD_USE_AMDLOAD2_MENU:-N}" == "Y" ]] ; then
  AMD_AMDLOAD2_STEP=1
  export AMD_CUR_STEP=1
  AMDLOAD2_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
  mainMenu 2>&1 | tee -a $AMDLOAD2_LOG 
else
  if (( $# > 0 )) ; then
    execSteps $* 
  else
    main
  fi
fi
wait
checkForErrors
print "$0 ending at " $(date)
