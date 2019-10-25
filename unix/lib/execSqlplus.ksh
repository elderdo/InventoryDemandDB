#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.20
#     $Date:   20 Nov 2015
# $Workfile:   execSqlplus.ksh  $
#
# 1.20  Douglas Elder 10/07/2019 Added additional checks for positional
#                                arg 1 which should be the 
#                                SQL*Plus script
#                                Created the usage function
# 1.19  Douglas Elder 11/20/2015 removed -u2 so print will send 
#                                output to stdout so checkforerrors.ksh
#                                will find error messages
# 1.18.1 Douglas Elder 9/3/2015 added SQLPATH to pick up login.sql script
# 1.18 Douglas Elder   9/15/2014 allow for an explicit sql path
# 1.17 Douglas Elder             create a better log name that can 
#                                use substeps when provided by the 
#                                invoking script
# 1.16 Douglas Elder             add the sqlplus script output to any 
#                                error log created when sqlplus does 
#                                NOT have a return code of zero
function usage {
  2>&1 echo ""
  2>&1 echo ""
  2>&1 echo "usage: execSqlplus.ksh  [-c connection_string | -s"
  2>&1 echo "       -e errorlog -l log -m msg -n -s -t -x xdir ] sql"
  2>&1 echo "            [ sqlparam1 sqlparam2...]"
  2>&1 echo ""
  2>&1 echo "       where"
  2>&1 echo "       all dash switches are optional"
  2>&1 echo "       -c connection_string is the OracleUserid@TNSNAME/password"
  2>&1 echo "       -e errorlog"
  2>&1 echo "       -h displays this message"
  2>&1 echo "       -l log specify the name of the log file"
  2>&1 echo "       -m message to be appended to the log file"
  2>&1 echo "       -n do not use a log file for stdout"
  2>&1 echo "       -r return the sqlplus exit code"
  2>&1 echo "           when sqlplus has an error"
  2>&1 echo "       -s use the spo connection string"
  2>&1 echo "                      (defaults to amd's connection string"
  2>&1 echo "       -t report start and end times"
  2>&1 echo "       -x xdir where xdir is the directory containing"
  2>&1 echo "          the SQL*Plus scripts"
  2>&1 echo "       positional arguments:"
  2>&1 echo "       sql a required positional argment"
  2>&1 echo "           it is the sql file that gets executed"
  2>&1 echo "       sqlpus1, ...2,  are optional positional arguments"
  2>&1 echo "       for the SQL*Plus script"
  2>&1 echo ""
  2>&1 echo ""
}

# set defaults
EXT="sql"
APP_HOME=/apps/CRON/AMD
LIB=$APP_HOME/lib
DAT=$APP_HOME/data
REPORT_TIMES=N
SQLPLUS_SCRIPT=
DEBUG=
# turn on debug by setting file $DAT/debug.txt to a Y
# debug messages will be going to stderr so need to send 
# stderr to some file like $(mktemp) when execuing this script
[[ -f "$DAT/debug.txt" ]] && DEBUG=$(cat $DAT/debug.txt)

if [[ -z $SRC_HOME || -z $DB_CONNECTION_STRING || -z $LOG_HOME  ]] ; then
  # get defaults
  if [[ -f $LIB/amdconfig.ksh ]] ; then
  	. $LIB/amdconfig.ksh
  else
    LIB_HOME=$APP_HOME/lib
    SRC_HOME=$APP_HOME/src
    LOG_HOME=$APP_HOME/log
    if [[ -f DB_CONNECTION_STRING ]] ; then
      . DB_CONNECTION_STRING
    fi
  fi
  if [[ "$SRC_HOME" != "" ]] ; then
    export SQLPATH=$SRC_HOME
  fi
fi
[[ "$DEBUG" == "Y" ]] && >&2 echo "$0 $@"

