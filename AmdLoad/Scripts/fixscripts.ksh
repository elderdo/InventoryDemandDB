#!/usr/bin/ksh
# fixscripts.ksh
# Author: Douglas S. Elder
# Date: 9/21/2017
# Rev: 1.1
# Use a sed script to apply
# several changes to ksh files.
# Once changed move them from the
# working directory to their normal
# directory and test the script.
# Check syntaix with ksh -n scriptname.ksh
#
# 
# scripts and put the output
#  Input: all the files with a ksh file extension
# Output: a work directory containing only the modified
#         scripts
#         a bku ( backup directory ) of all the 
#         modified ksh scripts.
# 
#  Rev 1.0  08/21/2015 Initial Rev
#  Rev 1.1  09/21/2017 Added comments
PARENT=$(basename $(dirname $(pwd)))
WORK=/tmp/wk$PARENT
if [[ ! -d $WORK ]] ; then
  mkdir $WORK
  chmod 770 $WORK
fi
rm -f $WORK/*.ksh
for f in *.ksh
do
  echo $f  
  sed  -f fixscripts.sed $f  > $WORK/$f
  diff $f $WORK/$f
  if (($?==0)) ; then
    rm $WORK/$f
  else
    cp $f bku/.
  fi
done
