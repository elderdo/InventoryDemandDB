#!/usr/bin/ksh
# vim: set ts=2 sw=2 sts=2 et
#   $Author:   zf297a  $
# $Revision:   1.51  $
#     $Date:   29 Jun 2012 $
# $Workfile:   trimTactics.ksh  $
#
USAGE="usage: trimTactics.ksh [-f forecast] [-o optimization aka strategy] [-t tactics] [-s strategy control]\n
\t[-n] [-d]\n
\t[-i]\n
\t[-c tactics control] [-r restart control] [-h site control home] [-j] [-b bin_dir] [-l log_dir] [-e script to execute] [-x server]\n
\t[-a user] [-v environment] [-w filter_errors_file] [-q] [-z] [-g]\n
\twhere\n
\t-a the user the script runs under (default is escm)\n
\t-b the directory that contains the executable script\n
\t-c the optional tactics control can have these values: default, x, ATR\n
\t\twhere A means the allocation step is executed\n
\t\tT means the transshipmensts step is executed\n
\t\tR means the replenishments step is executed\n
\t\tso ATR means execute allocations, transhipments, and replenishments\n
\t\t(the default is x)\n
\t-d enables debug\n
\t-e the script to execute (default is site_control.sh)\n
\t-f the forecast can have these values: none, complete, or c17complete (default is c17complete)\n
\t-g goto the end of the script i.e. - skip the alerts\n
\t-h the home directory that contains the site control script and log\n
\t-i run a simulation of the script: i.e. execute the St Louis script so it does nothing (same as -z option)\n
\t-j issues JUST error message and don't abort\n
\t-l the directory that contains the log files\n
\t-m email_address list to be notified\n
\t-n send diagnostic messages to stdout and do NOT exit vs sending them to abort and doing an exit\n
\t-o the optimization (aka strategy) can have these values: skip or n, run or y (default is run)\n
\t-t the tactics can have these values: skip or n, run or y (default is run)\n
\t-q set the mode to quiet so that email notification is turned off\n
\t-r the optional restart control can have these values: restart or y, or no_restart or n\n
\t\t(the default value is n)\n
\t-s the optional strategy control can have these values: default or x, fill_rate, or availability\n
\t\t(the default is x)\n
\t-w filename this file would override default sed error filter\n
\t-x the server the script runs on (default gpstl101 (dev), gpstl102 (crp), or gpsstl103 (prd)\n
\t-z run with the do nothing parameters\n"

if [[ "$#" -gt "0" && "$1" = "?" ]] ; then
  print $USAGE
  exit 0
fi

abort() {
  errmsg="`date`: For $SPO_ENV Trimng of Tactics Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  if [[ "${AMD_ERROR_NOTIFICATION:-Y}" = "Y" ]] ; then
    $LIB_HOME/notify.ksh -s "$errmsg on $hostname" \
      -m " $errmsg on $hostname. $1" 
    $LIB_HOME/sendPage.ksh  "$errmsg $1"    
  fi
  if [[ -f ${TRIM_TACTICS_LOCK_FILE} ]] ; then
    rm $TRIM_TACTICS_LOCK_FILE
    print "`date`: $REMOTE_CMD $SPO_SERVER $TACTICS_COMMAND - processing aborted.  " \
            "The lock file $TRIM_TACTICS_LOCK_FILE has been removed" | tee -a $LOG_NAME
  fi
  if [[ "${WARNINGS:-N}" = "N" ]] ; then
    exit 4
  fi
}

doNothing() {
  # have the script do nothing - good for testing
      SPO_FORECAST=none 
  SPO_OPT_AKA_SPO_STRATEGY=n 
  SPO_TACTICS=n 
}

# import common definitions
if [[ -n ${UNVAR:-} ]] ; then
  print "Using UNVAR=$UNVAR"
fi
. ${UNVAR:-}/apps/CRON/AMD/lib/amdconfig.ksh

SPO_SERVER=${SCM_HOST:-}
if [[ -z $SPO_SERVER ]] ; then
  abort "SPO_SERVER/SCM_HOST was not set."
fi

case $DATASYSENV in
  dev) SPO_ENV=dev ;;
  crp) SPO_ENV=crp ;;
  prd) SPO_ENV=prod ;; # the string is different for production
  *) abort "DATASYSENV=$DATASYSENV is not valid.";;
