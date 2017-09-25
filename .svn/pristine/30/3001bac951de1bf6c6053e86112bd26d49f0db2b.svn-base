#!/bin/ksh
# vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
#------------------------------------------------------------------------------
# Module    : genBssmFiles.ksh
# Version   : 1.1
# Date      : 18/May/2017
# Author    : Douglas S Elder
#
# Purpose: Create the BSSM flat files used by the BSSM load process
#
#
# Modification history:
#
# Date          Who           Purpose
# ---------     -----------   -------------------------------------------------
# 18/May/17     Douglas Elder added -o data_dir option to override the
#                             default data directory /apps/CRON/AMD/data
# 07/APR/17     Douglas Elder New module
# -----------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------
#

DEBUG=
DBGECHO=
APIDBG=
STEP=
DATA_DIR=

# set up the Oracle environment
. /apps/CRON/AMD/lib/amdenv.ksh
. /apps/CRON/AMD/lib/amdconfig.ksh

stepnum=1
rc=0

# return any non-zero return code
# when any piped command fails
set -o pipefail

function usage
{
  echo >&2 "usage: amd_bssmFlatFiles.ksh -d -h -m -o data_dir -r stepname -s stepnum"
  echo >&2 "  -d turn on debug"
  echo >&2 "  -h this message"
  echo >&2 "  -m show step menu"
  echo >&2 "  -o data_dir the output directory"
  echo >&2 "  -r stepname where stepname a = check_app_files"
  echo >&2 "  -s stepnum to start at"
}


OPTIND=1
while getopts dhmo:r:s: o
do  case "$o" in
  d)  DEBUG=Y 
      DBGECHO=ksh -x
      set -x ;;
  h)  usage
      exit 4;;
  m)  STEP=menu ;;
  o)  DATA_DIR=$OPTARG ;;
  r)  
     case "$OPTARG" in
       a) STEP=check_app_files;;
       d) STEP=check_data_file;;
       [?]) usage
          exit 4 ;;
     esac ;;
  s)  stepnum=$OPTARG ;;
[?])  usage
      exit 1;;
  esac
done
shift $(( $OPTIND - 1))


function check_app_files
{
  rc=0
  for l in ${steps[@]}
  do
	  if [ ! -r "$SRC_HOME/$l" ] ; then
	    echo "$SRC_HOME/$l is not readable"
      rc=4
    fi
  done

  return $rc

}


function main
{
  echo "********************************************************"
  echo "* Start Date & Time: $(date) $0"
  echo "********************************************************"
 
  check_app_files
  rc=$?
  if [ $rc -ne 0 ] ; then
    return $rc
  fi  

  n=0
  for l in ${steps[@]}
  do
    let n=$n+1
    if [ $n -eq $stepnum ] ; then
      echo "executing $SRC_HOME/$l - $(date)"
      sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/$l $DATA_DIR
      rc=$?
      if [ $rc -ne 0 ] ; then
        return $rc
      fi
      let stepnum=$stepnum+1
    fi
  done

  echo -e "##############################################################"
  echo "# Completion of RMADS bssmFlatFiles.ksh - $(date)"
  echo "# Return Code = $rc"
  echo "##############################################################"

  return $rc
 
}

function loadSteps
{
    if [ ! -e $DATA_HOME/bssm_sql.txt ] ; then
      echo $DATA_HOME/bssm_sql.txt not found
      rc=4
      return $rc
    fi

    n=0
    set -A steps
    while IFS= read -r line
    do
      steps[$n]=$line
      let n=$n+1
    done < $DATA_HOME/bssm_sql.txt
    num_steps=$n
}

function displayMenu
{
    if [ ! "$DEBUG"=="Y" ] ; then
      clear
    fi
    cnt=j
    for l in ${steps[@]}
    do
      let cnt=$cnt+1
      echo " $cnt. $l"
    done
    echo " "
}

function menu
{
    displayMenu
    while read stepnum?"Enter stepnum or 0 to exit? " 
    do

      if [ $stepnum -eq 0 ] ; then
        break
      fi

      if [ "$stepnum"=="0" ] ; then
        if ((stepnum <= num_steps))  ; then
          n=$stepnum-1
          echo "executing $SRC_HOME/${steps[$n]}"
          sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/${steps[$n]} $DATA_DIR
          if [ $? -ne 0 ] ; then
            echo "${steps[$n]} failed"
            rc=4
            break
          fi
        fi
      fi
    done
    return $rc
}

if [ "$debug" = "Y" -o "$DEBUG" = "Y" ] ; then
  echo ORACLE_HOME=$ORACLE_HOME
  echo BIN_HOME=$BIN_HOME
  echo TimeStamp=$TimeStamp
  which sqlplus
  which sqlldr
fi


echo "********************************************************";
echo "* Start Date & Time: $(date) $(basename $0)";
echo "********************************************************";

loadSteps
if [ $rc -eq 0 ] ; then
  {
    if [ "$STEP" = "menu" ] ; then
      menu
    elif [ "$STEP" = "check_app_files" ] ; then  
      check_app_files
    elif [ -n "$STEP" ] ; then
      echo "Step $STEP does not exist in this script"
      usage
      rc=4
    else  
      main
    fi
  } 2>&1 | tee -a $LOG_FILE
  rc=$?
  chmod 770 $DATA_HOME/*.TXT
fi

echo "********************************************************";
echo "* End Date & Time: $(date) $(basename $0)";
echo "********************************************************";

exit $rc


