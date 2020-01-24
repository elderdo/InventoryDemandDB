#!/bin/ksh
#   vim: ts=2 sw=2 sts=2 et 
#   $Author:   Douglas S. Elder
# $Revision:   1.64
#     $Date:   23 Apr 2016
# $Workfile:   edit_6_load_logs.ksh_  $
#
#

if [[ "$debug" = "Y" ]] ; then
  set -x
fi
TimeStamp=$(date +%Y%m)[1-31]
vi $(ls -t /apps/CRON/AMD/log/${TimeStamp}*amd_loader.log | head -n 6)
#for f in $(ls -t /apps/CRON/AMD/log/${TimeStamp}*amd_loader.log | head -n 6)
#do
#  vi $f
#done
