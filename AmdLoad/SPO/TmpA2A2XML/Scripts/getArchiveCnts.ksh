#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   Oct 31 2006 15:44:08  $
# $Workfile:   getArchiveCnts.ksh  $
# This script scans through a set of archive files and counts the A2A transactions
USAGE="usage: ${0##*/} [-z zip_directory] [-d data_directory] [-a app_home_directory] [-b] [zipFiles]\n\twhere -z is the directory containing the gzipped files\n\t-b will enter debug mode" # switch arguments
while getopts a:bd:z:o: arguments
do
	case $arguments in
	  b) set -x;;
	  a) APP_HOME=$OPTARG;;
	  z) ARCH_HOME=$OPTARG;;
	  d) DATA_HOME=$OPTARG;;
	  o) SCAN_OUTPUT=$OPTARG;;
	  :) print -u2 "You forgot to enter a filename for $OPTARG"
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
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"scanArchive.ksh failed"}
	print -u2 $USAGE
	exit ${2:-4}
}


function checkDirectory {
	if [[ ! -a $1 ]]
	then
		abort "$1 does not exist"
	else
		if [[ ! -r $1 ]]
		then
			abort "$1 is not readable for $curUser $belongingTo"
		else
			if [[ ! -d $1 ]]
			then
				abort "$1 is not a directory"
			fi
		fi
	fi
}



SCAN_OUTPUT=${SCAN_OUTPUT:-archiveCnts.xml}
APP_HOME=${APP_HOME:-/home/escmc172}
checkDirectory $APP_HOME
if [[ $curUser != escmc172 ]]
then
	SHLIB_PATH=. # if this variable is not set, .profile does not work
	if [[ ! -x $APP_HOME/.profile ]]
	then
		abort "$APP_HOME/.profile is not executable by $curUser $belongingTo"
	fi	

	. $APP_HOME/.profile

	PATH=$PATH:$APP_HOME/bin
	export PATH
fi



ARCH_HOME=${ARCH_HOME:-/data/escm_lb/xml/$myenv/archive}
checkDirectory $ARCH_HOME


BIN_HOME=${BIN_HOME:-$APP_HOME/bin}
checkDirectory $BIN_HOME
if [[ ! -x $BIN_HOME ]]
then
	abort "$BIN_HOME is not an executable directory for $curUser $belongingTo"
fi	

function scanArchive {
	gunzip $1
	tar xf *.tar 
	wc -l xml/$myenv/* | sed -e "s/xml\/$myenv\///" -e 's/\.xml//' | awk '{printf("<%s>%s</%s>\n",$2,$1,$2)}' >> $SCAN_OUTPUT
	gzip *.tar 
}
  . amdconfig.ksh

  print "ARCH_HOME=$ARCH_HOME"
  cd $ARCH_HOME
  rm $SCAN_OUTPUT
  print "<xml>" > $SCAN_OUTPUT 
  for file in ${1:-*.gz}
  do
	print "<scan>" >> $SCAN_OUTPUT
	print "<file>$file</file>" >> $SCAN_OUTPUT
	scanArchive $file $1 $2 
	print "</scan>" >> $SCAN_OUTPUT
  done
  print "</xml>" >> $SCAN_OUTPUT 
  chgrp dstagelb $SCAN_OUTPUT
  print results in $ARCH_HOME/$SCAN_OUTPUT
