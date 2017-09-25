#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.40  $
#     $Date:   11 Feb 2009 17:18:22  $
# $Workfile:   createXml.ksh  $
# This script reads data from the Oracle tables and creates xml using
# the java application Table2Xml.
# Table2Xml uses two files for each xml file created: an sql file 
# containing the query of all columns to be used and a properties file 
# that maps the column name to an xml tag
USAGE="usage: ${0##*/} [/h] [-i ini_filename]  [-f command_filename] [-e] 
[-q queue_name] [-x xml_directory] [-h SRC_HOME_directory] [-m] 
[-a AMD_HOME_directory] [-j java_runtime_directory] [-b] [-n] [-o]
\t/h or \"?\" will display this message if it is the only argument
\t-m will enable a selection menu
\t-b will enter debug mode
\t-e will enqueue the file after creating it
\t-n will bypass the archive step
\t-o will turn off sending of error messages" # switch arguments

if [[ "$#" -eq "1" && ("$1" = "?" || "$1" = "/h") ]]
then
	print "$USAGE"
	exit 0
fi

hostName=`uname -n`
curUser=`whoami`
belongingTo="belonging to the folowing group(s): `groups`"

function abort {
	print -u2 ${1:-"createXml.ksh failed"}
	print -u2 "$USAGE"
	if [[ ${NOTIFY_IS_OFF:-N} = "N" ]]
	then
		sendErrorMsg.ksh createXml.ksh "${1:-'createXml.ksh failed'}" "${1:-'createXml.ksh failed'} - createXml.ksh was aborted on $hostName for the $myenv environment."
	fi
	exit ${2:-4}
}

function checkFileIsWritable {
	if [[ -a $1 ]]
	then
		if [[ ! -w $1 ]]
		then
			fileInfo=`ls -al $1`
			abort "User $curUser $belongingTo, cannot write to $1 ($fileInfo)" 
		fi
	fi
}

function checkDirectoryIsWritable {
	if [[ -a $1 ]]
	then
		if [[ -d $1 ]]
		then
			if [[ ! -w $1 ]]
			then
				fileInfo=`ls -al $1`
				abort "User $curUser $belongingTo, cannot write to $1 ($fileInfo)" 
			fi
		else
			abort "$1 is not a directory"
		fi
	else
		abort "$1 does not exist"
	fi
}

function checkFile {
	if  [[ ! -a $1 ]]
	then
		abort "$1 does not exist"
	else
		if  [[ ! -f $1 ]]
		then
			abort "$1 is not a regular file or symbolic link"
		else
			if  [[ ! -r $1 ]]
			then
				fileInfo=`ls -al $a`
				abort "User $curUser $belongingTo, cannot read file $1 ($fileInfo)"
			fi
		fi
	fi
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
			if [[ ${curScript%/createXml.ksh} = "." ]]
			then
				curScript=`pwd`/createXml.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/createXml.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/createXml.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/createXml.ksh) export myenv=crp ;;
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
# command line arguments take priority over amdconfig.ksh files
OPTIND=1

while getopts :f:ei:q:x:hma:j:bno arguments
do
	case $arguments in
	  b) set -x;;
	  n) noArchive=Y;;
	  o) NOTIFY_IS_OFF=Y;;
	  m) menu=Y;;
	  j) JRE=$OPTARG;;
	  a) AMD_HOME=$OPTARG;;
	  h) SRC_HOME=$OPTARG;;
	  x) DATA_HOME=$OPTARG;;
	  q) queueName=$OPTARG;;
	  i) iniFilename=$OPTARG;;
	  f) commandFile=$OPTARG;;
	  e) enqueue=Y ;;
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
if (( $# > 0 ))
then
	args=$* # capture current position param's because subsequent .profile could override them
else
	args=
fi
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.


commandFile=${commandFile:-} 
menu=${menu:-N} 
enqueue=${enqueue:-N} # default not to queue xml file
queueName=${queueName:-LBC17V2}

iniFilename=${iniFilename:-}
if [[ -z $iniFilename ]]
then
	if [[ -z $AMDENV ]]
	then
		abort "AMDENV is not set"
	fi
	case $AMDENV in
		prod) iniFilename=XmlAmdP.ini;;
		it) iniFilename=XmlAmdI.ini;;
		dev) iniFilename=XmlAmdD.ini;;
	esac
fi

checkFile $SRC_HOME/$iniFilename
if [[ -a $BIN_HOME/${myenv}/ojdbc14.jar ]]
then
	ORACLE_JDBC=$BIN_HOME/${myenv}/ojdbc14.jar
