#!/usr/bin/sh
# primsaCheck.sh
# author: Douglas S. Elder
# date: 5/17/2011
# desc: Run the filterPrimesa.sh script
# If there is an error log, send it

USAGE="Usage: primsaCheck.sh [-a addr_file] [-d] [-s] INPUT_FILE BAD_DATA GOOD_DATA [RECIPIENT]\n
 where\n
 -a addr_file is an optional text file containing a list of email recipients\n
 -d optional param that turns on debug\n
 -s optional param that causes the filterPrimsa.sh to be skipped\n
 INPUT_FILE is the PRIMSA file with a qty in columns 107-115\n
 BAD_DATA is the file containing the list of records with a bad qty\n
 GOOD_DATA is the file containing the good records\n
 RECIPIENT is required if the -a option is NOT used. They are mutually exclusive\n"
NUM_REQ_PARAMS=4
SKIP_FILTER=N
if [ -r "addresses.txt" ]
then
  ADDR_FILE="addresses.txt"
else
  ADDR_FILE=
fi  

OPTIND=1
while getopts :a:ds arguments
do
        case $arguments in
          a)	NUM_REQ_PARAMS=3 
		ADDR_FILE=$OPTARG;;
          s) SKIP_FILTER=Y ;;
          d) debug=Y
             set -x;;
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


if (($#!=$NUM_REQ_PARAMS))
then
	echo $USAGE
	exit 4
fi

hostname=`uname -n`
FROM=$0_of_$hostname
INPUT=$1
BAD_DATA=$2
GOOD_DATA=$3
if (($NUM_REQ_PARAMS==4))
then
  EMAIL_RECIPIENT=$4
else
  EMAIL_RECIPIENT=
fi

# sendMsg
# desc: Send the input file as part
# of an email. Limit the number
# of records sent based on the filesize
# to a maximum of 3500 records.
# params
# $1 subject for th e email
# $2 file to send
# $3 number of recs in file
sendMsg () {

# show only 3500 recs max per email
if (($3>3500))
then
  CMD1="3500 of $3"
  CMD2="head -n 3500"
else
  CMD1=
  CMD2=cat
fi

/usr/sbin/sendmail -t -i << EOF
From: $FROM
To: $EMAIL_RECIPIENT
Subject: $1

$CMD1
$($CMD2 $2)

EOF

}

if [ -n "$ADDR_FILE"  -a  -r "$ADDR_FILE"  ]
then
  { while read myline; do
      if [ -z "$EMAIL_RECIPIENT" ]
      then
	EMAIL_RECIPIENT="$myline"
      else	
        EMAIL_RECIPIENT="$EMAIL_RECIPIENT,$myline"
      fi
    done } < $ADDR_FILE
fi

if [ "$SKIP_FILTER" = N ]
then
  perl filterPrimsa.pl < $INPUT > $GOOD_DATA 2> $BAD_DATA
fi
if [ -r $GOOD_DATA ]
then
	good_recs=`wc -l $GOOD_DATA`
	sendMsg "Daily Changes From PRIMSA" $GOOD_DATA $good_recs
fi
if [ -r $BAD_DATA ]
then
	bad_recs=`wc -l $BAD_DATA`
	sendMsg "PRIMSA bad data" $BAD_DATA $bad_recs
fi
