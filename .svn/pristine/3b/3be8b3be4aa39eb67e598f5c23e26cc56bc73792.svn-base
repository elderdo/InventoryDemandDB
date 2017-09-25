#!/usr/bin/sh
# filterPrimsa.sh
# author: Douglas S. Elder
# date: 5/17/2011
# desc: This script checks columns 107 to 115
# of the PRIMSA input file for numeric values
# greater than zero
# Input is via stdin
# Bad data is written to stderr
# Good data is written to stdout
#

badQty() {
  qty=`echo "$line" | cut -c 107-115`
  print -u2 "record: $cnt kit: $kit part: $part bad qty: <$qty>"
}

typeset -R5 cnt
cnt=0
while read line
do
  cnt=`expr $cnt + 1`
  kit=`echo "$line" | cut -c 1-20`
  part=`echo "$line" | cut -c 87-106`
  if echo "$line" | cut -c 107-115 | tr ' ' '0' | grep -q '^[0-9]*$' 
  then
    qty=`echo "$line" | cut -c 107-115 | tr ' ' '0'`
    if [ $qty -le 0 ]
    then
	badQty
    else
	echo "$line"
    fi
  else
    badQty 
  fi
done 
