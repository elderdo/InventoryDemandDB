#!/usr/bin/ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.19
#     $Date:   20 Nov 2015
# $Workfile:   execSqlplus.ksh  $
#
# 1.19 Douglas Elder 11/20/2015 removed -u2 so print will send output to stdout so checkforerrors.ksh will find error messages
# 1.18.1 Douglas Elder 9/3/2015 added SQLPATH to pick up login.sql script
# 1.18 Douglas Elder 9/15/2014 allow for an explicit sql path
# 1.17 Douglas Elder create a better log name that can use substeps when provided by the invoking script
# 1.16 Douglas Elder add the sqlplus script output to any error log created when sqlplus does not have a return code of zero
USAGE="usage: ${0##*/} [-c connection_string | -s ] [-t] [-n] [-e errorlog] [-l log] [-m msg] [-x xdir] sql [errorlog] [sqlparam1 sqlparam2...]
\nwhere
\t-r return the sqlplus exit code
\t-s use the spo connection string
\t\t(defaults to amd's connection string)
\t-c connection_string is the OracleUserid@TNSNAME/password
\t-e errorlog
\t-l log specify the name of the log file
\t-m message to be appended to the log file
\t-t report start and end times
\t-n do not use a log file for stdout
\t-x xdir exec sqlplus script contained in this directory
\t\tthe default is to create a log file for stdout based on the sql file name
\tsql is the sql file that gets executed
\terrorlog is the name of an optional file to create 
\t\twhen sqlplus has an error"

if [[ "$debug" == "Y" ]] ; then
	set -x
fi

if [[ "$1" == "?" || "$#" == "0" ]] ; then
	print "$USAGE"
	exit 0
fi

export UNVAR=${UNVAR:-}
if [[ -n $UNVAR ]] ; then
	print "Using $UNVAR for amdconfig.ksh"
fi

if [[ -z $SRC_HOME || -z $DB_CONNECTION_STRING || -z $LOG_HOME  ]] ; then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
fi

export SQLPATH=$SRC_HOME

while getopts :ndstl:m:c:e:x:r arguments
do
	case $arguments in
	  e) SQLPLUS_ERROR_LOG=${OPTARG};;
	  x) SRC_HOME=${OPTARG};;
	  l) LOG_NAME=${OPTARG};;
	  m) APP_MSG=${OPTARG};;
	  c) THE_CONNECTION_STRING=${OPTARG};;
	  s) THE_CONNECTION_STRING=$DB_CONNECTION_STRING_FOR_SPO;;
	  t) REPORT_TIMES=Y;;
	  d) debug=Y
	     set -x ;;
	  n) SQLPLUS_LOG=N;;
	  r) RETURN_RC=Y;;
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

if [[ -z ${TimeStamp:-} ]] ; then
	TimeStamp=$(date $DateStr | sed "s/:/_/g");
else
	TimeStamp=$(print $TimeStamp | sed "s/:/_/g")
fi

REPORT_TIMES=${REPORT_TIMES:-N}

# default to the AMD Connection String
THE_CONNECTION_STRING=${THE_CONNECTION_STRING:-$DB_CONNECTION_STRING}
if [[ -z $THE_CONNECTION_STRING ]] ; then
	print "System error: connection string not set"
	print "$USAGE"
	exit 4
fi

# remove path
sqlplus_script=$(basename "$1")
# get the file's extension
extension="${sqlplus_script##*.}"
# get file without extension
sqlplus_script="${sqlplus_script%.*}"

if [[ -f ${1} ]]; then
  SQLPLUS_SCRIPT_FILE=${1}
  shift
else
  # look for the sql file in the src directory

  if [[ -f $SRC_HOME/${sqlplus_script}.sql ]] ; then
    SQLPLUS_SCRIPT_FILE=$SRC_HOME/${sqlplus_script}.sql
    shift
  else
    print "$SRC_HOME/${sqlplus_script}.sql does not exist."
    exit 4
  fi

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

LOG_NAME=${LOG_NAME:-$LOG_HOME/${TimeStamp}_${AMD_CUR_STEP:+${AMD_CUR_STEP}_}${SUBSTEP:+${SUBSTEP}_}${sqlplus_script}.log}

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
