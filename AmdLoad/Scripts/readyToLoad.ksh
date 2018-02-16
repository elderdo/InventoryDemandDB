#!/bin/sh
# vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
#------------------------------------------------------------------------------
# Module    : readyToLoad.sh
# Version   : 1.0
# Date      : 22/Nov/2016
# Author    : Douglas Elder
#
# Purpose: Check to see if an Oracle account is ready 
# to be used in a batch load process
#
#
# Modification history:
#
# Date      Rev     Who           Purpose
# ---------         -----------   ----------------------------------------------------
# 20/Nov/16 1.0     Douglas Elder Initial Revision
# 15/Feb/18 1.1     Douglas Elder removed obsolete back tic's and use (( )) for
#                                         numeric tests


if [ "${debug:-}" == "Y" ] ; then
  set -x
  DEBUG=Y
else
  DEBUG=
fi

STEP=
stepnum=1
MAIL=Y
rc=0
HOME=/apps/CRON/AMD
LOG_HOME=$HOME/log
ADDR_FILE=$HOME/data/ready_addresses.txt
TimeStamp=$(date +%Y%m%d%H_%M_%S)
LOG_FILE=$LOG_HOME/${TimeStamp}_readyToLoad.log

# return any non-zero return code
# when any piped command fails
set -o pipefail

function usage 
{
  echo >&2 "usage: $0 -d -h -n -o logfilex"
  echo >&2 "  -d turn on debug"
  echo >&2 "  -h print this message"
  echo >&2 "  -n do NOT send email"
  echo >&2 "  -o logfile"
}

# set default email recipients
RECIPIENTS=
if [[ -e $ADDR_FILE ]]
then
  { while read myline; do
      # skip lines starting with #
      [[ $myline == \#* ]] && continue
      if [[ -z $RECIPIENTS ]] 
      then
        RECIPIENTS="$myline"
      else
        RECIPIENTS="$RECIPIENTS,$myline"
      fi
   done } < $ADDR_FILE
else
  RECIPIENTS=douglas.s.elder@boeing.com
fi


while getopts dehno: o
do  case "$o" in
  d)  DEBUG=Y 
      set -x ;;
  h)  usage
      exit 4;;
  n)  MAIL=N ;;
  o)  LOG_FILE=$OPTARG ;;
[?])  usage
      exit 1;;
  esac
done
shift $(( $OPTIND - 1))


function verifyPassword
{
  
  if [ "$DEBUG" == "Y" ] ; then
    set -x
  fi

  if [ -f /tmp/${TimeStamp}.log ] ; then
    rm -f /tmp/${TimeStamp}.log
  fi
  . $HOME/lib/DB_CONNECTION_STRING
  if [[ -z $DB_CONNECTION_STRING ]] ; then
    echo "Unable to set DB Connection String"
    return 1
  fi
  sqlplus /nolog <<END > /tmp/${TimeStamp}.log
  connect $DB_CONNECTION_STRING
  quit
END

  if [ "$TEST1" == "Y" ] ; then
    echo "ORA-00988" >> /tmp/${TimeStamp}.log
  fi
  if [ "$TEST2" == "Y" ] ; then
    echo "ORA-28001" >> /tmp/${TimeStamp}.log
  fi
  if [ "$TEST3" == "Y" ] ; then
    echo "ORA-28002" >> /tmp/${TimeStamp}.log
  fi
  if [ "$TEST4" == "Y" ] ; then
    echo "ORA-28011" >> /tmp/${TimeStamp}.log
  fi

  # if grep find a matching string it returns 0
  grep -i "ORA-[0-9][0-9]*" /tmp/${TimeStamp}.log
  rc=$?
  if ((rc==0)) ; then
    cat /tmp/${TimeStamp}.log
  fi
  rm /tmp/${TimeStamp}.log

  case $rc in
    0) return 1;; # a line matched one of the patterns

    1) return 0;; # no lines matched the pattern

    [?}) echo "grep for ORA- errors had some kind of error"
         return $? ;;
  esac
}

function main 
{
  verifyPassword
  rc=$?
  return $rc
}

{
  main
  rc=$?
  if [ $rc -ne 0 ]
  then
    if [ "$MAIL" == "Y" ] 
    then
      echo -e "From: AMD readyToLoad.sh\nSubject: AMD load is NOT ready to run - expired or invalid password.\nTo: ${RECIPIENTS}" | more $LOG_FILE | sed '/^~/s/~//' | sendmail -t
    fi
  fi
  chmod 777 $LOG_FILE
  exit $rc 
} 2>&1 | tee -a $LOG_FILE
rc=$?
# get rid of the log file since it has been emailed
rm $LOG_FILE
exit $rc

