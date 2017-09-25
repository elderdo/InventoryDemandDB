-- run at the end of post processing
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

@/tmp/enableUsers.sql

commit

host rm -f /tmp/enableUsers.sql

exit
