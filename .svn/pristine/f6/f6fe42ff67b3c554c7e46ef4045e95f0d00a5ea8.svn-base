CREATE OR REPLACE PACKAGE body AMD_OWNER.USER_PLANNER_PKG AS

 /*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   01 Dec 2008 12:05:54  $
    $Workfile:   USER_PLANNER_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\USER_PLANNER_PKG.pkb.-arc  $
/*   
/*      Rev 1.1   01 Dec 2008 12:05:54   zf297a
/*   Planner_code was removed from amd_site_asset_mgr.
/*   
/*      Rev 1.0   02 Oct 2008 14:22:20   zf297a
/*   Initial revision.
*/
    PROCEDURE writeMsg(
                pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 IN VARCHAR2 := '',
                pData IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
    BEGIN
        Amd_Utils.writeMsg (
                pSourceName => 'user_planner_pkg',    
                pTableName  => pTableName,
                pError_location => pError_location,
    			pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;
    
	PROCEDURE ErrorMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
                
                 pragma autonomous_transaction ;
                
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => 'user_planner_pkg',	pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => 'user_planner_pkg',
				pKey_1 => SUBSTR(pKey1,1,50),
				pKey_2 => SUBSTR(pKey2,1,50),			
				pKey_3 => SUBSTR(pKey3,1,50),
				pKey_4 => SUBSTR(pKey4,1,50),
				pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||') ' || pComments);
		COMMIT;
	END errorMsg ;
    
    
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
    
    function isValidPlannerCodeYorN(planner_code in amd_planners.planner_code%type) return varchar2 is
    begin
        if isValidPlannerCode(planner_code) then
            return 'Y' ;
        else
            return 'N' ; 
        end if ;                       
    end isValidPlannerCodeYorN ;
    
    function isValidBemsId(bems_id in amd_people_all_v.bems_id%type) return boolean is
        wk_bems_id amd_people_all_v.bems_id%type ;
    begin
        if length(bems_id) = 6 then
            wk_bems_id := '0' || bems_id ;
        elsif length(bems_id) = 7 then
            wk_bems_id := bems_id ;
        else
            writeMsg(pTableName => 'amd_people_all_v', pError_location => 10,
                pKey1 => 'isValidBemsId',
                pKey2 => 'Error: invalid bems_id(' || bems_id || ') must be at 6 or 7 characters long');
            dbms_output.put_line('Error: invalid bems_id(' || bems_id || ') must be at 6 or 7 characters long');
            return false ;            
        end if ;              
        select bems_id into wk_bems_id from amd_people_all_v where bems_id = wk_bems_id ;
        return true ;  
        exception 
            when standard.no_data_found then
                return false ;                            
        end isValidBemsId ;                    

    function isValidBemsIdYorN(bems_id in amd_people_all_v.bems_id%type) return varchar2 is
    begin
        if isValidBemsId(bems_id) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                        
    end isValidBemsIdYorN ;
    
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
        
        procedure dumpData(dumpId in number) is
        begin
            writeMsg(pTableName => 'amd_use1', pError_location => 20,
                pKey1 => 'insertAmdUse1Row:' || dumpId,
                pKey2 => insertAmdUse1Row.inuse_userid,
                pKey3 => nvl(old_user_name,'null'),
                pKey4 => nvl(old_employee_no,'null'),
                pComments => nvl(old_phone,'null') ) ;
            writeMsg(pTableName => 'amd_use1', pError_location => 30,
                pKey1 => 'insertAmdUse1Row:' || dumpId,
                pKey2 => nvl(old_ims_designator_code,'null'),
                pKey3 => nvl(old_employee_status,'null'),
                pKey4 => to_char(nvl(old_last_update_dt,sysdate),'MM/DD/YYYY HH:MI:SS AM') ) ;
            dbms_output.put_line('before: ' || insertAmdUse1Row.inuse_userid 
            || ' user_name=' || nvl(old_user_name,'null')  
            || ' employee_no=' || nvl(old_employee_no,'null') 
            || ' phone=' || nvl(old_phone,'null') ) ;
            dbms_output.put_line('---- old_ims_designator_code=' || nvl(old_ims_designator_code,'null')
            || ' employee_status=' || nvl(old_employee_status,'null') 
            || ' last_update_dt=' || to_char(nvl(old_last_update_dt,sysdate),'MM/DD/YYYY HH:MI:SS AM') ) ;
        end dumpData ;
        
    begin
       dbms_output.put_line('****** trying to insert: ' || insertAmdUse1Row.userid) ;
        if not isValidBemsId(employee_no) then
            writeMsg(pTableName => 'amd_use1', pError_location => 40,
                pKey1 => 'insertAmdUse1Row',
                pKey2 => 'Error: ' || employee_no || ' was not found in amd_people_all_v') ;
            dbms_output.put_line('Error: ' || employee_no || ' was not found in amd_people_all_v') ;
            return INVALID_BEMS_ID ;
        end if ;            
        if not isValidPlannerCode(ims_designator_code) then           
            dbms_output.put_line('Error: ' || ims_designator_code || ' was not found in amd_planners or amd_default_planners_v') ;
            return INVALID_PLANNER_CODE ;
        end if ;
                
        inuse_userid := insertAmdUse1Row.userid ;        
        insert into amd_owner.amd_use1
        (userid,user_name,employee_no,phone,ims_designator_code,employee_status,last_update_dt)
        values(insertAmdUse1Row.userid,insertAmdUse1Row.user_name,insertAmdUse1Row.employee_no,insertAmdUse1Row.phone,
                insertAmdUse1Row.ims_designator_code,insertAmdUse1Row.employee_status,sysdate) ;
                
        dumpData(10) ;                
        dbms_output.put_line('****** successful insert of: ' || insertAmdUse1Row.userid) ;                
        return SUCCESS ;
    
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
                dumpData(20) ;            
                update amd_owner.amd_use1
                set amd_use1.user_name =  insertAmdUse1Row.user_name,
                amd_use1.phone = insertAmdUse1Row.phone,
                amd_use1.ims_designator_code = insertAmdUse1Row.ims_designator_code,
                amd_use1.employee_status = insertAmdUse1Row.employee_status,
                amd_use1.last_update_dt =sysdate
                where amd_use1.employee_no = insertAmdUse1Row.employee_no ;
                dumpData(30) ;
            else
                inuse_userid := insertAmdUse1Row.userid ;            
                dbms_output.put_line(insertAmdUse1Row.userid || ' already exists. ' || sqlcode || ' ' || sqlerrm) ;
                select user_name, nvl(employee_no,'null'),nvl(phone,'null'),nvl(ims_designator_code,'null'),employee_status,nvl(last_update_dt,sysdate) into
                    old_user_name,old_employee_no,old_phone,old_ims_designator_code,old_employee_status,old_last_update_dt
                from amd_owner.amd_use1
                where amd_use1.userid = insertAmdUse1Row.userid ;
                dumpData(40) ; 
                update amd_owner.amd_use1
                set amd_use1.user_name =  insertAmdUse1Row.user_name,
                amd_use1.employee_no =  insertAmdUse1Row.employee_no,
                amd_use1.phone = insertAmdUse1Row.phone,
                amd_use1.ims_designator_code = insertAmdUse1Row.ims_designator_code,
                amd_use1.employee_status = insertAmdUse1Row.employee_status,
                amd_use1.last_update_dt =sysdate
                where amd_use1.userid = insertAmdUse1Row.userid ;
                dumpData(50) ;
            end if ;
        exception when others then
            return 10 ;
        end tryAgain;
    
        dbms_output.put_line('****** successful update of: ' || insertAmdUse1Row.userid) ;                
        return SUCCESS ;
    
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
            return INVALID_BEMS_ID ;
        end if ;             
        if not isValidPlannerCode(designator_code) then           
                dbms_output.put_line('Error: ' || designator_code || ' was not found in amd_planners or amd_default_planners_v') ;
                return INVALID_PLANNER_CODE ;
        end if ;
        inuse_userid := insertUimsRow.userid ;
        
        insert into amd_owner.uims
        (userid,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b,designator_code,last_update_dt)
        values(insertUimsRow.userid,insertUimsRow.alt_ims_des_code_b,insertUimsRow.alt_es_des_code_b,insertUimsRow.alt_sup_des_code_b,
                insertUimsRow.designator_code,sysdate) ;
                
        afterMsg ;                
        dbms_output.put_line('****** successful insert of: ' || insertUimsRow.userid) ;                
        return SUCCESS ;
    
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
        return SUCCESS ;
        
    end insertUimsRow ;
    
    function insertSiteAssetMgr(bems_id in amd_site_asset_mgr.bems_id%type) return number is
        user_exists number := 0 ; -- 1 = exists 0 = not exist                
    begin
        if not isValidBemsId(bems_id) then
             ErrorMsg(pTableName => 'amd_site_asset_mgr',
				   pError_location => 50,
				   pKey1 => bems_id,
                   pKey2 => 'invalid_bems_id') ;
            dbms_output.put_line('bems_id:' || bems_id || ' is invalid.') ;                   
            return INVALID_BEMS_ID ;                   
        end if ;
        
        <<checkAmdUsers>> 
        begin
            select 1 into user_exists 
            from amd_users 
            where bems_id = insertSiteAssetMgr.bems_id ;
            dbms_output.put_line('bems_id: ' || bems_id || ' already exists in amd_users.') ;
            dbms_output.put_line('amd_users will be used for x_user_v and spo_user') ;
            writeMsg(pTableName => 'amd_site_asset_mgr', pError_location => 55,
                pKey1 => bems_id,
                pKey2 => 'bems_id already exists in amd_users',
                pKey3 => 'amd_users will be sued for x_user_v and spo_user') ;            
        exception when standard.no_data_found then
            user_exists := 0 ;
        end checkAmdUsers ;
        
        insert into amd_site_asset_mgr
        (bems_id)
        values(insertSiteAssetMgr.bems_id) ;        
        return SUCCESS ;                               
    exception
        when standard.no_data_found then
            return sqlcode ;
        when standard.dup_val_on_index then
            return DUPLICATE ;
        when others then
            ErrorMsg(pTableName => 'amd_site_asset_mgr',
				   pError_location => 70,
				   pKey1 => bems_id) ;
            return sqlcode ;            
    end insertSiteAssetMgr ;                 

    function deleteSiteAssetMgr(bems_id in amd_site_asset_mgr.bems_id%type) return number is
    begin
        update amd_site_asset_mgr
        set action_code = amd_defaults.DELETE_ACTION,
        last_update_dt = sysdate 
        where bems_id = deleteSiteAssetMgr.bems_id ;
        return SUCCESS ;
    exception 
        when standard.no_data_found then
            ErrorMsg(pTableName => 'amd_site_asset_mgr',
                   pError_location => 80,
                   pKey1 => bems_id,
                   pKey2 => 'no_data_found') ;
            return sqlcode ;    
        when others then        
            ErrorMsg(pTableName => 'amd_site_asset_mgr',
                   pError_location => 90,
                   pKey1 => bems_id,
                   pComments => sqlerrm) ;
            return sqlcode ;
    end deleteSiteAssetMgr ;

   procedure version is
    begin
         writeMsg(pTableName => 'user_planner_pkg', 
                 pError_location => 410, pKey1 => 'user_planner_pkg', pKey2 => '$Revision:   1.1  $') ;
          dbms_output.put_line('user_planner_pkg: $Revision:   1.1  $') ;
    end version ;
    
    function getVersion return varchar2 is
    begin
        return '$Revision:   1.1  $' ;
    end getVersion ;
                                    
end user_planner_pkg ;
/
