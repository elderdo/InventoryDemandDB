/*
    This script creates users in amd_owner.amd_use1 that will get sent to SPO
*/
set serveroutput on size 100000
set linesize 200
set wrap on

declare
    ACTIVE_STATUS constant varchar2(1)  := 'A' ;

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
        if not isValidBemsId(employee_no) then
            dbms_output.put_line('Error: ' || employee_no || ' was not found in amd_people_all_v') ;
            return ;
        end if ; 
	if not isValidPlannerCode(ims_designator_code) then       	
            dbms_output.put_line('Error: ' || ims_designator_code || ' was not found in amd_planners or amd_default_planners_v') ;
            return ;
	end if ;
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
        dbms_output.put_line('****** successful update of: ' || insertAmdUse1Row.userid) ;                
    end insertAmdUse1Row ;
begin
	-- userid: the key to amd_use1 can be C followed by the completed bems_id with leading zero
	-- user_name: first name middle initial and last name
	-- employee_no: bems_id without any leading zero
	-- phone: best contact phone number
	-- ims_designator_code: can be the planner_code 
	-- amd_defaults.REPAIRABLE_PLANNER_CODE: the default planner_code for repairable parts UNR
	-- amd_defaults.CONSUMABLE_PLANNER_CODE: the default planner_code for consumable parts UNC
	-- employee_status: A for active

    insertAmdUse1Row( userid => 'C0500957',
	user_name => 'Rosalind S. Whitesides',
	employee_no => '500957',
	phone => '562-496-5730', 
	ims_designator_code => amd_defaults.REPAIRABLE_PLANNER_CODE,
	employee_status => ACTIVE_STATUS) ;

    insertAmdUse1Row(userid => 'C0673832',
	user_name => 'Laurie S. Compton',
	employee_no => '673832',
	phone => '562-593-8416', 
	ims_designator_code => amd_defaults.REPAIRABLE_PLANNER_CODE,
	employee_status => ACTIVE_STATUS) ;

    insertAmdUse1Row(userid => 'C1007170',
	user_name => 'Jen D. Golfo',
	employee_no => '1007170',
	phone => '562-593-8387', 
	ims_designator_code => amd_defaults.REPAIRABLE_PLANNER_CODE,
	employee_status => ACTIVE_STATUS) ;

    insertAmdUse1Row(userid => 'C1624839',
	user_name => 'Daffodil G. Oribel',
	employee_no => '1624839',
	phone => '562-593-6641', 
	ims_designator_code => amd_defaults.REPAIRABLE_PLANNER_CODE,
	employee_status => ACTIVE_STATUS) ;

    insertAmdUse1Row(userid => 'C0329744',
	user_name => 'Eric H. Honma',
	employee_no => '329744',
	phone => '562-593-3894', 
	ims_designator_code => amd_defaults.REPAIRABLE_PLANNER_CODE,
	employee_status => ACTIVE_STATUS) ;

exception when others then
    dbms_output.put_line('sqlcode='  || sqlcode || ' sqlerrm=' || sqlerrm) ; 
    raise ;    
end ;
/


ttitle left 'AMD_USE1 table:'
select * from amd_use1 where trunc(last_update_dt) = trunc(sysdate) ;

ttitle left 'Input Used to update table AMD_USERS:'
column bems_id format a8
column stable_email format a40
column last_name format a25
column first_name format a25

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

