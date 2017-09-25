#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.3  $
#     $Date:   21 Aug 2013
# $Workfile:   execJavaApp.ksh  $
#

export JRE=/usr/java/jdk1.7.0_72/jre

USAGE="usage: ${0##*/} [-j app_jar_file] [ -r jre ] [ -m amt_of_memory ] [-d] classname arg1..
\nwhere
\n\t-j app_jar_file gets added to the CLASSPATH
\n\t-r jre is the diretory for the java run time environment
\n\t\twhich defaults to $JRE
\n\t-m amd_of_memory MB used by the java Virtual Machine (default is 2048)
\n\t-d turns on debug
\n\tclassname is java class to execute
\n\targ1..... command line arguments passed to the java class"

if [[ "$1" = "?" || "$#" -eq "0" ]] ; then
	print $USAGE
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LIB_HOME ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

while getopts :j:r:m:d arguments
do
	case $arguments in
	  j) AMD_JAR=${OPTARG};;
	  r) export JRE=/usr/java/jdk1.7.0_72/jre ;;
	  m) AMD_JVM_MEMORY=${OPTARG};;
	  d) debug=Y
	     set -x ;;
	  *) print -u2 $USAGE
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


if [[ ! -d $JRE/lib ]] ; then
	print -u2 "$JRE/lib is not a directory"
	exit 4
fi

AMD_JAR=${AMD_JAR:-$LIB_HOME/WindowAlgo.jar}

if [[ ! -f $AMD_JAR ]] ; then
	print -u2 "$AMD_JAR does not exist"
	exit 4
fi
if [[ ! -f $LIB_HOME/ojdbc14.jar ]] ; then
	print -u2 "$LIB_HOME/ojdbc14.jar does not exist"
	exit 4
fi
if [[ ! -f $LIB_HOME/log4j-1.2.3.jar ]] ; then
	print -u2 "$LIB_HOME/log4j-1.2.3.jar does not exist"
	exit 4
fi

CLASSPATH=$JRE/lib:$AMD_JAR:$LIB_HOME/ojdbc14.jar:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME/opencsv-1.8.jar

if [[ -n ${AMD_LOG4j_PROPERTIES:-} ]] ; then
	if [[ -f ${AMD_LOG4j_PROPERTIES:-} ]] ; then
		CLASSPATH=${CLASSPATH}:$AMD_LOG4j_PROPERTIES
	else
		print -u2 "$AMD_LOG4j_PROPERTIES does not exist"
		exit 4
	fi
fi

export CLASSPATH=${CLASSPATH}:$LIB_HOME:.

JAVA_APP=$1
shift
$JRE/bin/java -Xmx${AMD_JVM_MEMORY:-2048}m $JAVA_APP "$@"
if (($?!=0)) ; then
	exit 4
fi