esac

SKIP_ALERTS=N
TRIM_TACTICS_LOCK_FILE=/tmp/trimTactics.lock

SPO_FORECAST=c17complete
SPO_OPT_AKA_SPO_STRATEGY=y # run the optimization step
SPO_TACTICS=y # run the tactics step
SPO_STRATEGY_CNTL=x
SPO_TACTICS_CNTL=x
SPO_RESTART_CNTL=n
NOTIFY_ADDR=douglas.s.elder@boeing.com
SPO_SCRIPT=site_control.sh
REMOTE_CMD="ssh -l amduser"
REMOTE_ERRORS="/tmp/bannerMessages.txt" # this gets rid of the banner which we don't need
rm -f $REMOTE_ERRORS
SPO_USER=escm

if [[ -z ${DateStr:-} ]] ; then
  DateStr=+%Y%m%d%H_%M_%S
fi

if [[ -z ${TimeStamp:-}  ]] ; then
  TimeStamp=`date $DateStr | sed "s/:/_/g"`
else
  # make sure the time stamp starts with YYYYMMDDHH
  # followed by an underscore
  echo "$TimeStamp" | egrep -q "^[0-9]{10}_.*"
  if (($?!=0)) ; then
    # The format was wrong so recreate it
    TimeStamp=`date $DateStr | sed "s/:/_/g"`
  fi
fi

STEP=${AMD_CUR_STEP:-$SUBSTEP}
LOG_NAME="$LOG_HOME/${TimeStamp}_${STEP:+${STEP}_}${XSTEP:+${XSTEP}_}trimTactics.log"


PARENT_SCRIPT=`ps -ef | grep $PPID | sort | head -1 | awk -f $LIB_HOME/findScript.awk` # get parent script
if [[ "$PARENT_SCRIPT" != "ksh" ]] ; then
  PARENT_SCRIPT=`basename $PARENT_SCRIPT` # remove path
  PARENT_SCRIPT=${PARENT_SCRIPT%\.*} # remove file extension
else
  PARENT_SCRIPT=
fi

OVERRIDE_FILE=$DATA_HOME/trimTactics${PARENT_SCRIPT:+_${PARENT_SCRIPT}}.txt

if [[ -f $OVERRIDE_FILE ]] ; then
  print "`date`: For SPO_ENV=$SPO_ENV overriding command line parameters with file $OVERRIDE_FILE" | tee -a $LOG_NAME
  cat $OVERRIDE_FILE | tee -a $LOG_NAME

  args=`awk '{for(i=1;i<=NF;i++) print $i}' $OVERRIDE_FILE`
  set -- $args
  print "`date`: For SPO_ENV=$SPO_ENV renaming override file $OVERRIDE_FILE to ${OVERRIDE_FILE}.bku" | tee -a $LOG_NAME
  mv $OVERRIDE_FILE ${OVERRIDE_FILE}.bku
else
  print "`date`: For SPO_ENV=$SPO_ENV $0 $@" | tee -a $LOG_NAME
fi


THE_CMD=$0
CMD_LINE_ARGS="$@"

