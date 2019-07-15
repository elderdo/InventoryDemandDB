#!/bin/ksh
# vim:ts=2:w=2:sts=2:et:ai:ff=unix:
# edit_loadInventory_logs.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   30 Jan 2017
#      Desc:   edit the lasts 6 loadInventory 
#              logs 
# 30 Jan 2017 $Revision:   1.0 Initial Rev
# 31 Jan 2017 $Revision:   1.1 use the generic edit_load_logs.ksh
#                          for the primary functionality
#                          Removed unnecessary code: TimeStamp
#                          and invoking env setup script
# 15 Feb 2018 $Revision:   1.2 replaced = with ==
#
#

if [[ "$debug" == "Y" ]] ; then
  set -x
fi
NUMLOGS=6
. /apps/CRON/AMD/lib/amdconfig.ksh

function usage {
  echo "edit_loadInventory_logs.ksh [ -d -n numlogs ]"
  echo "where -d turns on debugging"
  echo "      -n numlogs overrides the default of 6 logs"
}


while getopts :dhn: arguments
do
  case $arguments in
    d) debug=Y
       set -x ;;
    h) usage
       exit 0;;
    n) NUMLOGS=${OPTARG};;
    *) usage
       exit 4;;
  esac
done


$LIB_HOME/edit_load_logs.ksh -p "*loadInventory*.log" -n $NUMLOGS
