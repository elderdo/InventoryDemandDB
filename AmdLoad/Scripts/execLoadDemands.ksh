#!/usr/bin/ksh
# execLoadDemands.ksh
# Author: Douglas S. Elder
# Date: 10/17/2017
# Desc: load the amd demands
# Rev 1.0 7/12/2013 init rev
# Rev 1.1 5/15/2017 used a command file for amd_loader.ksh to execute the steps by name
#                   and a steps_file for AmdLoad2.ksh  to execute the steps by name
#                   scanned with ksh -n and eliminated all obsolete code
# Rev 1.2 10/17/2017 specifiy the exact steps to run to load the amd_demands table
#                    eliminated checkforerrors since each sqlplus step is checked
#                    and the script is aborted if any step fails
#                    exec the L67 script used by the main_amd_loader
#                    make sure a log is generated


USAGE="Usage: ${0##*/}  [-d -m]\n\n
\twhere\n
\t-d enables debug\n
\t-m display menu and select steps\n"
# setup the env

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
while getopts :dmo arguments
do
  case $arguments in
    d) debug=Y
       export debug
       set -x ;;

    m) USE_MENU=Y ;;

    o) AMD_ERROR_NOTIFICATION=N
       export AMD_ERROR_NOTIFICATION ;;

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

function abort {
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

function execSqlplus {
    print "$0.ksh $1 started at $(date)"
    $LIB_HOME/execSqlplus.ksh -e $DEMAND_LOG $1  
    RC=$?
    print "$0.ksh $1 ended at $(date)"
    if ((RC!=0)) ; then
      abort "$0 failed for $1"
    fi
    print "$0.ksh $1 ended at $(date)"
}

function processL67_File {
  print "processL67_File started at $(date)"
  $LIB_HOME/amd_LoadFtpFile.ksh L67 >$DEMAND_LOG 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh $DEMAND_LOG
  if (($?!=0 || RC!=0)) ; then
    print "Warning processL67_File without a return code of zero"
  fi
  print "processL67_File ended at $(date)"
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



steps[1]="execSqlplus truncateDemands"
steps[2]="processL67_File"
steps[3]="execSqlplus loadAmdBssmSourceTmpAmdDemands"
steps[4]="execSqlplus loadFmsDemands"
steps[5]="execSqlplus loadBascUkDemands"
steps[6]="execSqlplus loadAmdDemandsTable"
steps[7]="return"



DEMAND_LOG=$LOG_HOME/${TimeStamp}_${thisFile%\.*}.log

if [[ "${USE_MENU:-N}" == "Y" ]] ; then
  AMD_LOAD_DEMANDS_STEP=1
  mainMenu 2>&1 | tee -a $DEMAND_LOG 
else
  if (( $# > 0 )) ; then
    execSteps $* > $DEMAND_LOG
  else
    main > $DEMAND_LOG
  fi
fi

print "$0 ending at " $(date)