while getopts :ijndm:f:o:t:s:c:r:l:b:h:e:x:qzwg: arguments
do
  case $arguments in
    f) case ${OPTARG} in
        none|complete|c17complete) SPO_FORECAST=${OPTARG};;
        *) abort "invalid forecast ${OPTARG} - valid values are none, complete, c17complete" ;;
       esac ;;

    o) case ${OPTARG} in
      skip|n) SPO_OPT_AKA_SPO_STRATEGY=n ;;
      run|y) SPO_OPT_AKA_SPO_STRATEGY=y ;;
    *) abort "invalid optimization ${OPTARG} - valid values are skip or n, run or y" ;;
         esac ;;

    t) case ${OPTARG} in
      skip|n) SPO_TACTICS=n ;;
      run|y) SPO_TACTICS=y ;;
    *) abort "invalid tactics ${OPTARG} - valid values are skip or n, run or y" ;;
         esac ;;

    s) case ${OPTARG} in
      default|x) SPO_STRATEGY_CNTL=x;;
    fill_rate) SPO_STRATEGY_CNTL=FILL_RATE;;
    availability) SPO_STRATEGY_CNTL=AVAILABILITY;;
    *) abort "invalid strategy control ${OPTARG} - valid values are default or x, fill_rate,  or availability";;
         esac ;;

    c) case ${OPTARG} in
      default|x) SPO_TACTICS_CNTL=x;;
    *) SPO_TACTICS_CNTL=
       ll=`expr length ${OPTARG}`
       ((ll=ll+1))
       i=1
       while [[ i -lt ll ]] ;
       do
            ltr=`expr substr ${OPTARG} $i 1 | tr "[a-z]" "[A-Z]"`
      case $ltr in
        A | T | R) SPO_TACTICS_CNTL=${SPO_TACTICS_CNTL:-}$ltr ;;
        *) abort "Invalid tactics control $ltr - valid values are A T or R" ;;
      esac
            ((i=i+1))
       done ;;
         esac ;;
        
    r) case ${OPTARG} in
      restart|y) SPO_RESTART_CNTL=y;;
      no_restart|n) SPO_RESTART_CNTL=n;;
    *) abort "invalid restart control ${OPTARG} - valid values are restart or y, or no_start or n";;
         esac ;;

    m) NOTIFY_ADDR=${OPTARG} ;;

    w) FILTER_ERRORS_FILE=${OPTARG} ;;

    g) SKIP_ALERTS=Y ;;

    
    z)  doNothing ;;

    h) SPO_HOME=${OPTARG} ;;

    j) WARNINGS=Y ;;

    b) SPO_BIN=${OPTARG} ;;

    l) SPO_LOG_DIR=${OPTARG} ;;

    e) SPO_SCRIPT=${OPTARG} ;;

    x) SPO_SERVER=${OPTARG} ;;

    a) SPO_USER=${OPTARG} ;;
    
    n) TRIM_TACTICS_DIAGNOSTIC=N ;;

    i) doNothing ;;
    
    q) export AMD_ERROR_NOTIFICATION=N ;;
    
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

hostname=`uname -n`

# define defaults
SPO_HOME=${SPO_HOME:-/websites/escmapps/control}
SPO_BIN=${SPO_HOME}/${SPO_BIN:-sh/site_control}
SPO_LOG_DIR=${SPO_HOME}/${SPO_LOG_DIR:-log/spo_processing}


warn() {
  errmsg="`date`: Warning 0: For ENV=$SPO_ENV Trimng of Tactics Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  if [[ "${AMD_ERROR_NOTIFICATION:-Y}" = "Y" ]] ; then
    $LIB_HOME/notify.ksh -s "$errmsg on $hostname" \
      -m " $errmsg on $hostname. $1" 
  fi
}


if [[ "$SPO_OPT_AKA_SPO_STRATEGY" = "y" || "$SPO_OPT_AKA_SPO_STRATEGY" = "run" ]] ; then
  SPO_FILE_STRATEGY=strategy
else
  SPO_FILE_STRATEGY=x
fi
if [[ "$SPO_TACTICS" = "y" || "$SPO_TACTICS" = "run"  ]] ; then
  SPO_FILE_TACTICS=tactics
else
  SPO_FILE_TACTICS=x
fi  

SPO_LOG_FILE=c17_${SPO_ENV}_${SPO_FORECAST}_${SPO_FILE_STRATEGY}_${SPO_FILE_TACTICS}.log
TACTICS_LOG_FILE=$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}$SPO_LOG_FILE

