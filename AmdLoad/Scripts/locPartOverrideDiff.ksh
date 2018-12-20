#!/usr/bin/ksh
# vim: ts=2:sw=2:sts=2:et:autoindent:smartindent:ff=unix:
# locPartOverrideDiff.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.16
#     $Date:   15 Feb 2018 
#
#
# Date                 Who            Purpose
# --------             -------------  --------------------------------------------------
# Rev 1.16  02/15/2018 DSE            use == vs = and replaced back tic's with $(...)
# Rev 1.15  06/13/2016 DSE            used ...Diff.sql
# Rev 1.14  10/29/2013 DSE            removed spo functions
# Rev 1.13                            keep the import log and issue 
#                                     warnings only for locPartOverride zf297a
# 08/09/05             KenShew	      Initial implementation

if (($#>0)) ; then
	if [[ "$1" == "-d" ]] ; then
		set -x
		DEBUG=-d
	fi
fi

if [[ -z ${TimeStamp:-} ]] ; then
	export TimeStamp=$(date +%Y%m%d)
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $DATA_HOME || -z $DB_CONNECTION_STRING_FOR_SPO ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

function abort {
	errmsg="locPartOverrideDiff:"
	print "$errmsg $1"
	print -u2 "$errmsg $1"
	exit 4
}

function cap {
    typeset -u f
    f=${1:0:1}
    printf "%s%s\n" "$f" "${1:1}"
}

function execSqlplus {
	$LIB_HOME/execSqlplus.ksh ${DEBUG:-} $1 $2
	if (($?!=0)) ; then
		abort "$0 failed for $1"
	fi
}


execSqlplus locationPartOverrideDiff 
execSqlplus lpOverrideConsumablesDiff 

chmod 644 $LOG_HOME/WinDiff.log* 
