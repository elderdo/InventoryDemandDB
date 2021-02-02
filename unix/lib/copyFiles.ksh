#!/usr/bin/ksh
# vim:ts=2:sw=2:sts=2:et:ai:ff=unix:
# copyFiles.ksh
# Author: Douglas S. Elder
# Revision: 1.1
# Date: 02/15/2018
#
#------------------------------------------------------------------------------
# This script will copy files to the dev and integrated test servers
#
# Date      By            History
# 04/14     Elder D.      Rev 1.0 Initial Implementation
# 02/15/18  Elder D.      Rev 1.1 removed obsolete back tic's and replaced with $(..)
#
#
USAGE="Usage: ${0##*/}  [ -d ] [ -s dir ] [ FileType ]\n\n
\twhere\n
\t-d enables debug\n
\t-s dir specifies the source file directory\n
\tFileType is the prefix of the source files - default is L67\n"
# setup the env

CUR_USER=$(logname)
if [[ -z $CUR_USER ]] ; then
  CUR_USER=amduser
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
  print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $LOG_HOME || -z $LIB_HOME || -z $DB_CONNECTION_STRING ]] ; then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

# get command line options
while getopts :ds: arguments
do
  case $arguments in
    d) debug=Y
       export debug ;;
    s) FTPDir=${OPTARG} ;;
    *) print -u2 "$USAGE"
       exit 4;;
  esac
done

if [ "$debug" = "Y" ]
then
  set -x
fi

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

hostname=$(hostname -s)


if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
  export TimeStamp=$(print "$TimeStamp" | sed "s/:/_/g")
fi

if [[ -z ${FTPDir:-} ]] ; then
  FTPDir=$DATA_HOME/L67GV
fi

# make sure processed directory exists
if [[ ! -d $FTPDir ]] ; then
  print -u2 "$FTPDir does not exist"
  exit 4
fi
if (($#==0)) ; then
  FileType="L67"
else  
  FileType="$1"
  FileType=$(echo $FileType |tr -A "L67" "L67")
  FileType=$(echo $FileType |tr -A "GDSS" "GDSS")
fi

if [ "$FileType" = "L67" ]; then
  uType="L67"
elif [ "$FileType" = "GDSS" ]; then
  uType="GDSS"
else
  print "Processing FileType: $FileTye"
fi


function main
{
  [[ "$debug" == "Y" ]] && set -x

  ProcessFiles

}



#
# Process files
#
function ProcessFiles
{
  [[ "$debug" == "Y" ]] && set -x
  cd $FTPDir
  for InFile in $(ls -l L67* 2> /dev/null | grep ^- | awk '{print $9}')
  do
    SourceFile=$FTPDir/$InFile
    scp -q $SourceFile ssd-sw-9000.vmpc1.cloud.boeing.com:$SourceFile
    scp -q $SourceFile ssd-sw-6000.vmpc1.cloud.boeing.com:$SourceFile
  done
}


main $*
