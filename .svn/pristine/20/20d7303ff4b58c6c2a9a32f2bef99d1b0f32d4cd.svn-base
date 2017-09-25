#/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.51  $
#     $Date:   11 Feb 2009 17:17:18  $
# $Workfile:   sendXml.ksh  $
# This script sends xml files to the SPO via a MQ Series message queue
USAGE="usage: ${0##*/} [-b] [-h] [-f command_filename] [-q queue_name] 
[-x xml_directory] [-m] [-s split_into]
[-a app_home_directory] [-d log_directory] [-w] [A2A A2A...]
\twhere [...] indicates an optional parameter
\t-b enables debug mode
\t-h displays this help message
\t\t\"?\" displays this help message if it is the only argument
\t-m enables a selection menu
\t-s split_into is the number of files to split into 
\t\twhen filesize > max_filesize
\t\tdefault is 2
\t-a abort for any queue errors
\t-b debug mode
\t-i send inserts
\t-z send deletes
\t-w ignore missing files
\t-o will turn off sending of error messages
\t[A2A A2A...] list of A2A trans to process." 

if [[ $# -eq 1 && "$1" = "?" ]]
then
	print "$USAGE"
	exit 0
fi

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"sendXml.ksh failed"}
	print ${1:-"sendXml.ksh failed"} >> $ESCMLOGFILE
	print -u2 "$USAGE"
	print -u2 "ERROR: sendXml.ksh aborted"
	print "ERROR: sendXml.ksh aborted"
	print "ERROR: sendXml.ksh aborted" >> $ESCMLOGFILE
	if [[ ${NOTIFY_IS_OFF:-N} = "N" ]]
	then
		sendErrorMsg.ksh sendXml.ksh "${1:-'sendXml.ksh failed'}" "${1:-'sendXml.ksh failed'} - sendXml.ksh was aborted on $hostName for the $myenv environment."
	fi
	if [[ -O $SENTINEL ]]
	then
		rm $SENTINEL
	fi
	exit ${2:-4}
}

UNVAR=${UNVAR:-}
AMD_HOME=${AMD_HOME:-}
if [[ -z $AMD_HOME ]]
then
	conifgFile=
	LB_HOME=/apps/CRON/AMD
	if [[ -a ${UNVAR}${LB_HOME}/lib/amdconfig.ksh ]]
	then
		configFile=${UNVAR}${LB_HOME}/lib/amdconfig.ksh
	elif [[ -a ${LB_HOME}/lib/amdconfig.ksh ]]
	then
		configFile=${LB_HOME}/lib/amdconfig.ksh
	else
		STL_HOME=/home/escmc172
		myenv=${myenv:-}
		if [[ -z $myenv ]]
		then
			curScript=`which $0`
			if [[ ${curScript%/sendXml.ksh} = "." ]]
			then
				curScript=`pwd`/sendXml.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/sendXml.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/sendXml.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/sendXml.ksh) export myenv=crp ;;
			 *) abort "Unable to set myenv"
			esac
		fi
		if [[ -a ${STL_HOME}/bin/$myenv/amdconfig.ksh ]]
		then
			configFile=${STL_HOME}/bin/$myenv/amdconfig.ksh 
		else
			abort "Cannot find amdconfig.ksh"
		fi
	fi
	. $configFile
fi


