/*
    Create users in amd_owner.amd_use1 that will get sent to SPO
*/
set serveroutput on size 100000
set linesize 200
set wrap on

spool UimsAndUse1Output.txt

declare
    ACTIVE_STATUS constant varchar2(1)  := 'A' ;
    return_code number ;
    function isValidPlannerCode(planner_code in amd_planners.planner_code%type) return boolean is
	wk_planner_code amd_planners.planner_code%type ;
    begin
	select planner_code into wk_planner_code
	from amd_planners
	where planner_code = isValidPlannerCode.planner_code;
	return true ;
    exception	
	when standard.no_data_found then
		<<tryDefaults>>
		begin
			select planner_code into wk_planner_code
			from amd_default_planners_v
			where planner_code = isValidPlannerCode.planner_code ;
			return true ;
		exception 
		  when standard.no_data_found then
			return false ;
		end tryDefaults;
    end isValidPlannerCode ;
    function isValidBemsId(bems_id in amd_people_all_v.bems_id%type) return boolean is
        wk_bems_id amd_people_all_v.bems_id%type ;
    begin
        if length(bems_id) = 6 then
            wk_bems_id := '0' || bems_id ;
        elsif length(bems_id) = 7 then
            wk_bems_id := bems_id ;
        else
            dbms_output.put_line('Error: invalid bems_id(' || bems_id || ') must be at 6 or 7 characters long');
            return false ;            
        end if ;              
        select bems_id into wk_bems_id from amd_people_all_v where bems_id = wk_bems_id ;
        return true ;  
        exception 
            when standard.no_data_found then
                return false ;                            
        end isValidBemsId ;                    

    function insertAmdUse1Row(userid in amd_use1.userid%type, 
                user_name in amd_use1.user_name%type, 
                employee_no in amd_use1.employee_no%type,
                phone in amd_use1.phone%type, 
                ims_designator_code in amd_use1.ims_designator_code%type, 
                employee_status in amd_use1.employee_status%type) return number is
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
        if not isValidBemsId(employee_no) then
            dbms_output.put_line('Error: ' || employee_no || ' was not found in amd_people_all_v') ;
            return 4;
        end if ;            
	if not isValidPlannerCode(ims_designator_code) then       	
            dbms_output.put_line('Error: ' || ims_designator_code || ' was not found in amd_planners or amd_default_planners_v') ;
            return 8;
	end if ;        inuse_userid := insertAmdUse1Row.userid ;
        insert into amd_owner.amd_use1
        (userid,user_name,employee_no,phone,ims_designator_code,employee_status,last_update_dt)
        values(insertAmdUse1Row.userid,insertAmdUse1Row.user_name,insertAmdUse1Row.employee_no,insertAmdUse1Row.phone,
                insertAmdUse1Row.ims_designator_code,insertAmdUse1Row.employee_status,sysdate) ;
        afterMsg ;                
        dbms_output.put_line('****** successful insert of: ' || insertAmdUse1Row.userid) ;                
	return 0 ;
    exception when standard.dup_val_on_index then
	<<tryagain>>
	begin
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
	exception when others then
		return 10 ;
	end tryAgain;
        dbms_output.put_line('****** successful update of: ' || insertAmdUse1Row.userid) ;                
	return 0 ;
    end insertAmdUse1Row ;
    function insertUimsRow(userid in uims.userid%type, 
                designator_code in uims.designator_code%type, 
                alt_ims_des_code_b in uims.alt_ims_des_code_b%type, 
                alt_es_des_code_b in uims.alt_es_des_code_b%type,
                alt_sup_des_code_b in uims.alt_sup_des_code_b%type) return number is 
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
        if not isValidBemsId(substr(userid,2)) then
            dbms_output.put_line('Error: ' || substr(userid,2) || ' was not found in amd_people_all_v') ;
            return 4;
        end if ;             
	if not isValidPlannerCode(designator_code) then       	
            dbms_output.put_line('Error: ' || designator_code || ' was not found in amd_planners or amd_default_planners_v') ;
            return 8;
	end if ;
	inuse_userid := insertUimsRow.userid ;
        insert into amd_owner.uims
        (userid,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b,designator_code,last_update_dt)
        values(insertUimsRow.userid,insertUimsRow.alt_ims_des_code_b,insertUimsRow.alt_es_des_code_b,insertUimsRow.alt_sup_des_code_b,
                insertUimsRow.designator_code,sysdate) ;
        afterMsg ;                
        dbms_output.put_line('****** successful insert of: ' || insertUimsRow.userid) ;                
	return 0 ;
    exception when standard.dup_val_on_index then
	<<tryAgain>>
	begin
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
	exception when others then
		return 10 ;
	end tryAgain ;
	dbms_output.put_line('****** successful update of ' || insertUimsRow.userid) ;                
	return 0 ;
    end insertUimsRow ;
