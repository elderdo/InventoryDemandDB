#!/usr/bin/ksh
# vim: set ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.01 
#     $Date:   01 Nov 2013
# $Workfile:   sendSpoData.ksh

USAGE="Usage: ${0##*/}  [-m] [-o] [-f] [-d]  [startStep endStep ]\n\n
\twhere\n
\t-m will enable a selection menu\n
\t-o turn off notification via email\n
\t-f run all sqlplus steps in the foreground (default is background)\n
\t-d enables debug\n"

if [[ "$#" -gt "0" && "$1" = "?" ]] ; then
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

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :mndfo arguments
do
  case $arguments in
    m) MENU=Y;;
    o) export AMD_ERROR_NOTIFICATION=N;;
    f) FOREGROUND=Y;;
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
      ((x=x)) # make sure x is a number without leading zeros

      export SUBSTEP=`printf "%02d" $x`
      case ${steps[$x]} in
        "return" | "exit")
          EXIT=Y
          return ;;
        "sendToSpo")
          ${steps[$x]} & ;;
        *)
 	  print "${steps[$x]} started at `date`"
          ${steps[$x]} 
 	  print "${steps[$x]} ended at `date`" ;;
       esac

    done
}

sendSpoUser() {
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:-$SUBSTEP}_${0}.log"
  $LIB_HOME/sendToSpo.ksh SpoUser > $LOG_NAME 2>&1
  if (($?!=0)) ; then
    print "$0 failed for SpoUser at step $SUBSTEP ( ${AMD_CUR_STEP:-$THIS_FILE} )"
  fi
  $LIB_HOME/sendToSpo.ksh UserUserType >> $LOG_NAME 2>&1
  if (($?!=0)) ; then
    print "$0 failed for UserUser at step $SUBSTEP ( ${AMD_CUR_STEP:-$THIS_FILE} )"
  fi
  $LIB_HOME/execSqlplus.ksh checkUserTypes >> $LOG_NMAE 2>&1
  if (($?!=0)) ; then
    print "$0 failed for checkUserTypes at step $SUBSTEP ( ${AMD_CUR_STEP:-$THIS_FILE} )"
  fi
}



sendSpoParts()
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:-$SUBSTEP}_${0}.log"

  $LIB_HOME/sendSpoParts.ksh ${debug:+-d} > $LOG_NAME 2>&1
  RC=$?
  $LIB_HOME/checkforerrors.ksh -n $LOG_NAME
    if (($?!=0 || $RC!=0)) ; then
      #abort "$0 error."
      print "$0 error."
    fi
}


function sendToSpo {

  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:-$SUBSTEP}_${0}.log"
  if [[ "$1" = "-k" ]] ; then
    KEEP_IMP_ERR=-k
    shift
  fi
  if [[ "${FOREGROUND:-N}" = "Y" ]] then
    $LIB_HOME/sendToSpo.ksh ${KEEP_IMP_ERR:-} $1 > $LOG_NAME 2>&1
    if (($?!=0)) ; then
      #abort "$0 failed for $1"
      print "$0 failed for $1"
    fi
  else
    $LIB_HOME/sendToSpo.ksh ${KEEP_IMP_ERR:-} $1 > $LOG_NAME 2>&1
  fi

  # determine import error log 
  SPO_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:-$SUBSTEP}_${1}ImportErrors.log
  if [[ -f $SPO_ERROR_LOG && -s $SPO_ERROR_LOG ]] ; then
    $LIB_HOME/scanForMissingLocations.ksh $1 $SPO_ERROR_LOG 
  fi

}

trimmedPostProcessing()
{
  LOG_NAME="$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:-$SUBSTEP}_${0}.log"
  $LIB_HOME/trimTactics.ksh -j -f c17complete -o run -t run > $LOG_NAME 2>&1
  if (($?!=0)) ; then
      hostname=`hostname -s`
      MSG="AMD trimTactics.ksh failed on $AMDENV@$hostname for the AMD load at step $SUBSTEP ( ${AMD_CUR_STEP:-$THIS_FILE} )"
      $LIB_HOME/execSqlplus.ksh sendWarningMsg \
        "$MSG step $0${AMD_CUR_STEP:+ / AMD_STEP=$AMD_CUR_STEP}."
  fi 
}


