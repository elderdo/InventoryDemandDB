whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

update spoc17v2.flag
set value = 'Boeing Proprietary - Distribution Limited to Boeing Personnel Only - Warning a System Update is in Progress - Please Logoff'
where name = 'SECURITY_NOTICE_TEXT' ;

commit

quit

