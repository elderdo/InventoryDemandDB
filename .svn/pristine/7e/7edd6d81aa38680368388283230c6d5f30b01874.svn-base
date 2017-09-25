#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   09 Jan 2008 00:03:38  $
# $Workfile:   createXml.ksh  $
# This script reads data from the Oracle tables and creates xml using
# the java application Table2Xml.
# Table2Xml uses two files for each xml file created: an sql file 
# containing the query of all columns to be used and a properties file 
# that maps the column name to an xml tag
USAGE="usage: ${0##*/} [-i ini_filename]  [-f command_filename] [-e] [-q queue_name] [-x xml_directory] [-h SRC_HOME_directory] [-m] [-a AMD_HOME_directory] [-j java_runtime_directory] [-b]\n\twhere -m will enable a selection menu\n\t-b will enter debug mode" # switch arguments

curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"createXml.ksh failed"}
	print -u2 $USAGE
	exit ${2:-4}
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
				abort "$1 is not a readable file for $curUser $belongingTo"
			fi
		fi
	fi
}


UNVAR=${UNVAR:-}
if [[ -a $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CrON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -a /apps/CRON/AMD/lib/amdconfig.ksh ]]
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
		abort `which amdconfig.ksh` failed
	fi
fi
# command line arguments take priority over amdconfig.ksh files
while getopts :f:ei:q:x:hma:j:b arguments
do
	case $arguments in
	  b) set -x;;
	  m) menu=Y;;
	  j) JRE=$OPTARGR;;
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
args=$* # capture current position param's because subsequent .profile could override them
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.


commandFile=${commandFile:-} 
menu=${menu:-N} 
enqueue=${enqueue:-N} # default not to queue xml file
queueName=${queueName:-LBC17V2}

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
cd $BIN_HOME
ORACLE_JDBC=$LIB_HOME/ojdbc14.jar

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
	select item in SpoUser SiteAsset PartInfo PartLeadTime \
		PartFactors LocPartLeadTime DemandInfo RepairInfo InvInfo \
       		InTransit BackOrder OrderInfo PartAltRelDel ExtForecast \
		LocPartOverride FlightActy FlightActyForecast quit
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
	select item in FlightActyForecast_DEL FlightActy_DEL LocPartOverride_DEL ExtForecast_DEL PartAltRelDel OrderInfo_DEL \
	BackOrder_DEL InTransit_DEL InvInfo_DEL RepairInfo_DEL DemandInfo_DEL LocPartLeadTime_DEL PartFactors_DEL \
	PartLeadTime_DEL PartInfo_DEL SiteAsset_DEL quit
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
	checkFile $SRC_HOME/$1.sql
	checkFile $SRC_HOME/$1.properties

	$JRE/bin/java -classpath $LIB_HOME/Amd2Xml.jar:${ORACLE_JDBC}:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME:. Table2Xml $SRC_HOME/$iniFilename $SRC_HOME/$1 > $DATA_HOME/$1.xml
	if (( $? > 0 )) 
	then
		abort "Table2Xml failed for $1"
	fi
	wc -l $DATA_HOME/$1.xml
	if [[ $enqueue = "Y" ]]
	then
		runEnqueue.sh -q $queueName -i $DATA_HOME/$1.xml
		if (( $? > 0 ))
		then
			abort "runEnqueue failed for $1"
		fi
	fi
	return 0
}
# Create the A2A Delete transactions
function createDeletes {
	writeXml FlightActyForecast_DEL 	
	writeXml FlightActy_DEL 	
	writeXml LocPartOverride_DEL 	
	writeXml ExtForecast_DEL 	
	writeXml PartAltRelDel
	writeXml OrderInfo_DEL 	
	writeXml BackOrder_DEL	
	writeXml InTransit_DEL 	
	writeXml InvInfo_DEL 	
	writeXml RepairInfo_DEL 	
	writeXml DemandInfo_DEL	
	writeXml LocPartLeadTime_DEL 	
	writeXml PartFactors_DEL 	
	writeXml PartLeadTime_DEL 	
	writeXml PartInfo_DEL 	
	writeXml SiteAsset_DEL 	
	return 0
}
# Create the A2A Insert/Update transactions
function createInsertUpdates {
	writeXml SpoUser 	
	writeXml SiteAsset 	
	writeXml PartInfo 	
	writeXml PartLeadTime
	writeXml PartFactors
	writeXml LocPartLeadTime
	writeXml DemandInfo
	writeXml RepairInfo 	
	writeXml InvInfo
	writeXml InTransit
	writeXml BackOrder
	writeXml BomDetail
	writeXml OrderInfo
	writeXml ExtForecast
	writeXml LocPartOverride
	writeXml FlightActy
	writeXml FlightActyForecast
	return 0
}
##########################################################################
# The script begins execution at the next line

if [[ $args = \? ]]
then
	print $USAGE
	exit 4
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
