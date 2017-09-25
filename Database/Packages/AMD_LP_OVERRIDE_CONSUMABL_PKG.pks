CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_lp_override_consumabl_Pkg AS
 /*
      $Author:   zf297a  $
    $Revision:   1.19  $
        $Date:   14 Jul 2009 10:52:30  $
    $Workfile:   AMD_LP_OVERRIDE_CONSUMABL_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LP_OVERRIDE_CONSUMABL_PKG.pks.-arc  $
/*   
/*      Rev 1.19   14 Jul 2009 10:52:30   zf297a
/*   Updated spo type literals
/*   
/*      Rev 1.18   10 Jun 2009 13:45:20   zf297a
/*   Change rop_type and roq_type from constants to variables so they can be initialized from amd_spo_types_v.
/*   
/*      Rev 1.17   24 Feb 2009 13:20:22   zf297a
/*   Removed a2a code.
/*   
/*      Rev 1.16   05 Dec 2008 12:43:54   zf297a
/*   Added interfaces getTslOverrideUser, setUseLoadWhseX, and getUseLoadWhseX.
/*   
/*      Rev 1.15   10 Oct 2008 00:53:40   zf297a
/*   Changed interface for isTestPart and isTestPartYorN .. use amd_test_parts instead of amd_sent_to_a2a
/*
/*      Rev 1.14   19 Mar 2008 00:00:26   zf297a
/*   Added interfaces isValidTslData and isValidTslDataYorN
/*
/*      Rev 1.13   17 Mar 2008 10:36:52   zf297a
/*   Added interfaces getLoadZeroTslsYorN and setLoadZeroTsls.
/*
/*      Rev 1.12   12 Mar 2008 15:21:26   zf297a
/*   Added interfaces: getInsertData and setInsertData, which is to be used to control the boolean variable insertData.  This variable controls whether data actually gets inserted into a table and consequently it can be used for testing purposes to see the flow of control without updating the tables.
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

    ROQ_TYPE AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROQ-FIXED' ;
    function getROQ_TYPE return amd_locpart_overid_consumables.tsl_override_type%type ;
    ROP_TYPE AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_TYPE%type := 'ROP-FIXED' ;
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

    function getDebugYorN return varchar2 ;
    procedure setDebug(switch in varchar2) ;

    function getInsertDataYorN return varchar2 ;
    procedure setInsertData(switch in varchar2) ;

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



    procedure version ;

    function isTestPart(part_no in amd_test_parts.part_no%type) return boolean ; -- added 1/4/2008 by dse
    function isTestPartYorN(part_no in amd_test_parts.part_no%type) return varchar2 ; -- added 1/4/2008 by dse

    function getDebugCur return debugCur ;

    function getDebugCur(fromDate in date, toDate in date := sysdate) return debugCur ;
    function getDebugCur(textFilter in varchar2) return debugCur ;

    function listDebugMsgs return msgCur ;
    function listDebugMsgs(fromDate in date, toDate in date := sysdate) return msgCur ;
    function listDebugMsgs(textFilter in varchar2) return msgCur ;

    procedure deleteDebugMsgs ;

    function getVersion return varchar2 ;
    -- added 3/17/2008 by dse
    function getLoadZeroTslsYorN return varchar2 ;
    procedure setLoadZeroTsls(switch in varchar2) ;
    -- added 3/18/2008 by dse
    function isValidTslData(
        override_type in amd_locpart_overid_consumables.tsl_OVERRIDE_TYPE%type,
        override_quantity in amd_locpart_overid_consumables.tsl_OVERRIDE_qty%type) return boolean ;
    function isValidTslDataYorN(
        override_type in amd_locpart_overid_consumables.tsl_OVERRIDE_TYPE%type,
        override_quantity in amd_locpart_overid_consumables.tsl_OVERRIDE_qty%type) return varchar2 ;
        
    function getTslOverrideUser(spo_prime_part_no in amd_spare_parts.spo_prime_part_no%type) 
        return AMD_LOCPART_OVERID_CONSUMABLES.TSL_OVERRIDE_USER%type ; -- added 12/5/2008 by dse

    procedure setUseLoadWhseX(value in varchar2) ; -- added 12/5/2008 by dse
    function getUseLoadWhseX return varchar2 ; -- added 12/5/2008 by dse
    

end Amd_lp_override_consumabl_Pkg ;
/
