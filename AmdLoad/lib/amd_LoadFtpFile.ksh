#!/usr/bin/ksh
# amd_loadFtpFile.ksh
# Author: Douglas S. Elder
# Revision: 1.14
# Date: 10/18/2015
#
#------------------------------------------------------------------------------
# This script will process all files on the external ftp server by
# transferring it to the local server and then loading it 
# into either the AMD_L67_SOURCE table or amd_mission_flights table.
#
# Date      By            History
# 11/01  Fernando F.      Initial Implementation
# 01/10  Fernando F.      Modified GenStats().
# 01/24  Fernando F.      Added sqlldr control to load new icao's and 
#                         mission types. Mod report to report dups.
# 04/03/02  Fernando F.   Added logic to populate filename field in
#                         amd_l67_source.
# 08/22/02  Fernando F.   Removed Joan Watson from distribution.
# 10/14/02  Fernando F.   Added Laurie Compton to distribution.
# 10/29/02  Fernando F.   Added emailing of actual L67 file to Laurie.
# 03/04/03  Thuy Pham     Modified FTPSERVER.
# 07/12/2013 Douglas Elder  added archiving of input and got rid of any old commented out code
# 10/14/2013 Douglas Elder  fixed notify.ksh to send a message with the attached gzip'ed file
# 10/21/2013 Douglas Elder  fixed the other notify.ksh to send a message with the attached gzip'ed file
# 03/24/2014 Douglas Elder  fixed comment about compressing files
# 03/24/2014 Douglas Elder  Make sure gzip can be found and check for compressed file before attaching it
# 10/05/2015 Douglas Elder  fixed tr command and used ls instead of ll which does not exist on linux
#                           removed check for gzip and added "ended at date" message
# 10/16/2015 Douglas Elder  fixed awk print $1 instead of print $9
#
#
# 10/18/2015 Douglas Elder  added Rena Huang to the default email list
#                           used %.* to remove fix extensions
#                           fixed the tar command to use --append and --file when adding more files
#                           to an existing tar file
#                           added -a address_file command line argument to override the address file
#                           used by the notify.ksh script
#                           fixed DestFile in GenStats
#                           fixed fileWithoutExt in compressAttachedFile
# 11/09/2017 Douglas Elder  for /tmp files use Amd to distinguish Amd
#                           files
#                           replaced obsolete back tics with $(....)
USAGE="Usage: ${0##*/}  [ -a address_file -d ]\n\n
\twhere\n
\t-a address_file contains email addresses for the notify.ksh\n
\t   (default is $DATA_HOME/AmdLoadFtpAddresses.txt)\n
\t-d enables debug\n"
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
while getopts :da: arguments
do
  case $arguments in
    a) ADDRESSES=$OPTARG;;
    d) debug=Y
       export debug ;;
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

print "$0 started at " $(date)

if [[ -z ${TimeStamp:-} ]] ; then
  export TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
  export TimeStamp=$(print "$TimeStamp" | sed "s/:/_/g")
fi

FTPDir=$DATA_HOME/L67GV
# make sure processed directory exists
PROCESSED=$FTPDir/processed
if [[ ! -d $PROCESSED ]]
then
  mkdir $PROCESSED
  chmod $PROCESSED 664
fi

if [ -z "$ADDRESSES" ] ; then
  # default email addresses
  MesgRecpt1=laurie.compton@boeing.com
  MesgRecpt2=douglas.s.elder@boeing.com
  MesgRecpt3=phuong-thuy.pham@boeing.com
  MesgRecpt4=rena.r.huang@boeing.com
  ADDRESSES=$DATA_HOME/AmdLoadFtpAddresses.txt
  if [[ ! -f $ADDRESSES ]] ; then
    print $MesgRecpt1 > $ADDRESSES
    print $MesgRecpt2 >> $ADDRESSES
    print $MesgRecpt3 >> $ADDRESSES
    print $MesgRecpt4 >> $ADDRESSES
    chmod 664 $ADDRESSES
  fi
fi

