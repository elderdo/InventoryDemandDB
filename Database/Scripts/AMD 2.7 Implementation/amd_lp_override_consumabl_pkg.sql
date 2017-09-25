SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_lp_override_consumabl_Pkg AS
 /*
      $Author:   zf297a  $
    $Revision:   1.11  $
        $Date:   07 Jan 2008 09:35:22  $
    $Workfile:   AMD_LP_OVERRIDE_CONSUMABL_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LP_OVERRIDE_CONSUMABL_PKG.pks.-arc  $
/*   
/*      Rev 1.11   07 Jan 2008 09:35:22   zf297a
/*   Added enhanced debugging: a record defining the debug data, a cursor used to retrieve the debug data, functions and procedures to set debugging on or off and to retrieve or delete the debug data.
/*   
/*      Rev 1.10   08 Nov 2007 22:50:32   zf297a
/*   Added NONWESM_SOURCE.
/*   
/*      Rev 1.8   24 Oct 2007 17:30:10   zf297a
/*   Added interfaces for the following constants:
/*   ROQ_TYPE
/*   ROP_TYPE
/*   GOLD_SOURCE
/*   WESM_SOURCE
/*   WHSE_LOCSID
/*   WHSE_LOCID
/*   
/*      Rev 1.7   12 Oct 2007 17:00:46   zf297a
/*   Changed interface name from loadZeroTsls to loadDefaultTsls.
/*   Added interfaces loadBasc, loadUK, loadAustrailia, and loadCanada
/*   
/*      Rev 1.6   11 Oct 2007 22:42:00   zf297a
/*   Added interface for procedure loadZeroTsls
/*   
/*      Rev 1.5   19 Sep 2007 17:27:48   zf297a
/*   Added DELETE_ACTION constant as an alias for amd_defaults.DELETE_ACTION
/*   
/*      Rev 1.4   18 Sep 2007 21:19:44   zf297a
/*   Made constants that were in the package body public and made alias's  VIRTURAL_UAB and VIRTUAL_COD.
/*   
/*      Rev 1.3   16 Aug 2007 14:16:18   zf297a
/*   Added interface for procedure version
/*   
/*      Rev 1.2   16 Aug 2007 12:27:52   zf297a
/*   Added interface for procedure loadAllA2A
/*   
/*      Rev 1.1   19 Jul 2007 14:36:10   zf297a
/*   Added inerfaces for loadVirtualLocations and loadLocPartOverrides.
/*   
/*      Rev 1.0   06 Jul 2007 17:27:12   zf297a
/*   Initial revision.
*/

    type tmpLocPartOveridConsumablesTab is table of tmp_locpart_overid_consumables%rowtype ;
    
    type debugRec is record  (
        timestamp date,
        msg AMD_LOAD_DETAILS.KEY_2%type
    ) ;
    
    type msgRec is record (
        msg amd_load_details.key_2%type 
    ) ;
    
    type debugCur is ref cursor return debugRec ;
    
    type msgCur is ref cursor return msgRec ;
    
    ROQ_TYPE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROQ Fixed' ;
    function getROQ_TYPE return amd_locpart_overid_consumables.tsl_override_type%type ;
    ROP_TYPE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROP Fixed' ;
    function getROP_TYPE return amd_locpart_overid_consumables.tsl_override_type%type ;
    GOLD_SOURCE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type := 'GOLD' ;
    function getGOLD_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type ;
    WESM_SOURCE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type := 'WESM' ;
    function getWESM_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type ;
    NONWESM_SOURCE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type := 'NONWESM' ;
    function getNONWESM_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type ;
    WHSE_LOCSID constant number := 256 ;
    function getWHSE_LOCSID return number ;
    WHSE_LOCID constant varchar2(6) := 'FD2090' ;
    function getWHSE_LOCID return number ;
    
    VIRTUAL_UAB constant amd_spare_networks.SPO_LOCATION%type := amd_location_part_leadtime_pkg.VIRTUAL_UAB_SPO_LOCATION ;
    VIRTUAL_COD constant amd_spare_networks.SPO_LOCATION%type := amd_location_part_leadtime_pkg.VIRTUAL_COD_SPO_LOCATION ;
    DELETE_ACTION constant amd_spare_networks.action_code%type := amd_defaults.DELETE_ACTION ;
    
    debug boolean := false ;
    function getDebugYorN return varchar2 ;
    procedure setDebug(switch in varchar2) ;
   
    procedure loadLvls ;
    procedure loadBasc ; -- added 10/11/2007 by dse
    procedure loadUK ; -- added 10/11/2007 by dse
    procedure loadAustrailia ; -- added 10/11/2007 by dse
    procedure loadCanada ; -- added 10/11/2007 by dse
    procedure loadRamp ;
    procedure loadWhse ;
    procedure loadWesm ;
    procedure loadVirtualLocations ;
    procedure loadLocPartOverrides ;
    
    function getRop(economic_order_qty in number, approved_lvl_qty in number , reorder_point in number) return number ;
    function getRoq(economic_order_qty in number, approved_lvl_qty in number, reorder_point in number) return number ;
    
    function doLPOverrideConsumablesDiff(part_no in varchar2, spo_location in varchar2, tsl_override_type in varchar2,
        tsl_override_user in varchar2, tsl_override_source in varchar2, tsl_override_qty in number, loc_sid in number, action_code in varchar2) return number ;
    
    procedure initialize(action_code in varchar2 := null) ;

    procedure loadAllA2A ;
    
    procedure loadDefaultTsls ; -- added 10/9/2007 by dse
       
    procedure version ;

    function isTestPart(part_no in amd_sent_to_a2a.part_no%type) return boolean ; -- added 1/4/2008 by dse
    function isTestPartYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 ; -- added 1/4/2008 by dse
    
    function getDebugCur return debugCur ;
    
    function getDebugCur(fromDate in date, toDate in date := sysdate) return debugCur ;
    function getDebugCur(textFilter in varchar2) return debugCur ;
    
    function listDebugMsgs return msgCur ;
    function listDebugMsgs(fromDate in date, toDate in date := sysdate) return msgCur ;
    function listDebugMsgs(textFilter in varchar2) return msgCur ;
    
    procedure deleteDebugMsgs ;
    
    function getVersion return varchar2 ;

   
