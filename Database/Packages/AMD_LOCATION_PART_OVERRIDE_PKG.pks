CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Location_Part_Override_Pkg AS
 /*
      $Author:   zf297a  $
	$Revision:   1.32  $
        $Date:   13 Feb 2015
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pks  $
        Rev 1.32 commented out spo references
/*   
/*      Rev 1.31   10 Jun 2009 13:28:24   zf297a
/*   Convert tsl_override_type and override_reason to a variables that get initialized from data in amd_spo_types_v.
/*   
/*      Rev 1.30   24 Feb 2009 11:43:54   zf297a
/*   Removed A2A code
/*   
/*      Rev 1.29   19 Feb 2009 09:45:38   zf297a
/*   Defined get/set for loadFMSdata Y/N switch.
/*   
/*      Rev 1.28   14 Feb 2009 16:05:50   zf297a
/*   Changed the interface for loadWhse - endStep defaults now to 4.
/*   
/*      Rev 1.26   13 Feb 2009 13:49:14   zf297a
/*   Add set/get's interfaces for counters
/*   
/*      Rev 1.25   13 Mar 2008 15:32:48   zf297a
/*   Added interfaces getVersion, getDebugYorN, and setDebug.  Changed the constant from OVERRIDE_TYPE to TSL_OVERRIDE_TYPE to make the code more meaningful.  Made type locPartOverrideTab public.
/*   
/*      Rev 1.24   01 Nov 2007 09:03:54   zf297a
/*   Created interface for procedure loadRspTslA2A
/*   
/*      Rev 1.23   11 Oct 2007 12:50:30   zf297a
/*   Added interface loadCAN and modified interface LoadTmpAmdLocPartOverride by changing the end_step's default to 7.
/*   
/*      Rev 1.22   06 Aug 2007 10:10:36   zf297a
/*   Added ignoreStLouis flag which can be used to ignore the St Louis tables when that system is down.
/*   
/*      Rev 1.21   13 Jun 2007 20:05:24   zf297a
/*   Fixed the name of checkForDeletedSpoPrimeParts
/*   
/*      Rev 1.20   13 Jun 2007 14:04:46   zf297a
/*   Added interface checkForDeletedSpoPrimePart.
/*   
/*      Rev 1.19   12 Apr 2007 15:30:26   zf297a
/*   renamed loadZeroTsls to loadZeroRspTsls
/*   
/*      Rev 1.18   12 Apr 2007 14:41:48   zf297a
/*   Added interface loadZeroTsls
/*   
/*      Rev 1.17   10 Apr 2007 21:34:20   zf297a
/*   replaced loadUkandAUS with two distinct procedures loadUK and loadAUS
/*   
/*      Rev 1.16   03 Apr 2007 14:43:26   zf297a
/*   Added startStep and endStep arguments to loadTmpAmdLocationPartOverride with default values of 1 and 5 respectively.
/*   
/*   Make the following procedures public to allow for unit testing:
/*   loadUKandAUS
/*   loadFslMob
/*   loadBasc
/*   loadWhse
/*   
/*   For procedure loadWhse add arguments startStep and endStep with default values of 1 and 5 respectively.
/*   
/*   
/*   
/*   
/*      Rev 1.15   01 Mar 2007 12:40:46   zf297a
/*   Added interface for sendZeroTslsForSpoPrimePart
/*   
/*      Rev 1.14   26 Jan 2007 09:47:16   zf297a
/*   Added procedure interface for deleteRspTslA2A
/*   
/*      Rev 1.13   Dec 13 2006 12:00:16   zf297a
/*   Added interfaces isTmpA2AOkay and isTmpA2AOkayYorN
/*   
/*      Rev 1.12   Dec 05 2006 14:53:46   zf297a
/*   Changed interface for processTsl - removed unnessary paramater pDoAllA2A since the cursor has already done the filtering.
/*   
/*      Rev 1.11   Oct 25 2006 10:53:04   zf297a
/*   Defined constants with anchored declarations using the %type attribute.  Made loadOverrideUsers a public procedure.
/*   
/*      Rev 1.10   Aug 24 2006 10:33:28   zf297a
/*   Added a constant for the loc_sid warehouse value
/*   
/*      Rev 1.9   Jun 09 2006 11:55:42   zf297a
/*   added interface version
/*   
/*      Rev 1.8   Apr 28 2006 13:15:54   zf297a
/*   Added the interface for loadRspZeroTslA2A
/*   
/*      Rev 1.7   Apr 21 2006 13:50:40   zf297a
/*   Added isInTmpA2A, isInTmpA2AYorN, loadZeroTslByDate, and InsertTmpA2ALPO
/*   
/*      Rev 1.6   Feb 24 2006 15:08:32   zf297a
/*   Modified the interfaces for some TSL procedures and load procedures.
/*   
/*      Rev 1.5   Feb 15 2006 21:22:54   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.4   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.3   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.2   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*
/*      Rev 1.1   Nov 10 2005 11:10:46   zf297a
/*   Added interfaces getInsertCnt, getDeleteCnt, and getUpdateCnt.  Changed the interface for LoadAllA2A to have an optional boolean argument that can control the use of "test data".
/*
/*      Rev 1.0   Oct 18 2005 19:12:48   c394547
/*   Initial revision.
		 */