function checkForErrors {
  if [[ -a $SPO_ERROR_LOG ]] ; then
    if [[ ${AMD_ERROR_NOTIFICATION:-Y} = "N" ]] ; then
      CHECK4ERROROPT=-n
    fi                        
    rm /tmp/sendSpoData.log
    cat $SPO_ERROR_LOG | sed -f $DATA_HOME/filterSpoImportErrors.txt > /tmp/sendSpoData.log
    $LIB_HOME/checkforerrors.ksh ${CHECK4ERROROPT:-} /tmp/sendSpoData.log
    if (($?!=0)) ; then
      exit 4
    fi
  fi
}

function mainMenu {
  PS3="select n or n-n (range) ..... for multiple steps [hit return to re-display menu]? "

  select item in "${steps[@]}"
  do
    set  $REPLY
    execSteps $*
    if [[ "${EXIT:-N}" = "Y" ]] ; then
      return
    fi
  done
}

function main
{
  echo "main started at `date`" 
  execSteps 1-${#steps[*]}
  echo "main ended at `date`" 
    
}


function execSqlplus {
  if [[ "${FOREGROUND:-N}" = "Y" ]] then
    print "$0.ksh $1 started at `date`"
    $LIB_HOME/execSqlplus.ksh -e $SPO_ERROR_LOG $1  
    RC=$?
    print "$0.ksh $1 ended at `date`"
    if (($RC!=0)) ; then
      abort "$0 failed for $1"
    fi
  else
    print "$0.ksh $1 started in background at `date`"
    $LIB_HOME/execSqlplus.ksh -e $SPO_ERROR_LOG $1   &
  fi
}

function invSpoData {
    print "$0.ksh started at `date`"
    $LIB_HOME/$0.ksh
    RC=$?
    print "$0.ksh ended at `date`"
    if (($RC!=0)) ; then
      abort "$0.ksh failed"
    fi
}

function sendSpoDmndFrcst {
	$LIB_HOME/sendToSpo.ksh ${DEBUG:-} -f Dummy LpDemandForecast
	if (($?!=0)) ; then
		#abort "$0 failed"
		print "$0 failed"
	fi
}

function sendLpOverride {
		$LIB_HOME/sendToSpo.ksh ${DEBUG:-} -w -k LpOverride
		$LIB_HOME/scanForMissingLocations.ksh ${DEBUG:-} LpOverride $LOG_HOME/${TimeStamp}_LpOverrideImportErrors.log

}

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
  export TimeStamp=`print "$TimeStamp" | sed "s/:/_/g"`
fi

print "$0 started at " `date`
thisFile=${0##*/}

SPO_ERROR_LOG=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${thisFile%\.*}Errors.log


steps[1]="sendSpoUser"
steps[2]="sendSpoParts"
steps[3]="sendToSpo -k LpDemand"
steps[4]="invSpoData"
steps[5]="sendToSpo -k LpAttribute"
steps[6]="sendSpoDmndFrcst"
steps[7]="sendLpOverride"
steps[8]="trimmedPostProcessing"
steps[9]=return

THIS_FILE=`basename $0`
THIS_FILE_NO_EXT=`echo $THIS_FILE | sed 's/\..\{3\}$//'`


if [[ "${MENU:-N}" = "Y" ]] ; then
  SENDSPODATA_LOG=$LOG_HOME/${TimeStamp}_99_${thisFile%\.*}.log
  mainMenu 2>&1 | tee -a $SENDSPODATA_LOG 
else
  if (( $# > 0 )) ; then
    execSteps $* 
  else
    main
  fi
fi
wait
checkForErrors
print "$0 ending at " `date`
