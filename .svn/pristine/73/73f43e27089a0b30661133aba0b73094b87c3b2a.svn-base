#!/usr/bin/ksh
# vim: ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.5  $
#     $Date:   29 Oct 2013
# $Workfile:   partLocForecastsDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 08/09/05  KenShew    Initial implementation
# 10/02/13  Douglas Elder  ignore spo import errors until Spo 8 conversion
# 10/02/13  Douglas Elder  removed all spo functions


if (($#>0)) ; then
  if [[ "$1" = "-d" ]] ; then
    set -x
    DEBUG=-d  
  fi
fi

function abort {
  errmsg="AMD Load Failed"
  print "$errmsg $1"
  print -u2 "$errmsg $1"
  exit 4
}

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

$LIB_HOME/execJavaApp.ksh ${DEBUG:-} PartLocForecasts
if (($?!=0)) ; then
  abort "PartLocForecasts failed"
fi