function getScript {
  [[ "$DEBUG" == "Y" ]] && >&2 echo "getScript "

  if [[ "$DEBUG" == "Y" ]] ; then
    set -x
  fi

  if [[ "$1" == "" ]] ; then
    >&2 echo "execSqlplus.ksh: Missing argument for getScript"
    usage
    return 4
  fi
  if (($#!=1)) ; then
    >&2 echo "execSqlplus.ksh: Missing argument for getScript"
    usage
    return 4
  fi

  [[ "$DEBUG" == "Y" ]] && >&2 echo "arg1=$1"
  SQLPLUS_SCRIPT=$(basename "$1")
  typeset SCRIPT=
  typeset RC=0
  [[ "$DEBUG" == "Y" ]] && >&2 echo "SQLPLUS_SCRIPT=${SQLPLUS_SCRIPT}"

  # is the file accessable
  if [[ -f ${1} ]]; then
    SCRIPT="${1}"
  else
    # it must be a file in the src directory
    if [[ "$SQLPLUS_SCRIPT" == "" ]] ; then
      echo "Unable to get basename of SQL*Plus script"
      RC=4 
    else  
      # get the file's extension
      EXT="${SQLPLUS_SCRIPT##*.}"
      [[ "$DEBUG" == "Y" ]] && >&2 echo "EXT=${EXT}"
      if [[ "$EXT" == "" ]] ; then
        EXT=sql
      fi
      # get file without extension
      SQLPLUS_SCRIPT="${SQLPLUS_SCRIPT%.*}"
      [[ "$DEBUG" == "Y" ]] && >&2 echo "SQLPLUS_SCRIPT=${SQLPLUS_SCRIPT}"
      if [[ "$SQLPLUS_SCRIPT" == "" ]] ; then
        echo "argument 1 does not appear to be a SQL*Plus script"
        echo "args: $@"
        RC=4
      elif [[ -f $SRC_HOME/${SQLPLUS_SCRIPT}.sql ]] ; then
        SCRIPT=$SRC_HOME/${SQLPLUS_SCRIPT}.sql
      elif [[ -f $SRC_HOME/${SQLPLUS_SCRIPT} ]] ; then
        SCRIPT=$SRC_HOME/${SQLPLUS_SCRIPT}
      else
        echo "SQL*Plus script was not found"
        RC=4
      fi
    fi
  fi

  echo $SCRIPT
  return $RC
}

if [[ "$DEBUG" == "Y" ]] ; then
	set -x
fi

if [[ "$1" == "?" || "$#" == "0" ]] ; then
	usage
	exit 0
fi


if [[ "$DB_CONNECTION_STRING" != "" ]] ; then
  THE_CONNECTION_STRING=$DB_CONNECTION_STRING
fi

[[ "$DEBUG" == "Y" ]] && >&2 echo "Number of Args=$#"
cnt=0
for var in "$@"
do
  ((cnt++))
  [[ "$DEBUG" == "Y" ]] && >&2 echo "args ${cnt}. $var" 
done

while getopts :c:de:hl:m:nrstx: arguments
do
	case $arguments in
	  c) THE_CONNECTION_STRING="${OPTARG}";;
	  d) set -x
       DEBUG=Y;;
	  e) SQLPLUS_ERROR_LOG="${OPTARG}";;
	  h) usage
       exit 0;;
	  l) LOG_NAME="${OPTARG}"
       >&2 echo "LOG_NAME=$LOG_NAME";;
	  m) APP_MSG=${OPTARG};;
	  n) SQLPLUS_LOG=N;;
	  r) RETURN_RC=Y;;
	  s) if [[ -f DB_CONNECTION_STRING_FOR_SPO ]] ; then
         THE_CONNECTION_STRING=$DB_CONNECTION_STRING_FOR_SPO
       else
         echo "file DB_CONNECTION_STRING_FOR_SPO does not exist"
         usage
         exit 4
       fi;;
	  t) REPORT_TIMES=Y;;
	  x) SRC_HOME="${OPTARG}";;
	  *) usage
	     exit 4;;
	esac
done

[[ "$DEBUG" == "Y" ]] && >&2 echo "OPTIND=$OPTIND"

cnt=0
for var in "$@"
do
  ((cnt++))
  [[ "$DEBUG" == "Y" ]] && >&2 echo "args ${cnt}. $var" 
done

shift $((OPTIND - 1))

[[ "$DEBUG" == "Y" ]] && echo "$0 $@"

if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
	TimeStamp=$(print $TimeStamp | sed "s/:/_/g")
fi


# default to the AMD Connection String
if [[ -z $THE_CONNECTION_STRING ]] ; then
	echo "System error: connection string not set"
  usage
	exit 4
fi

if (($#==0)) || [[ "$1" == "" ]] ; then
  echo "Missing script to execute"
  usage
  exit 4
fi
[[ "$DEBUG" == "Y" ]] && >2& echo "num args $#"
[[ "$DEBUG" == "Y" ]] && >2& echo "invoking getScript $1"
SQLPLUS_SCRIPT_FILE=$(getScript "$1")
RC=$?
if [[ "$RC" != "0" ]] ; then
  echo "executed as: $0 $@"
  exit $RC
else
  shift
fi
if [[ "$SQLPLUS_SCRIPT_FILE" == "" ]] ; then
  echo "SQPLUS_SCRIPT_FILE is missing"
  usage
  exit 4
fi


grep -q "&1" ${SQLPLUS_SCRIPT_FILE}
if (($?==0)) ; then
	if (($#<1)) ; then
		if [[ -n ${SQLPLUS_ERROR_LOG:-} ]] ; then
			print "Error: execSqlplus.ksh error - sql script contains variables but no command line args were specified" >> $SQLPLUS_ERROR_LOG
		fi
		print "Error: execSqlplus.ksh error - sql script contains variables but no command line args were specified"
		exit 4
	fi
fi


if [[ "$REPORT_TIMES" == "Y" ]] ; then
	print "execSqlplus for $SQLPLUS_SCRIPT_FILE started at $(date)"
fi

LOG_NAME=${LOG_NAME:-$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${SUBSTEP:+${SUBSTEP}_}${SQLPLUS_SCRIPT}.log}

if [[ "${SQLPLUS_LOG:-Y}" == "Y" ]] ; then
	if [[ -n ${APP_MSG:-} ]] ; then
		print "$APP_MSG" >> $LOG_NAME
	fi
	sqlplus -logon $THE_CONNECTION_STRING @${SQLPLUS_SCRIPT_FILE} \
      	>> $LOG_NAME 2>&1 "$@"
else
	if [[ -n ${APP_MSG:-} ]] ; then
		print "$APP_MSG" 
	fi
	sqlplus -logon $THE_CONNECTION_STRING  @${SQLPLUS_SCRIPT_FILE}  "$@"
fi
RC=$?
if [[ "$REPORT_TIMES" == "Y" ]] ; then
	print "execSqlplus for $SQLPLUS_SCRIPT_FILE ended at $(date)"
fi
if  [[ "${RETURN_RC:-N}" == "Y" ]] ; then
	return $RC
fi
if ((RC!=0)) ; then
	# the error log file can be checked by any parent process
	if [[ -n ${SQLPLUS_ERROR_LOG:-} ]] ; then
		cat $LOG_NAME >> $SQLPLUS_ERROR_LOG
		print "Error: sqlplus exit code = $RC for ${SQLPLUS_SCRIPT_FILE}" >>$SQLPLUS_ERROR_LOG
	fi
	print "Error: sqlplus exit code = $RC for ${SQLPLUS_SCRIPT_FILE}" 
	exit 4
fi
