#!/usr/bin/ksh
# vim: ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   1.16
#     $Date:   22 Jun 2016 
#
#
# Date                 Who            Purpose
# --------             -------------  --------------------------------------------------
# Rev 1.16  06/22/2016 DSE            removed all Java references
# Rev 1.15  06/13/2016 DSE            used ...Diff.sql
# Rev 1.14  10/29/2013 DSE            removed spo functions
# Rev 1.13                            keep the import log and issue 
#                                     warnings only for locPartOverride zf297a
# 08/09/05             KenShew	      Initial implementation

THIS=$(basename $0)
APP=$(echo $THIS | cut -d. -f1)
HOME=/apps/CRON/AMD
DATA=$HOME/data
DEBUG_FILE=$DATA/debug.txt

if [[ -f $DEBUG_FILE ]] ; then
  DEBUG=$(cat $DEBUG_FILE)
else
  DEBUG=N
fi
[[ "$DEBUG" == "Y" ]] && set -x
STEP=1
function menu {
  >&2 echo "1.  execSqlplus locationPartOverrideDiff"
  >&2 echo "2.  execSqlplus lpOverrideConsumablesDiff"
}

function usage {
  >&2 echo "$THIS [ -d -m -s step ]"
  >&2 echo "where optional -d turns on debug"
  >&2 echo "      optional -m displays the menu of steps"
  >&2 echo "      optional -s step and step can"
  >&2 echo "      be 1 or 2 will start the"
  >&2 echo "      step"
}

while getopts "dms:" opt ; do
  case "$opt" in
    d) DEBUG=Y;set -x;;
    s) STEP=$OPTARG
       case "$STEP" in
         1|2) :;;
           *) usage;exit 4;;
       esac;;
    *) usage;exit 4;; 
  esac
done
shift $((OPTIND-1))

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
}

function cap {
    typeset -u f
    f=${1:0:1}
    printf "%s%s\n" "$f" "${1:1}"
}

function execJavaApp {
  [[ "$DEBUG" == "Y" ]] && set -x
  # capitalize the first char of $1
  JAVACLASS=$(cap $1)
  # remove Diff
  JAVACLASS=$(echo $JAVACLASS | sed 's/....$//')
	$LIB_HOME/execJavaApp.ksh $JAVACLASS
}


function execSqlplus {
  [[ "$DEBUG" == "Y" ]] && set -x
  typeset RC=0
  typeset OPT=
  [[ "$DEBUG" == "Y" ]] && OPT=-d
	$LIB_HOME/execSqlplus.ksh $OPT $1 $2
  RC=$?
	if ((RC!=0)) ; then
		abort "$0 failed for $1"
	fi
  return $RC
}

function main {
  typeset RC=0
  if ((STEP==1)) ; then
    execSqlplus locationPartOverrideDiff 
    RC=$?
  fi
  ((RC==0)) && ((STEP++))
  if ((RC==0)) && ((STEP==2)) ; then
    execSqlplus lpOverrideConsumablesDiff 
    RC=$?
  fi
  return $RC
}
 
main
exit $?
