#!/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix: 
# edit_load_logs.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.2
#     $Date:   15 Feb 2018
#      Desc:   edit the lasts 6 amd_loader 
#              logs 
# 26 Jan 2017 $Revision:   1.0 Initial Rev
# 31 Jan 2017 $Revision:   1.1 make script more generic
#                          added -p log_pat to specify the 
#                          type of log file to find
#                          added -l log_dir to explicitly
#                          specify the log directory
#                          default the log_pat based on
#                          what app is running: AMD load
#                          or RMAD load
#                          set the directory homes based on
#                          what app is running: AMD or RMAD
#                          Updated usage to reflect these 
#                          changes and fixed usage's file name
#                          to execute
#                          Use find to get the list of possible
#                          log file names to edit
# 15 Feb 2018 $Revision:   1.2 removed obsolete back tic's 
#                          replaced them with $(...)
#
#

if [[ "$debug" == "Y" ]] ; then
  set -x
fi
NUMLOGS=6

function usage {
  echo "edit_loader_logs.ksh [ -d -l log_dir -n numlogs -p log_pat ]"
  echo "where -d turns on debugging"
  echo "      -l log_dir sets the log directory"
  echo "      -n numlogs overrides the default of 6 logs"
  echo "      -p log_pat sets the core name of the log file"
}

# import common definitions
CWD=$(pwd)
if echo "$CWD" | grep -q "AMD" ; then
  . /apps/CRON/AMD/lib/amdconfig.ksh
  BATCH="*amd_loader*"
elif echo "$CWD" | grep -q "RMAD" ; then
  . /apps/CRON/RMAD/config.ksh
  BATCH="*_rmad_load.txt"
fi

while getopts :dhn:p: arguments
do
  case $arguments in
    d) debug=Y
       set -x ;;
    h) usage
       exit 0;;
    l) LOG_HOME=${OPTARG};;
    n) NUMLOGS=${OPTARG};;
    p) BATCH=${OPTARG};;
    *) usage
       exit 4;;
  esac
done
vi $(find $LOG_HOME -name "${BATCH}"  -print | xargs ls -t 2> /dev/null | head -n $NUMLOGS | sort)
