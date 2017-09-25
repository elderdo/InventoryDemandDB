/*
	Description:
	Create users in amd_owner.amd_use1 and amd_owner.uims with planner_codes 
	so that the users will get sent to SPO.
	Author: Douglas Elder
	Create Date:  9/19/200

	  $Author:   zf297a  $
	$Revision:   1.1  $
	    $Date:   19 Sep 2008 11:50:20  $
	$Workfile:   UimsAndUse1Update.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\UimsAndUse1Update.sql.-arc  $
/*   
/*      Rev 1.1   19 Sep 2008 11:50:20   zf297a
/*   Fixed PVCS keyword $Author$
/*   
/*      Rev 1.0   19 Sep 2008 11:49:18   zf297a
/*   Initial revision.
	
*/
set serveroutput on size 100000
set linesize 200
set wrap on

spool UimsAndUse1Output.txt

declare
    ACTIVE_STATUS constant varchar2(1)  := 'A' ;
    procedure insertAmdUse1Row(userid in amd_use1.userid%type, 
                user_name in amd_use1.user_name%type, 
                employee_no in amd_use1.employee_no%type,
                phone in amd_use1.phone%type, 
                ims_designator_code in amd_use1.ims_designator_code%type, 
                employee_status in amd_use1.employee_status%type) is
        inuse_userid amd_use1.USERID%type ;
        old_user_name amd_use1.user_name%type ;
        old_employee_no amd_use1.employee_no%type ;
        old_phone amd_use1.phone%type ;
        old_ims_designator_code amd_use1.ims_designator_code%type ;
        old_employee_status amd_use1.employee_status%type ;
        old_last_update_dt amd_use1.last_update_dt%type ;
        procedure beforeMsg is
        begin
            dbms_output.put_line('before: ' || insertAmdUse1Row.inuse_userid 
            || ' old_user_name=' || nvl(old_user_name,'null')  
            || ' old_employee_no=' || nvl(old_employee_no,'null') 
            || ' old_phone=' || nvl(old_phone,'null') ) ;
            dbms_output.put_line('---- old_ims_designator_code=' || nvl(old_ims_designator_code,'null')
            || ' old_employee_status=' || nvl(old_employee_status,'null') 
            || ' old_last_update_dt=' || to_char(nvl(old_last_update_dt,sysdate),'MM/DD/YYYY HH:MI:SS AM') ) ;
        end beforeMsg ;
        
        procedure afterMsg is
        begin
            dbms_output.put_line('after: ' || insertAmdUse1Row.inuse_userid ||
                ' user_name=' || insertAmdUse1Row.user_name ||  
                ' employee_no=' || insertAmdUse1Row.employee_no ||  
                ' phone=' || insertAmdUse1Row.phone) ;
            dbms_output.put_line('---- ' ||                
                ' ims_designator_code=' || insertAmdUse1Row.ims_designator_code ||  
                ' employee_status=' || insertAmdUse1Row.employee_status ||
                ' last_update_dt=' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM') ) ;
        end afterMsg ;
    begin
        dbms_output.put_line('****** trying to insert: ' || insertAmdUse1Row.userid) ;
        inuse_userid := insertAmdUse1Row.userid ;
        insert into amd_owner.amd_use1
        (userid,user_name,employee_no,phone,ims_designator_code,employee_status,last_update_dt)
        values(insertAmdUse1Row.userid,insertAmdUse1Row.user_name,insertAmdUse1Row.employee_no,insertAmdUse1Row.phone,
                insertAmdUse1Row.ims_designator_code,insertAmdUse1Row.employee_status,sysdate) ;
        afterMsg ;                
        dbms_output.put_line('****** successful insert of: ' || insertAmdUse1Row.userid) ;                
    exception when standard.dup_val_on_index then
        if instr(sqlerrm,'AMD_USE1_UK01') > 0 then
            dbms_output.put_line(employee_no || ' in use.') ;
            select userid, user_name, nvl(employee_no,'null'),nvl(phone,'null'),nvl(ims_designator_code,'null'),employee_status,nvl(last_update_dt,sysdate) into
                inuse_userid,  old_user_name,old_employee_no,old_phone,old_ims_designator_code,old_employee_status,old_last_update_dt
            from amd_owner.amd_use1
            where amd_use1.employee_no = insertAmdUse1Row.employee_no ; 
            dbms_output.put_line(employee_no || ' is already in use by userid ' ||  inuse_userid) ;
            beforeMsg ;            
            update amd_owner.amd_use1
            set amd_use1.user_name =  insertAmdUse1Row.user_name,
            amd_use1.phone = insertAmdUse1Row.phone,
            amd_use1.ims_designator_code = insertAmdUse1Row.ims_designator_code,
            amd_use1.employee_status = insertAmdUse1Row.employee_status,
            amd_use1.last_update_dt =sysdate
            where amd_use1.employee_no = insertAmdUse1Row.employee_no ;
            afterMsg ;
        else
            inuse_userid := insertAmdUse1Row.userid ;            
            dbms_output.put_line(insertAmdUse1Row.userid || ' already exists. ' || sqlcode || ' ' || sqlerrm) ;
            select user_name, nvl(employee_no,'null'),nvl(phone,'null'),nvl(ims_designator_code,'null'),employee_status,nvl(last_update_dt,sysdate) into
                old_user_name,old_employee_no,old_phone,old_ims_designator_code,old_employee_status,old_last_update_dt
            from amd_owner.amd_use1
            where amd_use1.userid = insertAmdUse1Row.userid ;
            beforeMsg ; 
            update amd_owner.amd_use1
            set amd_use1.user_name =  insertAmdUse1Row.user_name,
            amd_use1.employee_no =  insertAmdUse1Row.employee_no,
            amd_use1.phone = insertAmdUse1Row.phone,
            amd_use1.ims_designator_code = insertAmdUse1Row.ims_designator_code,
            amd_use1.employee_status = insertAmdUse1Row.employee_status,
            amd_use1.last_update_dt =sysdate
            where amd_use1.userid = insertAmdUse1Row.userid ;
            afterMsg ;
        end if ;
        dbms_output.put_line('****** successful update') ;                
    end insertAmdUse1Row ;
    procedure insertUimsRow(userid in uims.userid%type, 
                designator_code in uims.designator_code%type, 
                alt_ims_des_code_b in uims.alt_ims_des_code_b%type, 
                alt_es_des_code_b in uims.alt_es_des_code_b%type,
                alt_sup_des_code_b in uims.alt_sup_des_code_b%type) is 
        inuse_userid uims.USERID%type ;
        old_designator_code uims.designator_code%type ;
        old_alt_ims_des_code_b uims.alt_ims_des_code_b%type ;
        old_alt_es_des_code_b uims.alt_es_des_code_b%type ;
        old_alt_sup_des_code_b uims.alt_sup_des_code_b%type ;
        old_last_update_dt uims.last_update_dt%type ;
        procedure beforeMsg is
        begin
            dbms_output.put_line('before: ' || insertUimsRow.inuse_userid 
            || ' old_alt_ims_des_code_b=' || nvl(old_alt_ims_des_code_b,'null')  
            || ' old_alt_es_des_code_b=' || nvl(old_alt_es_des_code_b,'null') 
            || ' old_alt_sup_des_code_b=' || nvl(old_alt_sup_des_code_b,'null') ) ;
            dbms_output.put_line('---- old_designator_code=' || nvl(old_designator_code,'null')
            || ' old_last_update_dt=' || to_char(nvl(old_last_update_dt,sysdate),'MM/DD/YYYY HH:MI:SS AM') ) ;
        end beforeMsg ;
        
        procedure afterMsg is
        begin
            dbms_output.put_line('after: ' || insertUimsRow.inuse_userid ||
                ' alt_ims_des_code_b=' || insertUimsRow.alt_ims_des_code_b ||  
                ' alt_es_des_code_b=' || insertUimsRow.alt_es_des_code_b ||  
                ' alt_sup_des_code_b=' || insertUimsRow.alt_sup_des_code_b) ;
            dbms_output.put_line('---- ' ||                
                ' designator_code=' || insertUimsRow.designator_code ||  
                ' last_update_dt=' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM') ) ;
        end afterMsg ;
    begin
        dbms_output.put_line('****** trying to insert: ' || insertUimsRow.userid) ;
        inuse_userid := insertUimsRow.userid ;
        insert into amd_owner.uims
        (userid,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b,designator_code,last_update_dt)
        values(insertUimsRow.userid,insertUimsRow.alt_ims_des_code_b,insertUimsRow.alt_es_des_code_b,insertUimsRow.alt_sup_des_code_b,
                insertUimsRow.designator_code,sysdate) ;
        afterMsg ;                
        dbms_output.put_line('****** successful insert of: ' || insertUimsRow.userid) ;                
    exception when standard.dup_val_on_index then
        inuse_userid := insertUimsRow.userid ;            
        dbms_output.put_line(insertUimsRow.userid || ' already exists. ' || sqlcode || ' ' || sqlerrm) ;
        select alt_ims_des_code_b, nvl(alt_es_des_code_b,'null'),nvl(alt_sup_des_code_b,'null'),nvl(designator_code,'null'),nvl(last_update_dt,sysdate) into
            old_alt_ims_des_code_b,old_alt_es_des_code_b,old_alt_sup_des_code_b,old_designator_code,old_last_update_dt
        from amd_owner.uims
        where uims.userid = insertUimsRow.userid 
        and uims.designator_code = insertUimsRow.designator_code ;
        beforeMsg ; 
        update amd_owner.uims
        set uims.alt_ims_des_code_b =  insertUimsRow.alt_ims_des_code_b,
        uims.alt_es_des_code_b =  insertUimsRow.alt_es_des_code_b,
        uims.alt_sup_des_code_b = insertUimsRow.alt_sup_des_code_b,
        uims.designator_code = insertUimsRow.designator_code,
        uims.last_update_dt =sysdate
        where uims.userid = insertUimsRow.userid 
        and uims.designator_code = insertUimsRow.designator_code ;
        afterMsg ;
        dbms_output.put_line('****** successful update') ;                
    end insertUimsRow ;
begin
    /* Adding users to either uims or amd_use1 is sufficient to get the users sent to SPO.
	Users are added to both to show how to invoke the above procedures.
	*/
    insertUimsRow('C0673832' /* laurie compton */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
    insertUimsRow('C1007170'/* jen golfo */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
    insertUimsRow('C1624839' /* daffodil obriel */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
    insertUimsRow('C0329744' /* eric honma */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
    insertAmdUse1Row('C0500957','Rosalind S. Whitesides','500957','562-496-5730', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C0673832','Laurie S. Compton','673832','562-593-8416', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C1007170','Jen D. Golfo','1007170','562-593-8387', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C1624839','Daffodil G. Oribel','1624839','562-593-6641', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C0329744','Eric H. Honma','329744','562-593-3894', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
exception when others then
    dbms_output.put_line('sqlcode='  || sqlcode || ' sqlerrm=' || sqlerrm) ; 
    raise ;    
end ;
/

select * from uims where trunc(last_update_dt) = trunc(sysdate) ;

select * from amd_use1 where trunc(last_update_dt) = trunc(sysdate) ;

spool off

host notepad UimsAndUse1Output.txt

quit