end Amd_lp_override_consumabl_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG FOR AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_lp_override_consumabl_Pkg AS
 /*
      $Author:   zf297a  $
    $Revision:   1.51  $
        $Date:   14 Feb 2008 11:39:36  $
    $Workfile:   AMD_LP_OVERRIDE_CONSUMABL_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LP_OVERRIDE_CONSUMABL_PKG.pkb.-arc  $
/*   
/*      Rev 1.51   14 Feb 2008 11:39:36   zf297a
/*   Make sure that records with zero quantity are not written to tmp or amd tables.
/*
/*      Rev 1.50   10 Jan 2008 00:54:08   zf297a
/*   Made it comply to spec rev 30
/*
/*      Rev 1.49   07 Jan 2008 12:40:28   zf297a
/*   The calc for ROP is still dependent on the ROQ value:
/*   if rop <= 0 then
/*   	if rop = 0 then
/*   		if roq < default then
/*   			rop = default for ROP
/*   		end if
/*   	else
/*    		rop = default for ROP
/*   	end if
/*   end if
/*
/*      Rev 1.48   07 Jan 2008 09:31:36   zf297a
/*   Added enhanced debugging features: isTestPart now uses amd_test_parts as a data source, debug flag gets initialized via amd_param_changes or can be set via setDebug,  all dbms_output converted to use debugMsg which outputs via dbms_output and output to amd_load_details, added functions to return cursor's of the amd_load_details debug data, added procedure to delete all the debug rows, added getVersion function which returns the latest PVCS revision.
/*
/*      Rev 1.47   14 Dec 2007 09:40:46   zf297a
/*   Added parts to the test parts list.
/*
/*   Fixed  the wesmParts and lvls_by_base cursors to make rop and roq  independent.
/*
/*   For the loadWhse, processRec procedure make sure that rop is the default value if it is less than zero.
/*
/*   Fixed the dynamic query in nested procedure processWhseParts to make rop and roq independent.  Also, when adding to the sumRecs array treat the rop and roq independently.
/*
/*      Rev 1.46   07 Dec 2007 13:05:58   zf297a
/*   Fixed FD2090 calc in procedure loadWhse by adjusting BASC's ROQ column to be dynamic for nested procedure processWhseParts.
/*
/*      Rev 1.45   07 Dec 2007 00:27:52   zf297a
/*   For procedure doLPOverrideConsumablesDiff ignore duplicates since the diff's aging buffer may get full with this high value table.
/*
/*      Rev 1.44   05 Dec 2007 13:30:06   zf297a
/*   Removed debug code from doLPOverrideConsumablesDiff.
/*
/*      Rev 1.43   03 Dec 2007 13:17:18   zf297a
/*   implemented isTestPart to determine if a part belongs to the set of test parts.
/*   For loadWhse's FD2090 calc make sure ROP is greater than zero, otherwise use zero for both ROP and ROQ.
/*
/*      Rev 1.42   30 Nov 2007 12:00:44   zf297a
/*   Fixed the lvls_by_base cursor to use only records with a reorder_point > 0 per spec rev #28
/*
/*      Rev 1.41   29 Nov 2007 21:16:14   zf297a
/*   Fixed the roq column for the lvls_by_base cursor of the loadWhse routine - made sure that default roq was not returned.  (fixed bug 6-31B for ROQ calc)
/*
/*      Rev 1.40   28 Nov 2007 10:22:48   zf297a
/*   Round the tsl quantity when inserting into tmp_locpart_overid_consumables (bug # 6-29).
/*   Made sure the rop and roq from the whseData cursor are zero when the columns are null. (fixes bug 6-31 and 6-31B)
/*   Assign the values to the nonwesmSumRecs array for the levels by base, since this is the first time the array is used - therefore it needs initialized. (fixes bug 6-31 and 6-31B).
/*
/*      Rev 1.39   27 Nov 2007 18:12:42   zf297a
/*   Fixed calculation of FD2090 quantities by checking rop and roq for null values before trying to subtract them from the whse value.
/*
/*      Rev 1.38   19 Nov 2007 18:46:28   zf297a
/*   Fixed defaultTsls cursor by adding tsl_override_type to it.
/*
/*      Rev 1.37   15 Nov 2007 21:22:14   zf297a
/*   Add a part for debugging purposes.  Fix processRec of loadWhse to exclude records with BOTH ROP = the default ROP and ROQ = the default ROQ.
/*
/*      Rev 1.36   15 Nov 2007 00:10:42   zf297a
/*   Removed check for ROP/ROQ defaults for cursor wesmParts of procedure loadWhse and dynamic cursor in processWhseParts.
/*   Added tracing of an additional part + output the part no for each display using dbms_output.
/*
/*      Rev 1.35   09 Nov 2007 13:13:16   zf297a
/*   Removed trying to create recs for bulk insert - this method was too slow.
/*
/*      Rev 1.34   08 Nov 2007 22:51:40   zf297a
/*   Fixed summing of wesm and nonwesm parts for the loadWhse procedure.  Use bulk insert to load tmp_locpart_overid_consumables.
/*
/*      Rev 1.33   01 Nov 2007 22:24:30   zf297a
/*   For the loadDefaultTsls make sure that any part/location that is already in tmp_a2a_loc_part_override does not get created.
/*
/*      Rev 1.32   01 Nov 2007 18:23:02   zf297a
/*   Implemented the code to handle an action_code argument for the initialize procedure so that it can decide whether to delete data in tmp_a2a_loc_part_override, truncate all data from tmp_a2a_loc_part_override or to do nothing, which would imply that the table has already been prepared for initialization
/*
/*      Rev 1.31   01 Nov 2007 17:54:04   zf297a
/*   Don't delete RSP data that has been already loaded
/*
/*      Rev 1.30   01 Nov 2007 11:08:48   zf297a
/*   Make sure zero tsl's are consumables.
/*
/*      Rev 1.29   28 Oct 2007 16:40:06   zf297a
/*   User whse.user_ref3 for ROQ quantities.  Do include any default ROP or ROQ in the warehouse (FD2090) calculation.
/*
/*      Rev 1.28   26 Oct 2007 12:07:46   zf297a
/*   Converted dynamic sql to use bind variables.  Fixed whse retrievals to use whse.part instead of whse.prime.
/*
/*      Rev 1.27   24 Oct 2007 17:32:36   zf297a
/*   Implemented interfaces for the following constants:
/*   ROQ_TYPE
/*   ROP_TYPE
/*   GOLD_SOURCE
/*   WESM_SOURCE
/*   WHSE_LOCSID
/*   WHSE_LOCID
/*
/*   Implemented using amd_defaults to get ROP and ROQ default values.  Corrected cursors to use the correct ROP/ROQ default values.
/*
/*      Rev 1.26   18 Oct 2007 09:59:50   zf297a
/*   Fixed cursor lvls_by_base by using amd_defaults.getTSL_CONSUMABL_CALENDAR_DAYS instead of the 210 literal and removed a redundant check for a non-wesm part.
/*
/*      Rev 1.25   18 Oct 2007 09:55:46   zf297a
/*   Update cursor lvls_by_base to use the compatability_code when retriving the max(date_lvl_loaded)
/*
/*      Rev 1.24   16 Oct 2007 22:24:02   zf297a
/*   Fixed loadLvls by adding the compatability_code check for the max_dates.  This fixes bug 6-17C
/*
/*      Rev 1.23   16 Oct 2007 17:42:58   zf297a
/*   Fixed ROP for loadWesm - when it is null return -1.  Fixed Bug 6-7
/*
/*      Rev 1.22   12 Oct 2007 17:03:50   zf297a
/*   Implemented interfaces loadDefaultTsls, loadBasc, loadUK, loadAustrailia, and loadCanada.
/*   Update procedure loadWhse per spec rev 26.
/*
/*      Rev 1.21   11 Oct 2007 22:40:44   zf297a
/*   Added Canada (EY1414) and Warner Robins (FB2065) to lists of explicit loc_id's implemented proced loadZeroTsls
/*
/*      Rev 1.20   01 Oct 2007 09:20:38   zf297a
/*   Have the initialize procedure load amd_locpart_overid_consumables from tmp_locpart_overid_consumables ;;
/*
/*      Rev 1.19   28 Sep 2007 08:45:48   zf297a
/*   Fixed Bug#6-22: TSLs ROP Qty is 1 for non-WESM Parts when qualifying LVLS records have null or zero quantities.  TSLs: GOLD parts (i.e. non-WESM parts) that have qualifying GOLD.LVLS records where all 3 of the quantity fields are null or zero (i.e. Economic_Order_Qty, Approved_Lvl_Qty, and Reorder_Point) are sending an ROP qty of positive '1'.   This condition should send an ROP qty of negative '1'.
/*
/*      Rev 1.18   26 Sep 2007 16:57:38   zf297a
/*   Fixed cursor for loadWesm to make sure the roq is not zero
/*
/*      Rev 1.17   26 Sep 2007 11:50:36   zf297a
/*   Fixed the whse query for lvls to use the whseData cursor to get the values used in computing ROP and ROQ.  Also when no data is returned ROP = -1 and ROQ = 1.
/*
/*      Rev 1.16   25 Sep 2007 22:10:20   zf297a
/*   Fixed procedure loadWhse for Bug #6-10B where the ROP was being assigned a zero when it should not have been.  Also, change the whse query to a cursor sorted by the created_datetime in descending order so the most recent one is first.  When processing the cursor, only the first one is retrieved per each spo_prime_part_no.
/*
/*      Rev 1.15   19 Sep 2007 17:34:38   zf297a
/*   Moved procedure doUpdate to change its scope.  Added a boolean flag, canUpdate, to doInsert so that the invoking routine can determine if the tmp_locpart_overid_consumables table can be overlaid with the current passed parameters: currently the only invoking procedure to have it true is the loadWesm procedure since its data takes precedence over the loadLvlvs data.  Used procedure doInsert for loadLvls.  Added some code to laodRamp, but determined that it is only needed for repairables.
/*
/*      Rev 1.14   17 Sep 2007 10:06:54   zf297a
/*   When loading data from the ware house, make the rop and roq zero when the part cannot be found on the whse table.
/*
/*      Rev 1.13   14 Sep 2007 10:16:44   zf297a
/*   For procedure loadLvls changed cursor consumablesForLvls 's selection criteria to select wesm or non-wesm parts located at FSL's or select only wesm parts located at MOB's or always select parts located at bases EY1258','EY1746', or 'EY8780' .,
/*
/*      Rev 1.12   12 Sep 2007 13:50:56   zf297a
/*   Removed commits from for loops.
/*
/*      Rev 1.11   11 Sep 2007 16:01:50   zf297a
/*   Make sure the tsl_override_qty is not null before inserting or updating TMP_LOCPART_OVERID_CONSUMABLES.
/*
/*      Rev 1.10   10 Sep 2007 12:17:56   zf297a
/*   Added procedures doInsert and doUpdate to insert/update tmp_locpart_overid_consumables.  Streamlined loadWhse and loadWesm to use doInsert.  Changed queries for whse to sum data for each prime part retrieved.
/*
/*      Rev 1.9   20 Aug 2007 11:05:08   zf297a
/*   Fixed updateRow to use the action_code of  procedure doLPOverrideConsumab lesDiff  and fixed the insertRow to use the action_code of doLPOverrideConsumab lesDiff and to use sysdate for the last_update_dt.
/*
/*      Rev 1.8   17 Aug 2007 13:26:06   zf297a
/*   Make sure the diff function can handle inserting row's that have been logically deleted.
/*
/*      Rev 1.7   16 Aug 2007 23:35:54   zf297a
/*   Added errorMsg's to doLpOverrideConsumablesDiff.  Resequenced all pError_location numbers.
/*
/*      Rev 1.6   16 Aug 2007 14:16:44   zf297a
/*   Implemented interface for procedure version
/*
/*      Rev 1.5   16 Aug 2007 12:32:14   zf297a
/*   Added implementation of procedure loadAllA2A.
/*
/*      Rev 1.4   07 Aug 2007 10:08:26   zf297a
/*   Added check for loc_id's of EY1258, EY1746, EY8780
/*
/*      Rev 1.3   03 Aug 2007 13:54:00   zf297a
/*   Fixed the calc of whse_rop and whse_roq to be 1 if <= 0 or if no data is found for the given prime part.
/*
/*      Rev 1.2   03 Aug 2007 13:29:44   zf297a
/*   Fixed rop/roq calc for whse.  Used the isWesmPart function.
/*
/*      Rev 1.1   19 Jul 2007 14:37:10   zf297a
/*   implemented inerfaces for loadVirtualLocations and loadLocPartOverrides.
/*
/*      Rev 1.0   06 Jul 2007 17:27:10   zf297a
/*   Initial revision.
*/

    loggedDup boolean := false ;
    DEBUG_KEY constant amd_load_details.key_3%type := 'amd_lp_override_consumabl_pkg.debugMsg' ;

    type ropRoqRec is record (
        spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type,
        spo_location amd_spare_networks.spo_location%type,
        rop number,
        roq number
    ) ;

    type whseRec is record (
        spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type,
        rop number,
        roq number
    ) ;
    type whseTab is table of whseRec ;

    type locPartOveridConsumablesTab is table of TMP_LOCPART_OVERID_CONSUMABLES%rowtype ;
    locPartOveridConsumablesRecs locPartOveridConsumablesTab := locPartOveridConsumablesTab() ;

    type consumablesWhsePartsCur is ref cursor return whseRec ;

    type partTab is table of amd_sent_to_a2a.PART_NO%type ;
    testParts partTab ;

    cursor  consumableWhseParts(base in varchar2, source_code in varchar2, wesm_part in varchar2 := 'Y') is
        select sent.spo_prime_part_no,
        case
            when sum(nvl(whse.reorder_point,0)) <> 0 or sum(nvl(whse.USER_REF3 ,0)) > 0 then
                sum(nvl(whse.reorder_point,0))
            else amd_defaults.getROP
        end rop,
        case
            when sum(nvl(whse.USER_REF3 ,0)) > 0 then
                sum(nvl(whse.USER_REF3 ,0))
            else amd_defaults.getROQ
        end roq
        from whse,
        amd_spare_networks nwks,
        amd_sent_to_a2a sent
        where sent.action_code <> amd_defaults.getDELETE_ACTION
        and sent.part_no = sent.spo_prime_part_no
        and sent.spo_prime_part_no = whse.prime
        and whse.sc like source_code
        and nwks.action_code <> amd_defaults.getDELETE_ACTION
        and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = 'Y'
        and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = wesm_part
        and nwks.loc_id = base
        and nwks.spo_location is not null
        group by  spo_prime_part_no ;




    procedure writeMsg(
                pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 in varchar2 := '',
                pData IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
    BEGIN
        Amd_Utils.writeMsg (
                pSourceName => 'amd_lp_override_consumabl_pkg',
                pTableName  => pTableName,
                pError_location => pError_location,
                pKey1 => pKey1,
                pKey2 => pKey2,
                pKey3 => pKey3,
                pKey4 => pKey4,
                pData    => pData,
                pComments => pComments);
    exception when others then
        -- trying to rollback or commit from trigger
        if sqlcode = 4092 then
            raise_application_error(-20010,
                substr('amd_lp_override_consumabl_pkg '
                    || sqlcode || ' '
                    || pError_Location || ' '
                    || pTableName || ' '
                    || pKey1 || ' '
                    || pKey2 || ' '
                    || pKey3 || ' '
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        else
            raise ;
        end if ;
    end writeMsg ;

    procedure debugMsg(msg in varchar2, pError_location in number) is
    begin
        if debug then
            writeMsg(pTableName => 'debugMsg', pError_location => pError_location,
               pKey1 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
               pKey2 => msg,
               pKey3 => DEBUG_KEY) ;
            dbms_output.put_line(msg) ;
        end if ;
    exception when others then
        null ; -- a debug error should not stop the application
    end debugMsg ;

    procedure deleteDebugMsgs is
    begin
        delete from amd_load_details where key_3 = DEBUG_KEY ;
        commit ;
    end deleteDebugMsgs ;

    function listDebugMsgs return msgCur is
        cur msgCur ;
    begin
        open cur for select amd_load_details.key_2 msg from amd_load_details
                                 where key_3 = DEBUG_KEY
                                 order by AMD_LOAD_DETAILS.LOAD_NO ;
        return cur ;
    end listDebugMsgs ;

    function listDebugMsgs(fromDate in date, toDate in date := sysdate) return msgCur is
        cur msgCur ;
    begin
        open cur for select amd_load_details.key_2 msg from amd_load_details
                                 where key_3 = DEBUG_KEY
                                 and to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM')
                                 between fromDate and toDate
                                 order by AMD_LOAD_DETAILS.LOAD_NO ;
        return cur ;
    end listDebugMsgs ;

    function listDebugMsgs(textFilter in varchar2) return msgCur is
        cur msgCur ;
    begin
        if textFilter is null then
            open cur for select amd_load_details.key_2 msg from amd_load_details
                                     where key_3 = DEBUG_KEY
                                     order by AMD_LOAD_DETAILS.LOAD_NO ;
        else
            open cur for select amd_load_details.key_2 msg from amd_load_details
                                     where key_3 = DEBUG_KEY
                                     and key_2 like '%' || textFilter || '%'
                                     order by AMD_LOAD_DETAILS.LOAD_NO ;
        end if ;
        return cur ;
    end listDebugMsgs ;

    function getDebugCur return debugCur is
        cur debugCur ;
    begin
        open cur for select to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM') timestamp,
                                 amd_load_details.key_2 msg from amd_load_details
                                 where key_3 = DEBUG_KEY
                                 order by amd_load_details.load_no ;
        return cur ;
    end getDebugCur ;

    function getDebugCur(fromDate in date, toDate in date := sysdate) return debugCur is
        cur debugCur ;
    begin
        open cur for select to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM') timestamp,
                                 amd_load_details.key_2 msg from amd_load_details
                                 where key_3 = DEBUG_KEY
                                 and to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM')
                                    between fromDate and toDate
                                 order by amd_load_details.load_no ;
        return cur ;
    end getDebugCur ;

    function getDebugCur(textFilter in varchar2) return debugCur is
        cur debugCur ;
    begin
        if textFilter is null then
            open cur for select to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM') timestamp,
                                     amd_load_details.key_2 msg from amd_load_details
                                     where key_3 = DEBUG_KEY
                                     order by amd_load_details.load_no ;
        else
            open cur for select to_date(AMD_LOAD_DETAILS.KEY_1,'MM/DD/YYYY HH:MI:SS AM') timestamp,
                                     amd_load_details.key_2 msg from amd_load_details
                                     where key_3 = DEBUG_KEY
                                     and key_2 like '%' || textFilter || '%'
                                     order by amd_load_details.load_no ;
        end if ;

        return cur ;
    end getDebugCur ;

    PROCEDURE ErrorMsg(
        pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
        pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
        pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
        pKey1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
        pKey2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
        pKey3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
        pKey4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
        pComments IN VARCHAR2 := '') IS

        key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pComments ;
        error_location number ;
        load_no number ;

    BEGIN
      ROLLBACK;
      IF key5 = '' THEN
         key5 := pSqlFunction || '/' || pTableName ;
      ELSE
       key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
      END IF ;

      if pError_location is null then
        error_location := -9998 ;
      else
          if amd_utils.isNumber(pError_location) then
               error_location := pError_location ;
          else
               error_location := -9999 ;
          end if ;
     end if ;

      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important
      begin
        load_no := amd_utils.getLoadNo(pSourceName => substr(pSqlfunction,1,20), pTableName  => SUBSTR(pTableName,1,20)) ;
      exception when others then
        load_no := -1 ;  -- this should not happen
      end ;

      Amd_Utils.InsertErrorMsg (
        pLoad_no => load_no,
        pData_line_no => error_location,
        pData_line    => 'amd_lp_override_consumabl_pkg',
        pKey_1 => SUBSTR(pKey1,1,50),
        pKey_2 => SUBSTR(pKey2,1,50),
        pKey_3 => SUBSTR(pKey3,1,50),
        pKey_4 => SUBSTR(pKey4,1,50),
        pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
             ' ' || substr(key5,1,50),
        pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
        COMMIT;

    EXCEPTION WHEN OTHERS THEN
      if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
      if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
      if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
      if pKey1 is not null then dbms_output.put_line('key1=' || pKey1) ; end if ;
      if pkey2 is not null then dbms_output.put_line('key2=' || pKey2) ; end if ;
      if pKey3 is not null then dbms_output.put_line('key3=' || pKey3) ; end if ;
      if pKey4 is not null then dbms_output.put_line('key4=' || pKey4) ; end if ;
      if pComments is not null then dbms_output.put_line('pComments=' || pComments) ; end if ;
       raise_application_error(-20030,
            substr('amd_lp_override_consumabl_pkg '
                || sqlcode || ' '
                || pError_location || ' '
                || pSqlFunction || ' '
                || pTableName || ' '
                || pKey1 || ' '
                || pKey2 || ' '
                || pKey3 || ' '
                || pKey4 || ' '
                || pComments,1, 2000)) ;
	END ErrorMsg;


    function isTestPart(part_no in amd_sent_to_a2a.part_no%type) return boolean is
        result number ;
    begin
        if part_no in ('17P2A5974-519', '17P1B2630-1','M27500-20TN2G06','2609997',
        '17B9E3009-515', '17P3A1362-1', '17P5P0567-501', 'S4928912-6-025', 'S4928912-8-026', 'SLP5233C3-400',
        '17P2G3000-503','17P2A5371-217','17P2G3504-511','2606243','S2062646-302D-1',
        '17B6P6315-507','17B8D8302-517','17P2A1883-501','17P2A3921-11','17P6W7070-1','17P8D8127-2','2302775-2',
        '17B1U6022-1','3D0080-3-8','A36047','NP652095-2-629','17P8D8349-505',
        '1B0984','289-601-50','3D0068-3-11','3D0080-3-4',
        '3D0100-6AF','3D0099C6-5','1A8942','3D0234-1','3D0097C6-13') then
            return true ;
        end if ;


        if testParts.first is not null then
            for indx in testParts.first .. testParts.last loop
                if testParts(indx) = part_no then
                    return true ;
                end if ;
            end loop ;
        end if ;

        return false ;

    end isTestPart ;

    function isTestPartYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 is
    begin
        if isTestPart(part_no)  then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isTestPartYorN ;

    function getRop(economic_order_qty in number, approved_lvl_qty in number , reorder_point in number) return number is
    begin

        if economic_order_qty > 0 then
            return reorder_point ;
        end if ;

        return 1 ;

    end getRop ;

    function getROQ(economic_order_qty in number, approved_lvl_qty in number, reorder_point in number) return number is
    begin

        if economic_order_qty > 0 then
            return economic_order_qty ;
        end if ;

        if approved_lvl_qty > 0 then
            return approved_lvl_qty - reorder_point ;
        end if ;

        return 1 ;

    end getROQ ;

    function getTslOverrideUser(nsn in amd_national_stock_items.nsn%type) return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_USER%type is
        nsi_sid amd_national_stock_items.NSI_SID%type ;
    begin
        nsi_sid := amd_utils.GETNSISID(pNsn => nsn) ;
        return amd_location_part_override_pkg.GETFIRSTLOGONIDFORPART(nsi_sid) ;
    end getTslOverrideUser ;

    function getSpoPrimePartNo(nsn in amd_rbl_pairs.new_nsn%type) return amd_rbl_pairs.NEW_NSN%type is
        spo_prime_part_no amd_sent_to_a2a.SPO_PRIME_PART_NO%type ;
    begin
        begin
            select sent.spo_prime_part_no  into spo_prime_part_no
            from amd_national_stock_items items,
            amd_sent_to_a2a sent
            where items.nsn = getSpoPrimePartNo.nsn
            and items.action_code <> amd_defaults.getDELETE_ACTION
            and items.prime_part_no = sent.part_no
            and sent.part_no = sent.spo_prime_part_no
            and sent.action_code <> amd_defaults.getDELETE_ACTION ;
        exception when standard.NO_DATA_FOUND then
            spo_prime_part_no := null ;
        end ;
        return spo_prime_part_no ;
    end getSpoPrimePartNo ;

    procedure doUpdate(part_no in tmp_locpart_overid_consumables.part_no%type,
                spo_location in tmp_locpart_overid_consumables.spo_location%type,
                loc_sid in tmp_locpart_overid_consumables.loc_sid%type,
                tsl_override_type in tmp_locpart_overid_consumables.tsl_override_type%type,
                tsl_override_qty in tmp_locpart_overid_consumables.tsl_override_qty%type,
                tsl_override_user in tmp_locpart_overid_consumables.tsl_override_user%type,
                tsl_override_source in tmp_locpart_overid_consumables.tsl_override_source%type,
                update_cnt in out number) is



    begin
        if tsl_override_qty is not null then
            update tmp_locpart_overid_consumables
            set loc_sid = doUpdate.loc_sid,
            tsl_override_qty = doUpdate.tsl_override_qty,
            tsl_override_user = doUpdate.tsl_override_user,
            tsl_override_source = doupdate.tsl_override_source,
            last_update_dt = sysdate
            where part_no = doUpdate.part_no
            and spo_location = doupdate.spo_location
            and tsl_override_type = doUpdate.tsl_override_type ;
            update_cnt := update_cnt + 1 ;

            if update_cnt < 100 then
                -- record 1st 100 keys of recs updateds
                writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 10,
                   pKey1 => 'doUpdate.part_no=' || part_no,
                   pKey2 => 'spo_location=' || spo_location,
                   pKey3 => 'type=' || tsl_override_type,
                   pKey4 => 'loc_sid=' || to_char(loc_sid),
                   pData => 'source=' || tsl_override_source) ;
            end if ;
        end if ;

    exception
        when others then
             ErrorMsg(pSqlfunction => 'doUpdate',pTableName  => 'TMP_LOCPART_OVERID_CONSUMABLES',
               pError_location => 20,
               pKey1 => 'part_no=' || part_no,
               pKey2 => 'spo_location=' || spo_location,
               pKey3 => 'type=' || tsl_override_type,
               pKey4 => 'loc_sid=' || to_char(loc_sid),
               pComments => 'source=' || tsl_override_source) ;
             raise ;
    end doUpdate ;

    procedure doInsert(part_no in tmp_locpart_overid_consumables.part_no%type,
                spo_location in tmp_locpart_overid_consumables.spo_location%type,
                loc_sid in tmp_locpart_overid_consumables.loc_sid%type,
                tsl_override_type in tmp_locpart_overid_consumables.tsl_override_type%type,
                tsl_override_qty in tmp_locpart_overid_consumables.tsl_override_qty%type,
                tsl_override_user in tmp_locpart_overid_consumables.tsl_override_user%type,
                tsl_override_source in tmp_locpart_overid_consumables.TSL_OVERRIDE_SOURCE%type,
                insert_cnt in out number,
                update_cnt in out number,
                canUpdate in boolean,
                recs in out tmpLocPartOveridConsumablesTab) is
                rec tmp_locpart_overid_consumables%rowtype ;
    begin
        rec.part_no := part_no ;
        rec.spo_location := spo_location ;
        rec.loc_sid := loc_sid ;
        rec.tsl_override_type := tsl_override_type ;
        rec.tsl_override_qty := tsl_override_qty ;
        rec.tsl_override_user := tsl_override_user ;
        rec.tsl_override_source := tsl_override_source ;
        rec.action_code := amd_defaults.INSERT_ACTION ;
        rec.last_update_dt := sysdate ;
        insert_cnt := insert_cnt + 1 ;
        recs.extend ;
        recs(recs.last) := rec ;
    end doInsert ;


    procedure doInsert(part_no in tmp_locpart_overid_consumables.part_no%type,
                spo_location in tmp_locpart_overid_consumables.spo_location%type,
                loc_sid in tmp_locpart_overid_consumables.loc_sid%type,
                tsl_override_type in tmp_locpart_overid_consumables.tsl_override_type%type,
                tsl_override_qty in tmp_locpart_overid_consumables.tsl_override_qty%type,
                tsl_override_user in tmp_locpart_overid_consumables.tsl_override_user%type,
                tsl_override_source in tmp_locpart_overid_consumables.TSL_OVERRIDE_SOURCE%type,
                insert_cnt in out number,
                update_cnt in out number,
                canUpdate in boolean) is
    begin
        if tsl_override_qty is not null and tsl_override_qty <> 0 then -- Xzero
            if isTestPart(part_no) then
                debugMsg('inserting ' || part_no || ' for location ' || spo_location, pError_location => 30) ;
            end if ;
            insert into TMP_LOCPART_OVERID_CONSUMABLES
            (part_no, spo_location, loc_sid, tsl_override_type, tsl_override_qty, tsl_override_user, tsl_override_source)
            values (doInsert.part_no, doInsert.spo_location, doInsert.loc_sid ,
                doInsert.tsl_override_type, round(doInsert.tsl_override_qty), doInsert.tsl_override_user, doInsert.tsl_override_source) ;
            insert_cnt := insert_cnt + 1 ;
        else
            if isTestPart(part_no) then
               if tsl_override_qty is null then -- Xzero
                    debugMsg('tsl_override_qty was null for ' || part_no || ' for location ' || spo_location, pError_location => 40) ;
               elsif  tsl_override_qty <> 0 then  -- Xzero
                    debugMsg('tsl_override_qty was zero for ' || part_no || ' for location ' || spo_location, pError_location => 40) ; -- Xzero
               end if;  -- Xzero
            end if ;

        end if ;

    exception
        when standard.DUP_VAL_ON_INDEX then
            if canUpdate then
                doUpdate(part_no,spo_location,loc_sid,tsl_override_type,tsl_override_qty,tsl_override_user,tsl_override_source, update_cnt) ;
            end if ;
        when others then
             ErrorMsg(pSqlfunction       => 'doInsert',pTableName  => 'TMP_LOCPART_OVERID_CONSUMABLES',
                       pError_location => 50, pKey1 => 'part_no=' || part_no,
                       pKey2 => 'spo_location=' || spo_location,
                       pKey3 => 'type=' || tsl_override_type,
                       pKey4 => 'loc_sid=' || to_char(loc_sid),
                       pComments => 'source=' || tsl_override_source) ;
             raise ;
    end doInsert ;


    procedure loadWhseBase(spo_location in varchar2, sc in varchar2, roq in varchar2 := 'nvl(whse.USER_REF3 ,0)') is
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;
        tsl_override_user TMP_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_USER%type ;
        loc_sid tmp_locpart_overid_consumables.loc_sid%type ;
        theCursor SYS_REFCURSOR ;
        rec ropRoqRec ;
        operator varchar2(6) ;
        type whseBaseRec is record (
            spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type,
            spo_location amd_locpart_overid_consumables.spo_location%type,
            rop number,
            roq number
        ) ;
        type whseBaseTab is table of whseBaseRec ;
        whseBaseRecs whseBaseTab ;
        recs tmpLocPartOveridConsumablesTab := tmpLocPartOveridConsumablesTab() ;
    begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 60,
				pKey1 => 'loadWhseBase(' || spo_location || ',' || sc|| ',' || roq || ')',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

        if instr(sc,'%') > 0 then
            operator := ' like ' ;
        else
            operator := ' = ' ;
        end if ;

        open theCursor for
            'select sent.spo_prime_part_no,
                    nwks.spo_location,
                    case when sum(nvl(whse.reorder_point,0)) <> 0 or sum(nvl(' || roq || ',0)) > 0 then
                            sum(nvl(whse.reorder_point,0))
                         else
                            amd_defaults.getROP
                    end rop,
                    case when sum(nvl(' || roq || ',0)) > 0 then
                            sum(nvl(' || roq || ',0))
                          else amd_defaults.getROQ
                    end roq
                    from whse,
                    amd_spare_networks nwks,
                    amd_sent_to_a2a sent
                    where sent.action_code <> amd_defaults.getDELETE_ACTION
                    and sent.part_no = whse.part
                    and sent.part_no = sent.spo_prime_part_no
                    and whse.sc ' || operator || ' :the_sc
                    and nwks.action_code <> amd_defaults.getDELETE_ACTION
                    and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = ''Y''
                    and nwks.loc_id = :the_spo_location
                    and nwks.spo_location is not null
                    group by spo_location, spo_prime_part_no'
                    using sc, spo_location ;

        fetch theCursor bulk collect into whseBaseRecs ;
        close theCursor ;
        if whseBaseRecs.first is not null then
            for indx in whseBaseRecs.first .. whseBaseRecs.last
            loop
                insert_cnt := in_cnt + 1 ;

                tsl_override_user := getTslOverrideUser(amd_utils.getNsn(whseBaseRecs(indx).spo_prime_part_no)) ;
                if whseBaseRecs(indx).spo_location = WHSE_LOCID then
                    loc_sid := WHSE_LOCSID ;
                else
                    if whseBaseRecs(indx).spo_location like '%_RSP' then
                        loc_sid := amd_utils.getLocSid(substr(whseBaseRecs(indx).spo_location,1,6)) ;
                    else
                        loc_sid := amd_utils.getLocSid(whseBaseRecs(indx).spo_location) ;
                    end if ;
                end if ;

                doinsert(part_no => whseBaseRecs(indx).spo_prime_part_no, spo_location => whseBaseRecs(indx).spo_location, loc_sid => loc_sid,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => whseBaseRecs(indx).roq, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;


                doinsert(part_no => whseBaseRecs(indx).spo_prime_part_no, spo_location => whseBaseRecs(indx).spo_location, loc_sid => loc_sid,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => whseBaseRecs(indx).rop, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;
            end loop ;
        end if ;

        if recs.first is not null then
            forall indx in recs.first .. recs.last
                insert into tmp_locpart_overid_consumables
                values recs(indx) ;
            dbms_output.put_line(recs.count || ' recs loaded') ;
            commit ;
        else
            dbms_output.put_line('no recs loaded via bulk insert') ;
        end if ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 70,
				pKey1 => 'loadWhseBase(' || spo_location || ',' || sc|| ',' || roq || ')',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt)) ;
        commit ;

    end loadWhseBase ;

    procedure LoadBasc is
    begin
        loadWhseBase(spo_location => amd_defaults.AMD_BASC_LOC_ID, sc => amd_defaults.AMD_BASC_SC,
            roq =>  'nvl(whse.STOCK_LEVEL,0) - nvl(whse.reorder_point,0)' ) ;
    end loadBasc ;

    procedure LoadUk is
    begin
        loadWhseBase(spo_location => amd_defaults.GETAMD_UK_LOC_ID, sc => amd_defaults.GETAMD_UK_SC) ;
    end loadUK;

    procedure LoadCanada is
    begin
        loadWhseBase(spo_location => amd_defaults.GETAMD_CAN_LOC_ID, sc => amd_defaults.GETAMD_CAN_SC) ;
    end loadCanada ;

    procedure loadAustrailia is
    begin
        loadWhseBase(spo_location => amd_defaults.GETAMD_AUS_LOC_ID, sc => amd_defaults.GETAMD_AUS_SC) ;
    end loadAustrailia ;



    procedure loadLvls is
        type lvlsRec is record (
            spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type,
            loc_sid amd_locpart_overid_consumables.loc_sid%type,
            spo_location amd_locpart_overid_consumables.spo_location%type,
            current_stock_number lvls.CURRENT_STOCK_NUMBER%type,
            nsn amd_national_stock_items.nsn%type,
            sran lvls.SRAN%type,
            rop number,
            roq number
        ) ;
        type lvlsTab is table of lvlsRec ;
        lvlsRecs lvlsTab ;

        cursor consumablesForLvls is
            select sent.spo_prime_part_no,
            nwks.loc_sid,
            amd_utils.getSpoLocation(nwks.loc_sid) spo_location,
            current_stock_number,
            items.nsn nsn,
            a.sran,
            case
                when nvl(a.economic_order_qty,0) > 0 then nvl(a.reorder_point,0)
                when nvl(a.approved_lvl_qty,0) > 0 then nvl(a.reorder_point,0)
                when nvl(a.economic_order_qty,0) = 0
                    and nvl(a.approved_lvl_qty,0) = 0
                    and nvl(a.reorder_point,0) = 0 then amd_defaults.getROP
                else nvl(a.reorder_point,amd_defaults.getROP)
            end rop,
            case
                when nvl(a.economic_order_qty,0) > 0 then a.economic_order_qty
                when nvl(a.approved_lvl_qty,0) > 0
                    and a.approved_lvl_qty - nvl(a.reorder_point,0) > 0 then a.approved_lvl_qty - nvl(a.reorder_point,0)
                else amd_defaults.getROQ
            end roq
            from lvls a,
            amd_national_stock_items items,
            amd_spare_networks nwks,
            amd_sent_to_a2a sent,
	        (   select max(date_lvl_loaded) date_lvl_loaded, nsn, sran
                from lvls
                where COMPATIBILITY_CODE = 'C'
		        group by nsn, sran ) max_dates
            where items.action_code <> amd_defaults.getDELETE_ACTION
            and nwks.action_code <> amd_defaults.getDELETE_ACTION
            and a.COMPATIBILITY_CODE = 'C'
            and items.nsn = a.NSN
            and amd_utils.isPartConsumableYorN(items.prime_part_no) = 'Y'
            and a.date_lvl_loaded = max_dates.date_lvl_loaded
	        and a.nsn = max_dates.nsn
	        and a.sran = max_dates.sran
            and a.date_lvl_loaded between sysdate - amd_defaults.getTSL_CONSUMABL_CALENDAR_DAYS and sysdate
            and a.sran = nwks.LOC_ID
            and a.sran <> amd_defaults.GETAMD_WAREHOUSE_LOCID
            and (nwks.loc_type = 'FSL'
                  or (nwks.loc_type = 'MOB' and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = 'N')
                  or nwks.LOC_ID in (amd_defaults.getAMD_AUS_LOC_ID,
                                    amd_defaults.getAMD_CAN_LOC_ID,
                                    amd_defaults.getAMD_UK_LOC_ID)
                )
            and nwks.spo_location is not null
            and items.prime_part_no = sent.part_no
            and sent.part_no = sent.spo_prime_part_no
            and sent.action_code <> amd_defaults.getDELETE_ACTION
            order by niin, sran, document_datetime ;


            insert_cnt number := 0 ;
            update_cnt number := 0 ;
            in_cnt number := 0 ;
            spo_prime_part_no amd_sent_to_a2a.SPO_PRIME_PART_NO%type ;
            rop number ;
            roq number ;
            tsl_override_user TMP_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_USER%type ;


    begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 80,
				pKey1 => 'loadLvls',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

        open consumablesForLvls ;
        fetch consumablesForLvls bulk collect into lvlsRecs ;
        close consumablesForLvls ;

        if lvlsRecs.first is not null then
            for indx in lvlsRecs.first .. lvlsRecs.last loop
                insert_cnt := in_cnt + 1 ;

                tsl_override_user := getTslOverrideUser(lvlsRecs(indx).nsn) ;

                doinsert(part_no => lvlsRecs(indx).spo_prime_part_no, spo_location => lvlsRecs(indx).spo_location, loc_sid => lvlsRecs(indx).loc_sid,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => lvlsRecs(indx).roq, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false);


                doinsert(part_no => lvlsRecs(indx).spo_prime_part_no, spo_location => lvlsRecs(indx).spo_location, loc_sid => lvlsRecs(indx).loc_sid,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => lvlsRecs(indx).rop, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
            end loop ;
        end if ;

		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 90,
				pKey1 => 'loadLvls',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt)) ;
        commit ;
    end loadLvls ;

    procedure loadRamp  is
        /*
        cursor consumablesForRamp is
            select sent.spo_prime_part_no ,
            nwks.loc_sid,
            amd_utils.getSpoLocation(nwks.loc_sid) spo_location,
            current_stock_number,
            items.nsn nsn,
            ramp.sran,
            ramp.demand_level rop
            from ramp,
            cat1,
            amd_spare_networks nwks,
            amd_sent_to_a2a sent,
            amd_rbl_pairs rbl,
            amd_national_stock_items items
            where
            ( sent.spo_prime_part_no = sent.part_no
              and sent.action_code <> DELETE_ACTION
              and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = 'Y'
            ) and (
                    ramp.SC like 'C170008FB%G'
                    and cat1.source_code = 'F77'
                    and amd_utils.isNumberYorN(amd_utils.formatNsn(ramp.CURRENT_STOCK_NUMBER)) = 'Y'
                    and ramp.DELETE_INDICATOR <> DELETE_ACTION
            ) and (
                substr(ramp.sc,8,6) = nwks.loc_id
                and nwks.loc_type in ( 'FSL','MOB')
                and nwks.SPO_LOCATION is not null
                and nwks.action_code <> DELETE_ACTION
            )
            and ramp.CURRENT_STOCK_NUMBER = cat1.NSN
            and (
                    ( amd_utils.formatNsn(ramp.current_stock_number) = rbl.old_nsn
                      and rbl.new_nsn = amd_utils.getNsn(sent.spo_prime_part_no)
                    )
                    or amd_utils.formatNsn( ramp.current_stock_number ) = amd_utils.getNsn(sent.spo_prime_part_no)

                )
            group by sent.spo_prime_part_no ;
        */
    begin
        null ;
    end loadRamp ;



    procedure loadWhse  is

        type sumTab is table of whseRec index by amd_sent_to_a2a.spo_prime_part_no%type ;

        wesmSumRecs sumTab ;
        nonWesmSumRecs sumTab ;
        partIndx amd_sent_to_a2a.spo_prime_part_no%type ;

        wesmRecs whseTab ;

        cursor wesmParts is
        select spo_prime_part_no,
        sum(
            case when L11.BOEING_BASE_MIN_LEVEL > 0 then
                    case when L11.BOEING_BASE_MIN_LEVEL = 1
                        and nvl(boeing_base_max_level,0) - nvl(boeing_base_min_level,0) <= 0 then
                            0
                        else L11.BOEING_BASE_MIN_LEVEL
                    end
                 else
                    0 -- still pick up the part but do not factor in calc
            end) rop,
        sum(
             case when nvl(boeing_base_max_level,0) - nvl(boeing_base_min_level,0) > 0 then
                    case when nvl(boeing_base_max_level,0) - nvl(boeing_base_min_level,0) = 1
                        and L11.BOEING_BASE_MIN_LEVEL <= 0 then
                            0
                        else nvl(boeing_base_max_level,0) - nvl(boeing_base_min_level,0)
                    end
                  else
                    0 -- still pick up the part but do not factor in calc
             end
            ) roq
        from
        L11, amd_national_stock_items items,
        amd_spare_networks nwks,
        amd_sent_to_a2a sent,
        active_niins
        where source_of_supply = 'F77'
        and L11.niin = active_niins.niin
        and L11.nsn = items.nsn
        and items.nsn <> amd_defaults.getDELETE_ACTION
        and items.prime_part_no = sent.part_no
        and sent.part_no = sent.spo_prime_part_no
        and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = 'Y'
        and sent.action_code <> amd_defaults.getDELETE_ACTION
        and nwks.action_code <> amd_defaults.getDELETE_ACTION
        and L11.sran = substr(loc_id,3,4)
        and nwks.LOC_TYPE = 'MOB'
        and nwks.LOC_ID not in (amd_defaults.getAMD_UK_LOC_ID, amd_defaults.getAMD_BASC_LOC_ID,
                                amd_defaults.getAMD_WARNER_ROBINS_LOC_ID )
        and nwks.spo_location is not null
        group by spo_prime_part_no ;


        lvlsByBaseRecs whseTab ;

        cursor lvls_by_base is
            select sent.spo_prime_part_no spo_prime_part_no,
            sum (
                case when nvl(reorder_point,0) > 0 then
                        case when reorder_point = 1
                            and nvl(a.economic_order_qty,0) <= 0
                            and nvl(a.approved_lvl_qty,0) <= 0 then
                                0
                            else reorder_point
                        end
                     else
                        0
                end ) rop,
            sum (
                        case
                            when nvl(a.economic_order_qty,0) > 0 then
                                case when a.economic_order_qty = 1 and nvl(reorder_point,0) <= 0 then
                                        0
                                     else a.economic_order_qty
                                end
                            when nvl(a.approved_lvl_qty,0) > 0 then
                                case when a.approved_lvl_qty - nvl(a.reorder_point,0) = 1
                                    and nvl(reorder_point,0) <= 0 then
                                        0
                                     else a.approved_lvl_qty - nvl(a.reorder_point,0)
                                end
                            else 0
                        end
                 ) roq
            from lvls a,
            amd_national_stock_items items,
            amd_spare_networks nwks,
            amd_sent_to_a2a sent
            where items.action_code <> amd_defaults.getDELETE_ACTION
            and nwks.action_code <> amd_defaults.getDELETE_ACTION
            and a.COMPATIBILITY_CODE = 'C'
            and items.nsn = a.NSN
            and amd_utils.isPartConsumableYorN(items.prime_part_no) = 'Y'
            and date_lvl_loaded = (select max(date_lvl_loaded) from lvls where a.nsn = nsn and a.sran = sran and a.compatibility_code = 'C')
            and date_lvl_loaded between sysdate - amd_defaults.getTSL_CONSUMABL_CALENDAR_DAYS and sysdate
            and a.sran = nwks.LOC_ID
            and a.sran <> amd_defaults.getAMD_WAREHOUSE_LOCID
            and (nwks.loc_type = 'FSL'
                  or nwks.loc_type = 'MOB'
                  or nwks.LOC_ID = amd_defaults.getAMD_WARNER_ROBINS_LOC_ID
                )
            and nwks.spo_location is not null
            and items.prime_part_no = sent.part_no
            and sent.part_no = sent.spo_prime_part_no
            and sent.action_code <> amd_defaults.getDELETE_ACTION
            and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = 'N'
            group by sent.spo_prime_part_no ;

        in_cnt number := 0 ;
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
        whse_rop number ;
        rop number ;
        whse_roq number ;
        roq number ;


        rec whseRec ;

        recs tmpLocPartOveridConsumablesTab := tmpLocPartOveridConsumablesTab() ;

        function getRop(rop in number, roq in number) return number is
        begin
            if nvl(rop,0) = 1 and nvl(roq,0) = 0 then
                return 0 ;
            else
                return nvl(rop,0) ;
            end if ;
        end getRop ;

        function getRoq(roq in number, rop in number) return number is
        begin
            if nvl(roq,0) = 1 and nvl(rop,0) = 0 then
                return 0 ;
            else
                return nvl(roq,0) ;
            end if ;
        end getRoq ;

        procedure sumTheRecs(recs in whseTab, sums in out sumTab) is
            rop number ;
            roq number ;

            procedure increment(amt in number, result in out number) is
            begin
                if result is null then
                    result := amt ;
                else
                    result := result + amt ;
                end if ;
            end increment ;

        begin
            debugMsg('sum the recs',  pError_location => 100) ;
            if recs.first is not null then
                for indx in recs.first .. recs.last loop
                    in_cnt := in_cnt + 1 ;
                    rop := getRop(rop => recs(indx).rop, roq => recs(indx).roq) ;
                    roq := getRoq(roq => recs(indx).roq, rop => recs(indx).rop) ;

                    if isTestPart(recs(indx).spo_prime_part_no) then
                        debugMsg(recs(indx).spo_prime_part_no || ': base rop= ' || recs(indx).rop
                        || ' base roq=' || recs(indx).roq , pError_location => 110) ;
                        debugMsg(recs(indx).spo_prime_part_no || ': rop= ' || rop
                        || ' roq=' || roq, pError_location => 120) ;
                    end if ;
                    sums(recs(indx).spo_prime_part_no).spo_prime_part_no := recs(indx).spo_prime_part_no ;
                    if rop > 0 then
                        increment(amt => rop, result => sums(recs(indx).spo_prime_part_no).rop) ;
                    else
                        increment(amt => 0, result => sums(recs(indx).spo_prime_part_no).rop ) ;
                    end if ;
                    if roq > 0 then
                        increment(amt => roq, result => sums(recs(indx).spo_prime_part_no).roq) ;
                    else
                        increment(amt => 0, result => sums(recs(indx).spo_prime_part_no).roq) ;
                    end if ;
                end loop ;
            end if ;
        end sumTheRecs ;

        procedure processRec(rec in whseRec, tsl_override_source in tmp_locpart_overid_consumables.tsl_override_source%type) is
            cursor whseData(spo_prime_part_no in varchar2) is
                    select nvl(reorder_point,0) reorder_point, nvl(user_ref3,0) user_ref3, created_datetime
                    from whse
                    where prime = spo_prime_part_no
                    and part = prime
                    and substr(sc,1,3) = 'C17'
                    and substr(sc,8,7) = 'CTLATLG'
                    order by created_datetime desc ;
            recFound boolean := false ;
        begin
            tsl_override_user := getTslOverrideUser(amd_utils.getNsn( rec.spo_prime_part_no)) ;

            <<getWhseData>>
            begin
                recFound := false ;
                for warehouseRec in whseData(rec.spo_prime_part_no) loop
                    whse_rop := warehouseRec.reorder_point ;
                    whse_roq := warehouseRec.user_ref3 ;
                    recFound := true ;
                    exit when 1 = 1 ;
                end loop ;
                if isTestPart(rec.spo_prime_part_no) then
                    debugMsg(rec.spo_prime_part_no ||': whse_rop=' || whse_rop || ' whse_roq=' || whse_roq || ' rec.rop= ' || rec.rop || ' rec.roq=' || rec.roq, pError_location => 130) ;
                end if ;
                if recFound then
                    rop := whse_rop - nvl(rec.rop,0) ;

                    roq := whse_roq  - nvl(rec.roq,0) ;

                    if rop <= 0 then
                        if rop = 0 then
                            if roq < amd_defaults.ROQ then
                                rop := amd_defaults.ROP ;
                            end if ;
                        else
                            rop := amd_defaults.ROP ;
                        end if ;
                    end if ;

                    if roq <= 0 then
                        roq := amd_defaults.ROQ ;
                    end if ;
                else
                    rop := amd_defaults.ROP ;
                    roq := amd_defaults.ROQ ;
                end if ;

                if isTestPart(rec.spo_prime_part_no) then
                    debugMsg(rec.spo_prime_part_no  ||': rop= ' || rop || ' *** roq=' || roq || ' ***', pError_location => 140) ;
                end if ;

            end getWhseData ;

            /*
                The default values for ROP or ROQ on any base is not to be used
                in the FD2090 calculation regardless of whether that value
                combination is derived from actual source data or is assigned a default
                value.
            */

            if rop = amd_defaults.ROP and roq = amd_defaults.ROQ then
                if isTestPart(rec.spo_prime_part_no) then
                    debugMsg(rec.spo_prime_part_no || ' rejected', pError_location => 150) ;
                end if ;
            else
                doinsert(part_no => rec.spo_prime_part_no, spo_location => WHSE_LOCID, loc_sid => WHSE_LOCSID,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => roq, tsl_override_user => tsl_override_user,
                    tsl_override_source => tsl_override_source,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;



                doinsert(part_no => rec.spo_prime_part_no, spo_location => WHSE_LOCID, loc_sid => WHSE_LOCSID,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => rop, tsl_override_user => tsl_override_user,
                    tsl_override_source => tsl_override_source,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;

                if isTestPart(rec.spo_prime_part_no) then
                    debugMsg(rec.spo_prime_part_no ||  ' accepted', pError_location => 160) ;
                end if ;
            end if ;
        exception when others then
             ErrorMsg(pSqlfunction => 'loadWhse',pTableName  => 'TMP_LOCPART_OVERID_CONSUMABLES',
               pError_location => 170,
               pKey1 => 'spo_prime_part_no=' || nvl(rec.spo_prime_part_no,'null'),
               pKey2 => 'rop=' || to_char(rec.rop),
               pKey3 => 'roq=' || to_char(rec.roq) ) ;
             raise ;
        end processRec ;

        procedure processWhseParts(spo_location in varchar2,
            sc in varchar2, operator in varchar2, wesm_part in varchar2,
            sumRecs in out sumTab, roq in varchar2 := 'nvl(whse.USER_REF3 ,0)')  is
            theCursor SYS_REFCURSOR ;

            whsePartRecs whseTab ;

        begin
            dbms_output.put_line('processWhseParts: spo_location=' || amd_defaults.AMD_UK_LOC_ID
            || ' sc=' || sc || ' operator=' || operator || ' wesm_part=' || wesm_part || ' roq=' || roq) ;
            open theCursor for
                'select sent.spo_prime_part_no,
                 sum(
                    case when nvl(whse.reorder_point,0) > 0 then
                            case when to_number(nvl(whse.reorder_point,0)) = 1
                                and ' || roq || ' <= 0 then
                                    0
                                else to_number(nvl(whse.reorder_point,0))
                            end
                         else
                            0
                    end)  rop,
                 sum(
                    case when ' || roq || ' > 0 then
                            case when to_number( ' || roq || ') = 1
                                and nvl(whse.reorder_point,0) <= 0 then
                                    0
                                else to_number( ' || roq || ')
                            end
                         else
                            0
                    end) roq
                from whse,
                amd_spare_networks nwks,
                amd_sent_to_a2a sent
                where sent.action_code <> amd_defaults.getDELETE_ACTION
                and sent.part_no = sent.spo_prime_part_no
                and sent.spo_prime_part_no = whse.part
                and whse.sc ' || operator || ' :the_sc
                and nwks.action_code <> amd_defaults.getDELETE_ACTION
                and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = ''Y''
                and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = :the_wesm_part
                and nwks.loc_id = :the_spo_location
                and nwks.spo_location is not null
                group by  spo_prime_part_no'
                using sc, wesm_part, spo_location ;

            fetch theCursor bulk collect into whsePartRecs ;
            close theCursor ;

            sumTheRecs(recs => whsePartRecs, sums => sumRecs ) ;

        exception when others then
             ErrorMsg(pSqlfunction => 'processWhseParts',pTableName  => 'TMP_LOCPART_OVERID_CONSUMABLES',
               pError_location => 180,
               pKey1 => 'wesm_part=' || wesm_part,
               pKey2 => 'spo_location=' || spo_location,
               pKey3 => 'sc=' || sc,
               pKey4 => 'operator=' || operator) ;
            raise ;
        end processWhseParts ;


   begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 190,
                pKey1 => 'loadWhse',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;

        debugMsg('process wesmParts', pError_location => 200) ;
        open wesmParts ;
        fetch wesmParts bulk collect into wesmRecs ;
        close wesmParts ;
        sumTheRecs(recs => wesmRecs, sums => wesmSumRecs) ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 210,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'wesmRecs.count=' || to_char(wesmRecs.count)) ;


        debugMsg('process wesm parts whsePart for UK', pError_location => 220) ;
        processWhseParts(spo_location => amd_defaults.AMD_UK_LOC_ID,
                            sc => amd_defaults.AMD_UK_SC,
                            operator => 'like', wesm_part =>'Y',
                            sumRecs => wesmSumRecs ) ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 230,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'processed wesm UK') ;

        debugMsg('process wesm parts whsePart for BASC', pError_location => 240) ;
        processWhseParts(spo_location => amd_defaults.AMD_BASC_LOC_ID,
                            sc => amd_defaults.AMD_BASC_SC,
                            operator => '=', wesm_part =>'Y',
                            sumRecs => wesmSumRecs,
                            roq => 'nvl(whse.STOCK_LEVEL,0) - nvl(whse.reorder_point,0)' ) ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 250,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'processed wesm BASC') ;



        debugMsg('process wesmSumRecs', pError_location => 260) ;
        partIndx := wesmSumRecs.first ;
        while partIndx is not null loop
            if isTestPart(wesmSumRecs(partIndx).spo_prime_part_no) then
                debugMsg(wesmSumRecs(partIndx).spo_prime_part_no || ': rop= ' || wesmSumRecs(partIndx).rop || ' roq=' || wesmSumRecs(partIndx).roq, pError_location => 270) ;
            end if ;
            processRec(wesmSumRecs(partIndx), WESM_SOURCE) ;
            partIndx := wesmSumRecs.next(partIndx) ;
        end loop ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 280,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'wesmSumRecs.count=' || to_char(wesmSumRecs.count)) ;
        debugMsg('wesmSumRecs.count=' || wesmSumRecs.count, pError_location => 290) ;

        debugMsg('process lvls_by_base', pError_location => 300) ;
        open lvls_by_base ;
        fetch lvls_by_base bulk collect into lvlsByBaseRecs ;
        close lvls_by_base ;
        sumTheRecs(recs => lvlsByBaseRecs, sums => nonwesmSumRecs) ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 310,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'lvlsByBaseRecs.count=' || to_char(lvlsByBaseRecs.count)) ;

        debugMsg('process non-wesm parts whsePart for UK', pError_location => 320) ;
        processWhseParts(spo_location => amd_defaults.AMD_UK_LOC_ID,
                            sc => amd_defaults.AMD_UK_SC,
                            operator => 'like', wesm_part =>'N',
                            sumRecs => nonwesmSumRecs ) ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 330,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'processed nonwesm UK') ;

        debugMsg('process non-wesm parts whsePart for BASC', pError_location => 340) ;
        processWhseParts(spo_location => amd_defaults.AMD_BASC_LOC_ID,
                            sc => amd_defaults.AMD_BASC_SC,
                            operator => '=', wesm_part =>'N',
                            sumRecs => nonwesmSumRecs,
                            roq => 'nvl(whse.STOCK_LEVEL,0) - nvl(whse.reorder_point,0)') ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 350,
                pKey1 => 'loadWhse',
                pKey2 => 'at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'processed nonwesm BASC') ;


        partIndx := nonwesmSumRecs.first ;
        while partIndx is not null loop
            processRec(nonwesmSumRecs(partIndx), NONWESM_SOURCE) ;
            partIndx := nonwesmSumRecs.next(partIndx) ;
        end loop ;

        if recs.first is not null then
            forall indx in recs.first .. recs.last
                insert into tmp_locpart_overid_consumables
                values recs(indx) ;
            commit ;
            debugMsg(recs.count || ' recs loaded', pError_location => 360) ;
        else
            debugMsg('no recs loaded via bulk insert', pError_location => 370) ;
        end if ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 380,
                pKey1 => 'loadWhse',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt) ) ;
    end loadWhse ;

    procedure loadWesm  is
        TYPE wesmRec IS RECORD (
            spo_prime_part_no amd_sent_to_a2a.SPO_PRIME_PART_NO%type,
            loc_sid amd_location_part_override.LOC_SID%type,
            spo_location amd_locpart_overid_consumables.SPO_LOCATION%type,
            roq number,
            rop number,
            prime_part_no amd_national_stock_items.PRIME_PART_NO%type,
            nsn amd_national_stock_items.nsn%type,
            fsc l11.FSC%type,
            niin L11.NIIN%type,
            sran L11.sran%type,
            part L11.part%type,
            boeing_base_min_level L11.BOEING_BASE_MIN_LEVEL%type
        ) ;
        type wesmTab is table of wesmRec ;

        recs tmpLocPartOveridConsumablesTab := tmpLocPartOveridConsumablesTab() ;

        cursor wesm_data is
        select sent.spo_prime_part_no spo_prime_part_no, loc_sid,
        amd_utils.getSpoLocation(loc_sid) spo_location,
        case
            when boeing_base_max_level - boeing_base_min_level > 0 then boeing_base_max_level - boeing_base_min_level
            else amd_defaults.ROQ
        end roq,
        nvl(L11.BOEING_BASE_MIN_LEVEL,amd_defaults.getROP) rop,
        items.prime_part_no,
        items.nsn,
        fsc, L11.niin, sran, part, boeing_base_min_level
        from L11,
        active_niins,
        amd_national_stock_items items,
        amd_sent_to_a2a sent,
        amd_spare_networks nwks
        where source_of_supply = 'F77'
        and L11.niin = active_niins.niin
        and L11.nsn = items.nsn
        and items.nsn <> amd_defaults.getDELETE_ACTION
        and items.prime_part_no = sent.part_no
        and sent.part_no = sent.spo_prime_part_no
        and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = 'Y'
        and sent.action_code <> amd_defaults.getDELETE_ACTION
        and nwks.action_code <> amd_defaults.getDELETE_ACTION
        and L11.sran = substr(loc_id,3,4)
        and nwks.loc_id <> amd_defaults.GETAMD_WAREHOUSE_LOCID
        and (nwks.LOC_TYPE in ('MOB')
            or nwks.LOC_ID in (amd_defaults.getAMD_AUS_LOC_ID,amd_defaults.getAMD_UK_LOC_ID,
                                amd_defaults.getAMD_CAN_LOC_ID,amd_defaults.getAMD_WARNER_ROBINS_LOC_ID))
        and nwks.spo_location is not null ;

        wesmRecs wesmTab ;

        in_cnt number :=  0 ;
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;

    begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 390,
                pKey1 => 'loadWesm',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        dbms_output.put_line('loadWesm') ;
        open wesm_data ;
        fetch wesm_data bulk collect into wesmRecs ;
        close wesm_data ;

        if wesmRecs.first is not null then
            for indx in wesmRecs.first .. wesmRecs.last loop
                in_cnt := in_cnt + 1 ;

                tsl_override_user := getTslOverrideUser(wesmRecs(indx).nsn) ;

                doInsert(part_no => wesmRecs(indx).spo_prime_part_no, spo_location => wesmRecs(indx).spo_location, loc_sid => wesmRecs(indx).loc_sid,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => wesmRecs(indx).roq, tsl_override_user => tsl_override_user,
                    tsl_override_source => WESM_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => true) ;
                    --recs => recs) ;


               doInsert(part_no => wesmRecs(indx).spo_prime_part_no, spo_location => wesmRecs(indx).spo_location, loc_sid => wesmRecs(indx).loc_sid,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => wesmRecs(indx).rop, tsl_override_user => tsl_override_user,
                    tsl_override_source => WESM_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => true) ;
                    --recs => recs) ;


            end loop ;
        end if ;

        if recs.first is not null then
            forall indx in recs.first .. recs.last
                insert into tmp_locpart_overid_consumables
                values recs(indx) ;
            commit ;
            dbms_output.put_line(recs.count || ' recs loaded') ;
        else
            dbms_output.put_line('no recs loaded via bulk insert') ;
        end if ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 400,
                pKey1 => 'loadWesm',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt) ) ;
        commit ;
    end loadWesm ;


     procedure loadVirtualLocations is
        type spoPrimePartTab is table of amd_sent_to_a2a.spo_prime_part_no%type ;
        spoPrimePartRecs spoPrimePartTab ;

        cursor consumableParts is
        select sent.spo_prime_part_no spo_prime_part_no
        from amd_sent_to_a2a sent
        where sent.part_no = sent.spo_prime_part_no
        and sent.action_code <> amd_defaults.getDELETE_ACTION
        and amd_utils.isPartConsumableYorN(sent.part_no) = 'Y' ;

        recs tmpLocPartOveridConsumablesTab := tmpLocPartOveridConsumablesTab() ;


        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
     begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 410,
            pKey1 => 'loadVirtualLocations',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        dbms_output.put_line('loadVirtualLocations') ;
        open consumableParts ;
        fetch consumableParts bulk collect into spoPrimePartRecs ;
        close consumableParts ;

        if spoPrimePartRecs.first is not null then
            for indx in spoPrimePartRecs.first .. spoPrimePartRecs.last loop
                in_cnt := in_cnt + 1 ;

                tsl_override_user := getTslOverrideUser(amd_utils.GETNSN(spoPrimePartRecs(indx)) ) ;

               doInsert(part_no => spoPrimePartRecs(indx), spo_location => VIRTUAL_UAB, loc_sid => null,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => amd_defaults.ROQ, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;

               doInsert(part_no => spoPrimePartRecs(indx), spo_location => VIRTUAL_COD, loc_sid => null,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => amd_defaults.ROP, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;

               doInsert(part_no => spoPrimePartRecs(indx), spo_location => VIRTUAL_COD, loc_sid => null,
                    tsl_override_type => ROQ_TYPE, tsl_override_qty => amd_defaults.ROQ, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;


               doInsert(part_no => spoPrimePartRecs(indx), spo_location => VIRTUAL_UAB, loc_sid => null,
                    tsl_override_type => ROP_TYPE, tsl_override_qty => amd_defaults.ROP, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;

            end loop ;
        end if ;
        if recs.first is not null then
            forall indx in recs.first .. recs.last
                insert into tmp_locpart_overid_consumables
                values recs(indx) ;
            dbms_output.put_line(recs.count || ' recs loaded') ;
            commit ;
        else
            dbms_output.put_line('no recs loaded via bulk insert') ;
        end if ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 420,
                pKey1 => 'loadVirtualLocations',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt)) ;
     end loadVirtualLocations ;

    function doLPOverrideConsumablesDiff(part_no in varchar2, spo_location in varchar2, tsl_override_type in varchar2,
        tsl_override_user in varchar2, tsl_override_source in varchar2, tsl_override_qty in number, loc_sid in number, action_code in varchar2) return number is


        procedure updateRow is
        begin
            update amd_locpart_overid_consumables
            set tsl_override_user = doLPOverrideConsumablesDiff.tsl_override_user,
            tsl_override_source = doLPOverrideConsumablesDiff.tsl_override_source,
            tsl_override_qty = doLPOverrideConsumablesDiff.tsl_override_qty,
            loc_sid = doLPOverrideConsumablesDiff.loc_sid,
            action_code = doLPOverrideConsumablesDiff.action_code,
            last_update_dt = sysdate
            where part_no = doLPOverrideConsumablesDiff.part_no
            and spo_location = doLPOverrideConsumablesDiff.spo_location
            and tsl_override_type = doLPOverrideConsumablesDiff.tsl_override_type ;

        exception when others then
            errorMsg(pSqlfunction       => 'update',pTableName  => 'AMD_LOCPART_OVERID_CONSUMABLES',
                pError_location => 430,
                pKey1 => 'part_no=' || part_no,
                   pKey2 => 'spo_location=' || spo_location,
                pKey3              => 'tsl_override_type=' || tsl_override_type,
                pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
            raise ;
        end updateRow ;

        procedure insertRow is
            cur_action_code amd_locpart_overid_consumables.action_code%type ;
        begin
            if tsl_override_qty is not null and tsl_override_qty <> 0 then -- Xzero
                insert into amd_locpart_overid_consumables
                (part_no, spo_location, tsl_override_type, tsl_override_user, tsl_override_source, tsl_override_qty, loc_sid, last_update_dt, action_code)
                values(part_no, spo_location, tsl_override_type, tsl_override_user, tsl_override_source, tsl_override_qty, loc_sid, sysdate, action_code) ;
            end if ; -- Xzero

        exception
            when standard.DUP_VAL_ON_INDEX then
                select action_code into cur_action_code from amd_locpart_overid_consumables
                where part_no = doLPOverrideConsumablesDiff.part_no
                and spo_location = doLPOverrideConsumablesDiff.spo_location
                and tsl_override_type = doLPOverrideConsumablesDiff.tsl_override_type ;
                if cur_action_code = 'D' then
                    updateRow ;
                else
                    raise ;
                end if ;
            when others then
                errorMsg(pSqlfunction       => 'insert',pTableName  => 'AMD_LOCPART_OVERID_CONSUMABLES',
                    pError_location => 440,
                    pKey1 => 'part_no=' || part_no,
                    pKey2 => 'spo_location=' || spo_location,
                    pKey3              => 'tsl_override_type=' || tsl_override_type,
                    pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
                raise ;
        end insertRow ;



    begin

        /*
        writeMsg(pTableName => 'doLPOverrideConsumablesDiff', pError_location => 450,
           pKey1 => 'doUpdate.part_no=' || part_no,
           pKey2 => 'spo_location=' || spo_location,
           pKey3 => 'type=' || tsl_override_type,
           pKey4 => 'user=' || tsl_override_user,
           pData => 'source=' || tsl_override_source,
           pComments => 'qty=' || to_char(tsl_override_qty) || ' loc_sid=' || to_char(loc_sid) || ' action_code=' || action_code) ;

        return 0 ;
        */

        if action_code = 'A' then
            begin
                insertRow ;
            exception when standard.DUP_VAL_ON_INDEX then
                if not loggedDup then
                    writeMsg(pTableName => 'tmp_locpart_overid_consumables', pError_location => 460,
                        pKey1 => 'part_no=' || part_no,
                        pKey2 => 'spo_location=' || spo_location,
                        pKey3 => 'tsl_override_type=' || tsl_override_type,
                        pKey4 => 'DUP_VAL_ON_INDEX') ;
                    loggedDup := true ;
                end if ;
                return 0 ; -- row already exists: ignore since the diff's aging buffer may have gotten full
            end ;
        else
            updateRow ;
        end if ;

        declare
            result boolean ;
        begin
            result := amd_location_part_override_pkg.insertedTmpA2ALPO (
                  pPartNo    => part_no,
                  pBaseName    => spo_location,
                  pOverrideType => tsl_override_type,
                  pTslOverrideQty => tsl_override_qty,
                  pOverrideReason => amd_location_part_override_pkg.OVERRIDE_REASON,
                  pTslOverrideUser => tsl_override_user,
                  pBeginDate => sysdate,
                  pActionCode => action_code,
                  pLastUpdateDt => sysdate) ;
       end ;


        return 0 ;
    exception when others then
        errorMsg(pSqlfunction       => 'diff',pTableName  => 'AMD_LOCPART_OVERID_CONSUMABLES',
            pError_location => 470,
            pKey1 => 'part_no=' || part_no,
            pKey2 => 'spo_location=' || spo_location,
            pKey3 => 'tsl_override_type=' || tsl_override_type,
            pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
        raise ;
    end doLPOverrideConsumablesDiff;

    procedure initialize(action_code in varchar2 := null) is
    begin
        mta_truncate_table('amd_locpart_overid_consumables','reuse storage') ;

        if action_code = amd_defaults.DELETE_ACTION then
            delete from tmp_a2a_loc_part_override
            where override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE
            and site_location not like '%_RSP' ; -- don't delete any rsp data that was loaded by the amd_location_part_override_pkg
            commit ;
        elsif upper(action_code) = 'T' then
            mta_truncate_table('tmp_a2a_loc_part_override','reuse storage') ;
        end if ;

        loadLocPartOverrides ;
        commit ;

        insert into amd_locpart_overid_consumables
            select * from tmp_locpart_overid_consumables where tsl_override_qty <> 0 ; -- XZero
        commit ;

        insert into tmp_a2a_loc_part_override
        (part_no,site_location,override_type,override_quantity,override_user,begin_date,action_code, last_update_dt)
        select part_no, spo_location,tsl_override_type,tsl_override_qty,tsl_override_user,sysdate,action_code,sysdate
        from tmp_locpart_overid_consumables where tsl_override_qty <> 0 ; -- Xzero
        commit ;

    end initialize ;


     procedure loadLocPartOverrides is
     begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 480,
            pKey1 => 'loadLocPartOverrides',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        mta_truncate_table('tmp_locpart_overid_consumables','reuse storage') ;
        loadWesm ; -- always run this first
        loadBasc ;
        loadUK ;
        loadCanada ;
        loadAustrailia ;
        loadLvls ;
        loadRamp ;
        loadWhse ;
        loadVirtualLocations ;
        loadDefaultTsls ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 490,
            pKey1 => 'loadLocPartOverrides',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        commit ;
     end  loadLocPartOverrides ;
     procedure loadAllA2A is
        cursor consumables is
        select * from amd_locpart_overid_consumables ;
        result boolean ;
     begin
        delete from tmp_a2a_loc_part_override where override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE ;
        commit ;
        for rec in consumables loop
            result := amd_location_part_override_pkg.insertedTmpA2ALPO (
                  pPartNo    => rec.part_no,
                  pBaseName    => rec.spo_location,
                  pOverrideType => rec.tsl_override_type,
                  pTslOverrideQty => rec.tsl_override_qty,
                  pOverrideReason => amd_location_part_override_pkg.OVERRIDE_REASON,
                  pTslOverrideUser => rec.tsl_override_user,
                  pBeginDate => sysdate,
                  pActionCode => rec.action_code,
                  pLastUpdateDt => sysdate) ;
        end loop ;
        commit ;
     end loadAllA2A ;

     procedure loadDefaultTsls is
        type partBaseRec is record (
            spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type,
            spo_location amd_spare_networks.spo_location%type,
            tsl_override_type tmp_a2a_loc_part_override.OVERRIDE_TYPE%type
        ) ;
        type partBaseTab is table of partBaseRec ;
        partBaseRecs partBaseTab ;

        cursor defaultTsls is
        select *
        from
        (select spo_prime_part_no from amd_sent_to_a2a
         where part_no = spo_prime_part_no
         and amd_utils.isPartConsumableYorN(spo_prime_part_no) = 'Y'
         and action_code <> amd_defaults.getDELETE_ACTION) parts,
        (select distinct spo_location from amd_spare_networks where spo_location is not null
         union
         select distinct mob || '_RSP' rsp_location from amd_spare_networks where mob is not null
        ) bases,
        (select ROP_TYPE tsl_override_type  from dual
        union
        select ROQ_TYPE tsl_override_type from dual)
        minus
        (select part_no, spo_location, TSL_OVERRIDE_TYPE from tmp_locpart_overid_consumables
         union
         select part_no, site_location, override_type from tmp_a2a_loc_part_override where
            override_type in (ROP_TYPE,ROQ_TYPE)
         )  ;

        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
        tsl_override_qty tmp_locpart_overid_consumables.TSL_OVERRIDE_QTY%type ;

        recs tmpLocPartOveridConsumablesTab := tmpLocPartOveridConsumablesTab() ;
    begin
         writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 500,
            pKey1 => 'loadDefaultTsls',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        commit ;
       open defaultTsls ;
       fetch defaultTsls bulk collect into partBaseRecs ;
       close defaultTsls ;

       if partBaseRecs.first is not null then
           for indx in partBaseRecs.first .. partBaseRecs.last loop
                in_cnt := in_cnt + 1 ;
                tsl_override_user := getTslOverrideUser(amd_utils.GETNSN(partBaseRecs(indx).spo_prime_part_no) ) ;
                if partBaseRecs(indx).tsl_override_type = ROP_TYPE then
                    tsl_override_qty := amd_defaults.ROP ;
                else
                    tsl_override_qty := amd_defaults.ROQ ;
                end if ;

                doInsert(part_no => partBaseRecs(indx).spo_prime_part_no, spo_location => partBaseRecs(indx).spo_location,
                    loc_sid => amd_utils.getLocSid(partBaseRecs(indx).spo_location),
                    tsl_override_type => partBaseRecs(indx).tsl_override_type, tsl_override_qty => tsl_override_qty, tsl_override_user => tsl_override_user,
                    tsl_override_source => GOLD_SOURCE,
                    insert_cnt => insert_cnt,
                    update_cnt => update_cnt,
                    canUpdate => false) ;
                    --recs => recs) ;

           end loop ;
      end if ;

       if recs.first is not null then
            forall indx in recs.first .. recs.last
                insert into tmp_locpart_overid_consumables
                values recs(indx) ;
            commit ;
            dbms_output.put_line(recs.count || ' recs loaded') ;
        else
            dbms_output.put_line('no recs loaded via buld insert') ;
        end if ;
       writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 510,
            pKey1 => 'loadDefaultTsls',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'in_cnt=' || to_char(in_cnt),
            pKey4 => 'insert_cnt=' || to_char(insert_cnt),
            pData => 'update_cnt=' || to_char(update_cnt)) ;
        commit ;
    end loadDefaultTsls ;

    function getROQ_TYPE return amd_locpart_overid_consumables.TSL_OVERRIDE_TYPE%type is
    begin
        return ROQ_TYPE ;
    end getROQ_TYPE ;

    function getROP_TYPE return amd_locpart_overid_consumables.tsl_override_type%type is
    begin
        return ROP_TYPE ;
    end getROP_TYPE ;

    function getGOLD_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type is
    begin
        return GOLD_SOURCE ;
    end getGOLD_SOURCE ;

    function getWESM_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type is
    begin
        return WESM_SOURCE ;
    end getWESM_SOURCE ;

    function getNONWESM_SOURCE return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type is
    begin
        return NONWESM_SOURCE ;
    end getNONWESM_SOURCE ;

    function getWHSE_LOCSID return number is
    begin
        return WHSE_LOCSID ;
    end getWHSE_LOCSID ;

    function getWHSE_LOCID return number is
    begin
        return WHSE_LOCID ;
    end getWHSE_LOCID ;

    function getDebugYorN return varchar2 is
    begin
        if debug then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end getDebugYorN ;

    procedure setDebug(switch in varchar2) is
    begin
        debug := upper(switch) in ('Y','T','YES','TRUE') ;
    end setDebug ;

    procedure version IS
    begin
        writeMsg(pTableName => 'amd_lp_override_consumabl_pkg',
             pError_location => 520, pKey1 => 'amd_lp_override_consumabl_pkg', pKey2 => '$Revision:   1.51  $') ;
        dbms_output.put_line('amd_lp_override_consumabl_pkg: $Revision:   1.51  $') ;
    end version ;

    function getVersion return varchar2 is
    begin
        return '$Revision:   1.51  $' ;
    end getVersion ;


begin
    declare
        function getDebug return boolean is
            debug varchar2(50) ;
        begin
            debug := trim(amd_defaults.getParamValue('debugAmd_lp_override_consumabl_pkg')) ;

            return debug is null or upper(debug) in ('Y','T','YES','TRUE') ;
        end getDebug ;
    begin
        amd_lp_override_consumabl_pkg.debug := getDebug ;
        if debug then
            debugMsg('*package init with debug at ' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),
                pError_location => 530) ;
        end if ;
    end ;

    select part_no bulk collect into testParts from amd_test_parts ;
end Amd_lp_override_consumabl_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG FOR AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_WRITER_ROLE;


