#!/usr/bin/ksh
# vim:ts=2:sw=2:sts=2+expandtab:autoindent:
# validateScripts.ksh
# Author: Douglas S. Elder
# Date: 01/18/2018
# Rev: 1.0
# Desc: scan all *.ksh and *.sh
# files for Korn Shell syntax
# errors or warnings
#
# Rev 1.0    01/18/2018 Douglas S. Elder    Initial Rev

RECIPIENTS=
TimeStamp=$(date +%Y%m%d_%H_%M_$S)
ERROR_LOG=/tmp/${TimeStamp}_errors.log
LOG=/tmp/${TimeStamp}_validateScripts.log
CNT=0
ERRCNT=0
HOST=$(hostname -s)

function join {
  typeset IFS=,
  echo "$*"
}

if (($#>0)) ; then
  RECIPIENTS=$(join $*)
fi


function createEmail  {
  echo To: ${RECIPIENTS}
  echo From: validateScripts@${HOST}
  echo Subject: Script scan $1
  echo
  echo "******** $LOG **********"""
  cat $LOG
  if ((ERRCNT>0))  ; then # any errors ?
    echo
    echo "******** $ERROR_LOG *********"
    cat $ERROR_LOG
  fi # any errors
}


function main {
  if [[ "$debug" == "Y" ]] ; then
    set -x
  fi
  echo "$(date) scanning scripts for $(pwd)"
  # process all files ending in ksh or sh
  # including hidden files ( dot files )
  for f in *.ksh .*.ksh *.sh .*.sh
  do

    ((CNT=CNT+1))

    if [[ -e $f ]] ; then # exists ?

      echo Processing script $f

      if [[ -r $f ]] ; then # is readable ?
        if [[  -x $f ]] ; then # is executable

          ksh -n $f
          if (($?!=0)) ; then # has errors ?
            ((ERRCNT=ERRCNT+1))
            echo $f had one or more errors 
            echo $f had one or more errors >> $ERROR_LOG
          fi # end has errors

        else
          echo $f is not executable by $user
          continue
        fi # end is executable
      else
        echo $f is not readable by $user
      fi # end is readable
    fi # end exists

  done 2> /dev/null
  echo Procesed $CNT script files. $ERRCNT  had one or more errors
}

main 2>&1 | tee -a $LOG

if ((ERCNT>0)) ; then # any errors ?
  RESULT=Unsuccessfull
  cat $ERROR_LOG  | more
else
  RESULT=Successful
fi # end any errors

if [[ "${RECIPIENTS}" != "" ]] ; then # send mail ?
  createEmail $RESULT |  sendmail -t
fi # end send mail
