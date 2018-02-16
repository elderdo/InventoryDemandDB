#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   09 Apr 2009 21:04:28  $
# $Workfile:   notify.ksh  $
USAGE="usage: ${0##*/} [-a addr_file] [-f from] [-t recipient addresses] [-c cc addresses_file] [-C cc addresses] [-s subject] [-m message] [-b] [-o] [-p]  [file1 file2....]
\t-d data_directory - directory where data can be stored
\t-a addr_file file used to get a list of recipients
\t-f from sender's id
\t-t addres@boeing.com,address@boeing.com ... a list of recipients
\t-c cc address_file a file containing a list of cc recipients
\t-h bcc address_file a file containing a list of bcc recipients
\t-C me@boeing.com,you@boeing.com,... a list of cc recipients
\t-s subject for the email
\t-m message to be sent
\t-b turn on debug
\t-o do not send a message just print it to stdout
\t-p do not send html, send plain text
\t [file1 file2...] optional file attachments"

if [[ $# > 0 && "$1" == "?" ]]
then
	print $USAGE
	exit 0
fi

hostname=$(uname -n)

function abort {
	print -u2 ${1:-"$0 failed"}
	print -u2 $USAGE
	print -u2 "ERROR: $0 aborted"
	print "ERROR: $0 aborted"
	exit ${2:-4}
}

UNVAR=${UNVAR:-}

if [[ -n $UNVAR && -e $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "$UNVAR/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
	print "Using $UNVAR for amdconfig"
elif [[ -e /apps/CRON/AMD/lib/amdconfig.ksh ]]
then
	. /apps/CRON/AMD/lib/amdconfig.ksh
	if (( $? > 0 ))
	then
		abort "/apps/CRON/AMD/lib/amdconfig.ksh failed"
	fi
elif [[ -e ./amdconfig.ksh ]]
then
	. ./amdconfig.ksh 
	if (( $? > 0 ))
	then
		abort "./amdconfig failed"
	fi
else
	abort "Cannot find amdconfig.ksh"
fi

OPTIND=1
while getopts :h:of:c:a:bpt:C:s:m: arguments
do
	case $arguments in
	  o) AMD_NOTIFY=N;;
	  p) EMAIL_CONTENT_TYPE=plain;;
	  m) MSG=$OPTARG;;
	  f) FROM=$OPTARG;;
	  t) TO=$OPTARG;;
	  c) CC_FILE=$OPTARG;;
	  h) BCC_FILE=$OPTARG;;
	  C) CC=$OPTARG;;
	  s) SUBJ=$OPTARG;;
	  a) ADDR_FILE=$OPTARG;;
	  b) debug=Y
	     set -x;;
	  d) DATA_HOME=$OPTARG;;
	  :) print "You forgot to enter a filename for $OPTARG"
	     exit 4;;
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

if [[ -n $LOGNAME ]] ; then
	if [[ -e /home/amd/amduser/${LOGNAME} ]] ; then
		USER_HOME=/home/amd/amduser/${LOGNAME}
		if [[ -e ${USER_HOME}/data/${ADDR_FILE:-"addresses.txt"} ]] ; then
			DATA_HOME=${USER_HOME}${DATA_HOME} 
		fi
	fi
fi

if [[ -z $TO ]]
then
	ADDR_FILE=${ADDR_FILE:-"addresses.txt"}

        case $ADDR_FILE in
         /*) absolute=1 ;;
          *) absolute=0 
             ADDR_FILE=$DATA_HOME/$ADDR_FILE ;;
        esac
	if [[ -e $ADDR_FILE ]]
	then
		{ while read myline; do
			if [[ -z $TO ]]
			then
				TO="$myline"
			else
				TO="$TO,$myline"
			fi
		  done } < $ADDR_FILE
	else
		abort "$ADDR_FILE does not exist"
	fi
fi

if [[ -z $CC ]]
then
	CC_FILE=${CC_FILE:-"cc.txt"}
	if [[ -e $DATA_HOME/$CC_FILE ]]
	then
		{ while read myline; do
			if [[ -z $CC ]]
			then
				CC="$myline"
			else
				CC="$CC,$myline"
			fi
		done } < $DATA_HOME/$CC_FILE
	else
		CC=
	fi
fi

if [[ -z $BCC ]]
then
	BCC_FILE=${BCC_FILE:-"bcc.txt"}
	if [[ -e $DATA_HOME/$BCC_FILE ]]
	then
		{ while read myline; do
			if [[ -z $BCC ]]
			then
				BCC="$myline"
			else
				BCC="$CC,$myline"
			fi
		done } < $DATA_HOME/$BCC_FILE
	else
		BCC=
	fi
fi

TO=${TO:-"Douglas.S.Elder@boeing.com,rena.r.huang@boeing.com"}


SUBJ=${SUBJ:-Test of $0@$AMDENV}

FROM=${FROM:-"$0_on_$hostname"}


if [[ "$AMD_NOTIFY" == "N" ]] ; then 
	print "Subject: $SUUBJ"
	print "From: $FROM"
	print "To: $TO"
	print "Cc: $CC"
	print "${MSG:-This is a test message}"
	for file in $*
	do
		print "attacment: $file"
	done
	return 0
fi

if [[ "${debug:-N}" == "Y" ]] ; then
	EMAIL_COMMAND="cat"
else
	EMAIL_COMMAND="/usr/sbin/sendmail  -t"
fi

# see if uuencode exists
# UUENCODE will be zero if it exists
which uuencode 2> /dev/null > /dev/null
UUENCODE=$?

{

cat << EOF
MIME-Version: 1.0
Subject: ${SUBJ}
From: ${FROM}
To: ${TO}
Cc: ${CC}
bcc: ${BCC}
EOF

cat << EOF
Content-Type: multipart/mixed; boundary=DMW.Boundary.605592468

--DMW.Boundary.605592468
Content-Type: text/${EMAIL_CONTENT_TYPE:-html}
Content-Disposition: inline
EOF


cat << EOF
<h2>** This is system generated message.  Do not reply to it. **</h2><br>

${MSG:-This is a test message}

EOF

if [[ -n $1 && -f $1 && "$UUENCODE" == "0" ]]
then
	for file in $*
	do
		if [[ -e $file ]]
		then
			# sed -e '/^[ \t]*$/d' -e 's/$/<br>/' ${file}
			BASE=$(basename $file)
			print -R "--DMW.Boundary.605592468"
			print "Content-Type: application/7bit\; name=\"$BASE\""
			print "Content-Disposition: attachment\; filename=\"$BASE\""
			print "Content-Transfer-Encoding: uuencode"
			print
			uuencode < $file $BASE
		else
			print "${file} does not exist."
		fi
	done
fi

} | $EMAIL_COMMAND
