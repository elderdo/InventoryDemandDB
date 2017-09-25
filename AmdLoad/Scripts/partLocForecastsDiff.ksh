#!/usr/bin/ksh
# vim: ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.7
#     $Date:   20 Jun 2016
#
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew    Initial implementation
# 10/02/13  Douglas Elder  1.4 ignore spo import errors until Spo 8 conversion
# 10/02/13  Douglas Elder  1.5 removed all spo functions
# 06/13/16  Douglas Elder  1.6 use ...Diff.sql
# 06/20/16  Douglas Elder  1.7 added function to abort and check DEBUG env var
#                          so set -x can be done for the function


if (($#>0)) ; then
  if [[ "$1" = "-d" ]] ; then
    set -x
    DEBUG=-d  
  fi
fi

function abort {
  
  if [[ "$DEBUG" = "-d" ]] ; then
    set -x
  fi
  errmsg="AMD Load Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  exit 4
}

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execJavaApp.ksh ${DEBUG:-} PartLocForecasts
$LIB_HOME/execSqlplus.ksh ${DEBUG:-} partLocForecastsDiff
if (($?!=0)) ; then
  abort "partLocForecastsDiff failed"
fi
