#!/bin/ksh
# vim:ts=2:sts=2:sw=2:expandtab:autoindent:smartindent:ff=unix:
# oraCheck.ksh
#   $Author:   Douglas S. Elder
# $Revision:   1.1 
#     $Date:   10 Mar 2007 20:55:56  $
# $Workfile:   oraCheck.ksh  $
# Rev 1.0 10 Mar 2007  Douglas S. Elder Initial rev
# Rev 1.1 15 Feb 2018  Douglas S. Elder removed obsolete back tic's, use -e vs obsolete -a
USAGE="usage: ${0##*/} sql_query\n\tsql_query\tan sql query that returns a single value"

if [[ $# > 0 && ${1} == "?" ]]
then
	print $USAGE
	exit 0
fi

hostname=$(hostname -s)

function abort {
	print -u2 ${1:-"$0 failed"}
	print -u2 $USAGE
	print -u2 "ERROR: $0 aborted"
	print "ERROR: $0 aborted"
	exit ${2:-4}
}

UNVAR=${UNVAR:-}

if [[ -e $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CrON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -e /apps/CRON/AMD/lib/amdconfig.ksh ]]
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
		abort $(which amdconfig.ksh) failed
	fi
fi

if [[ -z $TimeStamp ]]
then
	TimeStamp=$(date $DateStr)
fi

if [ -z "${ORACLE_HOME}" ]
then
    echo ""
    echo "ORACLE_HOME is not set."
    echo "ORACLE_HOME is needed for SQL*Plus and SQL*LDR."
    echo ""
    echo "Exiting $0"
    echo ""
    exit 1
fi

if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
then
    echo ""
    echo "Can not find sqlplus."
    echo ""
    echo "Exiting $0"
    echo ""
    exit 1
fi

if (( $# > 0 ))
then
	query=$1
  if [[ "${query:((${#query}-1)):1}" != ";" ]] ; then
    query="${query};"
  fi
else
	print -u2 "You must pass a query"
	exit 4
fi

RESULT=$(sqlplus -s $DB_CONNECTION_STRING <<EOF
    set heading off feedback off verify off
    ${query:-select 'Y' from dual}
    exit
EOF
)
RESULT=$(print $RESULT | tr "[a-z]" "[A-Z]")
print "$RESULT"

