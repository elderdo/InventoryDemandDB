#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   13 Sep 2010 18:28  $
# $Workfile:   debugRemoteScript.ksh  $
#
USAGE="usage: ${0##*/} [-n] [-r] [-d] scriptName
\twhere
\t\t-d\tturns on debug
\t\t-r\tuse remsch when testing (default is ssh)
\t\t-n\tdon't use ksh -x when executing the script
\tscriptName is the script or command line to execute"

if [[ $# > 0 && $1 = "?" ]]
then
	print "$USAGE"
	exit 0
fi

# import common definitions
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh


while getopts :nr arguments
do
	case $arguments in
	  d) debug=Y
	     set -x
	  n) debug=N;;
	  r) USE_REMSCH=N;;
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

export TimeStamp=`date $DateStr`;



function execRemoteShell
{
	if [[ -z $1 ]]
	then
		print -u2 "Error: no script or command specified for remote shell"
		print -u2 "$USAGE"
		return 4
	else
		THE_COMMAND="$*"
	fi
	curUser=`whoami`
	if [ "$curUser" != "amduser" ]
	then
		print -u2 "Error: User $curUser cannot do a remote shell to $SCM_HOST, you must be user amduser" 
		return 4
	fi

	EXECREMOTE_ARGS=
	if [[ "${USE_RESMSH:-}" = "Y" ]] ; then
		EXECREMOTE_ARGS="-r"
	fi
	if [[ "${debug:-N}" = "Y" ]] ; then
		EXECREMOTE_ARGS="$EXECUTEREMOTE_ARGS -d"
		shellCmd="ksh -x"
	else
		shellCmd=
	fi

	$LIB_HOME/execRemoteShell.ksh $EXECREMOTE_ARGS "$shellCmd $THE_COMMAND"
	RC=$?
	print "execRemoteShell.ksh RC=$RC"
}

if [[ -n $UNVAR ]] ; then
	print "Warning: Your Unix variable is UNVAR=$UNVAR"
fi

if (($#>=1)) ; then
	execRemoteShell "$*"
else
	print -u2 "You must specify a remote script to execute"
	print -u2 "$USAGE"
	exit 4
fi
