SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.A2A_CONSUMABLES_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.A2a_consumables_Pkg AS
    
/*
      $Author:   zf297a  $
    $Revision:   1.7  $
        $Date:   13 Oct 2008 09:17:22  $
    $Workfile:   A2A_CONSUMABLES_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_CONSUMABLES_PKG.pks.-arc  $
/*   
/*      Rev 1.7   13 Oct 2008 09:17:22   zf297a
/*   Added setDebug interface
/*   
/*      Rev 1.6   28 Aug 2008 15:33:34   zf297a
/*   Added interface getVersion
/*   
/*      Rev 1.5   12 Aug 2008 08:05:58   zf297a
/*   Added new interface isPartValidYorN with additional arguments: part_no,  smr_code, nsn, planner_code, and mtbdr.
/*   
/*      Rev 1.4   19 Sep 2007 16:53:54   zf297a
/*   Added new public interface isPartValid.
/*   
/*      Rev 1.3   16 Aug 2007 14:25:48   zf297a
/*   Added interface for procedure version.
/*   
/*      Rev 1.2   01 Jun 2007 11:30:08   zf297a
/*   put showReason in spec so that it can easily be turned on for all routines and removed it from all interfaces.
/*   Added new interface insertPartInfo with action code and all data that is needed to perform the action.
/*   
/*      Rev 1.1   30 May 2007 09:06:00   zf297a
/*   Added interface for isPlannerCodeValid and isPlannerCodeValidYorN
/*   
/*      Rev 1.0   29 May 2007 12:53:24   zf297a
/*   Initial revision.
*/    

    showReason boolean := false ;

    -- added 8/7/2008 by dse
    function isPartValidYorN(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return varchar2 ;

    function isPartValid(part_no in varchar2) return boolean ;
    function isPartValidYorN(part_no in varchar2) return varchar2 ;
    -- added 9/19/2007 by dse
    function isPartValid(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return boolean ;
        
    procedure insertPartInfo(part_no in varchar2, action_code in varchar2) ;
    
	procedure insertPartInfo(action_code in varchar2, part_no in varchar2, nomenclature in varchar2,
           mfgr in varchar2,  unit_issue in varchar2, smr_code in varchar2, nsn in varchar2, planner_code in varchar2,
	       third_party_flag in varchar2, mtbdr in number, price in number) ;
    
    function isPlannerCodeValid(plannerCode in amd_national_stock_items.planner_code%type) return boolean ;
    function isPlannerCodeValidYorN(plannerCode in amd_national_stock_items.planner_code%type) return varchar2 ;
    
    function getIndenture(smr_code_preferred in amd_national_stock_items.smr_code%type) return tmp_a2a_part_info.indenture%type ;
    
    procedure version ;
    function getVersion return varchar2 ; -- added 8/28/2008 by dse
    procedure setDebug(switch in varchar2) ; -- added 10/11/2008 by dse
    
end a2a_consumables_pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM A2A_CONSUMABLES_PKG;

CREATE PUBLIC SYNONYM A2A_CONSUMABLES_PKG FOR AMD_OWNER.A2A_CONSUMABLES_PKG;


GRANT EXECUTE ON AMD_OWNER.A2A_CONSUMABLES_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.A2A_CONSUMABLES_PKG TO BSRM_LOADER;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.A2A_CONSUMABLES_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.A2a_consumables_Pkg AS
    
/*
      $Author:   zf297a  $
    $Revision:   1.12  $
        $Date:   13 Oct 2008 23:05:00  $
    $Workfile:   A2A_CONSUMABLES_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_CONSUMABLES_PKG.pkb.-arc  $
/*   
/*      Rev 1.12   13 Oct 2008 23:05:00   zf297a
/*   Added debug code + tweaked insert of tmp_a2a_part_info - it is hanging up for some reason.
/*   
/*      Rev 1.11   28 Aug 2008 15:34:02   zf297a
/*   Implemented getVersion
/*   
/*      Rev 1.10   13 Aug 2008 16:50:20   zf297a
/*   Made errorMsg act as autonomous transaction so that this routine may issue commits independent of the main transaction.
/*   
/*      Rev 1.9   12 Aug 2008 08:07:02   zf297a
/*   Implemented isPartValidYorN with additional arguments: part_no, smr_code, nsn, planner_code, and mtbdr.
/*   
/*      Rev 1.8   05 Aug 2008 18:25:20   zf297a
/*   Use the default planner_code when inserting or updating tmp_a2a_part_info and the planner_code passed in is null.
/*   
/*      Rev 1.7   31 Jul 2008 11:14:06   zf297a
/*   Used a2a_pkg.getAssignedPlannerCode to make sure all resp_asset_mgr of the tmp_a2a_part_info is set to a common value.
/*   
/*      Rev 1.6   09 Oct 2007 15:19:02   zf297a
/*   Removed planner code filter 
/*   
/*      Rev 1.5   19 Sep 2007 16:52:56   zf297a
/*   Fixed isPartValid to use the new amd_utils.isPartConsumable boolean function, which is a function that does not need to retrieve any data to make the determination if a part is consumable.
/*   
/*      Rev 1.4   20 Aug 2007 22:46:08   zf297a
/*   Added a doUpdate procedure to insertPartInfo to update any a2a record.
/*   
/*      Rev 1.3   16 Aug 2007 14:26:32   zf297a
/*   Implemented procedure version and added procedure writeMsg.
/*   
/*      Rev 1.2   Jul 19 2007 08:55:46   c402417
/*   Corrected typo PDS to PSD in
/*   function isPlannerCodeValid.
/*   
/*      Rev 1.1   Jul 18 2007 07:55:28   c402417
/*   Changed to get indenture from local instead of from a2a_pkg.pkg
/*   
/*      Rev 1.0   29 May 2007 12:54:04   zf297a
/*   Initial revision.
*/    
     mArgs VARCHAR2(2000) ;
     
     debug boolean := false ;
    
    procedure writemsg(
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
                pSourceName => 'a2a_consumables_pkg',    
                pTableName  => pTableName,
                pError_location => pError_location,
                pKey1 => pKey1,
                pKey2 => pKey2,
                pKey3 => pKey3,
                pKey4 => pKey4,
                pData    => pData,
                pComments => pComments);
    exception when others then
        --  ignoretrying to rollback or commit from trigger
        if sqlcode <> -4092 then
            raise_application_error(-20010,
                substr('a2a_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey1 || ' ' 
                    || pKey2 || ' ' 
                    || pKey3 || ' ' 
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        end if ;
    end writemsg ;
    
     PROCEDURE errorMsg(
         pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE := 'errorMsg',
         pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE := 'noname',
         pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := -100,
         pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
          pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
         pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
         pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
         pKeywordValuePairs IN VARCHAR2 := '') IS
         
         pragma autonomous_transaction ;
         
         key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pKeywordValuePairs ;
         saveSqlCode number := sqlcode ;
         
     BEGIN
          IF key5 = '' or key5 is null THEN
             key5 := pSqlFunction || '/' || pTableName ;
          ELSE
            if key5 is not null then
                if length(key5) + length('' || pSqlFunction || '/' || pTablename) < 50  then           
                    key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
                end if ;
            end if ;
          END IF ;
          -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
          -- do not exceed the length of the column's that the data gets inserted into
          -- This is for debugging and logging, so efforts to make it not be the source of more
          -- errors is VERY important
          
          dbms_output.put_line('insertError@' || pError_location) ;
          
          Amd_Utils.InsertErrorMsg (
            pLoad_no => Amd_Utils.GetLoadNo(
              pSourceName => SUBSTR(pSqlfunction,1,20),
              pTableName  => SUBSTR(pTableName,1,20)),
            pData_line_no => pError_location,
            pData_line    => 'a2a_consumables_pkg.' || mArgs,
            pKey_1 => SUBSTR(pKey_1,1,50),
            pKey_2 => SUBSTR(pKey_2,1,50),
            pKey_3 => SUBSTR(pKey_3,1,50),
            pKey_4 => SUBSTR(pKey_4,1,50),
            pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
                 ' ' || substr(key5,1,50),
            pComments => SUBSTR('sqlcode('||saveSQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
            
            if sqlcode <> -4092 then            
                COMMIT;
            end if ;
       
     EXCEPTION WHEN OTHERS THEN
       dbms_output.enable(10000) ;
       dbms_output.put_line('sql error=' || sqlcode || ' ' || sqlerrm) ;
       if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
       if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
       if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
       if pKey_1 is not null then dbms_output.put_line('key1=' || pKey_1) ; end if ;
       if pkey_2 is not null then dbms_output.put_line('key2=' || pKey_2) ; end if ;
       if pKey_3 is not null then dbms_output.put_line('key3=' || pKey_3) ; end if ;
       if pKey_4 is not null then dbms_output.put_line('key4=' || pKey_4) ; end if ;
       if pKeywordValuePairs is not null then dbms_output.put_line('pKeywordValuePairs=' || pKeywordValuePairs) ; end if ;
       if sqlcode <> -4092 then
           raise_application_error(-20030,
                substr('a2a_pkg ' 
                    || sqlcode || ' '
                    || pError_location || ' '
                    || pSqlFunction || ' ' 
                    || pTableName || ' ' 
                    || pKey_1 || ' ' 
                    || pKey_2 || ' ' 
                    || pKey_3 || ' ' 
                    || pKey_4 || ' '
                    || pKeywordValuePairs,1, 2000)) ;
        end if ;
	 END errorMsg;

     PROCEDURE debugMsg(msg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE, pError_Location IN NUMBER) IS
        pragma autonomous_transaction ;
     BEGIN
       IF debug THEN
           Amd_Utils.debugMsg(pMsg => msg,pPackage => 'a2a_pkg', pLocation => pError_location) ;
           COMMIT ; -- make sure the trace is kept
       END IF ;
     EXCEPTION WHEN OTHERS THEN
                IF SQLCODE = -14551 OR SQLCODE = -14552 THEN
                     NULL ; -- cannot do a commit inside a query, so ignore the error
               ELSE
                      RAISE ;
               END IF ;
     END debugMsg ;

    procedure getPartInfoData(part_no in amd_spare_parts.part_no%type,
        smr_code     out    amd_national_stock_items.smr_code%type,
        nsn          out    amd_spare_parts.nsn%type,
        planner_code out    amd_national_stock_items.planner_code%type,
        mtbdr        out    amd_national_stock_items.MTBDR%type ) is
        
        nsi_sid amd_national_stock_items.nsi_sid%type ;
        
    begin
        debugMsg('getPartInfo: ' || part_no, pError_location => 10) ;
        select items.smr_code, items.nsn,  items.mtbdr, items.nsi_sid
        into smr_code, nsn,  mtbdr, nsi_sid
        from amd_spare_parts parts, amd_national_stock_items items
        where getPartInfoData.part_no = parts.part_no
        and parts.nsn = items. nsn ;
        planner_code := amd_preferred_pkg.getPlannerCode(nsi_sid) ;
    exception
        when standard.no_data_found then
            return ;
        when others then
           errorMsg(pSqlfunction => 'select',pTableName => 'amd_spare_parts/amd_national_stock_items',
             pError_location => 20, pKey_1 => part_no ) ;
           raise ;
        
    end getPartInfoData ;
    
    procedure getPartInfoData(part_no in amd_spare_parts.part_no%type,
            nomenclature out     amd_spare_parts.NOMENCLATURE%type,
            mfgr         out    amd_spare_parts.MFGR%type,
            unit_issue   out    amd_spare_parts.UNIT_OF_ISSUE%type,
            smr_code     out    amd_national_stock_items.smr_code%type,
            nsn          out    amd_spare_parts.nsn%type,
            planner_code out    amd_national_stock_items.planner_code%type,
            mtbdr        out    amd_national_stock_items.MTBDR%type,
            price        out    amd_spare_parts.UNIT_COST%type ) 
         is
    begin        
        debugMsg('getPartInfoData(' || part_no || ')', pError_location => 30) ;            
        select nomenclature, mfgr, unit_of_issue, parts.nsn, 
            amd_preferred_pkg.GetPreferredValue(smr_code_cleaned, smr_code) smr_code,
            amd_preferred_pkg.getPreferredValue(mtbdr_cleaned, mtbdr_computed, mtbdr) mtbdr,            
            amd_preferred_pkg.getPreferredValue(planner_code_cleaned, planner_code) planner_code,
            amd_preferred_pkg.getPreferredValue(unit_cost_cleaned, unit_cost) price
        into nomenclature, mfgr, unit_issue, nsn, smr_code, mtbdr, planner_code, price             
        from amd_spare_parts parts, amd_national_stock_items items
        where part_no = getPartInfoData.part_no
        and parts.nsn = items.nsn ;
        
    exception when others then
       errorMsg(pSqlfunction => 'select',pTableName => 'amd_spare_parts/amd_national_stock_items',
         pError_location => 40, pKey_1 => part_no ) ;
       raise ;
        
    end getPartInfoData ;

     
    FUNCTION getIndenture(smr_code_preferred IN AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE) RETURN TMP_A2A_PART_INFO.indenture%TYPE IS
	 BEGIN
	   IF SUBSTR(smr_code_preferred,6,1) IN ('N','P') THEN
	        RETURN '3' ;
	   END IF ;
       return null;       
	 END getIndenture ; 

    function isPlannerCodeValid(plannerCode in amd_national_stock_items.planner_code%type) 
        return boolean is
        isValid BOOLEAN := TRUE ;
    begin
        return isValid ; 
    end isPlannerCodeValid ;
    
    function isPlannerCodeValidYorN(plannerCode in amd_national_stock_items.planner_code%type) return varchar2 is
    begin
        if isPlannerCodeValid(plannerCode) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isPlannerCodeValidYorN ;
           


    function isPartValid(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return boolean is
        
       result boolean := false ;
       
       lineNo           number := 0 ;
                  
    begin
        -- ToDo: change all literals and tests to be specifically for consumables               
    
        lineNo := 20 ;            
        if not amd_utils.isPartActive(part_no) then
             return false ;
        end if ;
        IF UPPER(part_No) = 'F117-PW-100' OR INSTR(UPPER(part_no),'17L8D') > 0 OR INSTR(UPPER(part_no),'17R9Y') > 0 OR INSTR(UPPER(smr_code),'PE') > 0 THEN
        	  RETURN FALSE ;
        END IF ;
       
       lineNo := 30 ;            
       if a2a_pkg.getAcquisitionAdviceCode(part_no) = 'Y' then
            return false ;
       end if ;
       
       lineNo := 40 ;            
       result := amd_utils.isPartConsumable(preferred_smr_code => smr_code,
                    preferred_planner_code => planner_code, nsn => nsn) ;
       
       if not result then
             if showreason then 
                dbms_output.put_line(smr_code || ' is NOT a valid smr code') ; 
            end if ;
       end if ;
       
       lineNo := 50 ;            
       result := result AND isPlannerCodeValid(planner_Code) ;
       IF result AND a2a_pkg.isNsl(part_no) THEN
       
         IF showReason AND (mtbdr IS NOT NULL AND mtbdr > 0) THEN
             dbms_output.put_line('mtbdr > 0 for part ' || part_no) ; 
         END IF ;
         
        lineNo := 60 ;            
        result := result AND (a2a_pkg.demandExists(part_no, showReason) 
                                    OR a2a_pkg.inventoryExists(part_no, showReason)
                                    OR (mtbdr IS NOT NULL AND mtbdr > 0)
                                    OR a2a_pkg.isNsnValid(part_no,showReason)
                             ) ;
      END IF ;
      
      if not result then
           if showreason then 
            dbms_output.put_line('part ' || part_no || ' is NOT valid.') ; 
           end if ;
	  end if ;
      
	  return result ;
      
	 exception when others then
		if sqlcode = -20000 then
			dbms_output.disable ; -- buffer overflow, disable
			return isPartValid(part_no) ; -- try validation again
		else
            errorMsg(pSqlfunction => 'select',pTableName => 'isPartValid',
              pError_location => 50, pKey_1 => part_no, pKey_2 => lineNo ) ;
            raise ;
		end if ;
	
    end isPartValid ;
    
    function isPartValidYorN(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return varchar2 is
    begin
        if isPartValid(part_no,smr_code,nsn,planner_code,mtbdr) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                        
    end isPartValidYorN ;        


    function isPartValid(part_no in varchar2) return boolean is
            smr_code        amd_national_stock_items.smr_code%type ;
            nsn             amd_spare_parts.nsn%type ;
            planner_code    amd_national_stock_items.planner_code%type ;
            mtbdr           amd_national_stock_items.MTBDR%type ;
    begin
        
        getPartInfoData(part_no, smr_code, nsn, planner_code, mtbdr) ;
         
        return isPartValid(part_no,  smr_code, nsn, planner_code, mtbdr) ;
        
    end isPartValid ;
     
    function isPartValidYorN(part_no in varchar2) return varchar2 is
    begin
        if isPartValid(part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isPartValidYorN;

    procedure insertPartInfo(part_no in varchar2, action_code in varchar2) is
            nomenclature      amd_spare_parts.NOMENCLATURE%type ;
            mfgr             amd_spare_parts.MFGR%type ;
            unit_issue       amd_spare_parts.UNIT_OF_ISSUE%type ;
            smr_code         amd_national_stock_items.smr_code%type ;
            nsn              amd_spare_parts.nsn%type ;
            planner_code     amd_national_stock_items.planner_code%type ;
            mtbdr            amd_national_stock_items.MTBDR%type ;
            price            amd_spare_parts.UNIT_COST%type ; 
    begin
        debugMsg('insertPartInfo: ' || part_no, pError_location => 60) ;
        getPartInfoData(part_no, nomenclature, mfgr, unit_issue, smr_code, nsn, planner_code, mtbdr, price) ;
        
        insertPartInfo(action_code, part_no, nomenclature, mfgr, unit_issue, smr_code, nsn, planner_code,
        a2a_pkg.THIRD_PARTY_FLAG, mtbdr, price) ;
        
    end insertPartInfo ;

	procedure insertPartInfo(action_code in varchar2, part_no in varchar2, nomenclature in varchar2,
           mfgr in varchar2,  unit_issue in varchar2, smr_code in varchar2, nsn in varchar2, planner_code in varchar2,
	       third_party_flag in varchar2, mtbdr in number, price in number) is
          
        indenture       tmp_a2a_part_info.INDENTURE%type ;
        rcm_ind         tmp_a2a_part_info.RCM_IND%type ;        
        a2a_action_code varchar2(1) := action_code ;
        nsn_fsc         tmp_a2a_part_info.NSN_FSC%type := substr(nsn, 1, 4) ;
        nsn_niin        tmp_a2a_part_info.NSN_NIIN%type := substr(nsn, 5, 9) ;
        thePlannerCode amd_national_stock_items.planner_code%type ;  
        
        procedure doUpdate(action_code in varchar2) is
        begin
            update tmp_a2a_part_info
            set cage_code = mfgr,
            unit_issue = insertPartInfo.unit_issue,
            noun = insertPartInfo.nomenclature,
            rcm_ind = insertPartInfo.rcm_ind,
            nsn_fsc = insertPartInfo.nsn_fsc,
            nsn_niin = insertPartInfo.nsn_niin,
            resp_asset_mgr = thePlannerCode,
            third_party_flag = a2a_pkg.THIRD_PARTY_FLAG,
            mtbf = insertPartInfo.mtbdr,
            preferred_smrcode = insertPartInfo.smr_code,
            indenture = insertPartInfo.indenture,
            action_code = doUpdate.action_code,
            last_update_dt = sysdate,
            price = insertPartInfo.price
            where part_no = insertPartInfo.part_no ;
        end doUpdate ;
        
        procedure insertTmpA2A(action_code in varchar2) is
        begin
            debugMsg('insertTmpA2A: ' || action_code || ' ' || part_no,
		        pError_location => 70) ;

            insert into tmp_a2a_part_info
             (cage_code, part_no, unit_issue, noun, 
		rcm_ind, nsn_fsc, nsn_niin, resp_asset_mgr, third_party_flag,
                mtbf, preferred_smrcode, indenture, action_code, 
		last_update_dt, price )
            values ( insertPartInfo.mfgr, insertPartInfo.part_no, insertPartInfo.unit_issue, insertPartInfo.nomenclature, 
		insertPartInfo.rcm_ind, insertPartInfo.nsn_fsc, insertPartInfo.nsn_niin, 
                thePlannerCode, a2a_pkg.THIRD_PARTY_FLAG,
                insertPartInfo.mtbdr, insertPartInfo.smr_code, insertPartInfo.indenture, insertTmpA2A.action_code, 
		sysdate, insertPartInfo.price ) ;
        exception when standard.DUP_VAL_ON_INDEX then
            doUpdate(action_code) ;
        end insertTmpA2A ;
        
         
    begin
        debugMsg('insertPartInfo: ' || part_no || ' ' || action_code,
            pError_location => 80) ;

        if planner_code is null then
            thePlannerCode := amd_defaults.CONSUMABLE_PLANNER_CODE ;
        else
            thePlannerCode := planner_code ;
        end if ;                        
    
        if isPartValid(part_no, smr_code, nsn, thePlannerCode, mtbdr) then
                        
            indenture := getIndenture(smr_code) ;
            
            if length(smr_code) >= 6 then
                rcm_ind := a2a_pkg.getValidRcmInd(SUBSTR(smr_code,6,1)) ; -- ToDo: make sure this works for consumables
            end if ;
            insertTmpA2A(action_code) ;
        else
            if a2a_pkg.isPartSent(part_no) then
                insertTmpA2A(amd_defaults.DELETE_ACTION ); -- make sure the part_no is deleted    
            else
                return ;    
            end if ;
        end if ;
        
    exception when others then
        errorMsg(pSqlfunction => 'select',pTableName => 'tmp_a2a_part_info',
            pError_location => 90, pKey_1 => part_no ) ;
        raise ;
    end insertPartInfo ;

    procedure version is
    begin
         writeMsg(pTableName => 'a2a_consumables_pkg', 
                 pError_location => 100, pKey1 => 'a2a_consumables_pkg', pKey2 => '$Revision:   1.12  $') ;
          dbms_output.put_line('a2a_consumables_pkg: $Revision:   1.12  $') ;
    end version ;
    
    function getVersion return varchar2 is
    begin
        return '$Revision:   1.12  $' ;
    end getVersion ;
     
    procedure setDebug(switch in varchar2) is
    begin
        debug := upper(switch) in ('Y','T','YES','TRUE') ;
        if debug then
            dbms_output.ENABLE(100000) ;
        else
            dbms_output.DISABLE ;
        end if ;                    
    end setDebug ;

end a2a_consumables_pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM A2A_CONSUMABLES_PKG;

CREATE PUBLIC SYNONYM A2A_CONSUMABLES_PKG FOR AMD_OWNER.A2A_CONSUMABLES_PKG;


GRANT EXECUTE ON AMD_OWNER.A2A_CONSUMABLES_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.A2A_CONSUMABLES_PKG TO BSRM_LOADER;


