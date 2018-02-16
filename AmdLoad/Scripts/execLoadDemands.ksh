#!/usr/bin/ksh
# vim:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab:
# execLoadDemands.ksh
# Author: Douglas S. Elder
# Date: 10/03/2017
# Desc: load the amd demands
# Rev 1.0 7/12/2013
# Rev 2.0 8/02/2017
# Rev 3.0 10/03/2017 fixed loadDemands to do
#                    loadSanAntonioDemands
#                    and loadWarnerRobinsDemands
#                    use -f option as the 2nd argument for
#                    execSqlplus so that the step will execute
#                    in the foreground
#                    Run the truncateDemands step in the foreground
#                    so it completes before the other steps start
#                    Run the loadAmdBssmSourceTmpAmdDemands step in the foreground
#                    so its truncate completes before the other steps run
# Rev 3.1 12/192017  removed loadSanAntonioDemands per TFS 48244


USAGE="Usage: ${0##*/}  [-d -f -m]\n\n
\twhere\n
\t-d enables debug\n
\t-f run sqlplus in foreground (default is background)\n
\t-m display menu and select steps\n"
# setup the env
set -o pipefail

CHECK4ERROROPT=

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

# get command line options
while getopts :dfmo arguments
do
  case $arguments in
    d) debug=Y
       export debug
       set -x ;;

    f) FOREGROUND=Y ;;
    m) USE_MENU=Y ;;

    o) AMD_ERROR_NOTIFICATION=N
       export AMD_ERROR_NOTIFICATION
       CHECK4ERROROPT=-n ;;

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

print "$0 started at " $(date)
thisFile=${0##*/}

abort() {
  errmsg="AmdLoad2.ksh Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  exit 4
}

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
  export TimeStamp=$(print "$TimeStamp" | sed "s/:/_/g")
fi

DEMAND_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log


function checkForErrors {
  if [[ -e $DEMAND_LOG ]] ; then
    $LIB_HOME/checkforerrors.ksh ${CHECK4ERROROPT:-} $DEMAND_LOG
    if (($?!=0)) ; then
      exit 4
    fi
  fi
}

function execSqlplus {

  if [[ "${FOREGROUND:-N}" == "Y" || "$2" == "-f" ]] ; then
    print "$0.ksh $1 started at $(date)"
    $LIB_HOME/execSqlplus.ksh -e $DEMAND_LOG $1
    RC=$?
    print "$0.ksh $1 ended at $(date)"
    if ((RC!=0)) ; then
      abort "$0 failed for $1"
    fi
  else
    print "$0.ksh $1 started in background at $(date)"
    $LIB_HOME/execSqlplus.ksh $1   &
  fi

}

function processL67_File
{
   $LIB_HOME/amd_LoadFtpFile.ksh L67 >$DEMAND_LOG 2>&1
   RC=$?
   $LIB_HOME/checkforerrors.ksh $DEMAND_LOG
   if (($?!=0 || RC!=0)) ; then
     print "Warning: $0 ended without a return code of zero"
   fi
}



function loadDemands {
  execSqlplus loadAmdBssmSourceTmpAmdDemands -f
  execSqlplus loadFmsDemands
  execSqlplus loadBascUkDemands
  execSqlplus loadWarnerRobinsDemands
  wait
  execSqlplus loadAmdDemandsTable
  echo -e  \
"\tloadAmdBssmSourceTmpAmdDemands\n
\tloadFmsDemands\n
\tloadBascUKDemands\n
\tloadWarnerRobinsDemands\n
\tloadAmdDemandsTable all ended at $(date)\n"
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
      if [[ "$AMD_LOAD_DEMANDS_STEP" == "1" ]] ; then
        AMD_CUR_STEP=$(printf "%02d" $x)
      fi
      if [[ "${steps[$x]}" == "return" || "${steps[$x]}" == "exit" ]] ; then
        AMD_EXIT=Y
        return
      else
        ${steps[$x]} 
      fi
    done

}

# prompt with menu
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

# run all the steps
function main
{
	echo "main started at $(date)" 
	execSteps 1-${#steps[*]}
	echo "main ended at $(date)" 
}



steps[1]="execSqlplus truncateDemands -f"
steps[2]="processL67_File"
steps[3]="loadDemands"
steps[4]="checkForErrors"
steps[5]="return"



if [[ "${USE_MENU:-N}" == "Y" ]] ; then
  AMD_LOAD_DEMANDS_STEP=1
  DEMAND_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
  mainMenu 2>&1 | tee -a $DEMAND_LOG 
else
  if (( $# > 0 )) ; then
    execSteps $* 
  else
    main
  fi
fi

print "$0 ending at " $(date)
