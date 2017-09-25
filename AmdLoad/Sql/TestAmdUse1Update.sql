/*
    Create users in amd_owner.amd_use1 that will get sent to SPO
*/

spool /tmp/AmdUse1Output.txt

@../data/AmdUse1Update.sql

spool off

rollback ;

quit
