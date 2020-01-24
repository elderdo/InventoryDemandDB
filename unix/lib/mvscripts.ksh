#!/usr/bin/ksh
cd /tmp/wk
for f in *.ksh
do
  echo $f  
  chmod 770 /apps/CRON/AMD/lib/$f 
  mv /tmp/wk/$f /apps/CRON/AMD/lib/$f
  chmod 550 /apps/CRON/AMD/lib/$f
done