elif [[ -a $BIN_HOME/${myenv}/classes12.zip ]]
then
	ORACLE_JDBC=$BIN_HOME/${myenv}/classes12.zip
else
	abort "Unable to find an ORACLE JDBC jar file or zip file."
fi

function mainMenu {
	PS3='select function (hit return to re-display menu)? '
	select item in createDeletes createInsertUpdates quit
	do
		if [[ -n $item ]]
		then
			case $item in
				createDeletes) deleteMenu;;
				createInsertUpdates) insertUpdateMenu;;
				quit) break;;
			esac
		else
			print -u2 'invalid selection'
		fi
		PS3='select function (hit return to re-display menu)? '
	done
}
function insertUpdateMenu {
	PS3='which insert/update a2a (hit return to re-display menu)? ' 
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
			writeXml $item
		else
			print -u2 'invalid selection'
		fi
	done
}

function deleteMenu {
	PS3='which delete a2a (hit return to re-display menu)? ' 
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
			writeXml $item
		else
			print -u2 'invalid selection'
		fi
	done
}

function writeXml {
	checkFile $SRC_HOME/${myenv}/$1.sql
	checkFile $SRC_HOME/${myenv}/$1.properties
	checkDirectoryIsWritable $XML_HOME
	checkFileIsWritable $XML_HOME/$1.xml

	$JRE/bin/java -classpath $BIN_HOME/${myenv}/Amd2Xml.jar:${ORACLE_JDBC}:${BIN_HOME}/${myenv}/log4j-1.2.3.jar:log4j.properties Table2Xml $SRC_HOME/$iniFilename $SRC_HOME/${myenv}/$1 > $XML_HOME/$1.xml
	if (( $? > 0 )) 
	then
		abort "Table2Xml failed for $1"
	fi
	wc -l $XML_HOME/$1.xml
	if [[ $enqueue = "Y" ]]
	then
		runEnqueue.sh -q $queueName -i $XML_HOME/$1.xml
		if (( $? > 0 ))
		then
			abort "runEnqueue failed for $1"
		fi
	fi
	if [[ -O $XML_HOME/$1.xml ]]
	then
		chgrp dstagelb $XML_HOME/$1.xml
		chmod g+w $XML_HOME/$1.xml
	fi
	return 0
}
# Create the A2A Delete transactions
function createDeletes {
	writeXml FlightActyForecast_DEL 	
	writeXml FlightActy_DEL 	
#	writeXml ExtForecast_DEL 	
#	writeXml PartAltRelDel
#	writeXml PartAlt_DEL
#	writeXml OrderInfo_DEL 	
#	writeXml BackOrder_DEL	
#	writeXml InTransit_DEL 	
#	writeXml InvInfo_DEL 	
#	writeXml RepairInfo_DEL 	
#	writeXml DemandInfo_DEL	
	writeXml LocPartLeadTime_DEL 	
#	writeXml PartFactors_DEL 	
#	writeXml PartLeadTime_DEL 	
#	writeXml PartInfo_DEL 	
#	writeXml SiteAsset_DEL 	
	return 0
}
# Create the A2A Insert/Update transactions
function createInsertUpdates {
#	writeXml SpoUser 	
#	writeXml SiteAsset 	
#	writeXml PartInfo 	
#	writeXml PartLeadTime
#	writeXml PartFactors
	writeXml LocPartLeadTime
#	writeXml DemandInfo
#	writeXml RepairInfo 	
#	writeXml InvInfo
#	writeXml InTransit
#	writeXml BackOrder
#	writeXml BomDetail
#	writeXml OrderInfo
#	writeXml PartAlt
#	writeXml ExtForecast
	writeXml FlightActy
	writeXml FlightActyForecast
	return 0
}
##########################################################################
# The script begins execution at the next line


# make sure any xml 
# gets archived
noArchive=${noArchive:-N}
if [[ $noArchive = N ]]
then
	archive.ksh
fi

if [[ $menu = Y ]]
then
	mainMenu
elif [[ -z $args ]] # use predefined list of files
then
  createDeletes
  if (( $? != 0 ))
  then
	abort "Creation of deletes failed"
  fi
  createInsertUpdates
  if (( $? != 0 ))
  then
	abort "Creation of inserts/updates failed"
  fi
elif [[ -n $commandFile ]] # use the set of files contained in this file
then
	while file
	do
		writeXml $file
	done < $commandFile
else # use the set of command line arguments
  for file in $args
  do
	writeXml $file
  done
fi
