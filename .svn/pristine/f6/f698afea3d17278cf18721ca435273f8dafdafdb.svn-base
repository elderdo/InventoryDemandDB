#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.3  $
#     $Date:   19 Aug 2013
# $Workfile:   execRemoteShell.ksh  $
#
# Rev 1.3 use new Phoenix servers
#
USAGE="usage: ${0##*/} [-h host] [-u user] [-d] the_command
\twhere\n
\t-d\tturns on debug
\t-h host\tconnects to host
\t-u uses\tconnects with user and executes a command
\tthe_command is the name of the remote script to execute."

if [[ "$1" = "?" ]] ; then
	print "$USAGE"
	return 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $SRC_HOME || -z $DB_CONNECTION_STRING ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi


USER=`whoami`
REMOTE_CMD="ssh -l $USER"
HOST=ussevm76.cs.boeing.com

while getopts :dh:u: arguments
do
	case $arguments in
	  h) if [[ "$AMDEVN" = "$OPTARG" ]] ;
	     then
	       print "script not needed - use regular Unix commands"
	       exit
            fi
	    case $OPTARG in
	      dev) HOST=ussemv76.cs.boeing.com ;;
	      it) HOST=ussevm83.cs.boeing.com ;;
	      prod) HOST=ussevm89.cs.boeing.com ;;
	      *) HOST=$OPTARG ;;
	     esac  ;;
	  u) USER=$OPTARG ;;
	  d) debug=Y
	     set -x ;;
	  *) print -u2 "$USAGE"
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

	if [[ "$USER" != "amduser" ]] 
	then
		REMOTE_CMD=ssh
	fi
	REMOTE_CMD=${REMOTE_CMD:-ssh -l $USER}
	print "$0 $@ starting at " `date`

	if [[ -z $1 ]]
	then
		if [[ "$USER" = "amduser" ]]
		then
			THE_COMMAND="su -u escm hostname"
		else
			THE_COMMAND="pwd;ls -al"
		fi
	else
		THE_COMMAND="$1"
	fi
	$REMOTE_CMD $HOST "$THE_COMMAND"

	print "$REMOTE_CMD $HOST $THE_COMMAND ending at " `date`
