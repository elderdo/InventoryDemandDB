#!/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix:
# cancelLoad.ksh
# Author: Douglas S. Elder
# Date: 02/15/2018
# Rev: 1.1
# Description: This script cancel
# all future AMD batch load jobs
# until rescheduleLoad.ksh is 
# executed
# Rev 1.0  Date: 12/19/2011
# Rev 1.1  Date: 02/15/2018 replaced obsolete -a with -e
#                           replaced obsolete back tic's with
#                           $(..)
USAGE="usage: ${0##*/} [-o] [-d]
\twhere\n
\t-d enables debug\n"

function abort {
        print -u2 ${1:-"$0 failed"}
        print -u2 $USAGE
        print -u2 "ERROR: $0 aborted"
        print "ERROR: $0 aborted"
        exit ${2:-4}
}

# import common definitions
UNVAR=${UNVAR:-}

if [[ -n $UNVAR && -e $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
  if (( $? > 0 ))
  then
    abort "$UNVAR/apps/CRON/AMD/lib/amdconfig.ksh failed"
  fi
  print "Using $UNVAR for amdconfig"
elif [[ -e /apps/CRON/AMD/lib/amdconfig.ksh ]]
then
  . /apps/CRON/AMD/lib/amdconfig.ksh
  if (( $? > 0 ))
  then
    abort "/apps/CRON/AMD/lib/amdconfig.ksh failed"
  fi
elif [[ -e ./amdconfig.ksh ]]
then
  . ./amdconfig.ksh
  if (( $? > 0 ))
  then
    abort "./amdconfig failed"
  fi
else
  abort "Cannot find amdconfig.ksh"
fi

OPTIND=1
while getopts :d arguments
do
  case $arguments in
    d) debug=Y
       set -x;;
   \?) print "$OPTARG is not a valid switch."
       print "$USAGE"
       exit 4;;
  esac
done
# OPTIND now contains a numnber representing the identity of the first
# nonswitch argument on the command line.  For example, if the first
# nonswitch argume on the command line is positional parameter $<F5>,
# OPTIND hold the number 5.
((positions_occupied_by_switches = OPTIND - 1))
# Use a shift statement to eliminate all switches and switch arguments
# from the set of positional parameters.
shift $positions_occupied_by_switches
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

function main {
  touch /tmp/cancelAMDLoad
  print "The next AMD load has been canceled"
}


export TimeStamp=$(date $DateStr | sed "s/:/_/g")
export LOG=$LOG_HOME/${TimeStamp}_cancelLoad.log

main | tee $LOG
