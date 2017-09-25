#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.7  $
#     $Date:   02 May 2007 08:40:36  $
# $Workfile:   query.ksh  $
USAGE="usage: $0 [-q query_directory] [-d | -i | -p] [-b]\n\t-d is AMDD\n\t-i is AMDI\n\t-p is AMDP\n\t-b debug mode" # switch arguments
curUser=`whoami`
belongingTo="belonging to the folowing group(s) `groups`"

function abort {
	print -u2 ${1:-"query.ksh failed"}
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
		AMD_SPO_ENV=${AMD_SPO_ENV:-}
		if [[ -z $AMD_SPO_ENV ]]
		then
			curScript=`which $0`
			if [[ ${curScript%/query.ksh} = "." ]]
			then
				curScript=`pwd`/query.ksh
			fi
			case $curScript in
			 $STL_HOME/bin/dev/query.ksh) export AMD_SPO_ENV=dev ;;
			 $STL_HOME/bin/prd/query.ksh) export AMD_SPO_ENV=prd ;;
			 $STL_HOME/bin/crp/query.ksh) export AMD_SPO_ENV=crp ;;
			 *) abort "Unable to set AMD_SPO_ENV"
			esac
		fi
		if [[ -a ${STL_HOME}/bin/$AMD_SPO_ENV/amdconfig.ksh ]]
		then
			configFile=${STL_HOME}/bin/$AMD_SPO_ENV/amdconfig.ksh 
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
	  q) SRC_HOME=$OPTARG;;
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
		prod) AMD_DATABASE=AMDP;;
		it) AMD_DATABASE=AMDI;;
		dev) AMD_DATABASE=AMDD;;
	esac
fi

if [[ -z $AMD_DATABASE ]]
then
	abort "AMD_DATABASE not defined"
fi

if [[ $# = 1 ]]
then
	query=$1
	runit=/
else
	runit=
	if [[ -n $AMD_SPO_ENV ]]
	then
		query=@$SRC_HOME/$AMD_SPO_ENV/queries/batchJob.sql
	else
		query=@$SRC_HOME/batchJob.sql
	fi

fi
sqlplus -s bsrm_loader/fromnewyork@${AMD_DATABASE} <<EOF
$query
$runit
EOF
