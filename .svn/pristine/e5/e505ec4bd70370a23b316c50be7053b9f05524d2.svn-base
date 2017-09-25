#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.7  $
#     $Date:   24 Jun 2008 10:31:34  $
# $Workfile:   recordCnts.ksh  $
USAGE="usage: $0 [AMDXML_CNT AMDQUEUE_CNT] [-d | -i | -p] [-b]
where
\tAMDXML_CNT\tnumber
\tAMDQUEUE_CNT\tnumber
\t-d is AMDD
\t-i is AMDI
\t-p is AMDP
\t-b debug mode" # switch arguments

if (($#==0)) ; then
	print "$USAGE"
	exit 0
fi

curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"recordCnts.ksh failed"}
	print -u2 $USAGE
	exit ${2:-4}
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
			if [[ ${curScript%/query.ksh} = "." ]]
			then
				curScript=`pwd`/query.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/query.ksh) export myenv=dev ;;
			 $STL_HOME/bin/prd/query.ksh) export myenv=prd ;;
			 $STL_HOME/bin/crp/query.ksh) export myenv=crp ;;
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
while getopts :dipbq: arguments
do
	case $arguments in
	  b) set -x;;
	  d) AMD_DATABASE=amdd;;
	  i) AMD_DATABASE=amdi;;
	  p) AMD_DATABASE=amdp;;
	  \?) print "$OPTARG is not a valid switch."
	     print "$USAGE"
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


AMD_DATABASE=${AMD_DATABASE:-}
if [[ -z $AMD_DATABASE ]]
then
	case $AMDENV in

		prd) AMD_DATABASE=AMDP;;
		it) AMD_DATABASE=AMDI;;
		dev) AMD_DATABASE=AMDD;;
	esac
fi

if [[ -z $AMD_DATABASE ]]
then
	abort "AMD_DATABASE not defined"
fi

if (( $# > 0 ))
then
	if [[ -n $1 && -n $2 ]]
	then
		AMDXML_CNT=$1
		AMDQUEUE_CNT=$2
	else
		abort "You must pass in 2 numbers"
	fi
fi

if [[ -z $AMDXML_CNT ]]
then
	abort "AMDXML_CNT not set"
fi

if [[ -z $AMDQUEUE_CNT ]]
then
	abort "AMDQUEUE_CNT not set"
fi
XML_COUNTS=${XML_COUNTS:-xmlCounts.xml}
queryStr=
typeset -i indx
indx=0
#### ### print XML_HOME=$XML_HOME XML_COUNTS=$XML_COUNTS
awk '{ tran_cnt[$1] = tran_cnt[$1] + $2 } END { for (tran in tran_cnt) print tran, tran_cnt[tran] }' $XML_HOME/$XML_COUNTS > /tmp/xmlCounts.txt
if [[ -O /tmp/xmlCounts.txt ]] ; then
	chgrp dstagelb /tmp/xmlCounts.txt
	chmod g+w /tmp/xmlCounts.txt
fi
cnt=`wc -l < /tmp/xmlCounts.txt`
if  (( $cnt == 0 ))
then
	exit 0
fi
while read tranType tranCnt
do
	### print $tranType $tranCnt
	queryStr="$queryStr nvl(${tranType},0)"
	let indx=indx+1
	if (( indx < cnt ))
	then
			queryStr="$queryStr + "
	else
			queryStr="$queryStr trncn "
			break
	fi
done  < /tmp/xmlCounts.txt
print $queryStr

DB_CONNECTION_STRING=${DB_CONNECTION_STRING:-bsrm_loader/fromnewyork@$AMD_DATABASE}
TRANS_PROCESSED=`sqlplus -s $DB_CONNECTION_STRING <<EOF

whenever sqlerror exit FAILURE
set feedback off
set echo off
set term off
set heading off

insert into amd_counts
(count_name, count_no)
values ('amdxml_cnt', $AMDXML_CNT) ;

insert into amd_counts
(count_name, count_no)
values ('amdqueue_cnt', $AMDQUEUE_CNT) ;

insert into amd_countS
(count_name, count_no)
select 'transprocessed',
$queryStr
 from datasys_trans_processed_v
where day = (select max(day) from datasys_trans_processed_v) ;

set echo on

select 
$queryStr
 from datasys_trans_processed_v
where day = (select max(day) from datasys_trans_processed_v) ;

quit
EOF
`
TRANS_PROCESSED=`print $TRANS_PROCESSED | sed 's/\/n//'`

hostname=`uname -n`

if (( AMDXML_CNT == AMDQUEUE_CNT && AMDQUEUE_CNT == TRANS_PROCESSED ))
then
	print "AMDXML_CNT = AMDQUEUE_CNT = TRANS_PROCESSED = $TRANS_PROCESSED"
else
	#sendErrorMsg.ksh "$0" "Counts are not equal" "Counts are not equal - AMDXML_CNT=$AMDXML_CNT AMDQUEUE_CNT=$AMDQUEUE_CNT and TRANS_PROCESSED=$TRANS_PROCESSED @ $myenv on $hostname"
	print "Counts are not equal - AMDXML_CNT=$AMDXML_CNT AMDQUEUE_CNT=$AMDQUEUE_CNT and TRANS_PROCESSED=$TRANS_PROCESSED @ $myenv on $hostname"
	exit 4
fi

exit 0
