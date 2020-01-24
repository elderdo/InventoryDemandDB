#!/bin/ksh
# $Author: zf297a
# $Revision: 1.1
# $Date: 2/29/2012
# This script loads data info AMD
# and then moves the input to a processed
# directory.
# rev 1.1 2/29/2012 Initial Rev
# rev 1.2 3/19/2017 fixed if - missing then
#
USAGE="usage: ${0##*/} [-a app_data_dirli 
[-l execSqlldr_options] [-o execSqlplus_opts] [-p sqlplus_script ] 
[-q execSqlldr_options] [-o execSqlplus_opts] [-p sqlplus_script ] 
[-x sqlplus_script] ctl_file\n
where\n
\t-a app_data_dir specifies the data directory name containing
\t-l execSqlldr options for the sqlldr script
\t-o execSqlplus_opts options for the pre_proc
\t-p sqlplus_script a script to run before sqlldr (pre_proc)
\t-q sqlplus args arguments for the sqlplus pre_proc script
\t-w execSqlplus_opts options for the post_proc
\t-x sqlplus_script a script to run after sqlldr (post_proc)
\t-y sqlplus args arguments for the sqlplus  post_proc script
\t\tthe files to be loaded
\tctl_file is the sqlldr control file located in the source home
\t\tdirectory.\n"

if [[ "$1" = "?" || "$#" -eq "0" ]] ; then
  print - "$USAGE"
  exit 0
fi

APP_DIR=repairCost
RC=0

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
  print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $SRC_HOME || -z $LOG_HOME || -z $DB_CONNECTION_STRING ]] ; then
  . $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi
while getopts :da:l:o:p:q:w:x:y: arguments
do
  case $arguments in
    a) APP_DIR=${OPTARG};;
    d) debug=Y
       set -x ;;
    l) LDR_OPT=${OPTARG};;
    o) PRE_OPT=${OPTARG};;
    p) PRE_PROC=${OPTARG};;
    q) PRE_ARGS=${OPTARG};;
    w) POST_OPT=${OPTARG};;
    x) POST_PROC=${OPTARG};;
    y) POST_ARGS=${OPTARG};;
    *) print -u2 $USAGE
       exit 4;;
  esac
done
((positions_occupied_by_switches = OPTIND - 1))
shift $positions_occupied_by_switches
if (($#<1)) ; then
  print - "$USAGE"
  exit 4
fi
CTL_FILE=$1
if [[ ! -f $SRC_HOME/${CTL_FILE}.ctl ]] ; then
  print -u2 $SRC_HOME/${CTL_FILE}.ctl does not exist
  exit 4
fi

if [[  -d $DATA_HOME/$APP_DIR ]] ; then
  if [[ ! -d $DATA_HOME/$APP_DIR/processed ]] ; then
    mkdir $DATA_HOME/$APP_DIR/processed
  fi
  if [[ ! -d $DATA_HOME/$APP_DIR/not_processed ]] ; then
    mkdir $DATA_HOME/$APP_DIR/not_processed
  fi
else
  print -u2 $DATA_HOME/$APP_DIR is not a directory
  exit 4
fi

if [[ -z ${TimeStamp:-} ]] ; then
  TimeStamp=`date $DateStr | sed "s/:/_/g"`;
else
  TimeStamp=`print $TimeStamp | sed "s/:/_/g"`
fi

if [[ -n ${PRE_PROC:-} ]] ; then
  if [[ -f $SRC_HOME/${PRE_PROC}.sql ]] ; then
    $LIB_HOME/execSqlplus.ksh ${PRE_OPT:-} $PRE_PROC ${PRE_ARGS:-}
    if (($?!=0)) ; then
      print -u2 "$LIB_HOME/execSqlplus.ksh ${PRE_OPT:-} $PRE_PROC ${PRE_ARGS:-} - failed"
      exit 4
    fi
  else
    print -u2 $SRC_HOME/${PRE_PROC}.sql does not exist
    exit 4
  fi
fi

for file in $DATA_HOME/${APP_DIR}/*
do
  $LIB_HOME/execSqlldr.ksh ${LDR_OPT:-} -f $file $SRC_HOME/$CTL_FILE
  if (($?=0)) ; then
    mv $file $DATA_HOME/${APP_DIR}/processed/${TimeStamp}_$file
    print $file loaded
  else
    print -u2 "$LIB_HOME/execSqlldr.ksh ${LDR_OPT:-} -f $file $SRC_HOME/$CTL_FILE - failed"
    mv $file $DATA_HOME/${APP_DIR}/not_processed/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${file}
    RC=4
  fi
done

if (($RC!=0)) ; then
  print -u2 One or more files were not loaded
  exit 4
fi

if [[ -n ${POST_PROC:-} ]] ; then
  if [[ -f $SRC_HOME/${POST_PROC}.sql ]] ; then 
    $LIB_HOME/execSqlplus.ksh ${POST_OPT:-} $POST_PROC ${POST_ARGS:-}
    if (($?!=0)) ; then
      print -u2 "$LIB_HOME/execSqlplus.ksh ${POST_OPT:-} $POST_PROC ${POST_ARGS:-} - failed"
      exit 4
    fi
  else
    print -u2 $SRC_HOME/${POST_PROC}.sql does not exist
    exit 4
  fi
fi

return $RC
