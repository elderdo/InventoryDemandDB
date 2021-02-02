#!/bin/ksh 
source /apps/CRON/AMD/lib/amdconfig.ksh
MesgFile=/tmp/AmdMesgBody25100.txt
hostname=$(hostname -s)
FileType=L67
InFile=L67Nov2020.txt
ADDRESSES=$DATA_HOME/douglas.txt
 if [[ -s $MesgFile ]]
 then
    $LIB_HOME/notify.ksh \
       -s "$FileType Notification on $hostname" \
       -m "L67 data loaded for $InFile" \
       -a $ADDRESSES ${MesgFile}
 fi