OPTIND=1
while getopts :f:q:x:mx:sa:dbizohw arguments
do
	case $arguments in
	  h) print "$USAGE"
	     exit 0 ;;
	  i) sendInserts=Y;;
	  z) sendDeletes=Y;;
	  o) NOTIFY_IS_OFF=Y;;
	  w) AMD_IGNORE_MISSING_FILE=Y;;
	  s) split_into=$OPTARG;;
	  b) set -x
	     debugMode=-b;;
	  a) AMD_HOME=$OPTARG;;
	  m) menu=Y;;
	  d) LOG_HOME=$OPTARG;;
	  x) XML_HOME=$OPTARG;;
	  f) commandFile=$OPTARG;;
	  q) queuename=$OPTARG ;;
	  :) print -u2 "You forgot to enter an argument for $OPTARG"
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
if (( $# > 0 ))
then
	args=$* # capture current position param's because subsequent .profile could override them
else
	args=
fi
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.

function checkScript {
	CMD=`which $1`
	if [[ ! -a $CMD ]]
	then
		abort  "$1 is not in this script's path: $PATH"
	else
		if [[ ! -f $CMD ]]
		then
			abort "Could not find the file for $1"
		else
			if [[ ! -x $CMD ]]
			then
				abort "$CMD is not executable by $curUser $belongingto"
			else
				if [[ ! -r $CMD ]]
				then
					abort "$1 is not a readable file for $curUser $belongingto"
				fi
			fi
		fi
	fi
}

function checkFile {
		if  [[ ! -a $1 ]]
		then
			if [[ "${AMD_IGNORE_MISSING_FILE:-N}" = "N" ]] ; then
				abort "$1 does not exist"
			else
				print "$1 does not exist"
				return 4
			fi
		else
			if  [[ ! -f $1 ]]
			then
				abort "$1 is not a regular file or symbolic link"
			else
				if  [[ ! -r $1 ]]
				then
					abort "$1 is not a readable file for $curUser $belongingto"
				fi
			fi
		fi
}

queuename=${queuename:-LBC17V2} # default not to queue xml file

checkScript "runBrowse.sh"
checkScript "runEnqueue.sh"
checkScript "runAdapter.sh"

FileTimeStamp=`print ${TimeStamp} | sed 's/:/_/g'`

ESCMLOGFILE=${LOG_HOME}/${FileTimeStamp}_runEnqueue_ESCM.${queuename}.INP.txt

max_filesize=`runBrowse.sh -q $queuename -a | grep "^Maximum Depth" | sed 's/Maximum Depth = //'`
if (( ${max_filesize:-0} <= 0 ))
then
	abort "Error in determining the Maximum queue depth for $queuename max_filesize = $max_filesize"
fi

max_filesize=${max_filesize:-512000}
split_into=${split_into:-4}

function mainMenu {
	print 'deletes should be send first followed by insert/updates'
	PS3='deletes or insert/updates (hit return to re-display menu)? '
	select item in sendDeletes sendInsertUpdates quit
	do
		if [[ -n $item ]]
		then
			case $item in
				sendDeletes) deleteMenu;;
				sendInsertUpdates) insertUpdateMenu;;
				quit) break;;
				*) print -u2 Invalid selection $item
			esac
		else
			print -u2 'invalid selection'
		fi
		PS3='deletes or insert/updates (hit return to re-display menu)? '
	done
}

function insertUpdateMenu {
	PS3='send insert/update a2a xml (hit return to re-display menu)? ' 
	select item in \
		PartFactors LocPartLeadTime DemandInfo RepairInfo \
       		ExtForecast \
		FlightActy FlightActyForecast quit
	do
		if [[ -n $item ]]
		then
			if [[ $item = quit ]]
			then
				break
			fi
			sendXml $item
		else
			print -u2 'invalid selection'
		fi
	done
}

function deleteMenu {
	PS3='send delete a2a xml (hit return to re-display menu)? ' 
	select item in FlightActyForecast_DEL FlightActy_DEL ExtForecast_DEL \
	RepairInfo_DEL DemandInfo_DEL LocPartLeadTime_DEL PartFactors_DEL \
	quit
	do
		if [[ -n $item ]]
		then
			if [[ $item = quit ]]
			then
				break
			fi
			sendXml $item
		else
			print -u2 'invalid selection'
		fi
	done
}

function getQueueCapacity {
	recsInQueue=`runBrowse.sh -q $queuename -a | grep "^Current Depth" | sed 's/Current Depth = //'`
	(( queueCapacity = $max_filesize - ${recsInQueue:-0} ))
	if (( $queueCapacity == 0 ))
	then
		if [[ ! -n $cnt ]]
		then
			cnt=0
		fi
		(( cnt = $cnt + 1 ))
		print `date` "invoking runAapter.sh because the queue capactiy is zero"
		runAdapter.sh -q $queuename # the trigger may not be working	
		if (( $cnt > 2 ))
		then
			abort "$queuename must be down"
		fi
	else
		cnt=0
	fi
}

