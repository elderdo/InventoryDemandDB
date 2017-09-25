#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.2  $
#     $Date:   Oct 24 2006 11:43:22  $
# $Workfile:   scanArchive.ksh  $
# This script scans through a set of archive files extracting a certain set
USAGE="usage: ${0##*/} [-z zip_directory] [-d data_directory] [-a app_home_directory] [-b] tran searchTxt [zipFiles]\n\twhere -z is the directory containing the gzipped files\n\t-b will enter debug mode\n\ttran is the A2A transaction name\n\tsearchText is the text to look for" # switch arguments
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



SCAN_OUTPUT=${SCAN_OUTPUT:-scanArchive.xml}
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
	tar xf *.tar `tar tf *.tar | grep "$2"`
	grep -i -e $3 xml/$myenv/$2 >> $SCAN_OUTPUT
	if ((  $? == 0 ))
	then
		hit=1
		print "<scanresult>$3 FOUND in $1</scanresult>" >> $SCAN_OUTPUT
	elif (( $? == 1 ))
	then
		print "<scanresult>$3 was NOT found in $1</scanresult>" >> $SCAN_OUTPUT
	fi
	gzip *.tar 
}
  . amdconfig.ksh

  if (( $# < 2 ))
  then
	  print -u You must enter the A2A tran and the search text and what archives to search
	  print $USAGE
	  exit 4
  fi
  print "ARCH_HOME=$ARCH_HOME"
  cd $ARCH_HOME
  rm $SCAN_OUTPUT
  hit=0
  print "<xml>" > $SCAN_OUTPUT 
  for file in ${3:-*.gz}
  do
	print "<scan>" >> $SCAN_OUTPUT
	print scanning $file.... 
	scanArchive $file $1 $2 
	print "</scan>" >> $SCAN_OUTPUT
  done
  if (( $hit == 0 ))
  then
	  print "No match found for $2"
	  rm $SCAN_OUTPUT
  else
  	print "</xml>" >> $SCAN_OUTPUT 
  	chgrp dstagelb $SCAN_OUTPUT
  	print results in $ARCH_HOME/$SCAN_OUTPUT
  fi
