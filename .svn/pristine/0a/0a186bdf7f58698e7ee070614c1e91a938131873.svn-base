whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size 100000

declare
cnt number := 0 ;
cursor bad_user_types is
select bems_id, user_type
from amd_user_type
where user_type not in (select NAME
			from spo_user_type_v) ;	               
theWarningMsg varchar2(32000) := '' ;		
PROCEDURE log(iMessage VARCHAR2) IS
    vMaxLength NUMBER := 200;
    vSpace     NUMBER;
    vMessage   VARCHAR2(32000) := iMessage;
BEGIN
    LOOP
      EXIT WHEN  vMessage IS NULL;
      vSpace := instr(vMessage, ' ', vMaxLength);
      IF vSpace = 0 THEN
        vSpace := vMaxLength + 1;
      END IF;
      dbms_output.put_line(substr(vMessage, 1, vSpace - 1));
      vMessage := substr(vMessage, vSpace);
    END LOOP;
END log;
begin
	for rec in bad_user_types loop
		dbms_output.put_line('bems_id=' || rec.bems_id) ;
		dbms_output.put_line('user_type=' || rec.user_type) ;
		theWarningMsg := 'amd_user_type: ' 
			|| rec.bems_id
			|| ' has a user_type of '
			|| rec.user_type 
			|| ' that is not in spo_user_type_v.' 
			|| ' You need to update amd_user_type' 
			|| ' with the correct user_type from spo_user_type_v.' 
			|| ' For example: update amd_user_type set user_type = ''DATA-MANAGER'' where' 
		       	|| ' user_type = ''DATA MANAGER''' ;
		amd_warnings_pkg.insertWarningMsg(1,'amd_user_type', pWarning => theWarningMsg) ;
		log(theWarningMsg) ;
		cnt := cnt + 1 ;
	end loop ;
	if cnt > 0 then
		dbms_output.put_line('There were ' || cnt || ' rows needing updated for amd_user_type') ;
	else
		--dbms_output.put_line('All user_type''s were ok for amd_user_type') ;
		null ; -- do nothing
	end if ;
end ;
/

exit
