DROP PACKAGE AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.14  $
        $Date:   26 Jul 2013
    $Workfile:   AMD_LOCATION_PART_LEADTIME_PKG.pks  $
          rev 1.14 remove an a2a table dependency
/*   
/*      Rev 1.12   24 Feb 2009 11:18:12   zf297a
/*   Removed a2a code.
/*   
/*      Rev 1.11   18 Feb 2008 14:50:04   zf297a
/*   Added interface for function getVersion
/*   
/*      Rev 1.10   07 Nov 2007 17:25:30   zf297a
/*   Added type locationPartLeadTimeTab.
/*   
/*      Rev 1.9   Oct 25 2006 09:56:32   zf297a
/*   Made the constanst anchored declarations - ie used %type attribute.
/*   
/*      Rev 1.8   Oct 25 2006 09:19:06   zf297a
/*   Added interfaces for functions to return constants:
/*   getVIRTUAL_COD_SPO_LOCATION
/*   getVIRTUAL_UAB_SPO_LOCATION
/*   getUK_LOCATION         
/*   getBASC_LOCATION
/*   getLEADTIMETYPE
/*   getBULKLIMIT 
/*   
/*   
/*      Rev 1.7   Jun 12 2006 13:22:08   zf297a
/*   added symbolic constants for UK_LOCATION and BASC_LOCATION.
/*   
/*      Rev 1.6   Jun 09 2006 11:50:52   zf297a
/*   added interface version
/*   
/*      Rev 1.5   Mar 03 2006 12:18:56   zf297a
/*   Removed IsLatestRun and GetBatchRunStart.  GetBatchRunStart is being replaced by amd_batch_pkg.getLastStartTime since it will always return the last start time of the last job that has been run even if it has already completed.  That way if data has changed since the start of the last batch job, then it should be sent in an a2a transaction.  This may cause the same data to be sent again but that is not a problem.
/*   
/*      Rev 1.4   Feb 15 2006 14:00:46   zf297a
/*   Added cur ref, record type and a common process routine so that the data gets loaded the same no matter what selection criteria is used.
/*   
/*      Rev 1.3   Jan 04 2006 10:07:38   zf297a
/*   Made loadAllA2A and loadA2AByDate conform to the a2a_pkg.initA2A procedures.
/*   
/*      Rev 1.2   Jan 03 2006 12:45:50   zf297a
/*   Added date range to procedure loadA2AByDate
/*   
/*      Rev 1.1   Dec 29 2005 16:29:58   zf297a
/*   Added loadA2AByDate procedure
/*   
/*      Rev 1.0   Nov 30 2005 12:40:00   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Nov 30 2005 12:31:04   zf297a
/*   Initial revision.
*/    

    VIRTUAL_COD_SPO_LOCATION CONSTANT amd_spare_networks.spo_location%type := 'VIRTUAL COD' ;
    VIRTUAL_UAB_SPO_LOCATION CONSTANT amd_spare_networks.spo_location%type := 'VIRTUAL UAB' ;
    UK_LOCATION              CONSTANT amd_spare_networks.LOC_ID%type  := 'EY8780' ;
    BASC_LOCATION             CONSTANT amd_spare_networks.loc_id%type  := 'EY1746' ;
    
    LEADTIMETYPE              CONSTANT varchar2(6) := 'REPAIR' ;
    
    BULKLIMIT                            CONSTANT NUMBER := 100000 ;
    SUCCESS                            CONSTANT NUMBER := 0 ;
    FAILURE                            CONSTANT NUMBER := 4 ;
    
    
    FUNCTION IsPartRepairable(pNsiSid amd_national_stock_items.nsi_sid%TYPE ) RETURN VARCHAR2 ;
    FUNCTION IsPartRepairable(pPartNo amd_spare_parts.part_no%TYPE ) RETURN VARCHAR2 ;
    -- pragma restrict_references (IsPartRepairable, WNDS) ;
    FUNCTION GetAvgRepairCycleTime(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp.avg_repair_cycle_time%TYPE ;
    FUNCTION GetRampData(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp%ROWTYPE ;
    pragma restrict_references (GetRampData, WNDS) ;
    pragma restrict_references (GetAvgRepairCycleTime, WNDS) ;
    
    
    -- load procedure will truncate tmp_amd_location_part_leadtime prior to loading
    
    FUNCTION InsertRow(
            pPartNo                      amd_location_part_leadtime.part_no%TYPE,
            pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
            pTimeToRepair                 amd_location_part_leadtime.time_to_repair%TYPE)
            return NUMBER ;
    
    FUNCTION Updaterow(
            pPartNo                      amd_location_part_leadtime.part_no%TYPE,
            pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
            pTimeToRepair                 amd_location_part_leadtime.time_to_repair%TYPE)
            RETURN NUMBER ;
    
    
    FUNCTION DeleteRow(
            pPartNo                      amd_location_part_leadtime.part_no%TYPE,
            pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
            pTimeToRepair                 amd_location_part_leadtime.time_to_repair%TYPE)
            RETURN NUMBER ;
    
    
    
    PROCEDURE LoadTmpAmdLocPartLeadtime ;
    PROCEDURE LoadAmdLocPartLeadtime ;
    PROCEDURE LoadInitial ;

    -- added 6/9/2006 by dse
    procedure version ;

    function getVersion return varchar2 ; -- added 2/18/2008 by dse
    
    -- added get functions to return constants 10/25/2006 by dse
    function getVIRTUAL_COD_SPO_LOCATION return amd_spare_networks.spo_location%type ;
    function getVIRTUAL_UAB_SPO_LOCATION return amd_spare_networks.spo_location%type ;
    function getUK_LOCATION              return amd_spare_networks.LOC_ID%type ;
    function getBASC_LOCATION             return amd_spare_networks.LOC_ID%type ;    
    function getLEADTIMETYPE              return varchar2 ;
    function getBULKLIMIT                     return number ;

END AMD_LOCATION_PART_LEADTIME_PKG ;
 
/


DROP PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG;

CREATE PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG FOR AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_WRITER_ROLE;
