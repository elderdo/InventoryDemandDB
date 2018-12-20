DROP PACKAGE BODY AMD_OWNER.AMD_TEST_DATA;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Test_Data  AS
    /*
        PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.15  $
         $Date:   Dec 06 2005 10:43:00  $
     $Workfile:   AMD_TEST_DATA.pkb  $
          $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_test_data.pkb-arc  $
   
      Rev 1.15   Dec 06 2005 10:43:00   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
   
      Rev 1.14   Nov 22 2005 11:05:30   c402417
   Revomed obsolete codes.

*/
    SUBTYPE data_source  IS NUMBER  ;
    
    theSequence number := 0 ;
    prevKey varchar2(256) := '' ;

    NSI_PARTS        CONSTANT data_source := 1 ;
    TMP_SPARE_PARTS CONSTANT data_source := 2 ;

    testProperty NUMBER ;
    xmlFile UTL_FILE.FILE_TYPE ;

    PROCEDURE setTestProperty(value IN NUMBER) IS
    BEGIN
         testProperty := value ;
    END setTestProperty ;

    PROCEDURE setTestProperty(value IN NUMBER, value2 IN NUMBER) IS
    BEGIN
         NULL ;
    END setTestProperty ;

    FUNCTION getTestProperty RETURN NUMBER IS
    BEGIN
         RETURN testProperty ;
    END getTestProperty ;

    FUNCTION DeleteParameters RETURN BOOLEAN IS
    BEGIN
        BEGIN
            DELETE FROM AMD_PARAM_CHANGES ;
        EXCEPTION WHEN OTHERS THEN
            NULL ; -- ignore
        END ;
        DELETE FROM AMD_PARAMS ;
        COMMIT ;
        RETURN TRUE ;
    END DeleteParameters ;
    FUNCTION CreateParameters RETURN BOOLEAN IS

        init_error EXCEPTION ;

        PROCEDURE InsertAmdParam(pParam_key IN AMD_PARAMS.param_key%TYPE,
            pParam_description IN AMD_PARAMS.param_description%TYPE,
            pParam_value IN AMD_PARAM_CHANGES.param_value%TYPE,
            pUser_id IN AMD_PARAM_CHANGES.user_id%TYPE DEFAULT 'c970183')  IS
            PROCEDURE ErrorMsg(pTableName IN VARCHAR2, pMsg IN VARCHAR2) IS
            BEGIN
                ROLLBACK ;
                Amd_Utils.InsertErrorMsg(
                    Amd_Utils.GetLoadNo(pSourceName => 'amd_test_data', pTableName => pTableName),
                    pParam_key, pParam_description, pParam_value, pUser_id, NULL, pMsg);
                COMMIT ;
            END ErrorMsg ;

        BEGIN
            BEGIN
                INSERT INTO AMD_PARAMS
                (param_key, param_description)
                VALUES (pParam_key, pParam_description) ;
            EXCEPTION WHEN OTHERS THEN
                ErrorMsg('amd_params', 'Could not insert') ;
                RAISE init_error ;
            END ;

            BEGIN
                INSERT INTO AMD_PARAM_CHANGES
                (param_key, effective_date, param_value, user_id)
                VALUES (pParam_key, SYSDATE, pParam_value, pUser_id) ;
            EXCEPTION WHEN OTHERS THEN
                ErrorMsg('amd_param_changes', 'Could not insert') ;
                RAISE init_error ;
            END ;
        END ;
    BEGIN
        InsertAmdParam(pParam_key => 'use_bssm_to_get_nsls',
            pParam_description => 'The amd_spare_parts_pkg uses this. If the value is Y it will retrieve NSN''s with keys like NSL#nnnnnn from the BSSM tables, when the value gets set to N it will generate its own sequence number for NSL''s.',
            pParam_value => 'Y') ;
        InsertAmdParam(pParam_key => 'consumable_reduction_factor',
            pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is QuasiRepairable (smr6=P) or Consumable (smr6=N).',
            pParam_value => '0.60') ;
        InsertAmdParam(pParam_key => 'engine_part_reduction_factor',
            pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is an Engine Part (planner_code = PSA or PSB).',
            pParam_value => '0.92') ;
        InsertAmdParam(pParam_key => 'non_engine_part_reductn_factor',
            pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is a Non-Engine Part (planner_code is not = PSA and planner_code is not = PSB).',
            pParam_value => '0.79') ;
        InsertAmdParam(pParam_key => 'order_lead_time_consumable',
            pParam_description => 'This is used by the amd_defaults package, which is used by amd_spare_parts_pkg.',
            pParam_value => '270') ;
        InsertAmdParam(pParam_key => 'order_lead_time_repairable',
            pParam_description => 'This is used by the amd_defaults package, which is used by amd_spare_parts_pkg.',
            pParam_value => '540') ;
        InsertAmdParam(pParam_key => 'order_quantity',
            pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
            pParam_value => '1') ;
        InsertAmdParam(pParam_key => 'order_uom',
            pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
            pParam_value => 'PC') ;
        InsertAmdParam(pParam_key => 'shelf_life',
            pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
            pParam_value => '999998') ;
        InsertAmdParam(pParam_key => 'condemn_avg',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'distrib_uom',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'nrts_avg',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'disposal_cost',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'off_base_turn_around',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'qpei_weighted',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'rts_avg',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'scrap_value',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'time_to_repair_on_base_avg',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        InsertAmdParam(pParam_key => 'unit_volume',
            pParam_description => 'todo - needs to be set to a valid value.',
            pParam_value => '0') ;
        COMMIT ;
        RETURN TRUE ;
    EXCEPTION WHEN init_error THEN
        RETURN FALSE ;
    END ;

    FUNCTION TestInsertNewPrimePart RETURN BOOLEAN IS
        RetVal1 NUMBER ;
    BEGIN
        --RetVal1 := AMD_OWNER.AMD_SPARE_PARTS_PKG.INSERTROW ( '17P1A7006-502', '88277', NULL, NULL, NULL,  'F77', 'Test the insertion of a new Prime Part', NULL, NULL, NULL, 'Y', NULL, NULL, NULL, NULL, 191.809780092593, '1560013353279', 'C', 'R', 'PAODDT', 'AFA', '','', '', '' );
        COMMIT ;
        dbms_output.put_line('RetVal1 = ' || RetVal1) ;
        IF RetVal1 = Amd_Spare_Parts_Pkg.SUCCESS THEN
            RETURN TRUE ;
        ELSE
            RETURN FALSE ;
        END IF ;
    END TestInsertNewPrimePart ;

    FUNCTION TestUpdEquivToPrime RETURN BOOLEAN IS
        RetVal2 NUMBER ;
    BEGIN
        --RetVal2 := AMD_OWNER.AMD_SPARE_PARTS_PKG.UPDATEROW ( '17P1A7006-501', '88277', NULL, NULL, NULL,  'F77', 'Test Change from Equiv to Prime', NULL, NULL, NULL, 'Y', NULL, NULL, NULL, NULL, 191.809780092593, '1560013353279', 'C', 'R', 'PAODDT', 'AFA', '', '', '', '' );
        COMMIT ;
        dbms_output.put_line('RetVal2 = ' || RetVal2) ;
        IF RetVal2 = Amd_Spare_Parts_Pkg.SUCCESS THEN
            RETURN TRUE ;
        ELSE
            RETURN FALSE ;
        END IF ;
    END TestUpdEquivToPrime ;

    PROCEDURE sleep(secs IN NUMBER) IS
        ss VARCHAR2(2) ;
    BEGIN
        ss := TO_CHAR(SYSDATE,'ss') ;
        WHILE TO_NUMBER(ss) + secs > TO_NUMBER(TO_CHAR(SYSDATE,'ss'))
        LOOP
            NULL ;
        END LOOP ;
    END ;
    FUNCTION test_amd_spare_parts_pkg RETURN BOOLEAN IS
        result BOOLEAN ;
        RetVal2 NUMBER ;
    BEGIN
        IF TestInsertNewPrimePart() THEN
            dbms_output.put_line('TestInsertNewPrimePart OK') ;
            -- must sleep for a couple of sec's otherwise
            -- the generated key with the timestamp
            -- might match a previous one - this acutally
            -- happened that is why I, DSE, put this here
            sleep(5) ;
            IF TestUpdEquivToPrime() THEN
                dbms_output.put_line('TestUpdEquivToPrime OK') ;
            ELSE
                RETURN FALSE ;
            END IF ;
        ELSE
            RETURN FALSE ;
        END IF ;
        RETURN TRUE ;
    END test_amd_spare_parts_pkg ;

    FUNCTION DeleteAmdSparePart(pNsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN BOOLEAN IS
    BEGIN
        BEGIN
            DELETE FROM AMD_DEMANDS WHERE nsi_sid = pNsi_sid ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_demands: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_MAINT_TASK_DISTRIBS WHERE nsi_sid = pNsi_sid ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_maint_task_distribs: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_PART_LOCS WHERE nsi_sid = pNsi_sid ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_part_locs: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_NATIONAL_STOCK_ITEMS WHERE nsi_sid = pNsi_sid ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_national_stock_items: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_ON_HAND_INVS
            WHERE part_no IN
                (SELECT part_no FROM AMD_SPARE_PARTS
                 WHERE nsn IN
                 (SELECT nsn FROM AMD_NSNS
                 WHERE nsi_sid = pNsi_sid)) ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_spare_invs: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_IN_REPAIR
            WHERE part_no IN
                (SELECT part_no FROM AMD_SPARE_PARTS
                 WHERE nsn IN
                 (SELECT nsn FROM AMD_NSNS
                 WHERE nsi_sid = pNsi_sid)) ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_spare_invs: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_ON_ORDER
            WHERE part_no IN
                (SELECT part_no FROM AMD_SPARE_PARTS
                 WHERE nsn IN
                 (SELECT nsn FROM AMD_NSNS
                 WHERE nsi_sid = pNsi_sid)) ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_spare_invs: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE FROM AMD_SPARE_PARTS WHERE nsn IN (SELECT nsn FROM AMD_NSNS WHERE nsi_sid = pNsi_sid) ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_spare_parts: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        BEGIN
            DELETE AMD_NSNS WHERE nsi_sid = pNsi_sid ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL ; -- do nothing
            WHEN OTHERS THEN
                dbms_output.put_line('amd_nsns: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM) ;
                RETURN FALSE ;
        END ;

        COMMIT ;

        RETURN TRUE ;
    END DeleteAmdSparePart ;

    FUNCTION DeleteAmdSpareParts RETURN BOOLEAN IS
    BEGIN
        DELETE FROM AMD_DEMANDS ;
        DELETE FROM AMD_MAINT_TASK_DISTRIBS ;
        DELETE FROM AMD_PART_LOCS ;
        DELETE FROM AMD_NATIONAL_STOCK_ITEMS ;
        DELETE FROM AMD_ON_HAND_INVS ;
        DELETE FROM AMD_IN_REPAIR ;
        DELETE FROM AMD_ON_ORDER ;
        DELETE FROM AMD_SPARE_PARTS ;
        DELETE FROM AMD_NSNS ;
        DELETE FROM AMD_NSI_PARTS ;
        COMMIT ;
        RETURN TRUE ;
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('SQLCODE = ' || SQLCODE || ' SQLERRM = ' || SQLERRM ) ;
        RETURN FALSE ;
    END DeleteAmdSpareParts ;

    /* This function can be used in place of the Java diff routine.
      However, it is less generic tham the Java diff routine, but
      it could be adapted to other data that require this functionality.
      */
    FUNCTION Diff RETURN NUMBER IS

        /* Return codes */
        SUCCESS                        CONSTANT NUMBER := 0 ;
        FAILURE                        CONSTANT NUMBER := 4 ;
        CANNOT_GET_NSI_SID            CONSTANT NUMBER := 8 ;
        CANNOT_GET_ITEM_DATA        CONSTANT NUMBER := 12 ;
        CANNOT_GET_NSI_PARTS_DATA    CONSTANT NUMBER := 16 ;
        GET_PART_DATA_ERROR            CONSTANT NUMBER := 20 ;
        GET_CURRENT_DATA_ERROR        CONSTANT NUMBER := 24 ;
        CURRENT_DATA_NOT_FOUND        CONSTANT NUMBER := 30 ;

        rows_read                    NUMBER := 0 ;
        rows_inserted                NUMBER := 0 ;
        rows_updated                NUMBER := 0 ;
        rows_deleted                NUMBER := 0 ;

        CURSOR newData IS
            SELECT *
            FROM TMP_AMD_SPARE_PARTS
            ORDER BY nsn ASC, prime_ind DESC ;

        oldParts    AMD_SPARE_PARTS%ROWTYPE := NULL ;

        result             NUMBER := NULL ;
        nsi_sid            AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE := NULL ;
        nsn_type        AMD_NSNS.nsn_type%TYPE := NULL ;
        item_type         AMD_NATIONAL_STOCK_ITEMS.item_type%TYPE := NULL ;
        order_quantity     AMD_NATIONAL_STOCK_ITEMS.order_quantity%TYPE := NULL ;
        planner_code     AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE := NULL ;
        smr_code         AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE := NULL ;
        prime_ind        AMD_NSI_PARTS.prime_ind%TYPE := NULL ;

        FUNCTION ErrorMsg(pMsg IN VARCHAR2, pTableName IN VARCHAR2, pData_line_no IN AMD_LOAD_DETAILS.data_line_no%TYPE, pPart_no IN AMD_SPARE_PARTS.part_no%TYPE, pMfgr IN AMD_SPARE_PARTS.mfgr%TYPE, pNsn IN AMD_SPARE_PARTS.nsn%TYPE, pReturnCode IN NUMBER) RETURN NUMBER IS
        BEGIN
            ROLLBACK ;
            dbms_output.put_line(pMsg) ;
            dbms_output.put_line('TableName=' || pTableName) ;
            dbms_output.put_line('Data_line_no=' || pData_line_no) ;
            dbms_output.put_line('part_no=' || pPart_no || ' mfgr=' || pMfgr || ' nsn=' || pNsn || ' ReturnCode=' || pReturnCode) ;
            Amd_Utils.InsertErrorMsg (
                pLoad_no => Amd_Utils.GetLoadNo(pSourceName => 'Diff', pTableName => pTableName),
                pData_line_no => pData_line_no,
                pData_line => 'amd_test_data',
                pKey_1 => pPart_no,
                pKey_2 => pMfgr,
                pKey_3 => pNsn,
                pKey_4 => pReturnCode,
                pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS'),
                pComments => pMsg) ;
            COMMIT ;
            RETURN  pReturnCode ;
        END ;

        FUNCTION InsertRow(newRec IN TMP_AMD_SPARE_PARTS%ROWTYPE) RETURN NUMBER IS
        BEGIN
             /*
            return amd_spare_parts_pkg.InsertRow(newRec.part_no,
                newRec.mfgr,
                newRec.date_icp,
                newRec.disposal_cost,
                newRec.erc,
                newRec.icp_ind,
                newRec.nomenclature,
                newRec.order_lead_time,
                newRec.order_quantity,
                newRec.order_uom,
                newRec.prime_ind,
                newRec.scrap_value,
                newRec.serial_flag,
                newRec.shelf_life,
                newRec.unit_cost,
                newRec.unit_volume,
                newRec.nsn,
                newRec.nsn_type,
                newRec.item_type,
                newRec.smr_code,
                newRec.planner_code, '', '', '', '') ;
                */
                NULL ;
        END InsertRow ;

        FUNCTION UpdateRow(newRec IN TMP_AMD_SPARE_PARTS%ROWTYPE) RETURN NUMBER IS
        BEGIN
             NULL ;
             /*
            return amd_spare_parts_pkg.UpdateRow
                 (newRec.part_no,
                newRec.mfgr,
                newRec.date_icp,
                newRec.disposal_cost,
                newRec.erc,
                newRec.icp_ind,
                newRec.nomenclature,
                newRec.order_lead_time,
                newRec.order_quantity,
                newRec.order_uom,
                newRec.prime_ind,
                newRec.scrap_value,
                newRec.serial_flag,
                newRec.shelf_life,
                newRec.unit_cost,
                newRec.unit_volume,
                newRec.nsn,
                newRec.nsn_type,
                newRec.item_type,
                newRec.smr_code,
                newRec.planner_code, '', '', '', '') ;
                */
        END UpdateRow ;

        FUNCTION IsDifferent(pOldParts IN AMD_SPARE_PARTS%ROWTYPE,
            pItem_type IN AMD_NATIONAL_STOCK_ITEMS.item_type%TYPE,
            pOrder_quantity IN AMD_NATIONAL_STOCK_ITEMS.order_quantity%TYPE,
            pPlanner_code IN AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE,
            pSmr_code IN AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE,
            pNsn_type IN AMD_NSNS.nsn_type%TYPE,
            pPrime_ind IN AMD_NSI_PARTS.prime_ind%TYPE,
            pNewRec IN TMP_AMD_SPARE_PARTS%ROWTYPE) RETURN BOOLEAN IS
            result BOOLEAN := FALSE ;
        BEGIN
                result := (pNewRec.date_icp = pOldParts.date_icp) ;
                result := (result AND (pNewRec.disposal_cost = pOldParts.disposal_cost)) ;
                result := (result AND (pNewRec.erc = pOldParts.erc)) ;
                result := (result AND (pNewRec.icp_ind = pOldParts.icp_ind)) ;
                result := (result AND (pNewRec.nomenclature = pOldParts.nomenclature)) ;
                result := (result AND (pNewRec.order_lead_time = pOldParts.order_lead_time)) ;
                result := (result AND (pNewRec.order_uom = pOldParts.order_uom)) ;
                result := (result AND (pNewRec.prime_ind = pPrime_ind)) ;
                result := (result AND (pNewRec.scrap_value = pOldParts.scrap_value)) ;
                result := (result AND (pNewRec.serial_flag = pOldParts.serial_flag)) ;
                result := (result AND (pNewRec.shelf_life = pOldParts.shelf_life)) ;
                result := (result AND (pNewRec.unit_cost = pOldParts.unit_cost)) ;
                result := (result AND (pNewRec.unit_volume = pOldParts.unit_volume)) ;
                IF result AND pNewRec.prime_ind = 'Y' THEN
                    result := (result AND (pNewRec.nsn = pOldParts.nsn)) ;
                    result := (result AND (pNewRec.order_quantity = pOrder_quantity)) ;
                    result := (result AND (pNewRec.nsn_type = pNsn_type)) ;
                    result := (result AND (pNewRec.item_type = pItem_type)) ;
                    result := (result AND (pNewRec.smr_code = pSmr_code)) ;
                    result := (result AND (pNewRec.planner_code = pPlanner_code)) ;
                END IF ;
                RETURN result ;
        END IsDifferent ;

        FUNCTION DeleteRows RETURN NUMBER IS
            CURSOR deleteData IS
                SELECT part_no, mfgr, nomenclature
                FROM AMD_SPARE_PARTS
                WHERE action_code != Amd_Defaults.DELETE_ACTION
                MINUS
                SELECT part_no, mfgr, nomenclature
                FROM TMP_AMD_SPARE_PARTS parts ;
        BEGIN
            FOR oldRec IN deleteData LOOP
                result := Amd_Spare_Parts_Pkg.DeleteRow(oldRec.part_no, oldRec.mfgr, oldRec.nomenclature) ;
                IF result != Amd_Spare_Parts_Pkg.SUCCESS THEN
                    RETURN result ;
                END IF ;
                rows_deleted := rows_deleted + 1 ;
                COMMIT ;
            END LOOP ;
            RETURN Diff.SUCCESS ;
        END DeleteRows ;

        FUNCTION GetCurrentData(pNewRec IN TMP_AMD_SPARE_PARTS%ROWTYPE) RETURN NUMBER IS

            FUNCTION GetPartData(pNewRec IN TMP_AMD_SPARE_PARTS%ROWTYPE) RETURN NUMBER IS

                FUNCTION GetDataFromOtherTables RETURN NUMBER IS
                    result NUMBER := NULL ;

                    FUNCTION GetNsiSid(pNsn IN AMD_NSNS.nsn%TYPE) RETURN NUMBER IS
                    BEGIN
                        SELECT nsi_sid, nsn_type
                        INTO nsi_sid, nsn_type
                        FROM AMD_NSNS
                        WHERE nsn = pNsn ;
                        RETURN Diff.SUCCESS ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            nsi_sid := NULL ;
                            nsn_type := NULL ;
                            RETURN Diff.SUCCESS ;
                        WHEN OTHERS THEN
                            RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
                                pTableName => 'amd_nsns',
                                pData_line_no => 1,
                                pPart_no => NULL,
                                pMfgr => NULL, pNsn => pNsn,
                                pReturnCode => Diff.CANNOT_GET_NSI_SID)  ;
                    END GetNsiSid ;

                    FUNCTION GetItemData RETURN NUMBER IS
                    BEGIN
                        SELECT item_type, order_quantity, planner_code, smr_code
                        INTO item_type, order_quantity, planner_code, smr_code
                        FROM AMD_NATIONAL_STOCK_ITEMS
                        WHERE nsi_sid = Diff.nsi_sid ;
                        RETURN Diff.SUCCESS ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            item_type := NULL ;
                            order_quantity := NULL ;
                            planner_code := NULL ;
                            smr_code := NULL ;
                            RETURN Diff.SUCCESS ;
                        WHEN OTHERS THEN
                            RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
                                pTableName => 'amd_nsns',
                                pData_line_no => 2,
                                pPart_no => NULL,
                                pMfgr => NULL,
                                pNsn =>  NULL,
                                pReturnCode => Diff.CANNOT_GET_ITEM_DATA)  ;
                    END GetItemData;

                    FUNCTION GetNsiPartsData(pPart_no IN AMD_NSI_PARTS.part_no%TYPE) RETURN NUMBER IS
                    BEGIN
                        SELECT prime_ind INTO prime_ind
                        FROM AMD_NSI_PARTS
                        WHERE nsi_sid = Diff.nsi_sid
                        AND part_no = pPart_no
                        AND unassignment_date IS NULL ;
                        RETURN Diff.SUCCESS ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            prime_ind := NULL ;
                            RETURN Diff.SUCCESS ;
                        WHEN OTHERS THEN
                            RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
                                pTableName => 'amd_nsns',
                                pData_line_no => 3,
                                pPart_no => pPart_no,
                                pMfgr => NULL,
                                pNsn => TO_CHAR(nsi_sid),
                                pReturnCode => Diff.CANNOT_GET_NSI_PARTS_DATA)  ;
                    END GetNsiPartsData;

                BEGIN
                    result := GetNsiSid(pNewRec.nsn) ;
                    IF result = Diff.SUCCESS THEN
                        result := GetItemData() ;
                    END IF ;
                    IF result = Diff.SUCCESS THEN
                        result := GetNsiPartsData(pPart_no => pNewRec.part_no ) ;
                    END IF ;
                    RETURN result ;
                END GetDataFromOtherTables ;

            BEGIN
                SELECT * INTO oldParts
                FROM AMD_SPARE_PARTS
                WHERE part_no = pNewRec.part_no
                AND mfgr = pNewRec.mfgr ;
                RETURN GetDataFromOtherTables() ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN Diff.CURRENT_DATA_NOT_FOUND ;
                WHEN OTHERS THEN
                    RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
                        pTableName => 'amd_nsns',
                        pData_line_no => 4,
                        pPart_no => pNewRec.part_no,
                        pMfgr => pNewRec.mfgr,
                        pNsn => pNewRec.nsn,
                        pReturnCode => Diff.GET_PART_DATA_ERROR)  ;
            END GetPartData ;

        BEGIN
            RETURN GetPartData(pNewRec => pNewRec) ;
        EXCEPTION WHEN OTHERS THEN
            RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
                pTableName => 'amd_nsns',
                pData_line_no => 5,
                pPart_no => pNewRec.part_no,
                pMfgr => pNewRec.mfgr,
                pNsn => pNewRec.nsn,
                pReturnCode => Diff.GET_CURRENT_DATA_ERROR)  ;
        END GetCurrentData;

    BEGIN --<<<-- Diff
        FOR newRec IN newData LOOP
            rows_read := rows_read + 1 ;
            result := GetCurrentData(pNewRec => newRec) ;
            IF result = Diff.CURRENT_DATA_NOT_FOUND THEN
                result := InsertRow(newRec) ;
                IF result = Amd_Spare_Parts_Pkg.SUCCESS THEN
                    rows_inserted := rows_inserted + 1 ;
                    COMMIT ;
                    result := Diff.SUCCESS ;
                END IF ;
            ELSIF result = Diff.SUCCESS THEN
                IF IsDifferent(oldParts, item_type, order_quantity,
                    planner_code, smr_code, nsn_type, prime_ind,
                    newRec ) THEN
                    result := UpdateRow(newRec) ;
                    IF result = Amd_Spare_Parts_Pkg.SUCCESS THEN
                        rows_updated := rows_updated + 1 ;
                        COMMIT ;
                        result := Diff.SUCCESS ;
                    END IF ;
                END IF ;
            END IF ;
            EXIT WHEN result != Diff.SUCCESS ;
        END LOOP ;
        dbms_output.put_line('rows_read=' || rows_read || ' rows_inserted=' || rows_inserted || ' rows_updated=' || rows_updated) ;
        IF result = Diff.SUCCESS THEN
            result := DeleteRows() ;
        END IF ;
        dbms_output.put_line('rows_deleted=' || rows_deleted) ;
        Amd_Utils.InsertErrorMsg (
            pLoad_no => Amd_Utils.GetLoadNo(pSourceName => 'Diff',
            pTableName => 'Diff'),
            pData_line_no => 6,
            pData_line => 'amd_test_data',
            pKey_1 => rows_read,
            pKey_2 => rows_inserted,
            pKey_3 => rows_updated,
            pKey_4 => rows_deleted,
            pKey_5 => SYSDATE,
            pComments => 'rows_read=' || rows_read ||' rows_inserted=' || rows_inserted || ' rows_updated=' || rows_updated || ' rows_deleted=' || rows_deleted) ;
        COMMIT ;
        RETURN result ;
    EXCEPTION WHEN OTHERS THEN
        IF result IS NULL THEN
            result := Diff.FAILURE ;
        END IF ;
        RETURN ErrorMsg(pMsg => 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM ,
            pTableName => 'amd_spare_parts',
            pData_line_no => 7,
            pPart_no => NULL,
            pMfgr => NULL,
            pNsn => NULL,
            pReturnCode => result)  ;
    END Diff ;

    FUNCTION PrimeExistForEachNsn(pDataSource IN data_source) RETURN BOOLEAN IS


        result BOOLEAN := TRUE ;

        FUNCTION IsGoodPartList RETURN BOOLEAN IS
            result BOOLEAN := TRUE ;

            nsi_sid AMD_NSI_PARTS.nsi_sid%TYPE := NULL ;
            prime_cnt NUMBER := 0 ;
            tactical_cnt NUMBER := 0 ;
            error_cnt NUMBER := 0 ;

            CURSOR partList IS
                SELECT
                    nsi_sid,
                    part_no,
                    prime_ind
                FROM AMD_NSI_PARTS
                WHERE unassignment_date IS NULL
                ORDER BY nsi_sid ;
            PROCEDURE reportError(pNsi_sid IN AMD_NSI_PARTS.nsi_sid%TYPE, pPrime_cnt IN NUMBER) IS
                CURSOR nsns IS
                    SELECT nsn
                    FROM AMD_NSNS
                    WHERE nsi_sid = pNsi_sid ;

                nsn AMD_NSNS.nsn%TYPE := NULL ;
                tactical AMD_NATIONAL_STOCK_ITEMS.tactical%TYPE ;
                CURSOR sourceData IS
                    SELECT
                        nsn,
                        part_no,
                        mfgr,
                        prime_ind,
                        unit_cost,
                        smr_code
                    FROM TMP_AMD_SPARE_PARTS
                    WHERE nsn = reportError.nsn ;
            BEGIN
                IF pPrime_cnt = 0 THEN
                    dbms_output.put('No prime for nsi_sid=' || pNsi_sid) ;
                ELSE
                    dbms_output.put('Multiple primes for nsi_sid=' || pNsi_sid) ;
                END IF ;
                FOR nsnRec IN nsns LOOP
                    reportError.nsn := nsnRec.nsn ;
                    FOR rec IN sourceData LOOP
                        SELECT tactical
                        INTO reportError.tactical
                        FROM AMD_NATIONAL_STOCK_ITEMS
                        WHERE nsi_sid = pNsi_sid ;
                        IF reportError.tactical = 'Y' THEN
                            tactical_cnt := tactical_cnt + 1 ;
                        END IF ;
                        dbms_output.put_line(' part_no=' || rec.part_no || ' mfgr=' || rec.mfgr || ' nsn=' || rec.nsn ) ;
                    END LOOP ;
                END LOOP ;
            END reportError ;
        BEGIN
            FOR partList_rec IN partList LOOP
                IF nsi_sid IS NULL THEN
                    nsi_sid := partList_rec.nsi_sid ;
                END IF ;
                IF nsi_sid != partList_rec.nsi_sid THEN
                    IF prime_cnt = 1 THEN
                        NULL ;
                    ELSE
                        result := FALSE ;
                        error_cnt := error_cnt + 1 ;
                        reportError(pNsi_sid => nsi_sid, pPrime_cnt => prime_cnt) ;
                    END IF ;
                    nsi_sid := partList_rec.nsi_sid ;
                    prime_cnt := 0 ;
                END IF ;
                IF partList_rec.prime_ind = Amd_Defaults.PRIME_PART THEN
                    prime_cnt := prime_cnt + 1 ;
                END IF ;
            END LOOP ;
            IF error_cnt > 0 THEN
                dbms_output.put_line('There were ' || error_cnt || ' errors. ' || tactical_cnt || ' were marked as tactical.') ;
            END IF ;
            RETURN result ;
        END IsGoodPartList ;

        FUNCTION IsGoodSourceData RETURN BOOLEAN IS
            result BOOLEAN := TRUE ;
            prime_cnt NUMBER := 0 ;
            error_cnt NUMBER := 0 ;

            CURSOR sourceData IS
                SELECT *
                FROM TMP_AMD_SPARE_PARTS
                ORDER BY nsn, part_no, mfgr ;
            nsn TMP_AMD_SPARE_PARTS.nsn%TYPE := NULL ;

            PROCEDURE reportError(pNsn TMP_AMD_SPARE_PARTS.nsn%TYPE, pPrime_cnt IN NUMBER) IS
            BEGIN
                IF pPrime_cnt = 0 THEN
                    dbms_output.put_line('No prime for nsn=' || pNsn) ;
                ELSE
                    dbms_output.put_line(prime_cnt || ' primes for nsn=' || pNsn) ;
                END IF ;
            END reportError ;
        BEGIN
            FOR rec IN sourceData LOOP
                IF nsn IS NULL THEN
                    nsn := rec.nsn ;
                END IF ;
                IF nsn != rec.nsn THEN
                    IF prime_cnt = 1 THEN
                        NULL ;
                    ELSE
                        result := FALSE ;
                        error_cnt := error_cnt + 1 ;
                        reportError(pNsn => nsn,pPrime_cnt => prime_cnt) ;
                    END IF ;
                    nsn := rec.nsn ;
                    prime_cnt := 0 ;
                END IF ;
                IF rec.prime_ind = Amd_Defaults.PRIME_PART THEN
                    prime_cnt := prime_cnt + 1 ;
                END IF ;
            END LOOP ;
             IF error_cnt > 0 THEN
                dbms_output.put_line('There were ' || error_cnt || ' errors.') ;
            END IF ;
             RETURN result ;
        END IsGoodSourceData ;
    BEGIN
        IF pDataSource = NSI_PARTS THEN
            result := IsGoodPartList() ;
        ELSE
            result := IsGoodSourceData() ;
        END IF ;
        IF result THEN
            dbms_output.put_line('Only 1 prime/nsi_sid in amd_nsi_parts - the system is correct.') ;
        END IF ;
        RETURN result ;
    END PrimeExistForEachNsn ;

    FUNCTION PrimeCheckForTmpAmdSpareParts RETURN BOOLEAN IS
    BEGIN
        RETURN PrimeExistForEachNsn(pDataSource => TMP_SPARE_PARTS ) ;
    END PrimeCheckForTmpAmdSpareParts ;

    FUNCTION PrimeCheckForAmdNsiParts RETURN BOOLEAN IS
    BEGIN
        RETURN PrimeExistForEachNsn(pDataSource => NSI_PARTS ) ;
    END PrimeCheckForAmdNsiParts ;

    FUNCTION TestDefaults RETURN BOOLEAN IS
    BEGIN
        dbms_output.put_line('CONDEMN_AVG=' || Amd_Defaults.CONDEMN_AVG) ;
        dbms_output.put_line('CONSUMABLE=' || Amd_Defaults.CONSUMABLE) ;
        dbms_output.put_line('DELETE_ACTION=' || Amd_Defaults.DELETE_ACTION) ;
        dbms_output.put_line('DISPOSAL_COST=' || Amd_Defaults.DISPOSAL_COST) ;
        dbms_output.put_line('DISTRIB_UOM=' || Amd_Defaults.DISTRIB_UOM) ;
        dbms_output.put_line('INSERT_ACTION=' || Amd_Defaults.INSERT_ACTION) ;
        dbms_output.put_line('NOT_PRIME_PART=' || Amd_Defaults.NOT_PRIME_PART) ;
        dbms_output.put_line('NRTS_AVG=' || Amd_Defaults.NRTS_AVG) ;
        dbms_output.put_line('OFF_BASE_TURN_AROUND=' || Amd_Defaults.OFF_BASE_TURN_AROUND) ;
        dbms_output.put_line('ORDER_LEAD_TIME (repairable)=' || Amd_Defaults.GetOrderLeadTime(Amd_Defaults.REPAIRABLE)) ;
        dbms_output.put_line('ORDER_LEAD_TIME (consumable)=' || Amd_Defaults.GetOrderLeadTime(Amd_Defaults.CONSUMABLE)) ;
        dbms_output.put_line('ORDER_QUANTITY=' || Amd_Defaults.ORDER_QUANTITY) ;
        dbms_output.put_line('ORDER_UOM=' || Amd_Defaults.ORDER_UOM) ;
        dbms_output.put_line('PRIME_PART=' || Amd_Defaults.PRIME_PART ) ;
        dbms_output.put_line('QPEI_WEIGHTED=' || Amd_Defaults.QPEI_WEIGHTED) ;
        dbms_output.put_line('REPAIRABLE=' || Amd_Defaults.REPAIRABLE) ;
        dbms_output.put_line('RTS_AVG=' || Amd_Defaults.RTS_AVG ) ;
        dbms_output.put_line('SCRAP_VALUE=' || Amd_Defaults.SCRAP_VALUE) ;
        dbms_output.put_line('SHELF_LIFE=' || Amd_Defaults.SHELF_LIFE) ;
        dbms_output.put_line('TIME_TO_REPAIR_ON_BASE_AVG=' || Amd_Defaults.TIME_TO_REPAIR_ON_BASE_AVG) ;
        dbms_output.put_line('UNIT_COST=' || Amd_Defaults.GetUnitCost(
            pNsn => '1660014172839',
            pPart_no => '174081-13',
            pMfgr => '49315',
            pSmr_code => 'P2345N',
            pPlanner_code => 'PSA')) ;

        dbms_output.put_line('UNIT_VOLUME=' || Amd_Defaults.UNIT_VOLUME) ;
        dbms_output.put_line('UPDATE_ACTION=' || Amd_Defaults.UPDATE_ACTION) ;
        dbms_output.put_line('USE_BSSM_TO_GET_NSLs=' || Amd_Defaults.USE_BSSM_TO_GET_NSLs) ;
        dbms_output.put_line('COST_TO_REPAIR_ONBASE=' || Amd_Defaults.COST_TO_REPAIR_ONBASE) ;
        dbms_output.put_line('TIME_TO_REPAIR_ONBASE=' || Amd_Defaults.TIME_TO_REPAIR_ONBASE) ;
        dbms_output.put_line('TIME_TO_REPAIR_OFFBASE=' || Amd_Defaults.TIME_TO_REPAIR_OFFBASE) ;
        dbms_output.put_line('UNIT_COST_FACTOR_OFFBASE=' || Amd_Defaults.UNIT_COST_FACTOR_OFFBASE) ;
        RETURN TRUE ;
    END TestDefaults ;

    FUNCTION TestGetNsiSid RETURN BOOLEAN IS
        nsn AMD_NSNS.nsn%TYPE := '12424242' ;
        nsi_sid AMD_NSNS.nsi_sid%TYPE ;
        part_no AMD_NSI_PARTS.part_no%TYPE := '123434' ;
    BEGIN
        BEGIN
            nsi_sid := Amd_Utils.GetNsiSid(pNsn => nsn) ;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('no data found') ;
        END ;
        BEGIN
            nsi_sid := Amd_Utils.GetNsiSid(pPart_no => part_no) ;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('no data found') ;
        END ;
        RETURN TRUE ;
    END TestGetNsiSid ;

    FUNCTION revision RETURN VARCHAR2 IS
    BEGIN
         RETURN '$Revision:   1.15  $' ;
    END revision ;

    PROCEDURE helloWorld IS
    BEGIN
         dbms_output.put_line('Hello World') ;
    END helloWorld ;

    PROCEDURE show_message(pmv_msg_in IN CLOB) IS
    BEGIN
      IF LENGTH(pmv_msg_in)  > 255 THEN
         dbms_output.put_line(SUBSTR(pmv_msg_in,1,255));
         show_message(SUBSTR(pmv_msg_in,256,LENGTH(pmv_msg_in)));
      ELSE
         dbms_output.put_line(pmv_msg_in);
      END IF;
    END show_message ;


    PROCEDURE printclobout(result IN OUT NOCOPY CLOB) IS
    xmlstr VARCHAR2(32767);
    line VARCHAR2(2000);
    BEGIN
      xmlstr := dbms_lob.SUBSTR(result,32767);
      LOOP
        EXIT WHEN xmlstr IS NULL;
        line := SUBSTR(xmlstr,1,INSTR(xmlstr,'>',1,2));
        dbms_output.put_line(line);
        xmlstr := SUBSTR(xmlstr,INSTR(xmlstr,'>',1,2)+1);
      END LOOP;
    END printclobout ;

    PROCEDURE genXml IS

              theXml XmlType ;

    BEGIN
        DECLARE
               theClob CLOB := theXml.getClobVal() ;
        BEGIN
              printClobOut(theClob ) ;
        END ;
    END genXml ;
