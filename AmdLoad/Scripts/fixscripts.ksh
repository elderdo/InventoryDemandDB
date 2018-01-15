#!/usr/bin/ksh
# vim:ts=2:sw=2:ff=unix:expandtab:autoindent:
# fixscripts.ksh
# Author: Douglas S. Elder
# Date: 01/15/2018
# Rev: 1.2
# Use a sed script to apply
# several changes to a set of files.
#
# 
#  Input: all the files specified by env var FILE_LIST
#         default is *.ksh
# Output: the modified files
#         a backup directory of all the 
#         modified files
# 
#  Rev 1.0  08/21/2015 Initial Rev
#  Rev 1.1  09/21/2017 Added comments
#  Rev 1.2  01/15/2018 added main function, log,
#                      and script validation with ksh -n
#                      changed PARENT variable to DIRNAME
#                      added PARENT_DIR and BACKUP_DIR
#                      added TimeStamp
#                      added LOG_DIR
#                      added LOG


# setup the log file
TimeStamp=$(date +%Y%m%d_%H_%M_%S)
PARENT_DIR=$(dirname $(pwd))
LOG_DIR=$PARENT_DIR/log
if [[ ! -d $LOG_DIR ]] ; then
  mkdir $LOG_DIR
  if (($?==0)) ; then
    chmod 770 $LOG_DIR
  else
    echo "Unable to create $LOG_DIR"
    exit 4
  fi
fi
LOG=$LOG_DIR/${TimeStamp}_fixfscripts.log

# setup the work directory

# go up one directory from the current directory
# and get the directory's name
DIRNAME=$(basename $(dirname $(pwd)))

# use DIRNAME to create a work directory
WORK=/tmp/wk$DIRNAME
if [[ ! -d $WORK ]] ; then
  mkdir $WORK
  if (($?==0)) ; then
    chmod 770 $WORK
  else
    echo "Unable to create $WORK"
    exit 4
  fi
else
  # get rid of all previously created work files
  rm -f $WORK/*.ksh
fi

# setup the backup directory
BACKUP_DIR=$PARENT_DIR/bku
if [[ ! -d $BACKUP_DIR ]] ; then
  mkdir $BACKUP_DIR
  if (($?==0)) ; then
    chmod 770 $BACKUP_DIR
  else
    echo "Unable to create $BACKUP_DIR"
    exit 4
  fi
fi

# setup default file list
FILE_LIST="*.ksh"

# setup default sed script file
SED_DIR=/apps/CRON/AMD/lib
SED_SCRIPT=/apps/CRON/AMD/lib/fixscripts.sed

function usage {
  echo " "
  echo "Usage: fixscripts.ksh -d -e file_extension|file_list -h -l log_file -s sed_script"
  echo "where -d -e file_extension -h -l -s are optional arguments"
  echo "      -d turns on debugging for this script"
  echo "      -e file_extension|file_list where file_extension any file extension"
  echo "         files with this file_extension will be processed by this script"
  echo "         or file_list is a list of files or file patterns to be processed by this script"
  echo "         for example \"*.ksh *.txt\" will process all ksh and txt files"
  echo "         the default is ksh"
  echo "      -h prints this message"
  echo "      -l log_file where log_file is the name of the output log"
  echo "         the default is log_directory/TimeStamp_fixscripts.log"
  echo "      -s sed_script where sed_script is the name of file containing the sed commands"
  echo "         the default is /apps/CRON/AMD/lib/fixscripts.sed"
  echo " "
}

OPTIND=1
while getopts de:hl:s: arguments
do
  case "$arguments" in
    d) debug=Y
       set -x;;
    e) FILE_LIST=$OPTARG;;
    h) usage
       exit 0;;
    l) LOG=$OPTARG;;
    s) SED_SCRIPT=$OPTARG;;
    ?) print "$OPTARG is not a valid switch."
       usage
       exit 4;;
  esac
done
((positions_occupied_by_switches = OPTIND - 1))
shift $positions_occupied_by_switches

# make sure the sed script exists
if [[ ! -e $SED_SCRIPT ]] ; then
  echo "sed script  $SED_SCRIPT not found"
  usage
  exit 4
fi

if [[ "$debug" == "Y" ]] ; then
  echo "BACKUP_DIR=$BACKUP_DIR"
  echo "FILE_LIST=$FILE_LIST"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG=$LOG"
  echo "PARENT_DIR=$PARENT_DIR"
  echo "WORK=$DIRNAME"
fi

function main {
  cnt=0
  echo "<<<<<<< $(date): processing files >>>>>>>>"
  for f in $FILE_LIST
  do

    # don't modify this script
    if [[ "$f" == "fixscripts.ksh" ]] ; then
      continue
    fi

    echo "processing $f"  
    ((cnt=cnt+1))
    # apply stream editor substitutions
    # using regular expression pattern matching
    sed  -f $SED_SCRIPT $f  > $WORK/$f

    # were any changes made?
    diff $f $WORK/$f
    if (($?==0)) ; then
      # no changes - get rid of this work file
      rm $WORK/$f
    else

      # yes there were changes made
      # save a back of the original
      cp $f $BACKUP_DIR/.
      echo "Backup of $f was made in $BACKUP_DIR"

      # if this is a Korn Shell script syntax check it
      # before replacing it with the changed file
      if [[ "$FILE_LIST" == "*.ksh" || "$FILE_LIST" == "*.sh" ]] ; then

        # syntax check the new script
        ksh -n $WORK/$f
        if (($?==0)) ; then
          # replace the current file with the new one
          mv $WORK/$f $f
          chmod 770 $f
          echo "$f has been updated and is ready to test"
        else
          # leave the current file as is until syntax errors
          # can be resolved.
          echo "$WORK/$f had syntax errors or may not be a ksh script"
        fi

      else
          mv $WORK/$f $f
          echo "$f has been updated"
      fi
    fi
  done
  echo "<<<<<<< $(date): $cnt files processed >>>>>>>>"
}

# run the main routine and keep a log
# send stderr messages to stdout 2>&1
main 2>&1 | tee -a $LOG
