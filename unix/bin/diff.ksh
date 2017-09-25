#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   10 Jan 2008 11:02:22  $
# $Workfile:   diff.ksh  $
#
#

USAGE="diff.ksh [-n] [-i inifile ] [ -m memmory ] java_class\n\t where -n means do not use an ini file at all\n\t-i inifile the ini file must be in the lib directory\n\t-m memory where memmory can be 1024, 2048, ...\n\tjava_class is any java diff application class name"


# command line arguments take priority over amdconfig.ksh files
while getopts ni:m: arguments
do
	case $arguments in
	  n) USE_INI=N ;;
	  i) INI=$OPTARG;;
	  m) MEM=-Xmx${OPTARG}m ;;
	  :) print -u2 "You forgot to enter a filename or memory for $OPTARG"
	     exit 4;;
	  \?) print -u2 "$OPTARG is not a valid switch."
	     print -u2 "$USAGE"
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
args=$* # capture current position param's because subsequent .profile could override them
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

export JRE=/opt/java1.4/jre
export CLASSPATH=$JRE/lib:$LIB_HOME/WindowAlgo.jar:$LIB_HOME/ojdbc14.jar:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME:.

cd $BIN_HOME

if [[ -z $1 ]]
then
	print You must supply a diff application class name!
	print $USAGE
	exit 4
fi

if [[ $1 = ? ]]
then
	print $USAGE
	exit 0
fi	

MEM=${MEM:--Xmx1024m} # default to 1 gig
USE_INI=${USE_INI:-Y}

if [[ $USE_INI = N ]]
then
	INI=
else	
	INI=$LIB_HOME/${INI:-WindowAlgo.ini}
fi

case $1 in
	LPOverrideConsumables)
		MEM=-Xmx2048m # use 2 gig when executing
		INI= ;;
	Users)
		INI= ;;
esac	

$JRE/bin/java $MEM $1 $INI
if [[ -O $LOG_HOME/.log* ]]
then
	chmod 666 $LOG_HOME/.log*
fi