function sendXml {
	checkFile $XML_HOME/$1.xml
	if (($?!=0)) ; then
		# do nothing for missing file
		return
	fi		
	filesize=`cat $XML_HOME/$1.xml | wc -l`
	if (( $filesize == 0 ))
	then
		print $XML_HOME/$1.xml is empty
		return 0 # nothing to send
	fi
	startDate=`date +%Y-%m-%d`
	if (( $filesize > $max_filesize ))
	then
		# check to see if the file was previously split into 4 files
		if  [[ ! -a $1.xmlaa && ! -a $1.xmlab && ! -a $1.xmlac && ! -a $1.xmlad ]]
		then
			splitFile.ksh -n $split_into -s $filesize $XML_HOME/$1.xml # split the file into 4 separate files
		fi
		for file in $XML_HOME/$1.xml??
		do
			filesize=`cat $file | wc -l`
			getQueueCapacity
			while (( $queueCapacity < $filesize ))
			do
				print `date` "invoking runAapter.sh because the queue capactiy is less than the filesize."
				runAdapter.sh -q $queuename
				if (( $? > 0 ) && ( $? != 255))
				then
					abort "runAdapter failed for $queuename"
				fi
				sleep 60
				getQueueCapacity
			done
			runEnqueue.sh -q $queuename -i $file > /dev/null 2>> $ESCMLOGFILE # ignore stdout append stderr to log
			if (( $? > 0 ))
			then
				abort "runEnqueue failed for $file"
			else
				rm $file
			fi
			print `date` " enqueued successfully $filesize for $file"
			print `date` " enqueued successfully $filesize for $file" >> $ESCMLOGFILE
			endDate=`date +%Y-%m-%d`
			if [[ -s $ESCMLOGFILE ]]
			then
				grep -q -i -e ^${startDate}.*failed -e ^${startDate}.*Exception -e ^${endDate}.*failed -e ^${endDate}.*Exception $ESCMLOGFILE
				if (( $? == 0 ))
				then
					if [[ $SENTINEL -ot $ESCMLOGFILE ]]
					then
						abort "runEnqueue failed for $file (see $ESCMLOGFILE)"
					fi
				fi
			fi
		done
	else
		getQueueCapacity
		while (( $queueCapacity < $filesize ))
		do
			print `date` "invoking runAapter.sh because the queue capactiy is less than the filesize."
			runAdapter.sh -q $queuename
			sleep 60
			getQueueCapacity
		done
		runEnqueue.sh -q $queuename -i $XML_HOME/$1.xml > /dev/null 2>> $ESCMLOGFILE # ignore stdout append stderr to log
		if (( $? > 0 ))
		then
			abort "runEnqueue failed for $1"
		fi
		print `date` " enqueued successfully $filesize for $1.xml"
		print `date` " enqueued successfully $filesize for $1.xml" >> $ESCMLOGFILE
		endDate=`date +%Y-%m-%d`
		if [[ -s $ESCMLOGFILE ]]
		then
			grep -q -i -e ^${startDate}.*failed -e ^${startDate}.*Exception -e ^${endDate}.*failed -e ^${endDate}.*Exception $ESCMLOGFILE
			if (( $? == 0 ))
			then
				if [[ $SENTINEL -ot $ESCMLOGFILE ]]
				then
					abort "runEnqueue failed for $1.xml (see $ESCMLOGFILE)"
				fi
			fi
		fi
	fi
	print `awk -f $BIN_HOME/$AMD_SPO_ENV/getTranType.txt $XML_HOME/$1.xml` " $filesize" >> $XML_HOME/$XML_COUNTS
	((AMDXML_CNT = AMDXML_CNT + filesize))	
#	if [[ $myenv = dev ]]
#	then
#		print `date` "invoking runAapter.sh because the trigger is not enabled for $myenv"
		runAdapter.sh -q $queuename
		print `date` " runAdapter completed for $1.xml"
		print `date` " runAdapter completed for $1.xml" >> $ESCMLOGFILE
		updateSpo.ksh # import the data from x_imp table now
		print `date` " updateSpo completed for $1.xml"
		print `date` " updateSpo completed for $1.xml" >> $ESCMLOGFILE
#	fi
	((AMD_FILES_SENT=AMD_FILES_SENT+1))
}
# send the A2A Delete transactions
function sendDeletes {
	sendXml FlightActyForecast_DEL 	
	sendXml FlightActy_DEL 	
#	sendXml ExtForecast_DEL 	
#	sendXml PartAltRelDel
#	sendXml PartAlt_DEL
#	sendXml OrderInfo_DEL 	
#	sendXml BackOrder_DEL	
#	sendXml InTransit_DEL 	
#	sendXml InvInfo_DEL 	
#	sendXml RepairInfo_DEL 	
#	sendXml DemandInfo_DEL	
	sendXml LocPartLeadTime_DEL 	
#	sendXml PartFactors_DEL 	
#	sendXml PartLeadTime_DEL 	
#	sendXml PartInfo_DEL 	
#	sendXml SiteAsset_DEL 	
}
# Create the A2A Insert/Update transactions
function sendInsertUpdates {
#	sendXml SpoUser 	
#	sendXml SiteAsset 	
#	sendXml PartInfo 	
#	sendXml PartLeadTime
#	sendXml PartFactors
	sendXml LocPartLeadTime
#	sendXml DemandInfo
#	sendXml RepairInfo 	
#	sendXml InvInfo
#	sendXml InTransit
#	sendXml BackOrder
#	sendXml BomDetail
#	sendXml OrderInfo
#	sendXml PartAlt
#	sendXml ExtForecast
	sendXml FlightActy
	sendXml FlightActyForecast
}
##########################################################################
# The script begins execution at the next line


