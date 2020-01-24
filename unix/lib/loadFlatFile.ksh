#!/bin/ksh
# loadFlatFile.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.0
#     $Date:   12 Aug 2016
#
# Rev      Date      By    Desc
# 1.0      08/12/16  DSE   initial Rev
# 1.0      07/11/19  DSE   The truncation step is optional

. /apps/CRON/AMD/lib/amdconfig.ksh
CTL=
DIR=
TRUNC=
EXT=csv

function usage {
  echo "usage: loadFlatFile.ksh -c ctl -d dir -t trunc [ -f ext ] -x"
  echo -e "where"
  echo -e "\t-c ctl is the SQL*Loader control file minus the ctl extension"
  echo -e "\tthis is required"
  echo -e "\t-d dir is the data sub directory containing the flat file"
  echo -e "\tthis is required"
  echo -e "\t-t trunc is the sql file that truncates the tabe minus the sql file extension"
  echo -e "\tthis is optional"
  echo -e "\t-f ext is the flat file's data extension - default is csv"
  echo -e "\t-x turns on debug for all functions and sub-scripts"
  
}

if [[ "$1" == "?" ]]  || (($#==0)) ; then
	usage
	exit 0
fi


while getopts :c:d:t:c:x arguments
do
	case $arguments in
	  c) CTL=${OPTARG};;
	  d) DIR=${OPTARG};;
	  f) EXT=${OPTARG};;
	  t) TRUNC=${OPTARG};;
	  x) DEBUG=Y
       set -x;;
	  *) usage
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

if [ "$CTL" = "" -o "$DIR" = "" ] ; then
  usage
  exit 4  
fi
function validateFiles {
  [[ "$DEBUG" == "Y" ]] && set -x
  typeset RC=0
  if [[ ! -d "$DATA_HOME/$DIR" ]] ; then
    mkdir $DATA_HOME/$DIR
    RC=$?
    if ((RC==0)) ; then
      echo created $DATA_HOME/$DIR
      mkdir $DATA_HOME/$DIR/archive
      echo created $DATA_HOME/$DIR/archive
    else
      2>&1 echo "Unable to create director $DATA_HOME/$DIR"
    fi
  fi
  if ((RC==0)) ; then
    if [[ ! -e $SRC_HOME/${CTL}.ctl ]] ; then
      echo "Error: $SRC_HOME/$CTL is not a valid ctl file"
      RC=4
    fi
  fi
  if ((RC==0)) ; then
    if [[ "$TRUNC" != "" ]] ; then
      if [[ ! -e $SRC_HOME/$TRUNC.sql ]] ; then
        2>&1 echo "Error: $SRC_HOME/$TRUNC.sql does not exist"
        RC=4
      else
        grep -qi "mta_truncate_table" $SRC_HOME/$TRUNC.sql
        RC=$?
        if ((RC!=0)) ; then
          2>& echo \
            "Error: $SRC_HOME/$TRUNC.sql does not have mta_truncate_table"
          RC=4
        fi
      fi
    fi
  fi
}

function truncateTable {
  DEBUGOPT=
  [[ "$DEBUG" == "Y" ]] && set -x && DEBUGOPT=-d
  $LIB_HOME/execSqlplus.ksh $DEBUGOPT $TRUNC
  if [ "$?" != "0" ] ; then
    cat $SRC_HOME/$TRUNC.sql
    echo "Error: unable to truncate"
    return 4
  fi
}
function archiveFile {
  typeset file=$1
  mv $file $DATA_HOME/$DIR/archive/$(basename $file)
}
function loadTable {
  typeset file=$1
  typeset DEBUGOPT=
  typeset RC=0
  [[ "$DEBUG" == "Y" ]] && set -x && DEBUGOPT=-d
  $LIB_HOME/execSqlldr.ksh $DEBUGOPT -l $LOG -f $file $CTL
  RC=$?
  if ((RC==0))  ||  ((RC==2)) ; then
    ((CNT++))
    grep -i "into table" $SRC_HOME/$CTL.ctl
    echo "loaded table with $file"
    archiveFile $file
  else
    grep -i "into table" $SRC_HOME/$CTL.ctl
    2>&1 echo "Error: unable to load file $file"
  fi
  return $RC
}

function main {
  [[ "$DEBUG" == "Y" ]] && set -x
  if (($#==0)) ; then
    2>&1 echo "main: needs $DATA_HOME's subdirectory, file extension "
    2>&1 echo "      and the optional Truncation script"
    return 4
  fi
  typeset DIR=$1
  typeset EXT=$2
  typeset TRUNC=$3
  typeset RC=0
  typeset CNT=0
  typeset f=
  for f in $(ls $DATA_HOME/$DIR/*.${EXT} 2> /dev/null)
  do
    if [ -f $f ] ; then
      if [ -s $f ] ; then
        if [[ "$TRUNC" != "" ]] ; then
          truncateTable
          RC=$?
        fi
        dos2unix $f
        RC=$?
        if ((RC==0)) ; then
          loadTable $f
          RC=$?
        else
          2>&1 echo "Unable to convert $f from Windows DOS to Unix format"
        fi
      else
        echo "removing empty file $f"
        rm $f
      fi
    fi
  done
  if ((CNT>0)) ; then
    echo "Loaded $CNT files"
  fi
  return $RC
}

LOG=$LOG_HOME/$(date +%Y%m%d_%H_%M_%S)_loadFlatFile.log
main $DIR $EXT $TRUNC  2>&1 \
   | tee -a $LOG
return $? 