/*
    PROCEDURE orderInfoXml IS
              theXml XmlType ;
        CURSOR orderInfo IS
        SELECT
            xmlelement("ORDER",
              xmlelement("TRANHEADER",
                xmlelement("SITE",'LBC17'),
                xmlelement("TRANSRC",'BATCH'),
                xmlelement("TRANPRI",DECODE(action_code,'A','002','C','002','007')),
                xmlelement("TRANTYPE",'ORDER_INFO'),
                xmlelement("TRANACT",DECODE(action_code, 'A', 'I', 'C', 'I', action_code)),
                xmlelement("TRANDTE",TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')),
                xmlelement("ERRORFLG",'N')
                ),
              xmlelement("PARTHEADER",
                xmlelement("SRCSYS",PH_SOURCE_SYSTEM),
                xmlelement("CAGE",PH_CAGE_CODE),
                xmlelement("PART",PH_PART_NO),
                xmlelement("PCAGE",PH_PRIME_CAGE),
                xmlelement("PRIME",PH_PRIME_PART),
                xmlelement("NOUN",PH_NOUN),
                xmlelement("RCMIND",PH_RCM_IND),
                xmlelement("COG",PH_COG),
                xmlelement("FSC",PH_FSC),
                xmlelement("NIIN",PH_NIIN),
                xmlelement("ASSETMGR",PH_RESP_ASSET_MGR),
                xmlelement("PLAN",PH_PLANNED_PART),
                xmlelement("LEADTIME",PH_LEAD_TIME),
                xmlelement("PRICETYPE",PH_PRICE_TYPE),
                xmlelement("PRICE",PH_PRICE),
                xmlelement("FISCAL",PH_PRICE_FISCAL_YEAR),
                xmlelement("INDENT",PH_INDENTURE)
               ),
            xmlelement("DATA",
              xmlelement("ORDERNO",ORDER_NO),
              xmlelement("SITE",SITE_LOCATION),
              xmlelement("CREATED",TO_CHAR(CREATED_DATE, 'YYYYMMDDHH24MISS')),
              xmlelement("STATUS",STATUS)
             )
         ) AS theData
        FROM TMP_A2A_ORDER_INFO, amd_part_header_v
        WHERE part_no = ph_part_no ;

        theClob CLOB ; 

    BEGIN
        FOR rec IN orderInfo LOOP
               theXml := rec.theData ;
               theClob := theXml.getClobVal() ;
              printClobOut(theClob ) ;
        END LOOP ;
    END orderInfoXml ; */
 /*
    PROCEDURE orderInfoLineXml IS
              theXml XmlType ;
        CURSOR orderInfoLine IS
        SELECT
            xmlelement("ORDERLINE",
              xmlelement("TRANHEADER",
                xmlelement("SITE",'LBC17'),
                xmlelement("TRANSRC",'BATCH'),
                xmlelement("TRANPRI",DECODE(action_code,'A','002','C','002','007')),
                xmlelement("TRANTYPE",'ORDER_INFO'),
                xmlelement("TRANACT",DECODE(action_code, 'A', 'I', 'C', 'I', action_code)),
                xmlelement("TRANDTE",TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')),
                xmlelement("ERRORFLG",'N')
                ),
              xmlelement("PARTHEADER",
                xmlelement("SRCSYS",PH_SOURCE_SYSTEM),
                xmlelement("CAGE",PH_CAGE_CODE),
                xmlelement("PART",PH_PART_NO),
                xmlelement("PCAGE",PH_PRIME_CAGE),
                xmlelement("PRIME",PH_PRIME_PART),
                xmlelement("NOUN",PH_NOUN),
                xmlelement("RCMIND",PH_RCM_IND),
                xmlelement("COG",PH_COG),
                xmlelement("FSC",PH_FSC),
                xmlelement("NIIN",PH_NIIN),
                xmlelement("ASSETMGR",PH_RESP_ASSET_MGR),
                xmlelement("PLAN",PH_PLANNED_PART),
                xmlelement("LEADTIME",PH_LEAD_TIME),
                xmlelement("PRICETYPE",PH_PRICE_TYPE),
                xmlelement("PRICE",PH_PRICE),
                xmlelement("FISCAL",PH_PRICE_FISCAL_YEAR),
                xmlelement("INDENT",PH_INDENTURE)
               ),
            xmlelement("DATA",
              xmlelement("ORDERNO",ORDER_NO),
              xmlelement("SITE",SITE_LOCATION),
              xmlelement("CREATED",TO_CHAR(CREATED_DATE, 'YYYYMMDDHH24MISS')),
              xmlelement("STATUS",STATUS),
              xmlelement("LINE",LINE),
              xmlelement("QTYORDERED",QTY_ORDERED),
              xmlelement("QTYREC",QTY_RECEIVED)
             )
         ) AS theData
        FROM TMP_A2A_ORDER_INFO_LINE, amd_part_header_v
        WHERE part_no = ph_part_no ;

        theClob CLOB ;

    BEGIN
        FOR rec IN orderInfoLine LOOP
               theXml := rec.theData ;
               theClob := theXml.getClobVal() ;
              printClobOut(theClob ) ;
        END LOOP ;
    END orderInfoLineXml ; */

    PROCEDURE fix_national_stock_items IS
              CURSOR tmp_parts IS
              SELECT part_no, nsn FROM TMP_AMD_SPARE_PARTS ;
              plannerCodeCleaned AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE ;

              CURSOR items IS
              SELECT prime_part_no, nsn FROM AMD_NATIONAL_STOCK_ITEMS ;
              tmpCnt NUMBER := 0 ;
              itemCnt NUMBER := 0 ;
              threshold CONSTANT NUMBER := 500 ;
              updateCnt NUMBER := 0 ;
              recCnt NUMBER := 0 ;

              FUNCTION isValidPlannerCode(planner_code IN VARCHAR2) RETURN BOOLEAN IS
                         plannerCode AMD_PLANNERS.planner_code%TYPE ;
              BEGIN
                     SELECT planner_code INTO plannerCode FROM AMD_PLANNERS WHERE planner_code = isValidPlannerCode.planner_code ;
                   RETURN TRUE ;
              EXCEPTION WHEN standard.NO_DATA_FOUND THEN
                     RETURN FALSE ;
              END isValidPlannerCode ;
    BEGIN
         FOR rec IN tmp_parts LOOP
              recCnt := recCnt + 1 ;
              plannerCodeCleaned := Amd_Clean_Data.getPlannerCode(rec.nsn, rec.part_no) ;
             IF isValidPlannerCode(plannerCodeCleaned) THEN
                 IF plannerCodeCleaned IS NOT NULL
                 AND plannerCodeCleaned > '' THEN
                      tmpCnt := tmpCnt + 1 ;
                 END IF ;
                  UPDATE TMP_AMD_SPARE_PARTS
                 SET planner_code_cleaned = plannerCodeCleaned
                 WHERE part_no = rec.part_no
                 AND nsn = rec.nsn ;
                  updateCnt := updateCnt + 1 ;
                 IF MOD(updateCnt,threshold) = 0 THEN
                     COMMIT ;
                 END IF ;
             END IF ;
         END LOOP ;

         dbms_output.put_line('Processed ' || recCnt || ' parts.  Loaded ' || tmpCnt || ' tmp parts with planner_code_cleaned.'  || 'Updated ' || updateCnt || ' rows.') ;
         recCnt := 0 ;
         updateCnt := 0 ;

         FOR rec IN items LOOP
              recCnt := recCnt + 1 ;
              plannerCodeCleaned := Amd_Clean_Data.getPlannerCode(rec.nsn, rec.prime_part_no) ;
             IF isValidPlannerCode(plannerCodeCleaned) THEN
                 IF plannerCodeCleaned IS NOT NULL
                 AND plannerCodeCleaned > '' THEN
                      itemCnt := itemCnt + 1 ;
                 END IF ;
                 UPDATE AMD_NATIONAL_STOCK_ITEMS
                 SET planner_code_cleaned = plannerCodeCleaned
                 WHERE prime_part_no = rec.prime_part_no
                 AND nsn = rec.nsn ;
                  updateCnt := updateCnt + 1 ;
                 IF MOD(updateCnt,threshold) = 0 THEN
                     COMMIT ;
                 END IF ;
             END IF ;
         END LOOP ;
         dbms_output.put_line('Processed ' || recCnt || ' items.  Loaded ' || itemCnt || ' items with planner_code_cleaned.'  || 'Updated ' || updateCnt || ' rows.') ;

    END ;
    
    procedure setSequence(value in number) is
    begin
        theSequence := value ;
    end setSequence ;
    
    function setSequence(value in number) return number is
    begin
        theSequence := value ;
        return theSequence ;
    end setSequence ;
    
    function nextSequence(key in varchar2 := '') return number is
    begin
        if key = prevKey then
            null ;
        else
            theSequence := 0 ;
            prevKey := key ;
        end if;
        theSequence := theSequence + 1 ;
        return theSequence ;
    end nextSequence ;
    
    function getSequence return number is
    begin
        return theSequence ;
    end getSequence ;        

END;
/


DROP PUBLIC SYNONYM AMD_TEST_DATA;

CREATE PUBLIC SYNONYM AMD_TEST_DATA FOR AMD_OWNER.AMD_TEST_DATA;


GRANT EXECUTE ON AMD_OWNER.AMD_TEST_DATA TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_TEST_DATA TO AMD_WRITER_ROLE;