--	TSL_OVERRIDE_TYPE 	  	 amd_spo_types_v.tsl_fixed_override%type := 'TSL-FIXED' ;
--	OVERRIDE_REASON 		 amd_spo_types_v.fixed_tsl_load_override_reason%type := 'Fixed TSL Load' ;
	THE_WAREHOUSE 			 CONSTANT amd_spare_networks.spo_location%type := 'FD2090' ;
	THE_WAREHOUSE_LOC_SID 	 CONSTANT amd_spare_networks.LOC_SID%type := 256 ;
	
	BULKLIMIT CONSTANT NUMBER := 100000 ;
	COMMITAFTER CONSTANT NUMBER := 100000 ;
	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;
    debug boolean := true ; -- set via param changes: key is debugLocPartOverride value of 1 is TRUE 
                            -- otherwise gets set to FALSE
    ignoreStLouis   boolean := false ;
    function ignoreStLouisYorN return varchar2 ;
	
	
	TYPE locPartOverrideRec IS RECORD (
		 part_no AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
		 site_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 override_type VARCHAR2(32),
	     override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE,
		 override_reason VARCHAR2(64),
		 tsl_override_user AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_USER%TYPE,
		 begin_date DATE,
		 end_date DATE,
		 action_code AMD_LOCATION_PART_OVERRIDE.ACTION_CODE%TYPE,
		 last_update_dt AMD_LOCATION_PART_OVERRIDE.LAST_UPDATE_DT%TYPE
	) ;
    type locPartOverrideTab is table of locPartOverrideRec ;
	
	
	PROCEDURE LoadInitial ;
	PROCEDURE LoadTmpAmdLocPartOverride( startStep in number := 1, endStep in number := 7) ;
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	FUNCTION Updaterow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
			-- return Y or N
	FUNCTION IsNumeric(pString VARCHAR2) RETURN VARCHAR2 ;
	--PRAGMA RESTRICT_REFERENCES(IsNumeric, WNDS) ;
	
	-- testing
	FUNCTION GetFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE ;

	-- added 02/13/09 by dse
	function getGtZeroCnt return number ;
	procedure setGtZeroCnt(value in number) ;
	function getTmpInsertCnt return number ;
	procedure setTmpInsertCnt(value in number) ;
	function getTmpUpdateCnt return number ;
	procedure setTmpUpdateCnt(value in number) ;
	
	procedure setUpdateCnt(value in number) ;
	procedure setDeleteCnt(value in number) ;
	procedure setInsertCnt(value in number) ;

	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER ;
	FUNCTION getUpdateCnt RETURN NUMBER ;
	FUNCTION getDeleteCnt RETURN NUMBER ;
	
	-- added 02/23/2006 dse
	-- these functions allow  stand alone SQL to use the package constants
--	FUNCTION getTSL_OVERRIDE_TYPE RETURN VARCHAR2 ;
--	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 ;
	FUNCTION getBULKLIMIT RETURN NUMBER ;
	FUNCTION getCOMMITAFTER RETURN NUMBER ;
	FUNCTION getSUCCESS RETURN NUMBER ;
	FUNCTION getFAILURE RETURN NUMBER ;
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 ;
	 
		
	
	-- added 6/9/2006 by dse
	procedure version ;
	
	-- added 9/1/2006 by dse		
	procedure LoadOverrideUsers ;
	


    procedure loadRampData ; -- added 2/14/09 by dse

    
    -- added 4/2/2007 by dse
    procedure LoadUk ;
    procedure LoadAUS ;
    procedure LoadBasc ;
    procedure loadCAN ; -- added 10/11/2007 by dse

	PROCEDURE LoadWhse(startStep in number := 1, endStep in number := 4) ;


    -- added 3/13/2008 by dse
    function getVersion return varchar2 ;
    function getDebugYorN return varchar2 ;
    procedure setDebug(switch in varchar2) ;
 
    procedure setLoadFMSdata(value in varchar2) ;
        
    function getLoadFMSdata return varchar2 ;
       	
END Amd_Location_Part_Override_Pkg ;
/