TACTICS_COMMAND="sudo -u $SPO_USER $SPO_BIN/$SPO_SCRIPT $SPO_ENV $SPO_FORECAST $SPO_OPT_AKA_SPO_STRATEGY $SPO_TACTICS $SPO_STRATEGY_CNTL $SPO_TACTICS_CNTL $SPO_RESTART_CNTL $NOTIFY_ADDR" 

issueDiagnostic() {
  DIAG_MSG=
  cnt=0
        for txt in "$@"
        do
                DIAG_MSG="$DIAG_MSG $txt"
                ((cnt=cnt+1))
        done
  if [[ "${TRIM_TACTICS_DIAGNOSTIC:-Y}" = N ]] ; then 
    print "$DIAG_MSG"
  else
    abort "$DIAG_MSG"
  fi
}

USER_USER_TYPE_DUMP="$DATA_HOME/UserUserTypeDump.csv"

dumpUserUserType() {

  rm -f $USER_USER_TYPE_DUMP # make sure the previous dump file is gone

  $LIB_HOME/execSqlplus.ksh -s UserUserTypeDump
  RC=$?
  if (($RC!=0)) ; then
    issueDiagnostic "$0 failed for trimTactics at $(date)"
  fi
  return $RC
}

truncateUserUserType() {
  $LIB_HOME/execSqlplus.ksh -s truncateSpoC17v2Table user_user_type
  RC=$?
  if (($RC!=0)) ; then
    issueDiagnostic "$0 failed for trimTactics.ksh at $(date)"
  fi
  return $RC
}

restoreUserUserType() {

  if [[ "$debug" = "Y" \
    && "$SPO_FORECAST" = "none" \
    && "$SPO_OPT_AKA_SPO_STRATEGY" = "n" && "$SPO_TACTICS" = "n" ]] ; then
    print "sleeping for 30 secs"
         sleep 30 # delay for 30 sec's to allow for a user login test
       fi        

  $LIB_HOME/execSqlldr.ksh -s UserUserTypeRestore
  RC=$?
  if (($RC!=0)) ; then
    issueDiagnostic "$0 failed for trimTactics.ksh at $(date)"
  else
    rm -f $USER_USER_TYPE_DUMP
  fi
  return $RC
}

checkLockFile() {
  if [[ "$debug" = "Y" ]] ; then
    debug_notify="ksh -x "
  else
    debug_notify=
  fi
  if [[ -f ${TRIM_TACTICS_LOCK_FILE} ]] ; then
    TRIMTACTICS_WARNING_MESSAGE="trimTactics.ksh is already running, because the lock file ${TRIM_TACTICS_LOCK_FILE} (`ls -al ${TRIM_TACTICS_LOCK_FILE}` was found to exist.  Delete it if there is no trimTactics.ksh script running.  The current process id is $$.  Searching for other processes...: `ps -elf | grep trimTactics.ksh | sed '/grep trimTactics/d'`"
    print "`date`: $TRIMTACTICS_WARNING_MESSAGE" | tee -a $LOG_NAME
    print "$0 ended at `date`" | tee -a $LOG_NAME
    $debug_notify $LIB_HOME/notify.ksh -f "trimTactics.ksh" -a trimTacticsAddr.txt -s "trimTactics.ksh lock file for $SPO_ENV" -m "$TRIMTACTICS_WARNING_MESSAGE"
    return 4
  fi

  # create a lock file
  touch $TRIM_TACTICS_LOCK_FILE

  return 0
}

