set define off

DROP PACKAGE AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_lp_override_consumabl_Pkg AS
 /*
      $Author:   zf297a  $
    $Revision:   1.10  $
        $Date:   16 Oct 2007 22:49:02  $
    $Workfile:   amd_lp_override_consumabl_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\amd_lp_override_consumabl_pkg.sql.-arc  $
/*   
/*      Rev 1.10   16 Oct 2007 22:49:02   zf297a
/*   Fixed loadLvls by adding the compatibility_code check to the max_dates view fixing bug 6-17C
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
    ROQ_TYPE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROQ Fixed' ;
    ROP_TYPE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROP Fixed' ;
    GOLD_SOURCE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type := 'GOLD' ;
    WESM_SOURCE constant AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_SOURCE%type := 'WESM' ;
    WHSE_LOCSID constant number := 256 ;
    WHSE_LOCID constant varchar2(6) := 'FD2090' ;
    VIRTUAL_UAB constant amd_spare_networks.SPO_LOCATION%type := amd_location_part_leadtime_pkg.VIRTUAL_UAB_SPO_LOCATION ;
    VIRTUAL_COD constant amd_spare_networks.SPO_LOCATION%type := amd_location_part_leadtime_pkg.VIRTUAL_COD_SPO_LOCATION ;
    DELETE_ACTION constant amd_spare_networks.action_code%type := amd_defaults.DELETE_ACTION ;
   
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
    
    procedure initialize ;

    procedure loadAllA2A ;
    
    procedure loadDefaultTsls ; -- added 10/9/2007 by dse
       
    procedure version ;

   
end Amd_lp_override_consumabl_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG FOR AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_lp_override_consumabl_Pkg AS
 /*
      $Author:   zf297a  $
    $Revision:   1.10  $
        $Date:   16 Oct 2007 22:49:02  $
    $Workfile:   amd_lp_override_consumabl_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LP_OVERRIDE_CONSUMABL_PKG.pkb.-arc  $
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
             
    
    type consumablesWhsePartsCur is ref cursor return whseRec ;     
        
    cursor  consumableWhseParts(base in varchar2, source_code in varchar2, wesm_part in varchar2 := 'Y') is
        select sent.spo_prime_part_no, 
        sum(nvl(whse.reorder_point,0)) rop,
        sum(nvl(whse.USER_REF1 ,0)) roq 
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
                canUpdate in boolean) is
    begin
        if tsl_override_qty is not null then
            insert into TMP_LOCPART_OVERID_CONSUMABLES
            (part_no, spo_location, loc_sid, tsl_override_type, tsl_override_qty, tsl_override_user, tsl_override_source)
            values (doInsert.part_no, doInsert.spo_location, doInsert.loc_sid , 
                doInsert.tsl_override_type, doInsert.tsl_override_qty, doInsert.tsl_override_user, doInsert.tsl_override_source) ;
            insert_cnt := insert_cnt + 1 ;                    
        end if ;                    
                
    exception 
        when standard.DUP_VAL_ON_INDEX then
            if canUpdate then
                doUpdate(part_no,spo_location,loc_sid,tsl_override_type,tsl_override_qty,tsl_override_user,tsl_override_source, update_cnt) ;
            end if ;                    
        when others then
             ErrorMsg(pSqlfunction       => 'doInsert',pTableName  => 'TMP_LOCPART_OVERID_CONSUMABLES',
                       pError_location => 30, pKey1 => 'part_no=' || part_no,
                       pKey2 => 'spo_location=' || spo_location,
                       pKey3 => 'type=' || tsl_override_type,
                       pKey4 => 'loc_sid=' || to_char(loc_sid),
                       pComments => 'source=' || tsl_override_source) ;            
             raise ;                        
    end doInsert ;

    
    procedure loadWhseBase(spo_location in varchar2, sc in varchar2, roq in varchar2 := 'nvl(whse.USER_REF1 ,0)') is
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;
        tsl_override_user TMP_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_USER%type ;
        loc_sid tmp_locpart_overid_consumables.loc_sid%type ;
        theCursor SYS_REFCURSOR ;
        rec ropRoqRec ;
        operator varchar2(6) ;
    begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 40,
				pKey1 => 'loadWhseBase(' || spo_location || ',' || sc|| ',' || roq || ')',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                        
        if instr(sc,'%') > 0 then
            operator := ' like ' ;
        else
            operator := ' = ' ;
        end if ;
        
        open theCursor for 
            'select sent.spo_prime_part_no, ' 
                || 'nwks.spo_location, '
                || 'sum(nvl(whse.reorder_point,0)) rop, '
                || 'sum(' || roq || ') roq ' 
                || 'from whse, ' 
                || 'amd_spare_networks nwks, '
                || 'amd_sent_to_a2a sent '
                || 'where sent.action_code <> amd_defaults.getDELETE_ACTION '
                || 'and sent.part_no = sent.spo_prime_part_no '
                || 'and sent.spo_prime_part_no = whse.prime '
                || 'and whse.sc ' || operator || '''' ||   sc || ''' '
                || 'and nwks.action_code <> amd_defaults.getDELETE_ACTION '
                || 'and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = ''Y'' '
                || 'and nwks.loc_id = ' || '''' || spo_location || ''' '
                || 'and nwks.spo_location is not null '
                || 'group by spo_location, spo_prime_part_no ' ; 
        
        loop
            fetch theCursor into rec ;
            exit when theCursor%notfound ; 
            insert_cnt := in_cnt + 1 ;
                
            tsl_override_user := getTslOverrideUser(amd_utils.getNsn(rec.spo_prime_part_no)) ;
            loc_sid := amd_utils.getLocSid(rec.spo_location) ;
            
            doinsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => loc_sid,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => rec.roq, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false);
                
          
            doinsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => loc_sid,
                tsl_override_type => ROP_TYPE, tsl_override_qty => rec.rop, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
        end loop ;
        
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 50,
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
                when nvl(a.economic_order_qty,0) = 0 and nvl(a.approved_lvl_qty,0) = 0 and nvl(a.reorder_point,0) = 0 then -1
                else nvl(a.reorder_point,0)
            end rop,
            case
                when nvl(a.economic_order_qty,0) > 0 then a.economic_order_qty
                when nvl(a.approved_lvl_qty,0) > 0 then a.approved_lvl_qty - nvl(a.reorder_point,0)
                else 1
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
                  or nwks.LOC_ID in ('EY1258','EY1414', 'EY1746','EY8780' )
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
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 60,
				pKey1 => 'loadLvls',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        for rec in consumablesForLvls loop
            insert_cnt := in_cnt + 1 ;
                
            tsl_override_user := getTslOverrideUser(rec.nsn) ;
            
            doinsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => rec.loc_sid,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => rec.roq, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false);
                
          
            doinsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => rec.loc_sid,
                tsl_override_type => ROP_TYPE, tsl_override_qty => rec.rop, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
        end loop ;
        
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 70,
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

        cursor wesmParts is
        select spo_prime_part_no,
        sum(L11.BOEING_BASE_MIN_LEVEL) rop,
        sum(boeing_base_max_level - boeing_base_min_level) roq
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
        
        cursor lvls_by_base is
            select sent.spo_prime_part_no spo_prime_part_no, 
            sum (
            case
                when nvl(a.economic_order_qty,0) > 0 then nvl(a.reorder_point,0)
                when nvl(a.approved_lvl_qty,0) > 0 then nvl(a.reorder_point,0)
                when nvl(a.economic_order_qty,0) = 0 and nvl(a.approved_lvl_qty,0) = 0 and nvl(a.reorder_point,0) = 0 then -1
                else nvl(a.reorder_point,0)
            end ) rop,
            sum (
            case
                when nvl(a.economic_order_qty,0) > 0 then a.economic_order_qty
                when nvl(a.approved_lvl_qty,0) > 0 then a.approved_lvl_qty - nvl(a.reorder_point,0)
                else 1
            end ) roq
            from lvls a, 
            amd_national_stock_items items, 
            amd_spare_networks nwks,
            amd_sent_to_a2a sent
            where items.action_code <> amd_defaults.getDELETE_ACTION
            and nwks.action_code <> amd_defaults.getDELETE_ACTION
            and a.COMPATIBILITY_CODE = 'C' 
            and items.nsn = a.NSN
            and amd_utils.isPartConsumableYorN(items.prime_part_no) = 'Y'
            and date_lvl_loaded = (select max(date_lvl_loaded) from lvls where a.nsn = nsn and a.sran = sran)
            and date_lvl_loaded between sysdate - 210 and sysdate
            and a.sran = nwks.LOC_ID
            and a.sran <> amd_defaults.getAMD_WAREHOUSE_LOCID
            and (nwks.loc_type = 'FSL' 
                  or nwks.loc_type = 'MOB' 
                  or nwks.LOC_ID = amd_defaults.getAMD_WARNER_ROBINS_LOC_ID
                )
            and nwks.spo_location is not null
            and items.prime_part_no = sent.part_no
            and sent.part_no = sent.spo_prime_part_no
            and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = 'N'
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
        
        
        theCursor SYS_REFCURSOR ;
        rec whseRec ;
                

        procedure processRec(rec in whseRec) is
            cursor whseData(spo_prime_part_no in varchar2) is
                    select reorder_point, user_ref3, created_datetime  
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
                if recFound then
                    rop := whse_rop - rec.rop ;
                    
                    roq := whse_roq  - rec.roq ;
                    if roq <= 0 then
                        roq := 1 ;
                    end if ;
                else
                    rop := -1 ;
                    roq := 1 ;                
                end if ;                    
                
            end getWhseData ;                
            
            doinsert(part_no => rec.spo_prime_part_no, spo_location => WHSE_LOCID, loc_sid => WHSE_LOCSID,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => roq, tsl_override_user => tsl_override_user,
                tsl_override_source => WESM_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
                
                

            doinsert(part_no => rec.spo_prime_part_no, spo_location => WHSE_LOCID, loc_sid => WHSE_LOCSID,
                tsl_override_type => ROP_TYPE, tsl_override_qty => rop, tsl_override_user => tsl_override_user,
                tsl_override_source => WESM_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
        end processRec ; 
        
        procedure processWhseParts(spo_location in varchar2,
            sc in varchar2, operator in varchar2, wesm_part in varchar2)  is
            theCursor SYS_REFCURSOR ;
        begin        
            open theCursor for 
                'select sent.spo_prime_part_no, ' 
                || 'sum(nvl(whse.reorder_point,0)) rop, '
                || 'sum(nvl(whse.USER_REF1 ,0)) roq ' 
                || 'from whse, ' 
                || 'amd_spare_networks nwks, '
                || 'amd_sent_to_a2a sent '
                || 'where sent.action_code <> amd_defaults.getDELETE_ACTION '
                || 'and sent.part_no = sent.spo_prime_part_no '
                || 'and sent.spo_prime_part_no = whse.prime '
                || 'and whse.sc ' || operator || '''' || sc || ''' '
                || 'and nwks.action_code <> amd_defaults.getDELETE_ACTION '
                || 'and amd_utils.isPartConsumableYorN(sent.spo_prime_part_no) = ''Y'' ' 
                || 'and amd_utils.isWesmPartYorN(sent.spo_prime_part_no) = ' || '''' || wesm_part || ''' '
                || 'and nwks.loc_id = ' || '''' || spo_location || ''' '
                || 'and nwks.spo_location is not null '
                || 'group by  spo_prime_part_no ' ;
             
            loop
                fetch theCursor into rec ;
                exit when theCursor%notfound ;                            
                processRec(rec) ;
            end loop ;
            close theCursor ;
            commit ;
            
        end processWhseParts ;
        
                             
   begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 80,
                pKey1 => 'loadWhse',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
                
        for rec in wesmParts loop
            in_cnt := in_cnt + 1 ;
            processRec(rec) ;                                                                    
        end loop ;
        
        commit ;
        
        processWhseParts(spo_location => amd_defaults.AMD_UK_LOC_ID, 
                            sc => amd_defaults.AMD_UK_SC, 
                            operator => 'like', wesm_part =>'Y') ;
        
        processWhseParts(spo_location => amd_defaults.AMD_BASC_LOC_ID, 
                            sc => amd_defaults.AMD_BASC_SC, 
                            operator => '=', wesm_part =>'Y') ;
        


        for rec in lvls_by_base loop
            in_cnt := in_cnt + 1 ;
            processRec(rec) ;
        end loop ;
        
        commit ;

        processWhseParts(spo_location => amd_defaults.AMD_UK_LOC_ID, 
                            sc => amd_defaults.AMD_UK_SC, 
                            operator => 'like', wesm_part =>'N') ;
        
        processWhseParts(spo_location => amd_defaults.AMD_BASC_LOC_ID, 
                            sc => amd_defaults.AMD_BASC_SC, 
                            operator => '=', wesm_part =>'N') ;

        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 90,
                pKey1 => 'loadWhse',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt) ) ;
    end loadWhse ;
    
    procedure loadWesm  is
        cursor wesm_data is
        select sent.spo_prime_part_no spo_prime_part_no, loc_sid, 
        amd_utils.getSpoLocation(loc_sid) spo_location,
        case
            when boeing_base_max_level - boeing_base_min_level > 0 then boeing_base_max_level - boeing_base_min_level
            else 1 
        end roq,
        nvl(L11.BOEING_BASE_MIN_LEVEL,-1) rop,
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
        and (nwks.LOC_TYPE in ('MOB') or nwks.LOC_ID in ('EY1258','EY1746','EY8780', 'EY1414','FB2065'))
        and nwks.spo_location is not null ;
        
        in_cnt number :=  0 ;
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
        
    begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 100,
                pKey1 => 'loadWesm',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        for rec in wesm_data loop
            in_cnt := in_cnt + 1 ;
            
            tsl_override_user := getTslOverrideUser(rec.nsn) ;
            
            doInsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => rec.loc_sid,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => rec.roq, tsl_override_user => tsl_override_user,
                tsl_override_source => WESM_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => true) ;
            
 
           doInsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => rec.loc_sid,
                tsl_override_type => ROP_TYPE, tsl_override_qty => rec.rop, tsl_override_user => tsl_override_user,
                tsl_override_source => WESM_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => true) ;
                                     
            
        end loop ;
        
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 110,
                pKey1 => 'loadWesm',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'in_cnt=' || to_char(in_cnt),
                pKey4 => 'insert_cnt=' || to_char(insert_cnt),
                pData => 'update_cnt=' || to_char(update_cnt) ) ;
        commit ;
    end loadWesm ;
    
     
     procedure loadVirtualLocations is
        cursor consumableParts is
        select sent.spo_prime_part_no spo_prime_part_no 
        from amd_sent_to_a2a sent
        where sent.part_no = sent.spo_prime_part_no
        and sent.action_code <> amd_defaults.getDELETE_ACTION
        and amd_utils.isPartConsumableYorN(sent.part_no) = 'Y' ; 

        
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;     
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
     begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 120,
            pKey1 => 'loadVirtualLocations',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        for rec in consumableParts loop
            in_cnt := in_cnt + 1 ;
            
            tsl_override_user := getTslOverrideUser(amd_utils.GETNSN(rec.spo_prime_part_no) ) ;

           doInsert(part_no => rec.spo_prime_part_no, spo_location => VIRTUAL_UAB, loc_sid => null,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => 1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
            
           doInsert(part_no => rec.spo_prime_part_no, spo_location => VIRTUAL_COD, loc_sid => null,
                tsl_override_type => ROP_TYPE, tsl_override_qty => -1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
                                 
           doInsert(part_no => rec.spo_prime_part_no, spo_location => VIRTUAL_COD, loc_sid => null,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => 1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
            
            
           doInsert(part_no => rec.spo_prime_part_no, spo_location => VIRTUAL_UAB, loc_sid => null,
                tsl_override_type => ROP_TYPE, tsl_override_qty => -1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
                        
        end loop ;
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 130,
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
                pError_location => 140, 
                pKey1 => 'part_no=' || part_no,
                   pKey2 => 'spo_location=' || spo_location,
                pKey3              => 'tsl_override_type=' || tsl_override_type,
                pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
            raise ;            
        end updateRow ;
        
        procedure insertRow is
            cur_action_code amd_locpart_overid_consumables.action_code%type ;
        begin
            insert into amd_locpart_overid_consumables
            (part_no, spo_location, tsl_override_type, tsl_override_user, tsl_override_source, tsl_override_qty, loc_sid, last_update_dt, action_code)
            values(part_no, spo_location, tsl_override_type, tsl_override_user, tsl_override_source, tsl_override_qty, loc_sid, sysdate, action_code) ;
            
        exception
            when standard.DUP_VAL_ON_INDEX then
                select action_code into cur_action_code from amd_locpart_overid_consumables
                where part_no = doLPOverrideConsumablesDiff.part_no
                and spo_location = doLPOverrideConsumablesDiff.spo_location
                and tsl_override_type = doLPOverrideConsumablesDiff.tsl_override_type ;
                if cur_action_code = 'D' then
                    updateRow ;
                else
                    raise_application_error(-20040,'amd_lp_override_consumabl_pkg: dup part_no=' ||
                        part_no || ' sppo_location = ' || spo_location || ' tsl_override_type=' || tsl_override_type) ;
                end if ;                                             
            when others then
                errorMsg(pSqlfunction       => 'insert',pTableName  => 'AMD_LOCPART_OVERID_CONSUMABLES',
                    pError_location => 150, 
                    pKey1 => 'part_no=' || part_no,
                    pKey2 => 'spo_location=' || spo_location,
                    pKey3              => 'tsl_override_type=' || tsl_override_type,
                    pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
                raise ;            
        end insertRow ;
        
        
        
    begin
        if action_code = 'A' then
            insertRow ;
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
            pError_location => 160, 
            pKey1 => 'part_no=' || part_no,
            pKey2 => 'spo_location=' || spo_location,
            pKey3 => 'tsl_override_type=' || tsl_override_type,
            pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
        raise ;            
    end doLPOverrideConsumablesDiff;
    
    procedure initialize is
    begin
        mta_truncate_table('amd_locpart_overid_consumables','reuse storage') ;
        delete from tmp_a2a_loc_part_override where override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE ;
        commit ;
        loadLocPartOverrides ;
        commit ;
        insert into amd_locpart_overid_consumables
            select * from tmp_locpart_overid_consumables ;
        commit ;            
    end initialize ;
    
     procedure loadLocPartOverrides is
     begin
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 170,
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
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 180,
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
        cursor zeroTsls is
        select * 
        from
        (select spo_prime_part_no from amd_sent_to_a2a
         where part_no = spo_prime_part_no
         and action_code <> amd_defaults.getDELETE_ACTION) parts,
        (select distinct spo_location from amd_spare_networks where spo_location is not null  
         union
         select distinct mob || '_RSP' rsp_location from amd_spare_networks where mob is not null
        ) bases
        minus
        select part_no, spo_location from tmp_locpart_overid_consumables;
        
        insert_cnt number := 0 ;
        update_cnt number := 0 ;
        in_cnt number := 0 ;     
        tsl_override_user tmp_locpart_overid_consumables.TSL_OVERRIDE_USER%type ;
     begin
         writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 190,
            pKey1 => 'loadDefaultTsls',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        commit ;
                
       for rec in zeroTsls loop
            in_cnt := in_cnt + 1 ;
            tsl_override_user := getTslOverrideUser(amd_utils.GETNSN(rec.spo_prime_part_no) ) ;
                       
            doInsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => null,
                tsl_override_type => ROP_TYPE, tsl_override_qty => -1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
                                 
           doInsert(part_no => rec.spo_prime_part_no, spo_location => rec.spo_location, loc_sid => null,
                tsl_override_type => ROQ_TYPE, tsl_override_qty => 1, tsl_override_user => tsl_override_user,
                tsl_override_source => GOLD_SOURCE,
                insert_cnt => insert_cnt,
                update_cnt => update_cnt,
                canUpdate => false) ;
       end loop ;
     
       writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 200,
            pKey1 => 'loadDefaultTsls',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'in_cnt=' || to_char(in_cnt),
            pKey4 => 'insert_cnt=' || to_char(insert_cnt),
            pData => 'update_cnt=' || to_char(update_cnt)) ;
        commit ;            
    end loadDefaultTsls ;
     
    procedure version IS
    begin
        writeMsg(pTableName => 'amd_lp_override_consumabl_pkg', 
             pError_location => 210, pKey1 => 'amd_lp_override_consumabl_pkg', pKey2 => '$Revision:   1.10  $') ;
        dbms_output.put_line('amd_lp_override_consumabl_pkg: $Revision:   1.10  $') ;
    end version ;


end Amd_lp_override_consumabl_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_CONSUMABL_PKG FOR AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LP_OVERRIDE_CONSUMABL_PKG TO AMD_WRITER_ROLE;