begin
  return_code := insertUimsRow('C0500957' /* rosalind whitesides */, amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
  if return_code <> 0 then
	dbms_output.put_line('insertUimsRow failed for C0500957 with return code of ' || return_code) ;
  end if ;
  return_code := insertUimsRow('C0673832' /* laurie compton */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
  if return_code <> 0 then
	dbms_output.put_line('insertUimsRow failed for C0673832 with return code of ' || return_code) ;
  end if ;
  return_code := insertUimsRow('C1007170'/* jen golfo */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
  if return_code <> 0 then
	dbms_output.put_line('insertUimsRow failed for C1007170 with return code of ' || return_code) ;
  end if ;
  return_code := insertUimsRow('C1624839' /* daffodil obriel */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
  if return_code <> 0 then
	dbms_output.put_line('insertUimsRow failed for C1624839 with return code of ' || return_code) ;
  end if ;
  return_code := insertUimsRow('C0329744' /* eric honma */,amd_defaults.getREPAIRABLE_PLANNER_CODE,'T','F','F') ;
  if return_code <> 0 then
	dbms_output.put_line('insertUimsRow failed c0329744 with return code of ' || return_code) ;
  end if ;
/*
    insertAmdUse1Row('C0500957','Rosalind S. Whitesides','500957','562-496-5730', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C0673832','Laurie S. Compton','673832','562-593-8416', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C1007170','Jen D. Golfo','1007170','562-593-8387', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C1624839','Daffodil G. Oribel','1624839','562-593-6641', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
    insertAmdUse1Row('C0329744','Eric H. Honma','329744','562-593-3894', amd_defaults.getREPAIRABLE_PLANNER_CODE,'A') ;
*/
exception when others then
    dbms_output.put_line('sqlcode='  || sqlcode || ' sqlerrm=' || sqlerrm) ; 
    raise ;    
end ;
/

select * from uims where trunc(last_update_dt) = trunc(sysdate) ;

select * from amd_use1 where trunc(last_update_dt) = trunc(sysdate) ;

ttitle left 'AMD_USE1 table:'
select * from amd_use1 where trunc(last_update_dt) = trunc(sysdate) ;

ttitle left 'Input Used to update table AMD_USERS:'
column bems_id format a8
column stable_email format a35
column last_name format a20
column first_name format a20
column data_source format a4

Select distinct amd_load.getBemsId(employee_NO) bems_id, stable_email, last_name, first_name, 'use1' data_source 
from amd_use1, amd_people_all_v 
where employee_status = 'A'  
and length(ims_designator_code) = 3 
and amd_load.getBemsId(employee_no) = bems_id
and trunc(amd_use1.last_update_dt) = trunc(sysdate) 
union 
select amd_load.getBemsId(userid) bems_id, stable_email, last_name, first_name, 'uims' data_source 
from uims, amd_people_all_v 
where length(designator_code) = 3  
and amd_load.getBemsId(userid) = bems_id
and trunc(uims.last_update_dt) = trunc(sysdate) ; 

ttitle left 'Input Used to update table AMD_PLANNER_LOGONS:'
column planner_code format a4
column logon_id format a8
column data_source format a1

select distinct ims_designator_code planner_code, 
amd_load.getBemsId(employee_no) logon_id, 
'1' data_source 
from amd_use1 
where employee_status = 'A' and length(ims_designator_code) = 3 
and amd_load.getBemsId(employee_no) is not null 
and trunc(last_update_dt) = trunc(sysdate) 
union 
select designator_code planner_code, 
amd_load.getBemsId(userid) logon_id, '2' data_source 
from uims where length(designator_code) = 3 
and amd_load.getBemsId(userid) is not null 
and upper(ALT_IMS_DES_CODE_B) = 'T'
and trunc(last_update_dt) = trunc(sysdate) ;
spool off

host notepad UimsAndUse1Output.txt
