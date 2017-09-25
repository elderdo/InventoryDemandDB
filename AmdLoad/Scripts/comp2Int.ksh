scp sbhs6144.slb.cal.boeing.com:/apps/CRON/AMD/lib/$1 /tmp/$1 > /dev/null 2>&1
diff $1 /tmp/$1
