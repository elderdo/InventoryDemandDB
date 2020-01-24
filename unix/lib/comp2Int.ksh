scp ussevm83.cs.boeing.com:/apps/CRON/AMD/lib/$1 /tmp/$1 > /dev/null 2>&1
diff $1 /tmp/$1