SENTINEL=/tmp/sendXmlStarted${TimeStamp:-}.txt
touch $SENTINEL
XML_COUNTS=xmlCounts.xml
rm -f $XML_HOME/$XML_COUNTS
typeset -x -i AMDXML_CNT=0
typeset -x -i AMDQUEUE_CNT=0
typeset -x -i AMD_FILES_SENT=0

if [[ ${menu:-N} = Y ]]
then
	mainMenu
elif [[ ${sendInserts:-N} = Y || ${sendDeletes:-N} = Y ]] 
then
	if [[ ${sendDeletes:-N} = Y ]]
	then
		sendDeletes
	fi
	if [[ ${sendInserts:-N} = Y ]]
	then
		sendInsertUpdates
	fi
elif [[ -z $args ]] # use predefined list of files
then
  sendDeletes
  sendInsertUpdates
elif [[ -n $commandFile ]] # use the set of files contained in this file
then
	while file
	do
		sendXml $file
	done < $commandFile
else # use the set of command line arguments
  for file in $args
  do
	sendXml $file
  done
fi
ESCM_BROWSE_LOG=$LOG_HOME/${FileTimeStamp}_runBrowse_${queuename:-}.log
runBrowse.sh -q $queuename -a >  $ESCM_BROWSE_LOG
chgrp dstagelb $ESCM_BROWSE_LOG
chmod 440 $ESCM_BROWSE_LOG

AMDQUEUE_CNT=`runBrowse.sh -q $queuename -a | grep "^Current Depth" | sed 's/Current Depth = //'`

if (($AMDQUEUE_CNT!=0)) ; then
	runAdapter.sh -q $queuename > /dev/null
	updateSpo.ksh # import the data from x_imp table now
fi

if (($AMDXML_CNT>0 && $AMDQUEUE_CNT>0)) ; then
	case $AMDENV in
		dev) switch=-d;;
		crp) switch=-i;;
		prd) switch=-p;;
		*) switch=
	esac
	recordCnts.ksh $switch $AMDXML_CNT $AMDQUEUE_CNT
fi

if [[ -O $SENTINEL ]]
then
	rm $SENTINEL
fi
print "Sent $AMD_FILES_SENT files."