analyzeTacticsLogFile() {
  # make sure the date in the log file matches with the CMD_END_DATE
  TAIL_OF_FILE=/tmp/tacticsLogFileTail.txt
  tail -5 $TACTICS_LOG_FILE > $TAIL_OF_FILE
  if [[ "$SPO_FORECAST" = "none" ]] ; then
    SEARCH_EXPRESSION="${CMD_END_DATE}"
  else
    if [[ -f $DATA_HOME/post_proc_last_step.txt ]] ; then
      POST_PROC_LAST_STEP=`cat $DATA_HOME/post_proc_last_step.txt`
    else
      POST_PROC_LAST_STEP="end of allert scanner"
    fi
    SEARCH_EXPRESSION="${POST_PROC_LAST_STEP}[ ]*${CMD_END_DATE}" 
  fi
  grep "${SEARCH_EXPRESSION}" $TAIL_OF_FILE
  if (($?==1)) ; then
    issueDiagnostic "$REMOTE_CMD of $TACTICS_COMMAND on server $SPO_SERVER" \
      "with ENV=$SPO_ENV failed for" \
      "tactics_metrics.sql, because the" \
      "regular expression ${SEARCH_EXPRESSION}" \
      "was not found in file $TACTICS_LOG_FILE!" \
      ", which means either the command did not complete" \
      " or the log is from some previous execution.  Either" \
      " way something was not right"
    return 4
  elif (($?==2)) ; then
    issueDiagnostic "For ENV=$SPO_ENV grep syntax error" \
      "for regular expression" \
      "$SEARCH_EXPRESSION or the file" \
      "($TACTICS_LOG_FILE) was inaccessible!"
    return 4
  fi
  FILTER_ERRORS_FILE=${FILTER_ERRORS_FILE:-$DATA_HOME/trimTacticsSedFilter.txt}
  if [[ ! -f $FILTER_ERRORS_FILE ]] ; then

    issueDiagnostic "`date`: aborting $0 because sed script for" \
      "filtering errors," \
      "$FILTER_ERRORS_FILE, does not exist."
    return 4
  fi
  print "`date`: For SPO_ENV=$SPO_ENV using $FILTER_ERRORS_FILE to filter out erroneous errors from $TACTICS_LOG_FILE" | tee -a $LOG_NAME
  sed -f $FILTER_ERRORS_FILE \
  $TACTICS_LOG_FILE > /tmp/tactics.log # filter out these lines of text
  
  $LIB_HOME/checkforerrors.ksh /tmp/tactics.log
  if (($?!=0)) ; then

         issueDiagnostic "`date`: aborting $0 because checkforerrors" \
      "found error text in /tmp/tactics.log"
         return 4
       fi
  if (($REMOTE_SH_1!=0)) ; then
    issueDiagnostic "`date`: Warning 1: $REMOTE_CMD of $TACTICS_COMMAND" \
      "on server $SPO_SERVER with ENV=$SPO_ENV" \
      "failed because the $REMOTE_CMD had a" \
      "non-zero return code of $REMOTE_SH_1." 
    return 4
  fi
  if (($REMOTE_SH_2!=0)) ; then
    issueDiagnostic "`date`: Warning 2: $REMOTE_CMD of" \
      "find $SPO_LOG_DIR on $SPO_SERVER -mtime ${FIND_MTIME}0" \
      "-name ${SPO_LOG_FILE}_old on server $SPO_SERVER" \
      "with ENV=$SPO_ENV failed because the $REMOTE_CMD" \
      "had a non-zero return code of $REMOTE_SH_2." | tee -a $LOG_NAME
    return 4
  fi
  return 0
}