rm -f /tmp/AmdFileList*.txt
TMPFILE=/tmp/AmdFileList${$}.txt
rm -f /tmp/AmdMesgBody*.txt
MesgFile=/tmp/AmdMesgBody${$}.txt

if [  $# -ne 1 ] ; then
  print -u2 "$USAGE"
  exit 4
fi
FileType="$1"
FileType=$(echo $FileType |tr '[:lower:]' '[:upper:]')

if [ "$FileType" = "L67" ]; then
  uType="L67"
elif [ "$FileType" = "GDSS" ]; then
  uType="GDSS"
else
  exit
fi


function main
{
  BuildList

  ProcessList

  GenStats
}

function compressAttachedFile
{
  if [ "$debug" = "Y" ]
  then
    set -x
  fi

  fileToCompress=$(basename $1)
  # remove file extension
  fileWithoutExt=${fileToCompress%.*}
  TARFILE=/tmp/Amd$fileWithoutExt${$}.tar
  rm -f $/tmp/Amd${fileWithoutExt}*.tar
  rm -f $/tmp/Amd${fileWithoutExt}*.tar.gz
  CUR_DIR=$(pwd)
  cd $(dirname $1)
  # do the tar without path info 
  tar -cvf $TARFILE $fileToCompress > $LOG_HOME/tarLogs.log
  if (($?!=0)) ; then
    echo "tar failed to create $TARFILE for $fileToCompress"
    cd $CUR_DIR
    return 4
  fi    
  # make sure tar file exists
  if [[ -f $TARFILE ]] ; then
    gzip $TARFILE
    if (($?==0)) ; then
      GZIPFILE=${TARFILE}.gz
    else
      GZIPFILE=
      rm -f ${TARFILE}
    fi      
  fi
  cd $CUR_DIR
  return 0
}


#
# Create list of current files to process
#
function BuildList
{
  if [ "$debug" = "Y" ]
  then
    set -x
  fi

  (cd $FTPDir
    ls ${uType}* 2> /dev/null
  )>$TMPFILE
}

#
# Process file retreived in above list.
#
function ProcessList
{
  if [ "$debug" = "Y" ]
  then
    set -x
  fi

  for InFile in $(grep -i $FileType $TMPFILE|awk '{print $1}')
  do
    SourceFile=$FTPDir/$InFile
    DestFile=$DATA_HOME/${InFile%.*}

    cp $SourceFile $DestFile
  
    if [[ -f $DestFile ]]
    then
      if [ "$FileType" = "L67" ]; then
        LoadFile=$DestFile.tmp        #Will contain filename in file.
        AttFile=$DestFile.txt         #File to be attached.
        FileArg=$(basename $DestFile)
      
        # Add the filename to the file to populate in the database.
        awk -v FileName=$FileArg \
          '{printf("%-50s%s\n", FileName,$0)}' $DestFile >$LoadFile

        print "Loading file $InFile to AMD_L67_SOURCE table."
        sqlldr \
          silent=header \
          userid=$DB_CONNECTION_STRING \
          data=$LoadFile \
          control=$SRC_HOME/amd_l67_source.ctl \
          log=$LOG_HOME/$InFile.log \
          bad=$LOG_HOME/$InFile.bad

        print "Emailing $InFile."
        cat $DestFile >>$AttFile

	      compressAttachedFile $AttFile
      	if [[ -f $GZIPFILE ]] ; then
      	  $LIB_HOME/notify.ksh -m "L67 data loaded for $InFile" \
             -a $ADDRESSES \
             -s "$InFile on $hostname" \
	           $GZIPFILE
      	else
      	  $LIB_HOME/notify.ksh -m "L67 data loaded for $InFile" \
             -a $ADDRESSES \
             -s "$InFile on $hostname"
        fi
        rm -f $LoadFile $AttFile

      elif [ "$FileType" = "GDSS" ]; then
        InFileType=$InFile.Type.dat
        DestFileType=$DestFile.Type.dat

        print "\nCreating AMD_MISSION_TYPES file($InFileType) from $InFile."
        awk 'BEGIN{FS=","}
          {print $8 "," $8}' $DestFile | sort -u > $DestFileType

        print "\nLoading file $InFileType to AMD_MISSION_TYPES table."
        sqlldr \
          silent=header \
          userid=$DB_CONNECTION_STRING \
          data=$DestFileType \
          control=$SRC_HOME/amd_mission_types.ctl \
          log=$LOG_HOME/$InFileType.log \
          bad=$LOG_HOME/$InFileType.bad

        InFileIcao=$InFile.icao.dat
        DestFileIcao=$DestFile.icao.dat

        print "\nCreating AMD_AIRPORTS file($InFileIcao) from $InFile."
        awk 'BEGIN{FS=","}
          {print $6 "," $6}' $DestFile | sort -u > $DestFileIcao

        print "\nLoading file $InFileIcao to AMD_AIRPORTS table."
        sqlldr \
          silent=header \
          userid=$DB_CONNECTION_STRING \
          data=$DestFileIcao \
          control=$SRC_HOME/amd_airports.ctl \
          log=$LOG_HOME/$InFileIcao.log \
          bad=$LOG_HOME/$InFileIcao.bad

        print "\nLoading file $InFile to AMD_MISSION_FLIGHTS table."
        sqlldr \
          silent=header \
          userid=$DB_CONNECTION_STRING \
          data=$DestFile \
          control=$SRC_HOME/amd_mission_flights.ctl \
          log=$LOG_HOME/$InFile.log \
          bad=$LOG_HOME/$InFile.bad
      fi
      # add the source file to a tar archive
      if [[ ! -f $PROCESSED/L67${TimeStamp}.tar ]]
      then
        # create the archive if it does not exist  
        tar -cf $PROCESSED/L67${TimeStamp}.tar $SourceFile
       	if (($?==0)) ; then
          # we don't need to keep the files once it is archived
          rm $SourceFile
        fi	  
      else
        # archive already exists - append file to it
        tar --append --file=processed/L67${TimeStamp}.tar $SourceFile
      	if (($?==0)) ; then
          # we don't need to keep the files once it is archived
          rm $SourceFile
        fi	  
      fi

    else
      print "ERROR: Unable to cp $SourceFile to $DestFile."
    fi;

  done
  # compress any tar archive file created
  if [[ -f $PROCESSED/L67${TimeStamp}.tar ]]
  then
    gzip $PROCESSED/L67${TimeStamp}.tar
  fi
}


#
# Collect stats then email notification.
#
function GenStats
{
  if [ "$debug" = "Y" ]
  then
    set -x
  fi

  rm -f $MesgFile

  for InFile in $(grep -i $FileType $TMPFILE|awk '{print $1}')
  do
    DestFile=$DATA_HOME/${InFile%.*}

    (if [[ -f $DestFile ]]
    then
      awk -v FileName=$InFile \
        'BEGIN{DupRec=0}
        /ORA-00001:/{
            DupRec=DupRec+1;
          }
        /Rows successfully loaded./{
            GoodRec=$1
          }
        /not loaded due to data errors./{
            ErrorRec=$1
          }
        /WHEN clauses were failed/{
            Discard=$1
          }
        /Total logical records read:/{
            TotalRec=$5
          }
        END {
          printf("Processed %s: %d loaded, %d error(s), %d duplicate(s).  ",FileName,GoodRec,ErrorRec-DupRec,DupRec)
          if (Discard==TotalRec)
          {
            printf("File is empty.")
          }
          printf("\n")
        }' $LOG_HOME/$InFile.log
    else
      print "ERROR: $InFile not processed due to an error."
    fi; ) >> $MesgFile

  done

  if [ -s $MesgFile ]
  then
    compressAttachedFile $MesgFile
    if [[ -f ${GZIPFILE} ]] ; then
      $LIB_HOME/notify.ksh -m "L67 data loaded for $InFile" -a $ADDRESSES -s "$FileType Notification on $hostname" \
        ${GZIPFILE}
    else
      $LIB_HOME/notify.ksh -m "L67 data loaded for $InFile" -a $ADDRESSES -s "$FileType Notification on $hostname" 
    fi
  fi
}


main $*
print "$0 ended at " $(date)
