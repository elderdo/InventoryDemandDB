#!/bin/ksh
# vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
#------------------------------------------------------------------------------
# Module    : genBssmFiles.ksh
# Version   : 1.1
# Date      : 15/Feb/2018
# Author    : Douglas S Elder
#
# Purpose: Create the BSSM flat files used by the BSSM load process
# using both the old sql and the new Viesws
#
#
# Modification history:
#
#          Date          Who           Purpose
#          ---------     -----------   -------------------------------------------------
# Rev 1.0  23/May/17     Douglas Elder New module
# Rev 1.1  15/Feb/15     Douglas Elder use (( )) and == when doing a numeric compare
# -----------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------
#

DEBUG=
DBGECHO=
APIDBG=
STEP=
DATA_DIR=bssm
SILENT=-s

# set up the Oracle environment
. /apps/CRON/AMD/lib/amdenv.ksh
. /apps/CRON/AMD/lib/amdconfig.ksh
# set up log file
LOG_FILE=$LOG_HOME/$(date +%Y%m%d_%H_%M_%S)_mkbssmff.log

stepnum=1
rc=0

# return any non-zero return code
# when any piped command fails
set -o pipefail

function usage
{
  echo >&2 "usage: mkbssmff.ksh -d -h -m -o data_dir -r stepname -s stepnum -v"
  echo >&2 "  -d turn on debug"
  echo >&2 "  -h this message"
  echo >&2 "  -m show step menu"
  echo >&2 "  -o data_dir the output directory"
  echo >&2 "  -r stepname where stepname a = amd_bssmFlatFiles or genBssmFiles"
  echo >&2 "  -s stepnum to start at"
  echo >&2 "  -v verbose - show sqlplus messages"
}


OPTIND=1
while getopts dhmo:r:s:v o
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
  v)  SILENT= ;;
[?])  usage
      exit 1;;
  esac
done
shift $(( $OPTIND - 1))


function amd_bssmFlatFiles
{
  if [[ "$DEBUG" == "Y" ]] ; then
    set -x
    opt=-d
  else
    opt=
  fi
  echo "********************************************************"
  echo "* Start Date & Time: $(date) $0"
  echo "********************************************************"
  $LIB_HOME/amd_bssmFlatFiles.ksh $opt
  rc=$?
  echo "********************************************************"
  echo "* End Date & Time: $(date) $0"
  echo "********************************************************"
  return $rc
}

function genBssmFiles
{
  if [[ "$DEBUG" == "Y" ]] ; then
     set -x
     opt=-d
  else
    opt=
  fi
  echo "********************************************************"
  echo "* Start Date & Time: $(date) $0"
  echo "********************************************************"
  $LIB_HOME/genBssmFiles.ksh $opt -o $DATA_DIR
  rc=$?
  echo "********************************************************"
  echo "* End Date & Time: $(date) $0"
  echo "********************************************************"
  return $rc
}

function checkAppFiles
{
  if [[ -e $LIB_HOME/amd_bssmFlatFiles.ksh ]] ; then
    if [[ ! -r $LIB_HOME/amd_bssmFlatFiles.ksh ]] ; then
      echo $LIB_HOME/amd_bssmFlatFiles.ksh is not readable
      ls -al $LIB_HOME/amd_bssmFlatFiles.ksh is not readable
      rc=4
    fi
  else
    echo $LIB_HOME/amd_bssmFlatFiles.ksh does not exist
    rc=4
  fi
  if [[ -e $LIB_HOME/genBssmFiles.ksh ]] ; then
    if [[ ! -r $LIB_HOME/genBssmFiles.ksh ]] ; then
      echo $LIB_HOME/genBssmFiles.ksh is not readable
      ls -al $LIB_HOME/genBssmFiles.ksh is not readable
      rc=4
    fi
  else
    echo $LIB_HOME/genBssmFiles.ksh does not exist
    rc=4
  fi
  if [[ -e $LIB_HOME/compare.ksh ]] ; then
    if [[ ! -r $LIB_HOME/compare.ksh ]] ; then
      echo $LIB_HOME/compare.ksh not readable
      ls -al $LIB_HOME/compare.ksh not readable
      rc=4
    fi
  else
    echo $LIB_HOME/compare.ksh not exist
    rc=4
  fi
  return $rc
}

function compare
{
  if [[ "$DEBUG" == "Y" ]] ; then
    set -x
    opt=-d
  else
    opt=
  fi
  echo "********************************************************"
  echo "* Start Date & Time: $(date) $0"
  echo "********************************************************"
  $LIB_HOME/compare.ksh $opt  
  rc=$?
  echo "********************************************************"
  echo "* End Date & Time: $(date) $0"
  echo "********************************************************"
  return $rc
}

function main
{
  [[ "$DEBUG" == "Y" ]] && set -x
  echo "********************************************************"
  echo "* Start Date & Time: $(date) $0"
  echo "********************************************************"
 
  rc=$?
  # get rid of previous files
    if [ $stepnum -eq 1 ] ; then
      amd_bssmFlatFiles
      rc=$?
      if [ $rc -eq 0 ] ; then
        let stepnum+=1
      fi
    fi
    if [[ ((stepnum==2)) && ((rc==0)) ]] ; then
      genBssmFiles
      rc=$?
      if [ $rc -eq 0 ] ; then
        let stepnum+=1
      fi
    fi
    if [[ ((stepnum==3)) && ((rc==0)) ]]  ; then
      compare
      rc=$?
      if [ $rc -eq 0 ] ; then
        let stepnum+=1
      fi
    fi

  echo -e "##############################################################"
  echo "# Completion of RMADS mkbssmff.ksh - $(date)"
  echo "# Return Code = $rc"
  echo "##############################################################"

  return $rc
 
}

function displayMenu
{
  echo " 1. amd_bssmFlatFiles"
  echo " 2. genBssmFiles"
  echo " 3. compare"
  return 0
}

function menu
{
  displayMenu
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

{
  checkAppFiles

  if [[ ((rc==0)) ]] ; then
    if [ "$STEP" = "menu" ] ; then
      menu
    elif [ "$STEP" = "genBssmFiles" ] ; then  
      genBssmFiles
    elif [ "$STEP" = "amd_bssmFlatFiles" ] ; then  
      amd_bssmFlatFilesgenBssmFiles
    elif [ -n "$STEP" ] ; then
      echo "Step $STEP does not exist in this script"
      usage
      rc=4
    else  
      main
    fi
  fi

} 2>&1 | tee -a $LOG_FILE
rc=$?

echo "********************************************************";
echo "* End Date & Time: $(date) $(basename $0)";
echo "********************************************************";

exit $rc