getTrimTacticsLogFile() {
  # get the current day-of-week month and day-of-month from the remote server
  CMD_END_DATE=`$REMOTE_CMD $SPO_SERVER  'date "+%a %b %-1d"' 2>> $REMOTE_ERRORS`
  grep "Remote login for account amduser is not allowed." $REMOTE_ERRORS
  if (($?==0)) ; then
    issueDiagnostic "`date`: aborting $0 because remote login for amduser to $SCM_HOST is not allowed"
    return 4
  fi


  print "`date`: capture log file from the remote server using these commands:" | tee -a $LOG_NAME
  print "$REMOTE_CMD $SPO_SERVER uname -s > /tmp/OS.txt 2>> $REMOTE_ERRORS"
  $REMOTE_CMD $SPO_SERVER uname -s > /tmp/OS.txt 2>> $REMOTE_ERRORS

  REMOTE_OS=`cat /tmp/OS.txt`
  case $REMOTE_OS in
    AIX) FIND_MTIME=+ ;;
    HP-UX) FIND_MTIME= ;;
  esac

  print "`date` $REMOTE_CMD $SPO_SERVER find $SPO_LOG_DIR -mtime -1 " \
    "-name \"${SPO_LOG_FILE}_old\" > /tmp/tacticsLogFile.txt"

  # make sure that there is a log file that has just been updated within the last 24 hrs (-mtime -1)
  $REMOTE_CMD $SPO_SERVER  \
    find $SPO_LOG_DIR -mtime -1 \
    -name "${SPO_LOG_FILE}_old" > /tmp/tacticsLogFile.txt 2>> $REMOTE_ERRORS
  REMOTE_SH_2=$?
  TACTICS_LOG_FILE_NAME=`cat /tmp/tacticsLogFile.txt`
  if (($?==0)) ; then
    if [[ -n $TACTICS_LOG_FILE_NAME ]] ; then
      rm /tmp/tacticsLogFile.txt
      print "`date` $REMOTE_CMD $SPO_SERVER cat $TACTICS_LOG_FILE_NAME > $TACTICS_LOG_FILE"
      $REMOTE_CMD $SPO_SERVER cat $TACTICS_LOG_FILE_NAME > $TACTICS_LOG_FILE 2>> $REMOTE_ERRORS
    else
      issueDiagnostic "Warning: Unable to get the name of the tactics log file name using empty dummy log" 
      touch /tmp/dummy.log
      TACTICS_LOG_FILE=/tmp/dummy.log
    fi
  fi

  return 0
}

