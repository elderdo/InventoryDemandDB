#!/usr/bin/ksh
# vim: ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.15
#     $Date:   16 Jan 2014 
# $Workfile:   locPartOverrideDiff.ksh  $
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# Rev 1.15  DSE            removed test of DB_CONNECTION_STRING_FOR_SPO
# Rev 1.14  DSE            removed spo functions
# Rev 1.13  keep the import log and issue warnings only for locPartOverride zf297a
# 08/09/05  KenShew	   Initial implementation

if (($#>0)) ; then
	if [[ "$1" = "-d" ]] ; then
		set -x
		DEBUG=-d
	fi
fi

if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=`date +%Y%m%d`
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $DATA_HOME ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

function abort {
	errmsg="locPartOverrideDiff:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}


function execJavaApp {
	$LIB_HOME/execJavaApp.ksh ${DEBUG:-} $1 $2
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}


execJavaApp LocationPartOverride 
execJavaApp LPOverrideConsumables 

chmod 644 $LOG_HOME/WinDiff.log* 
