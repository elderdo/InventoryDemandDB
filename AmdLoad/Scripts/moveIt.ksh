#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.21  $
#     $Date:   31 Aug 2015
# $Workfile:   moveIt.ksh  $
#
# 1.21 31 Aug 2015 Douglas Elder Linux does not allow chown
USAGE="usage: ${0##*/} [-s] [-t type] [-c reason_for_move] [-l logfile] [-m maxlogsize] [-p permission ] file(s)
\n\n\twhere\n\t-t type\ttype is bin, sql, ctl or lib
\n\t-s\tis silent mode - no printing of moves
\n\t-p permission\tpermission is 550 (read execute for group and owner)
\n\t-m maxlogsize\tthe maximum size of the moveIt.log.  default is 5,000 recs
\n\t\t440 (read for group and owner)...
\n\t\tused by the chmod command for all files moved
\n\t\totherwise a default based on the type of directory is used
\n\tfile(s)\tone or more files to be moved
\n\t\tassigned ownership and permissions"

if [[ $# = 0 || $1 = "?" ]]
then
	print $USAGE
	exit 0
fi

if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

. ${UNVAR:-}/apps/CRON/AMD/lib/amdconfig.ksh

while getopts st:p:c:m: arguments
do
	case $arguments in
	  m) MAX_LOG_SIZE=${OPTARG};;
	  c) REASON=${OPTARG};;
	  l) LOG_NAME=${OPTARG};;
	  p) PERMISSION=${OPTARG};;
	  t) TYPE=${OPTARG};;
	  s) SILENT=Y;;
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

if [[ $# = 0 || $1 = "?" ]]
then
	print $USAGE
	exit 0
fi

export TimeStamp=`date +%Y_%m_%d_%H_%M_%S`

function moveIt {
	if [[ $1 = moveIt.ksh ]]
	then
		return 0
	fi
	if [[ ${SILENT:-N} = N ]]
	then
		print "moving $1 to $2 with permissions of $3"
	fi
	mv -f $1 ../$2/.
	if (( $? == 0 ))
	then
		chmod $3 ../$2/$1
		chgrp amd ../$2/$1
		if [[ -z ${REASON:-} ]] ; then
			print "Enter reason for move. Hit Enter to end.> \c"
			data=
			while [[ "$data" = "" ]]
			do
				read data
				if [[ "$data" != "" ]] ; then
					REASON="${REASON:-}${data}\n"
					data=
				else
					break
				fi
			done
		fi
		THE_LOG_FILE=$LOG_HOME/${LOG_NAME:-moveIt}.log
		print "${TimeStamp}: `logname` moved $1 to $2 with permissions of ${3}\n${REASON:+Reason: ${REASON}}" >> $THE_LOG_FILE
		LOG_FILE_SIZE=`cat $THE_LOG_FILE | wc -l`
		if ((LOG_FILE_SIZE>${MAX_LOG_SIZE:-5000})) ; then
			$LIB_HOME/archive.ksh -x moveIt -d $LOG_HOME/archive $THE_LOG_FILE
		fi
	else
		print -u2 "$1 not moved to $2"
	fi
}

cd /apps/CRON/AMD/SUBMIT

#chmod g+w /apps/CRON/AMD/bin 2> /dev/null

TYPE=${TYPE:-}

for file in $*
do
	if [[ -n $TYPE ]]
	then
		# move based on the value of $TYPE

		case $TYPE in
			bin) moveIt $file bin ${PERMISSION:-550} ;;
			sql|ctl) moveIt $file src ${PERMISSION:-440} ;;
			data) moveIt $file data ${PERMISSION:-440} ;;
			lib) moveIt $file lib ${PERMISSION:-440} ;;
			*)
			print -u2 "Error: Unknown type $TYPE - must be bin, sql, ctl, or lib"
			print $USAGE
			exit 4 ;;
		esac

		continue
	fi
	
	# move based on file extension

	if [[  ${file##*.} = ksh  || -z ${file##*.} ]]
	then
		moveIt $file lib ${PERMISSION:-550}

	elif [[ ${file##*.} = sql || ${file##*.} = ctl  ]]
	then
		moveIt $file src ${PERMISSION:-440}

	elif [[ ${file##*.} = txt  ]]
	then
		moveIt $file data ${PERMISSION:-440}
		
	elif [[ ${file##*.} = properties || ${file##*.} = jar || ${file##*.} = ini ]]
	then
		moveIt $file lib ${PERMISSION:-440}

	else
		print -u2 "Error: Unknown file extension.  $1 not moved.  Use moveIt.ksh -t ... $1"
		print $USAGE
		exit 4
	fi
done
