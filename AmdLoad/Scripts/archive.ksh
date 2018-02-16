#!/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix:
# archive.ksh
#   $Author:   Douglas S Elder
# $Revision:   1.17
#     $Date:   15 Feb 2018
# This script archives and compresses a set of files to a time_stamped file.
#
# $Revision:   1.16   21 May 2009 17:51:04
# $Revision:   1.17   15 Feb 2018 removed obsolete back tics and replaced with $(..)
#                                 removed obsolete -a and replaced with -e
#                                 use (( )) and no $ variables for numeric compares
#
USAGE="usage: ${0##*/} [-x archname] [-d archive_directory] [file1 file2 file3...] [-a app_home_directory] [-b] [-p arch_data_pattern ]
\n\t-x archname is the name of the archive without the time stamp. defaults to null 
\n\t-d defaults to $ESCMXML
\n\t-p arch_data_pattern where arch_data_pattern is data/*.csv or xml/*.xml...
\n\t file1 file2 file3... defaults to *.xml
\n\t-b debug mode" 

UNVAR=${UNVAR:-}
if [[ -e $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CrON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -e /apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. /apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
else
	. amdconfig.ksh 
	if (( $? > 0 ))
	then
		abort $(which amdconfig.ksh) failed
	fi
fi
OPTIND=1
while getopts :d:a:bp:x: arguments
do
	case $arguments in
	  b) set -x;;
	  x) ARCH_NAME=$OPTARG;;
	  p) ARCH_DATA_PATTERN=$OPTARG;;
	  a) AMD_HOME=$OPTARG;;
	  d) ARCH_HOME=$OPTARG;;
	  :) print "You forgot to enter a filename for $OPTARG"
	     exit 4;;
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

curUser=$(whoami)
belongingTo="belonging to the folowing group(s) $(groups)"

if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
	TimeStamp=$(print $TimeStamp | sed "s/:/_/g")
fi

function abort {
	print -u2 ${1:-"archive.ksh failed"}
	print -u2 $USAGE
	exit ${2:-4}
}

function checkDirectory {
	if [[ ! -e $1 ]]
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

if [[ -z $ARCH_HOME ]]
then
	abort "A writable directory must be defined for environment variable ARCH_HOME."
fi

if [[ ! -e $ARCH_HOME ]] ; then
	mkdir $ARCH_HOME
	chmod 750 $ARCH_HOME
fi

ARCHFILE=$(print arch_$TimeStamp${ARCH_NAME:+_${ARCH_NAME}}.tar | sed "s/:/_/g")

file_cnt=0

if (( $# > 0 ))
then
	for file in $*
	do
		if [[ -f $file ]] ; then
			((file_cnt=file_cnt+1))
		fi
	done
	if ((file_cnt>0)) ; then
		tar -cvvf $ARCH_HOME/$ARCHFILE $*
		gzip $ARCH_HOME/$ARCHFILE
		rm -f $*
	fi
else
	if [[ -n ${CSV_HOME:-} ]] ; then
		cd $CSV_HOME
		cd ..
		if [[ -z $ARCH_DATA_PATTERN ]] ; then
			ARCH_DATA_PATTERN=data/*.csv
		fi
		AMD_GROUP=amd
	elif [[ -n $XML_HOME ]] ; then
		cd $XML_HOME
		if [[ -z $myenv ]]
		then
			cd ..
			ARCH_DATA_PATTERN=xml/*.xml
		else 
			cd ../..
			ARCH_DATA_PATTERN=xml/$myenv/*.xml
		fi
		AMD_GROUP=dstagelb
	else
		abort "data to be archived not defined."
	fi

	for file in $ARCH_DATA_PATTERN
	do
		if [[ -f $file ]] ; then
			((file_cnt=file_cnt+1))
		fi
	done
	if ((file_cnt>0)) ; then
		tar -cvvf $ARCH_HOME/$ARCHFILE $ARCH_DATA_PATTERN
		gzip $ARCH_HOME/$ARCHFILE
		rm -f $ARCH_DATA_PATTERN
	fi
fi

if [[ -s $ARCH_HOME/${ARCHFILE}.gz ]] ; then 
	if [[ -O $ARCH_HOME/${ARCHFILE}.gz ]] ; then 
		chgrp ${AMD_GROUP:-amd} $ARCH_HOME/${ARCHFILE}.gz
	fi
else
	rm -f $ARCH_HOME/${ARCHFILE}.gz
fi