tactics() {

  print "$0 started at `date`" | tee -a $LOG_NAME

  print "`date`: Lock file $TRIM_TACTICS_LOCK_FILE created (`ls -al $TRIM_TACTICS_LOCK_FILE`)" | tee -a $LOG_NAME

  print "$THE_CMD $CMD_LINE_ARAGS started at `date`" | tee -a $LOG_NAME


  print "`date`: executing: $REMOTE_CMD $SPO_SERVER $TACTICS_COMMAND" | tee -a $LOG_NAME
  print "$REMOTE_CMD $SPO_SERVER $TACTICS_COMMAND" > /tmp/postProcessCmd.ksh
  chmod 770 /tmp/postProcessCmd.ksh

  # the simulation feature and the -z was added to allow for easier testing 
  # since a regular exec of site_control.sh runs so long
  $REMOTE_CMD $SPO_SERVER  \
    $TACTICS_COMMAND >> $LOG_NAME 2> $REMOTE_ERRORS # redirect stderr to $REMOTE_ERRORS
  REMOTE_SH_1=$?
  print "return code from ssh is $REMOTE_SH_1"

  # does the $REMOTE_ERRORS file exist
  if [[ -f $REMOTE_ERRORS ]] ; then
    # yes, quietly check the file for a password prompt
    grep  -q "Password:" $REMOTE_ERRORS
    # did grep find the text Password:?
    if (($?==0)) ; then
      # yes, grep found the text Password: .. abort the run
      abort "Unable to execute $TACTICS_COMMAND because the St Louis server is requesting a password." 
    fi
    # check for the text "error" (case insensitive) and save the error message
    REMOTE_ERROR_MESSAGE=`grep  -i "error" $REMOTE_ERRORS`
    # did grep find the text?
    if (($?==0)) ; then
      # yes, error was found... abort the run
      abort "Unable to execute $TACTICS_COMMAND because of this error: $REMOTE_ERROR_MESSAGE" 
    fi
  fi

  rm $TRIM_TACTICS_LOCK_FILE
  print "`date`: $REMOTE_CMD $SPO_SERVER $TACTICS_COMMAND - processing completed.  " \
          "The lock file $TRIM_TACTICS_LOCK_FILE has been removed" | tee -a $LOG_NAME

  getTrimTacticsLogFile
  if (($?!=0)) ; then
    return 4
  fi
  
  if [[ -s $TACTICS_LOG_FILE ]] ; then # is the size of the file > zero
    analyzeTacticsLogFile
    if (($?!=0)) ; then
      return 4
    fi
  else
    issueDiagnostic "$REMOTE_CMD of $TACTICS_COMMAND on server $SPO_SERVER" \
            "with ENV=$SPO_ENV did not run, because the size of the log file," \
            "$TACTICS_LOG_FILE, was NOT greater than zero" \
            "($SPO_SERVER may be inaccessible)"
    return 0 # at this time just exit the routine, but do not stop the script
  fi

  sed -n '/.home.escm.orbtrc/!p' $LOG_NAME > /tmp/tactics2.log 
  $LIB_HOME/checkforerrors.ksh /tmp/tactics2.log
  if (($?!=0)) ; then
         issueDiagnostic "`date`: aborting $0 because checkforerrors" \
            "found error text in /tmp/tactics2.log"
         return 4
        fi

  if (($REMOTE_SH_1!=0)) ; then
    issueDiagnostic "`date`: Warning 3: $REMOTE_CMD of" \
      "$TACTICS_COMMAND on server $SPO_SERVER with" \
            "ENV=$SPO_ENV failed because the $REMOTE_CMD" \
            "had a non-zero return code of $REMOTE_SH_1." | tee -a $LOG_NAME
    return 4
  fi
  if (($REMOTE_SH_2!=0)) ; then
    issueDiagnostic "`date`: Warning 4: $REMOTE_CMD of" \
            "find $SPO_LOG_DIR on $SPO_SERVER -mtime ${FIND_MTIME}0" \
            "-name ${SPO_LOG_FILE}_old on server $SPO_SERVER" \
            "with ENV=$SPO_ENV failed because the $REMOTE_CMD" \
            "had a non-zero return code of $REMOTE_SH_2." | tee -a $LOG_NAME
    return 4
  fi
  print "$0 ended at `date`" | tee -a $LOG_NAME
}

prePPHolds() {
  print "$0 started at `date`" | tee -a $LOG_NAME
  $LIB_HOME/execSqlplus.ksh -s $0
  if (($?!=0)) ; then
     abort "$0 failed for $0"
  fi
  print "$0 ended at `date`" | tee -a $LOG_NAME
}

postPPAlerts() {
  print "$0 started at `date`" | tee -a $LOG_NAME
  $LIB_HOME/execSqlplus.ksh -s $0
  if (($?!=0)) ; then
     abort "$0 failed for $0"
  fi
  print "$0 ended at `date`" | tee -a $LOG_NAME
}

postPPHolds() {
  print "$0 started at `date`" | tee -a $LOG_NAME
  $LIB_HOME/execSqlplus.ksh -s $0
  if (($?!=0)) ; then
     abort "$0 failed for $0"
  fi
  print "$0 ended at `date`" | tee -a $LOG_NAME
}


checkLockFile
if (($?!=0)) ; then
  return 4
fi

dumpUserUserType
if (($?==0)) ; then
  truncateUserUserType
fi

if [[ "$SKIP_ALERTS" = "N" ]] ; then
  prePPHolds
fi
tactics # also known as Post Processing ... i.e. PP
RC=$?
if [[ "$RC" = 0 && "$SKIP_ALERTS" = "N" ]] ; then
  postPPHolds
  RC=$?
  if [[ "$RC" = "0" && "$SKIP_ALERTS" = "N" ]] ; then
    postPPAlerts
  fi
fi

if [[ -f "$USER_USER_TYPE_DUMP" ]] ; then
  restoreUserUserType
  if (($?!=0)) ; then
    abort "spoc17v2.user_user_type needs to be restored"
  fi
fi
