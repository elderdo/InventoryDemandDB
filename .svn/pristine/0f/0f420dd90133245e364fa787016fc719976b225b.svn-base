#!/usr/bin/ksh
# File: fixscripts.ksh
# Author: Douglas S. Elder
# Date: 8/21/2015
#
# Desc: For all scripts in the same directory
# as this script, apply the sed commands.
# When the file is changed it gets
# copied to directory $WORK
# and a backup of the original file will be 
# copied to directory ./bku.
# If the file didn't change
# it gets removed from the $WORK directory.
# After inspecting the resulting output with vi
# and the new file looks good,
# then replace the current ones with this new
# script.
#
# --------------------------------------------
# Rev 1.0 08/21/2015 DSE Initial Rev
# Rev 1.1 05/01/2016 DSE added commemnts
#                        and optional
#                        command line argument
#                        to override the script file extension
#                        for example:
#
# fixscripts.ksh sh      would make the script file extension sh  


PARENT=$(basename $(dirname `pwd`))
WORK=/tmp/wk$PARENT
if (($#==0)) ; then
  FILE_EXT=ksh
else
  FILE_EXT=$1
fi

ORACLE_HOME=$(dirname $(dirname $(find / -type f -name "sqlplus" -executable -print 2> /dev/null | xargs ls -t | head -n 1)))
JAVA_HOME=$(dirname $(dirname $(find / -type f -name "javac" -executable  -print 2> /dev/null | xargs ls -t | head -n 1)))

if [[ ! -d $WORK ]] ; then
  mkdir $WORK
  chmod 770 $WORK
fi
rm -f $WORK/*.${FILE_EXT}

function update {
  IN=$1
  OUT=$2
sed -f - "$IN" > "$OUT" << SED_SCRIPT
s/^ *\([a-zA-Z][a-zA-Z0-9_]*\)()/function \1/
s/uname -n/hostname -s/
s/JRE=.* *$/JRE=${JAVA_HOME}/
s/ORACLE_HOME=.* *$/ORACLE_HOME=${ORACLE_HOME}/
SED_SCRIPT

}

for f in *.${FILE_EXT}
do
  echo $f  
  update $f $WORK/$f
  diff $f $WORK/$f
  if (($?==0)) ; then
    rm $WORK/$f
  else
    if [[ ! -d bku ]] ; then
      mkdir bku
    fi
    cp $f bku/.
  fi
done
