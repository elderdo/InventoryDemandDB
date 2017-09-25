SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Location_Part_Override_Pkg AS
 /*
      $Author:   zf297a  $
	$Revision:   1.24  $
        $Date:   01 Nov 2007 09:03:54  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pks.-arc  $
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

	OVERRIDE_TYPE 	  	 	 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_TYPE%type := 'TSL Fixed' ;
	OVERRIDE_REASON 		 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_REASON%type := 'Fixed TSL Load' ;
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
	
	TYPE tslRec IS RECORD (
		 spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE,
		 action_code AMD_SENT_TO_A2A.ACTION_CODE%TYPE,
		 transaction_date AMD_SENT_TO_A2A.TRANSACTION_DATE%TYPE,
		 spo_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 nsn AMD_NATIONAL_STOCK_ITEMS.nsn%TYPE,
		 nsi_sid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
		 override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE
	) ;
	
	TYPE locPartOverrideCur IS REF CURSOR RETURN locPartOverrideRec ;
	TYPE tslCur IS REF CURSOR RETURN tslRec ;
    type tslTab is table of tslRec ;
	
	PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) ;
	PROCEDURE processTsl(tsl IN tslCur) ;
	
	PROCEDURE LoadInitial ;
	PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadAllA2A (useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE LoadTmpAmdLocPartOverride( startStep in number := 1, endStep in number := 7) ;
	PROCEDURE LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   ;
	
	
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
	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER ;
	FUNCTION getUpdateCnt RETURN NUMBER ;
	FUNCTION getDeleteCnt RETURN NUMBER ;
	
	-- added 02/23/2006 dse
	-- these functions allow  stand alone SQL to use the package constants
	FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 ;
	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 ;
	FUNCTION getBULKLIMIT RETURN NUMBER ;
	FUNCTION getCOMMITAFTER RETURN NUMBER ;
	FUNCTION getSUCCESS RETURN NUMBER ;
	FUNCTION getFAILURE RETURN NUMBER ;
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 ;
	FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 ;
	FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN ;
	 
	PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE ) ;
	PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false) ;
    PROCEDURE deleteRspTslA2A ;
	PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	
	PROCEDURE loadZeroTslA2AByDate(pDoAllA2A IN BOOLEAN, 
			  from_dt IN DATE, to_dt IN DATE, pSpolocation IN VARCHAR2) ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN ;
	
	-- added 6/9/2006 by dse
	procedure version ;
	
	-- added 9/1/2006 by dse		
	procedure LoadOverrideUsers ;
	
	-- added 12/5/2006 by dse
	function isTmpA2AOkay return boolean ;
	function isTmpA2AOkayYorN return varchar2 ;

    -- added 3/1/2007 by dse
	procedure sendZeroTslsForSpoPrimePart(spo_prime_part_no in amd_sent_to_a2a.part_no%type) ;
    
    -- added 4/2/2007 by dse
    procedure LoadUk ;
    procedure LoadAUS ;
    procedure LoadFslMob ;
    procedure LoadBasc ;
    procedure loadCAN ; -- added 10/11/2007 by dse

	PROCEDURE LoadWhse(startStep in number := 1, endStep in number := 5) ;

    -- added 4/12/2007 by dse    
    procedure loadZeroRspTsls ;
    -- added 6/13/2007 by dse
    procedure checkForDeletedSpoPrimeParts ;
    -- added 10/31/2007 by dse
    procedure loadRspTslA2A ;
    	
END Amd_Location_Part_Override_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG;

CREATE PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG FOR AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Location_Part_Override_Pkg AS

 /*
      $Author:   zf297a  $
	$Revision:   1.91  $
        $Date:   14 Feb 2008 11:39:34  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pkb.-arc  $
/*   
/*      Rev 1.91   14 Feb 2008 11:39:34   zf297a
/*   Make sure that records with zero quantity are not written to tmp or amd tables.
/*   
/*      Rev 1.90   12 Nov 2007 00:46:10   zf297a
/*   Fixed retrieving of amd_rsp_sum: used its override_type column and determined the rsp_level based on the override_type.
/*   
/*      Rev 1.89   07 Nov 2007 01:24:32   zf297a
/*   Used bulk collect for all cursors.
/*   
/*      Rev 1.88   02 Nov 2007 10:46:44   zf297a
/*   Make sure GetFirstLogonIdForPart returns the default logon id when it gets a NOT FOUND from the query.
/*   
/*      Rev 1.87   01 Nov 2007 09:04:32   zf297a
/*   Implemented interface for loadRspTslA2A
/*   
/*      Rev 1.86   31 Oct 2007 13:15:58   zf297a
/*   Subtract 1 from rsp_level when creating a tmp_a2a_loc_part_override transaction.
/*   
/*      Rev 1.85   16 Oct 2007 09:25:26   zf297a
/*   Added amd_locpart_overid_consumables to the cursor of checkForDeletedSpoPrimeParts to make sure those LocPartOverrides get deleted too.
/*   
/*      Rev 1.84   11 Oct 2007 12:55:10   zf297a
/*   Renumbered pError_location.  Implemented loadCan and modified LoadTmpAmdLocPartOverride
/*   
/*      Rev 1.83   17 Sep 2007 07:26:58   zf297a
/*   Make sure that override_quantity is never null for table tmp_a2a_loc_part_override.  Also, make sure that the override types of ROQ Fixed and ROP Fixed go only with consumable parts and that TSL Fixedf go only with repairable parts.
/*   
/*      Rev 1.82   12 Sep 2007 13:45:22   zf297a
/*   Removed commits from for loops and added the override_type colum to the update statement of the doUpdate procedure.
/*   
/*      Rev 1.81   12 Sep 2007 13:29:58   zf297a
/*   Make sure parts with  an override type of TSL Fixed are "repairable".
/*   
/*      Rev 1.80   28 Aug 2007 15:24:42   zf297a
/*   Fixed code that was causing ORA-01555 errors by eliminating periodic commits.
/*   
/*      Rev 1.79   16 Aug 2007 23:14:06   zf297a
/*   Every query of tmp_a2a_loc_part_override qualified by its key, requires that it also check for the override_type that is created for repairable parts, since override_type is no part of the primary key... otherwise override_type belonging to consumables could be incorrectly retrieved or a query could return more than one row when onlly one row is expected.
/*   
/*      Rev 1.78   06 Aug 2007 10:09:30   zf297a
/*   Added override_type as part of the key for tmp_a2a_loc_part_override.  Added ignoreStLouis flag so that the check of the St Louis tables could be turned off when that system is down.
/*   
/*      Rev 1.77   20 Jun 2007 10:08:20   zf297a
/*   Enhanced the procedure errorMsg so it is less likely to fail.  Made all loadXXX routine retrieve only repairable parts.
/*   
/*      Rev 1.76   15 Jun 2007 16:44:38   zf297a
/*   Add error checks for insertedTmpA2ALPO and changed formating of some of the code.
/*   
/*      Rev 1.75   13 Jun 2007 20:06:50   zf297a
/*   Fixed the name of checkForDeletedSpoPrimeParts.
/*   
/*      Rev 1.74   13 Jun 2007 19:35:24   zf297a
/*   For doupdate make sure the action belonging to insertedTmpA2ALPO.
/*   Add debug code to record the occurance of an incorrect action_code for non active spo_prime_part.  The trigger now handles this condition and makes it the correct value.
/*   Make sure the insert into tmp_a2a_loc_part_override uses the action code belonging to insertedTmpA2ALPO.
/*   Implemented a procedure to check for deleted spo prime part no and make sure the corresponding part_no in amd_location_part_override and amd_rsp_sum have an action code of D and generate the A2A transactions for this procedure.
/*   Add a dynamic debug flag that can be turned on using amd_param_changes with a key of debugLocPartOverride and a value of 1.  If the flag is not found, the debug variable gets set to false.
/*   
/*      Rev 1.73   13 Jun 2007 18:57:18   zf297a
/*   For a delete_action check to see if a lpOverride exists for a given part/site_location.  If it does exist create the A2A delete transaction, otherwise don't create it
/*   
/*      Rev 1.72   23 May 2007 14:24:20   zf297a
/*   For zero tsl's that are created via tran date and batch start time, include all part related tables and their last_update_dt.   By doing this, it will insure that all data that has changed for a given run will be processed.
/*   
/*      Rev 1.71   21 May 2007 12:36:00   zf297a
/*   For procedure loadRspZeroTslA2A added a check to get only the spoPrimePartNo/rsp_locations that do NOT have an active rsp_level to all the routines that open the rspTsl cursor.
/*   
/*      Rev 1.70   15 May 2007 09:27:40   zf297a
/*   Changed literal from a2a_pkg to amd_location_part_override_pkg for raise_application_error's.
/*   
/*      Rev 1.69   13 Apr 2007 16:25:14   zf297a
/*   Added amd_defults.AMD_AUS_LOC_ID to cursor_peacetimeBasesSum
/*   
/*      Rev 1.68   12 Apr 2007 15:31:40   zf297a
/*   changed cursors for loadZeroTslA2A to only reference amd_sent_to_a2a in the from clause
/*   
/*   renamed loadZeroTsls to loadZeroRspTsls
/*   
/*      Rev 1.67   12 Apr 2007 14:42:02   zf297a
/*   Implemented loadZeroTsls
/*   
/*      Rev 1.66   12 Apr 2007 11:56:44   zf297a
/*   Replaced isPartActive with isSpoPrimePartActive since amd_location_part_override can only contain spo_prime_part's
/*   
/*      Rev 1.65   12 Apr 2007 10:54:42   zf297a
/*   Move check of whether a part is active out of insertRow and updateRow and put it close to the point of creating a row in tmp_a2a_loc_part_override - insertedTmpA2ALPO.
/*   
/*      Rev 1.64   12 Apr 2007 10:25:40   zf297a
/*   For insertRow and updateRow added check if the part is active to determine the value of the action_code.  If the part is not active then send a amd_defaults.DELETE_ACTION.
/*   
/*      Rev 1.63   10 Apr 2007 21:34:34   zf297a
/*   replaced loadUkandAUS with two distinct procedures loadUK and loadAUS
/*   
/*      Rev 1.62   03 Apr 2007 14:51:16   zf297a
/*   Implement loadTmpAmdLocationPartOverride with argiments startStep and endStep arguments to  with default values of 1 and 5 respectively.
/*   
/*   For procedure loadWhse add arguments startStep and endStep with default values of 1 and 5 respectively.
/*   
/*   For  procedure loadWhse and for the following cursors make sure that the part_no or spo_prime_part_no is not null:
/*   cursor_warehouse_parts
/*   cursor_peacetimeBasesSum
/*   cursor_wartimeRspSum
/*   cursor_peacetimeBO_Spo_Sum
/*   cursor_peacetimeSpoInv
/*   
/*   Create separate nested procedures to  load the following cursors and record the start and end times to amd_load_details using writeMsg:
/*   cursor_warehouse_parts
/*   cursor_peacetimeBasesSum
/*   cursor_wartimeRspSum
/*   cursor_peacetimeBO_Spo_Sum
/*   cursor_peacetimeSpoInv
/*   
/*   For debugging purposes, renumber all pError_location values.
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   2
/*      Rev 1.61   22 Mar 2007 16:44:36   zf297a
/*   Changed LoadUk to LoadUkandAUS and added check for the AUS location id.  Fixed the query for cur_stock to use 'C17%CODAUSG' with a G at the end.
/*   
/*      Rev 1.60   22 Mar 2007 09:57:06   zf297a
/*   For procedure sendZeroTslsForSpoPrimePart check if the spo_prime_part_no is an ACTIVE spo_prime_part_no in amd_sent_to_a2a instead of just seeing that it is a prime_part_no in amd_national_stock_items.
/*   
/*      Rev 1.59   22 Mar 2007 08:40:14   zf297a
/*   Added raise_application_error for procedures errorMsg and writeMsg to guarantee that error information of trace information gets displayed.
/*   
/*      Rev 1.58   21 Mar 2007 14:58:10   zf297a
/*   Use isPartSent to check that the part was sent to Data Systems - ie in amd_sent_to_a2a
/*   
/*      Rev 1.57   21 Mar 2007 11:32:38   zf297a
/*   Check if a part exists in Data Systems and it has not been marked deleted before sending any deletes, otherwise DataSystems will flag it as an error when trying to delete parts that have already been deleted
/*   
/*      Rev 1.56   02 Mar 2007 10:59:04   zf297a
/*   For procedures getAllBasses and getAllBasesNotSet change the default action codes to the "function based" variables.  For getAllBasesSent make sure there isn't an active record either in amd_rsp_sum or amd_location_part_override whose rsp_level or tsl_override_qty is greater than zero.
/*   
/*      Rev 1.55   01 Mar 2007 14:43:40   zf297a
/*   Make sure getAllBases is generating DELETE's and sending a zero quantity for all the bases.  If there is already a DELETE tran for the part/base in tmp_a2a_loc_part_override, then don't generate another one.
/*   
/*      Rev 1.54   01 Mar 2007 13:38:50   zf297a
/*   Fixed exists clause of queries in getAllBases and getAllBasesNotSent
/*   
/*      Rev 1.53   01 Mar 2007 12:41:38   zf297a
/*   Implemented sendZeroTslsForSpoPrimePart
/*   
/*      Rev 1.52   26 Jan 2007 09:53:10   zf297a
/*   implemented deleteRspTslA2A
/*   
/*      Rev 1.51   Dec 19 2006 10:52:48   zf297a
/*   Fixed deleteRow to use an Update action_code, when the part is valid to be an A2A part, otherwise it will always send a Delete action_code.
/*   
/*   Fixed the open cursor for getTestData, getDataByLastUpdateDt, and getAllData to use a DELETE action_code when the A2A part has been deleted from the amd_sent_to_a2a, otherwise send an UPDATE action_code when the action_code is DELETE for the amd_location_part_override row or when the amd_location_part_override row has an INSERT or UPDATE send amd_location_part_override.action_code.
/*   
/*   
/*   
/*      Rev 1.50   Dec 13 2006 12:00:38   zf297a
/*   When a part/loc_sid is being deleted by the java diff applicaton, update the spo data with a zero quantity - i.e. insert a record with a quantity of zero and an action_code of UPDATE.
/*   
/*   For all cursor queries make sure the quantity is zero when the action_code is DELETE and make sure that the UPDATE action gets sent for a row that has been deleted in amd_location_part_override.
/*   
/*   Implemented isTmpA2AOkay - this just checks to be sure that every part that has been sent is associated with a location.
/*   
/*      Rev 1.49   Dec 05 2006 15:14:50   zf297a
/*   Implemented new interface for processTsl.  The pDoAllA2A parameter was removed.  It was no longer necessary since the tsl cursor does all the filtering.  Removed unecessary code:
/*   insertTmpA2A - this is redundant code
/*   Removed all the unnecessary condition checks since the tsl cursor does all the fnecessary filtering.
/*   Resequenced values used for pError_location.
/*   in LoadAllA2A removed unused variables - doAllA2A, returnCode and rc.
/*   Fixed the open of the cursors to use the action_code from the amd_location_part_override for deleted rows, otherwise use the amd_sent_to_a2a action_code.
/*   For the unions of amd_rsp_sum make sure the mob is still valid by checking it against amd_spare_networks.  For the amd_rsp_sum data always use the amd_sent_to_a2a action_code and always send a zero for any row that has been deleted.
/*   
/*      Rev 1.48   Dec 04 2006 13:57:22   zf297a
/*   Fixed processTsl - used trunc for date compare + checked each action_code per each record of the tsl cursor (tslCur).
/*   
/*      Rev 1.47   Nov 28 2006 13:44:48   zf297a
/*   fixed getDataByLastUpdateDt - changed code layout for open.
/*   
/*   fixed getDataByTranDtAndBatchTime - changed code layout for open.
/*   
/*      Rev 1.46   Nov 28 2006 12:54:40   zf297a
/*   fixed insertTmpA2ALPO - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_loc_part_override.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_loc_part_override.
/*   
/*   fixed insertTmpA2A for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_loc_part_override.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_loc_part_override.
/*   
/*   fixed getDataByLastUpdtDt to check if there is a part in amd_location_part_overrides that has changed for the given time period.
/*   
/*   fixed getDataByTranDtAndBatchTime check if there is a part in amd_location_part_overrides that has changed for the given time period.
/*   
/*      Rev 1.45   Oct 23 2006 11:05:28   zf297a
/*   Check pError_location in procedured errorMsg to make sure it is numeric.   Changed dup_val_on_index for insertedTmpA2ALPO to update tmp_a2a_loc_part_override and to record what has changed in amd_load_details.  This may provide the necessary information to eliminate this exception condition.
/*   
/*      Rev 1.44   Oct 19 2006 11:08:26   zf297a
/*   Fixed all tslCur's to use the amd_sent_to_a2a.action_code and created a nested procedure for each unique Open of the tslCur and record the procedure's name in amd_load_details.
/*   
/*      Rev 1.42   Oct 16 2006 08:41:44   zf297a
/*   For function getFirstLogonIdForPart only consider the action_code for amd_planners and amd_planner_logons since the part may have been deleted, but still needs to be sent with the proper logon_id when sending delete A2A transactions.
/*   
/*      Rev 1.41   Oct 11 2006 11:03:46   zf297a
/*   When doing a loadAllA2A and getting data from amd_rsp_sum always use the action_code of amd_sent_to_a2a.spo_prime_part_no and send a zero quantity when the amd_rsp_sum.action_code = 'D' otherwise send the rsp_level.
/*   
/*      Rev 1.40   Oct 09 2006 22:28:04   zf297a
/*   Fixed inner getActionCode function of insertTmpA2A of processTsl - used rsp_location / site_location for search of amd_rsp_sum.  Added additional exception handlers for getActionCode too.
/*   
/*      Rev 1.39   Oct 09 2006 10:34:56   zf297a
/*   For A2A transactions give the action_code belonging to amd_location_part_override or amd_rsp_sum priority when it is a delete action, otherwise use the action_code from the associated amd_sent_to_a2a row.
/*   
/*      Rev 1.38   Sep 05 2006 12:47:08   zf297a
/*   Renumbered pError_location's values
/*   
/*      Rev 1.37   Aug 31 2006 16:02:12   zf297a
/*   Added more exception handlers.  Added dbms_output to version procedure.
/*   
/*      Rev 1.36   Aug 31 2006 15:34:22   zf297a
/*   Replaced errorMsg function with errorMsg procedure
/*   
/*      Rev 1.35   Aug 31 2006 14:56:12   zf297a
/*   Added more when others exceptions
/*   fixed loadAllA2A to use the amd_sent_to_a2a action_code 
/*   
/*      Rev 1.34   Aug 31 2006 12:03:18   zf297a
/*   Used not exists instead of function inInTmpA2AYorN
/*   Used action_code from amd_sent_to_a2a in most cases
/*   
/*   
/*      Rev 1.33   Jul 17 2006 11:21:00   zf297a
/*   Added cursor_spoSum for warehouse.  This amount get subtracted from the spo_total_inventory
/*   
/*      Rev 1.32   Jun 16 2006 09:21:54   zf297a
/*   For LoadWhse added a cursor_rspSum which get summed with cursor_basesSum resulting in substracting out the rsp sum for the final tsl_override_qty that gets put into tmp_amd_location_part_override.
/*   
/*      Rev 1.31   Jun 12 2006 13:22:32   zf297a
/*   use symbolic constants UK_LOCATION and BASC_LOCATION.
/*   
/*      Rev 1.30   Jun 09 2006 11:56:00   zf297a
/*   implemented version
/*   
/*      Rev 1.29   Jun 07 2006 11:11:04   zf297a
/*   For the loadAll unioned amd_rsp_sum with amd_location_part_overrides to get the non zero tsl's.
/*   
/*      Rev 1.28   Jun 07 2006 09:45:06   zf297a
/*   for loadRspZeroTsl fixed the sql for the cursors where amd_location_part_override_pkg.isInTmpA2AYorN(spo_prime_part_no, mob || '_RSP') = 'N' is needed (the value was checked for was not all 'N''s and the mob was not concatenated with the literal '_RSP')
/*   
/*      Rev 1.27   Jun 03 2006 20:25:54   zf297a
/*   enhanced the use of writeMsg
/*   
/*      Rev 1.26   Jun 03 2006 19:09:54   zf297a
/*   added:
/*   and parts.action_code != amd_defaults.getDELETE_ACTION
/*   to the last open tsl cursor of procedure LoadZeroTslA2A
/*   
/*      Rev 1.25   Jun 03 2006 18:59:36   zf297a
/*   fixed procedure amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*    to use select's similar to the following: 
/*    SELECT distinct primes.spo_prime_part_no,
/*      amd_defaults.getINSERT_ACTION,
/*      sysdate,
/*      theLocation spo_location,
/*      ansi.nsn,
/*      ansi.nsi_sid,
/*      0 override_qty
/*      FROM (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D') primes, 
/*      AMD_NATIONAL_STOCK_ITEMS ansi
/*      WHERE amd_location_part_override_pkg.isInTmpA2AYorN(primes.spo_prime_part_no, theLocation) = 'N'
/*      AND ansi.prime_part_no = primes.spo_prime_part_no
/*      AND ansi.action_code != Amd_Defaults.getDELETE_ACTION 
/*     
/*   and procedure amd_location_part_override_pkg.LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   was fixed by adding an additional invocation of 
/*   amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   for pSpoLocation equal to amd_location_part_override_pkg.THE_WAREHOUSE (FD2090).
/*   
/*   
/*      Rev 1.24   Jun 01 2006 22:20:24   zf297a
/*   Fiixed query for loadRspZeroTsl - added qualification for amd_spare_parts - part_no = spo_prime_part_no
/*   
/*      Rev 1.23   Jun 01 2006 12:01:14   zf297a
/*   Added writeMsg to the beginning of processTsl
/*   
/*      Rev 1.22   Jun 01 2006 10:57:52   zf297a
/*   Fixed loadRspZeroTsl's.  use amd_utils.writeMsg instead of dbms_output
/*   
/*      Rev 1.21   May 31 2006 08:20:46   zf297a
/*   Used Mta_Truncate_Table for loadAllA2A instead of truncateIfOld
/*   
/*      Rev 1.20   May 12 2006 14:00:36   zf297a
/*   For loadAllA2A include all action_codes and all parts that are in amd_sent_to_a2a  where the spo_prime_part_no is filled in too.
/*   
/*      Rev 1.19   Apr 28 2006 13:16:24   zf297a
/*   Implemented the loadRspZeroTslA2A
/*   
/*      Rev 1.18   Apr 21 2006 14:02:00   zf297a
/*   Made insertTmpA2ALPO public, so prototype could be removed.  Also made sure that insertTmpA2ALPO never updates an existing tmp_a2a record with a zero quantity.
/*   
/*      Rev 1.17   Apr 20 2006 13:23:00   zf297a
/*   Added an insertTmpA2A routine for the processTsl procedure.  This routine is used only to insert zero tsl's.  If a tmp_a2a row exists already, it is not overwritten.
/*   
/*      Rev 1.16   Mar 23 2006 09:08:56   zf297a
/*   Use truncateIfOld for tmp_a2a_loc_part_override - .  The table will get truncated if there is no active batch job or it will get truncated if there is an active batch job and the table has not changed since the batch job started.
/*   
/*      Rev 1.15   Mar 06 2006 08:37:34   zf297a
/*   Removed unused references to amd_batch_jobs
/*   
/*      Rev 1.14   Mar 05 2006 15:26:36   zf297a
/*   Added debug code.
/*   
/*      Rev 1.13   Mar 05 2006 14:16:24   zf297a
/*   Added amd_utils.debugMsg to record counts and procedure completion.
/*   Added enhanced processing to tsl's.
/*   
/*      Rev 1.12   Mar 03 2006 12:06:22   zf297a
/*   Moved boolean2Varchar2 to amd_utils.  Used amd_batch_pkg.getLastStartTime instead of amd_location_part_leadtime_pkg.getBatchRunStart.  This will retrieve the last batch start time even if the job has finished.  This way any data changed since the last batch job has been run, can have a2a transactions created for it.  (The only other choice with the previous method would be the "send all" method versus what has changed since the last batch start time).
/*   Added more qualification for the tsl cursor in procedure loadZeroTslA2APartsWithNoTsls
/*   
/*   
/*      Rev 1.11   Feb 24 2006 15:07:26   zf297a
/*   Streamlined routines handling TSL's.  Added some additional TSL loads.
/*   
/*      Rev 1.10   Feb 17 2006 09:25:10   zf297a
/*   Changed requisition_objective to demand_level
/*   
/*      Rev 1.9   Feb 15 2006 21:22:52   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.8   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.7   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.6   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*   
/*      Rev 1.5   Dec 15 2005 12:16:44   zf297a
/*   Added truncate table tmp_a2a_loc_part_override to LoadTmpAmdLocPartOverride
/*   
/*      Rev 1.4   Dec 06 2005 09:52:36   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.3   Nov 15 2005 11:57:26   zf297a
/*   Add additional where clauses to load all the data.  Added return statement for insertedTmpA2ALPO.
/*   
/*      Rev 1.2   Nov 10 2005 11:08:24   zf297a
/*   Added global counters for insert, update, and delete and public getter's.
/*   
/*   Added a testData Cursor.
/*   
/*   Added counters and displaying of start/end messages for all the load routines.
/*   
/*      Rev 1.1   Oct 28 2005 12:46:04   zf297a
/*   Added check for wasPartSent before inserting to tmp_a2a_loc_part_override
/*   
/*      Rev 1.0   Oct 19 2005 12:40:56   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Oct 18 2005 13:07:22   zf297a
/*   Initial revision.
		 */

    type candiateRec is record (
        part_no amd_sent_to_a2a.part_no%type,
        loc_sid amd_spare_networks.loc_sid%type
    ) ;
    type candidateTab is table of candiateRec ;
	candidateRecs candidateTab ;
    
    type stockRec is record (
        part_no amd_sent_to_a2a.part_no%type,
        tsl_override_qty number
    ) ;
    type stockTab is table of stockRec ;
    stockRecs stockTab ;
    
    type partSumRec is record (
        part_no amd_sent_to_a2a.part_no%type,
        qty number
    ) ;
    type partSumTab is table of partSumRec ;
    partSumRecs partSumTab ;        
        
	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_LOCATION_PART_OVERRIDE_PKG' ;
	
	
	insertCnt NUMBER := 0 ;
	updateCnt NUMBER := 0 ;
	deleteCnt NUMBER := 0 ;
	
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
				pSourceName => 'amd_location_part_override_pkg',	
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
                substr('amd_location_part_override_pkg ' 
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
	    pData_line    => 'amd_location_part_override_pkg',
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
            substr('amd_location_part_override_pkg ' 
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
	
	
	PROCEDURE UpdateAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 10) ;
		 raise ;	
	END UpdateAmdLocPartOverride ;
	
	PROCEDURE UpdateTmpAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
		 exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 20) ;
		 raise ;	
		 END UpdateTmpAmdLocPartOverride ;
	
	
	PROCEDURE InsertTmpAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
        if pTslOverrideQty <> 0 then -- Xzero
             INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE
             (
                    part_no,
                    loc_sid,
                    tsl_override_qty,
                    tsl_override_user,
                    action_code,
                    last_update_dt
             )
             VALUES
             (
                    pPartNo,
                    pLocSid,
                    pTslOverrideQty,
                    pTslOverrideUser,
                    pActionCode,
                    pLastUpdateDt
             ) ;
        end if ;             
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateTmpAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	  when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 30) ;
		raise ;
	END InsertTmpAmdLocPartOverride ;
	
	PROCEDURE InsertAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_SPARE_NETWORKS.loc_sid%TYPE,
			  pTslOverrideQty			NUMBER,
			  pTslOverrideUser			VARCHAR2,
			  pActionCode				VARCHAR2,
			  pLastUpdateDt				DATE) IS
	BEGIN
         if pTslOverrideQty <> 0 then -- Xzero
             INSERT INTO AMD_LOCATION_PART_OVERRIDE
             (
                    part_no,
                    loc_sid,
                    tsl_override_qty,
                    tsl_override_user,
                    action_code,
                    last_update_dt
             )
             VALUES
             (
                    pPartNo,
                    pLocSid,
                    pTslOverrideQty,
                    pTslOverrideUser,
                    pActionCode,
                    pLastUpdateDt
             ) ;
        end if ;              
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	 when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 40) ;
		 raise ;
	END InsertAmdLocPartOverride ;
	
				  
	FUNCTION insertedTmpA2ALPO(rec IN TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE) RETURN BOOLEAN IS
			 rc number ;
	BEGIN
		 RETURN insertedTmpA2ALPO(
				  rec.part_no,
				  rec.site_location,
				  rec.override_type,
				  rec.override_quantity,
				  rec.override_reason,
				  rec.override_user,
				  rec.begin_date,
				  rec.action_code,
				  rec.last_update_dt) ;
				 
	exception when others then
			  
		 ErrorMsg(
				   pSqlfunction 	  => 'insertedTmpA2ALPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 50,
				   pKey1			  => 'part_no=' || rec.part_no,
	   			   pKey2			  => 'location=' || rec.site_location,
				   pKey3			  => 'action=' || rec.action_code,
                   pKey4              => 'user=' || rec.override_user,
				   pComments		  => 'qty=' || to_char(rec.override_quantity) ) ;
		RAISE ;
	END insertedTmpA2ALPO ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN IS
				  
			rc number ;
            
            action_code tmp_a2a_loc_part_override.action_code%type ;
			
            procedure doUpdate is
            begin
                UPDATE TMP_A2A_LOC_PART_OVERRIDE
                SET
                    override_quantity	 = pTslOverrideQty,
                    override_type = pOverrideType,
                    override_reason	 = pOverrideReason,
                    override_user		 = pTslOverrideUser,
                    begin_date		 = pBeginDate,
                    action_code		 = insertedTmpA2ALPO.action_code,
                    last_update_dt	 = pLastUpdateDt
                WHERE
                    part_no 			 = pPartNo AND
                    site_location		 = pBaseName and
                    override_type        = pOverrideType ;
            exception
                when others then
                    ErrorMsg(
                        pSqlfunction 	  => 'doUpdate',
                        pTableName  	  	  => 'tmp_a2a_loc_part_override',
                        pError_location => 60,
                        pKey1			  => 'pPartNo=' || pPartNo,
                        pKey2			  => 'pBaseName=' || pBaseName,
                        pKey3			  => 'insertedTmpA2ALPO.action_code=' || insertedTmpA2ALPO.action_code) ;
                    raise ;
            end doUpdate ;
			
			procedure insertRow is

					  procedure recordInfo is
					 		override_type tmp_a2a_loc_part_override.OVERRIDE_TYPE%type ;
							override_quantity tmp_a2a_loc_part_override.OVERRIDE_QUANTITY%type ;
							override_reason tmp_a2a_loc_part_override.OVERRIDE_REASON%type ;
							override_user tmp_a2a_loc_part_override.OVERRIDE_USER%type ;
							begin_date tmp_a2a_loc_part_override.BEGIN_DATE%type ;
							action_code tmp_a2a_loc_part_override.ACTION_CODE%type ;
							last_update_dt tmp_a2a_loc_part_override.LAST_UPDATE_DT%type ;
							
							-- log what's different about this row
							procedure changed (field in varchar2, curfieldValue in varchar2, prevFieldValue in varchar2, 
									  pError_location in number) is
							begin
								writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => pError_Location,
									pKey1 => 'insertedTmpA2ALPO.changed',
									pKey2 => 'part_no=' || pPartNo,
									pKey3 => 'pBaseName=' || pBaseName,
									pKey4 => 'prev ' || field || '=' || nvl(prevfieldValue,'Null'),
									pData => 'cur ' || field || '=' || nvl(curFieldValue,'Null') ) ;
							end changed ;
					
					  begin
			 	
					    select override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
						into override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
						from tmp_a2a_loc_part_override 
						where part_no = pPartNo
						and site_location = pBaseName 
                        and override_type = pOverrideType ;
						
						if override_quantity <> pTslOverrideQty or override_reason <> pOverrideReason
						or pBeginDate <> begin_date or pActionCode <> action_code or pLastUpdateDt <> last_update_dt then
						   	   -- something changed 
							   -- record only the column that changed
							   if pTslOverrideQty <> override_quantity then
							   	  changed('override_quantity', to_char(pTslOverrideQty), to_char(override_quantity), pError_location => 70) ;
							   end if ;
							   if pOverrideReason <> override_reason then
							   	  changed('override_reason', pOverrideReason, override_reason,  pError_location => 80) ;
							   end if ; 
							   if pTslOverrideUser <> override_user then
							   	  changed('override_user', pTslOverrideUser, override_user,  pError_location => 90) ;
							   end if ;
							   if pBeginDate <> begin_date then				   
							   	  changed('begin_date', to_char(pBeginDate,'MM/DD/YYYY HH:MI:SS'), to_char(begin_date,'MM/DD/YYYY HH:MI:SS'), pError_location => 100) ;
							   end if ;
							   if pActionCode <> action_code then
							   	  changed('action_code',  pActionCode, action_code, pError_location => 110) ;
							   end if ;
							   if pLastUpdateDt <> last_update_dt then
							   	  changed('last_update_dt', to_char(pLastUpdateDt,'MM/DD/YYYY HH:MI:SS'), to_char(last_update_dt,'MM/DD/YYYY HH:MI:SS'), pError_location => 120) ;
							   end if ;
						 end if ;
                      exception  
                        when others then
                		 ErrorMsg(
        				   pSqlfunction 	  => 'recordInfo',
        				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
        				   pError_location => 130,
        				   pKey1			  => 'pPartNo=' || pPartNo,
        	   			   pKey2			  => 'pBaseName=' || pBaseName,
                           pKey3              => 'pOverrideType=' || pOverrideType,
        				   pKey4			  => 'insertedTmpA2ALPO.action_code=' || insertedTmpA2ALPO.action_code) ;
        		        raise ;
					  end recordInfo ;
					  
			begin
                    if debug and not a2a_pkg.ISSPOPRIMEPARTACTIVE(pPartNo) 
                        and insertedTmpA2ALPO.action_code <> amd_defaults.DELETE_ACTION  then
                        -- the trigger should take care of this situation, but
                        -- just record it to see where the code is failing
        				writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 140,
        					pKey1 => 'insertedTmpA2ALPO.insertRow',
        					pKey2 => 'part_no=' || pPartNo,
        					pKey3 => 'pBaseName=' || pBaseName,
        					pKey4 => 'action_code= ' || insertedTmpA2ALPO.action_code,
        					pData => 'action_code should be D') ;
                    end if ;
                    
                    if (pOverrideType = OVERRIDE_TYPE and not amd_utils.isPartRepairable(pPartNo))
                    or (pOverrideType in (amd_lp_override_consumabl_pkg.ROP_TYPE,amd_lp_override_consumabl_pkg.ROQ_TYPE) and not amd_utils.isPartConsumable(pPartNo))
                    or pTslOverrideQty is null 
                    or pTslOverrideQty = 0 then -- Xzero
                        return ;
                    end if ;                        
                     			 	 
					 INSERT INTO TMP_A2A_LOC_PART_OVERRIDE (
						  part_no,
						  site_location,
						  override_type,
						  override_quantity,
						  override_reason,
						  override_user,
						  begin_date,
						  action_code,
						  last_update_dt
					 )
					 VALUES
					 (
					 	  pPartNo,
						  pBaseName,
						  pOverrideType,
						  pTslOverrideQty,
						  pOverrideReason,
						  pTslOverrideUser,
						  pBeginDate,
						  insertedTmpA2ALPO.action_code,
						  pLastUpdateDt
					 ) ;
					 
		    EXCEPTION 
			    WHEN DUP_VAL_ON_INDEX THEN
			  	   if debug then
                        recordInfo ;
                   end if ;                        
				   doUpdate ;
                when others then
        		 ErrorMsg(
				   pSqlfunction 	  => 'insertRow',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 150,
				   pKey1			  => 'pPartNo=' || pPartNo,
	   			   pKey2			  => 'pBaseName=' || pBaseName,
				   pKey3			  => 'insertedTmpA2ALPO.action_code=' || insertedTmpA2ALPO.action_code) ;
		        raise ;
			end insertRow ;
			
	BEGIN
        action_code := pActionCode ;
        if a2a_pkg.isSpoPrimePartActive(pPartNo) then
            if action_code = amd_defaults.INSERT_ACTION or action_code = amd_defaults.UPDATE_ACTION then
                null ; -- everything is ok
            else
                action_code := amd_defaults.INSERT_ACTION ; -- default to an insert
            end if ;
        else
            action_code := amd_defaults.DELETE_ACTION ;  -- the part is not active therefore all associated data must be deleted
        end if ;
		 if action_code = amd_defaults.INSERT_ACTION
		 or action_code = amd_defaults.UPDATE_ACTION then
		 
			 IF A2a_Pkg.wasPartSent(pPartNo) 
			 AND pBaseName IS NOT NULL  THEN -- see if part exsits in amd_sent_to_a2a with action_code <> DELETE_ACTION
			 
				  insertRow ;
				  RETURN TRUE ;
				  
			ELSE
			  RETURN FALSE ;
			END IF ;
		else
            -- only delete parts that have been sent previously
            if a2a_pkg.isPartSent(pPartNo) then 
                if ignoreStLouis or a2a_pkg.lpOverrideExists(pPartNo, pBaseName) then
                   insertRow ;  -- if the part/base is NOT deleted in data systems then make sure it gets deleted     			   
                end if ;
            end if ;	
			return true ;
		end if ;
	 exception WHEN others THEN
	 
  	   ErrorMsg(pSqlfunction => 'insertedTmpA2ALPO',
		   pTableName => 'tmp_a2a_loc_part_override',
		   pError_location => 160,
		   pKey1 => pPartNo,
  		   pKey2 => pBaseName,
		   pKey3 => pActionCode) ;
		RAISE ;
	
	END insertedTmpA2ALPO ;
	
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
		 returnCode NUMBER ;
	BEGIN
		 BEGIN
		    InsertAmdLocPartOverride (
		 	  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.INSERT_ACTION,
			  SYSDATE ) ;
	
		 exception when others then
		 errorMsg(pSqlfunction => 'InsertRow.InsertAmdLocPartOverride', pTableName => 'amd_location_part_override',
            pError_location => 170, pKey1 => pPartNo, pKey2 => pLocSid) ;
		 raise ;
	
		 end ;
		 begin
		  	   if insertedTmpA2ALPO(
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  amd_defaults.INSERT_ACTION,
				  SYSDATE
			    ) THEN
				 insertCnt := insertCnt + 1 ;
			end if ;
	
	
		  end ;
		  return success ;
	exception when others then
		 errorMsg(pSqlfunction => 'InsertRow.InsertTmpA2A_LPO',pTableName => 'tmp_a2a_loc_part_override',
            pError_location => 180, pKey1 => pPartNo, pKey2	=> pLocSid) ;
		raise ;
	end insertRow ;
	
	
	function updateRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
			returnCode NUMBER ;
	begin
		 begin
		 	updateAmdLocPartOverride (
	  		  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.UPDATE_ACTION,
			  sysdate ) ;
		 exception when others then
		    errorMsg(pSqlfunction => 'UpdateRow.InsertTmpA2A_LPO',pTableName => 'amd_location_part_override',
                pError_location => 190, pKey1 => pPartNo, pKey2 => pLocSid) ;
		    raise ;
		 end ;
		 begin
			if insertedTmpA2ALPO (
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  amd_defaults.UPDATE_ACTION,
				  sysdate
		   ) then
		   	 updateCnt := updateCnt + 1 ;
		 end if ;
		 end ;
		 return success ;
	exception when others then
		 errorMsg(pSqlfunction => 'UpdateRow.InsertTmpA2A_LPO',pTableName => 'tmp_a2a_loc_part_override',
            pError_location => 200,pKey1 => pPartNo, pKey2 => pLocSid) ;
		raise ;
	end updateRow ;
	
	
	
	function deleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			return number is
			returnCode number ;
	begin
		 begin
			 updateAmdLocPartOverride (
		  		  pPartNo,
				  pLocSid,
				  pTslOverrideQty,
				  pTslOverrideUser,
				  Amd_Defaults.DELETE_ACTION,
				  SYSDATE ) ;
		 exception when others then
		 errorMsg(pSqlfunction => 'DeleteRow.UpdateAmdLocPartOverride',pTableName => 'amd_location_part_override',
            pError_location => 210, pKey1 => pPartNo, pKey2 => pLocSid) ;
		 raise ;
		 end ;
		 declare
		 		action_code tmp_a2a_loc_part_override.ACTION_CODE%type ;
		 begin
		 	  if a2a_pkg.isSpoPrimePartActive(pPartNo) then
			  	 action_code := amd_defaults.UPDATE_ACTION ;
			  else
			  	 action_code := amd_defaults.DELETE_ACTION ;
			  end if ;
		 	  
		 	  -- deletion of parts handled by part info delete
		 	--IF (NOT amd_location_part_leadtime_pkg.IsPartDeleted(pPartNo)) THEN
		 		IF insertedTmpA2ALPO (
		 			  pPartNo,
		 			  Amd_Utils.GetSpoLocation(pLocSid),
		 			  OVERRIDE_TYPE,
		 			  0, -- quantity needs to be set to zero when deleting
		 			  OVERRIDE_REASON,
		 			  pTslOverrideUser,
		 			  SYSDATE,
		 			  action_code,
		 			  sysdate
		 	   ) then
			   deleteCnt := deleteCnt + 1 ;
			 end if ;
			--end if ;
		 end ;
	  	return success ;
	exception when others then
		 errorMsg(pSqlfunction => 'DeleteRow',pTableName => 'tmp_a2a_loc_part_override',
            pError_location => 220, pKey1 => pPartNo,pKey2 => pLocSid) ;
		raise ;
	end deleteRow ;
	
	function isNumeric(pString varchar2) return varchar2 is
			 ret varchar2(1) ;
			 I number ;
	begin
		 begin
		 	  if pString is null then
			  	 ret := 'N' ;
			  else
			     I := to_number(pString) ;
			     ret := 'Y' ;
			  end if ;
		 exception when others then
		 	  ret := 'N' ;
		 end ;
		 return ret ;
	end isNumeric ;
    
	procedure loadUk IS
        candidateRecs candidateTab ;
                    
		cursor cur_cand IS
			select spo_prime_part_no part_no,
				  loc_sid
				  from amd_sent_to_a2a asta, amd_spare_networks asn
				  where asta.part_no = asta.spo_prime_part_no
				  and (asn.loc_id = Amd_Defaults.AMD_UK_LOC_ID)
				  and asta.action_code != Amd_Defaults.DELETE_ACTION
                  and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	
        stockRecs stockTab ;
            
	 	cursor cur_stock IS
			select amd_partprime_pkg.getSuperPrimePart(asp.part_no) part_no,
				   sum(nvl(stock_level, 0)) tsl_override_qty
				  from whse w, amd_spare_parts asp
				  where w.part = asp.part_no
                  and amd_utils.isPartRepairableYorN(asp.part_no) = 'Y'
				  and (w.sc like 'C17%CODUKBG')
		 	      and asp.action_code != Amd_Defaults.DELETE_ACTION
				  Group by	amd_partPrime_pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode number ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		cand_cnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 230,
				pKey1 => 'LoadUk',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		begin
            open cur_stock ;
            fetch cur_stock bulk collect into stockRecs ;
            close cur_stock ;
            
            if stockRecs.first is not null then
                for indx in stockRecs.first .. stockRecs.last loop
                    begin
                         if ( stockRecs(indx).part_no is not null ) then
                            partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
                         end if ;
                    exception when others then
                        errorMsg(pSqlfunction => 'LoadUk',pTableName => 'tmp_amd_location_part_override',
                           pError_location => 240, pKey1 => 'partNo: ' || stockRecs(indx).part_no, pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
                        raise ;
                    end ;
                    stock_cnt := stock_cnt + 1 ;
                end loop ;
            end if ;                

            open cur_cand ;
            fetch cur_cand bulk collect into candidateRecs ;
            close cur_cand ;
            
            if candidateRecs.first is not null then            
                for indx in candidateRecs.first .. candidateRecs.last loop
                    tslOverrideQty := 0 ;
                    begin
                        tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
                    exception when no_data_found then
                        tslOverrideQty := 0 ;
                    end ;
                    begin
                         insertTmpAmdLocPartOverride(
                            candidateRecs(indx).part_no,
                            candidateRecs(indx).loc_sid,
                            tslOverrideQty,
                            null,
                            Amd_Defaults.INSERT_ACTION,
                            sysdate
                         ) ;
                    exception when others then
                      errorMsg(pSqlfunction	=> 'LoadUk',pTableName => 'tmp_amd_location_part_override',
                           pError_location => 250, pKey1 => 'partNo: ' || candidateRecs(indx).part_no, pKey2 => 'locSid: ' || candidateRecs(indx).loc_sid) ;
                           raise ;
                    end ;
                    cand_cnt := cand_cnt + 1 ;
                end loop ;
            end if ;                
            
		end ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 260,
				pKey1 => 'LoadUk',
				pKey2 => 'ended at ' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt, 
				pKey4 => 'cand_cnt=' || cand_cnt ) ;
        commit ;                
	exception when others then
		 errorMsg(pSqlfunction => 'LoadUk',pTableName => 'tmp_amd_location_part_override',
            pError_location => 270, pKey1 => 'stock_cnt=' || to_char(stock_cnt), pKey2 => 'cand_cnt=' || to_char(cand_cnt) ) ;
		raise ;
	end loadUk ;
	
	procedure loadAUS IS
    
        
		cursor cur_cand IS
			select spo_prime_part_no part_no,
				  loc_sid
				  from amd_sent_to_a2a asta, amd_spare_networks asn
				  where asta.part_no = asta.spo_prime_part_no
				  and (asn.loc_id = amd_defaults.AMD_AUS_LOC_ID)
				  and asta.action_code != Amd_Defaults.DELETE_ACTION
                  and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	

	 	cursor cur_stock is
			select Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   sum(nvl(stock_level, 0)) tsl_override_qty
				  from whse w, amd_spare_parts asp
				  where w.part = asp.part_no
                  and amd_utils.isPartRepairableYorN(asp.part_no) = 'Y'
				  and (w.sc like 'C17%CODAUSG')
		 	      and asp.action_code != Amd_Defaults.DELETE_ACTION
				  group by	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		cand_cnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 280,
				pKey1 => 'LoadAUS',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		begin
            open cur_stock ;
            fetch cur_stock bulk collect into stockRecs ;
            close cur_stock ;
            
            if stockRecs.first is not null then
                for indx in stockRecs.first .. stockRecs.last loop
                    begin
                         if ( stockRecs(indx).part_no is not null ) then
                            partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
                         end if ;
                    exception when others then
                        ErrorMsg(pSqlfunction => 'LoadAUS', pTableName => 'tmp_amd_location_part_override',
                           pError_location => 290, pKey1 => 'partNo: ' || stockRecs(indx).part_no, pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
                        raise ;
                    end ;
                    stock_cnt := stock_cnt + 1 ;
                end loop ;
            end if ;                
            
            open cur_cand ;
            fetch cur_cand bulk collect into candidateRecs ;
            close cur_cand ;
            
            if candidateRecs.first is not null then
                for indx in candidateRecs.first .. candidateRecs.last loop
                    tslOverrideQty := 0 ;
                    begin
                        tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
                    exception when no_data_found then
                        tslOverrideQty := 0 ;
                    end ;
                    begin
                         insertTmpAmdLocPartOverride(
                            candidateRecs(indx).part_no,
                            candidateRecs(indx).loc_sid,
                            tslOverrideQty,
                            null,
                            Amd_Defaults.INSERT_ACTION,
                            sysdate
                         ) ;
                    exception when others then
                      errorMsg(pSqlfunction => 'LoadAUS', pTableName => 'tmp_amd_location_part_override',
                           pError_location => 300, pKey1 => 'partNo: '|| candidateRecs(indx).part_no, pKey2 => 'locSid: '|| candidateRecs(indx).loc_sid) ;
                           raise ;
                    end ;
                    cand_cnt := cand_cnt + 1 ;
                end loop ;
            end if ;                
		end ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 310,
				pKey1 => 'LoadAUS',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt, 
				pKey4 => 'cand_cnt=' || cand_cnt ) ;
        commit ;                
	exception when others then
		 errorMsg(pSqlfunction => 'LoadAUS',pTableName => 'tmp_amd_location_part_override',
            pError_location => 320, pKey1 => 'stock_cnt=' || to_char(stock_cnt), pKey2 => 'cand_cnt=' || to_char(cand_cnt) ) ;
		raise ;
	end loadAUS ;
	
	procedure loadCAN IS -- added 10/11/2007 by dse
        
		cursor cur_cand IS
			select spo_prime_part_no part_no,
				  loc_sid
				  from amd_sent_to_a2a asta, amd_spare_networks asn
				  where asta.part_no = asta.spo_prime_part_no
				  and (asn.loc_id = amd_defaults.AMD_CAN_LOC_ID)
				  and asta.action_code != Amd_Defaults.DELETE_ACTION
                  and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	
        
	 	cursor cur_stock is
			select Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   sum(nvl(stock_level, 0)) tsl_override_qty
				  from whse w, amd_spare_parts asp
				  where w.part = asp.part_no
                  and amd_utils.isPartRepairableYorN(asp.part_no) = 'Y'
				  and (w.sc like 'C17%CODCANG')
		 	      and asp.action_code != Amd_Defaults.DELETE_ACTION
				  group by	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		cand_cnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 330,
				pKey1 => 'LoadCAN',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		begin
            open cur_stock;
            fetch cur_stock bulk collect into stockRecs ;
            close cur_stock ;
            
            if stockRecs.first is not null then
                for indx in stockRecs.first .. stockRecs.last loop
                    begin
                         if ( stockRecs(indx).part_no is not null ) then
                            partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
                         end if ;
                    exception when others then
                        ErrorMsg(pSqlfunction => 'LoadCAN', pTableName => 'tmp_amd_location_part_override',
                           pError_location => 340, pKey1 => 'partNo: ' || stockRecs(indx).part_no, pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
                        raise ;
                    end ;
                    stock_cnt := stock_cnt + 1 ;
                end loop ;
            end if ;                

            open cur_cand ;
            fetch cur_cand bulk collect into candidateRecs ;
            close cur_cand ;
            
            if candidateRecs.first is not null then            
                for indx in candidateRecs.first .. candidateRecs.last loop
                    tslOverrideQty := 0 ;
                    begin
                        tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
                    exception when no_data_found then
                        tslOverrideQty := 0 ;
                    end ;
                    begin
                         insertTmpAmdLocPartOverride(
                            candidateRecs(indx).part_no,
                            candidateRecs(indx).loc_sid,
                            tslOverrideQty,
                            null,
                            Amd_Defaults.INSERT_ACTION,
                            sysdate
                         ) ;
                    exception when others then
                      errorMsg(pSqlfunction => 'LoadCAN', pTableName => 'tmp_amd_location_part_override',
                           pError_location => 350, pKey1 => 'partNo: '|| candidateRecs(indx).part_no, pKey2 => 'locSid: '|| candidateRecs(indx).loc_sid) ;
                           raise ;
                    end ;
                    cand_cnt := cand_cnt + 1 ;
                end loop ;
            end if ;                
		end ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 360,
				pKey1 => 'LoadCAN',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt, 
				pKey4 => 'cand_cnt=' || cand_cnt ) ;
        commit ;                
	exception when others then
		 errorMsg(pSqlfunction => 'LoadCAN',pTableName => 'tmp_amd_location_part_override',
            pError_location => 370, pKey1 => 'stock_cnt=' || to_char(stock_cnt), pKey2 => 'cand_cnt=' || to_char(cand_cnt) ) ;
		raise ;
	end loadCAN ;

	
	PROCEDURE LoadBasc IS
		cursor cur_cand is
			select spo_prime_part_no part_no,
				  loc_sid
				  from amd_sent_to_a2a asta, amd_spare_networks asn
				  where asta.part_no = asta.spo_prime_part_no
				  and asn.loc_id = Amd_Defaults.AMD_BASC_LOC_ID
				  and asta.action_code != Amd_Defaults.DELETE_ACTION
                  and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	
	 	cursor cur_stock is
			select Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   sum(nvl(stock_level, 0)) tsl_override_qty
				  from whse w, amd_spare_parts asp
				  where w.part = asp.part_no
                  and amd_utils.isPartRepairableYorN(asp.part_no) = 'Y'
				  and sc = 'C17PCAG'
		 	      and asp.action_code != Amd_Defaults.DELETE_ACTION
	 			  group by	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode number ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		stock_cnt NUMBER := 0 ;
		cand_cnt NUMBER := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 380,
				pKey1 => 'LoadBasc',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		begin
            open cur_stock;
            fetch cur_stock bulk collect into stockRecs ;
            close cur_stock ;
            
            if stockRecs.first is not null then
                for indx in stockRecs.first .. stockRecs.last loop
                    begin
                         if ( stockRecs(indx).part_no is not null ) then
                             partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
                         end if ;
                    exception when others then
                        errorMsg(pSqlfunction => 'LoadBasc', pTableName => 'tmp_amd_location_part_override',
                           pError_location => 390, pKey1 => 'partNo: ' || stockRecs(indx).part_no, pKey2 => 'qty: '|| stockRecs(indx).tsl_override_qty) ;
                           raise ;
                    end ;
                    stock_cnt := stock_cnt + 1 ;
			    end loop ;
            end if ;
            
            open cur_cand ;
            fetch cur_cand bulk collect into candidateRecs ;
            close cur_cand ;
            
            if candidateRecs.first is not null then            
                for indx in candidateRecs.first .. candidateRecs.last loop
                    tslOverrideQty := 0 ;
                    begin
                        tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
                    exception when no_data_found then
                        tslOverrideQty := 0 ;
                    end ;
                    begin
                         insertTmpAmdLocPartOverride(
                            candidateRecs(indx).part_no,
                            candidateRecs(indx).loc_sid,
                            tslOverrideQty,
                            NULL,
                            Amd_Defaults.INSERT_ACTION,
                            SYSDATE
                         ) ;
                    EXCEPTION WHEN OTHERS THEN
                        ErrorMsg(pSqlfunction => 'LoadBasc',pTableName => 'tmp_amd_location_part_override',
                           pError_location => 400, pKey1 => 'partNo: ' || candidateRecs(indx).part_no, pKey2 => 'locSid: ' || candidateRecs(indx).loc_sid) ;
                        raise ;
                    end ;
                    cand_cnt := cand_cnt + 1 ;
                end loop ;
            end if ;                
            
		end ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 410,
				pKey1 => 'LoadBasc',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt,
				pKey4 => 'cand_cnt=' || cand_cnt) ;
        commit ;                
	exception when others then
		errorMsg(pSqlfunction => 'LoadBasc', pTableName => 'tmp_amd_location_part_override',
		   pError_location => 420, pKey1 => 'stock_cnt=' || to_char(stock_cnt), 
           pKey2 => 'cand_cnt=' || to_char(cand_cnt)) ;
		raise ;
	end loadBasc ;
	
	procedure loadFslMob IS
        
        type fslMobTab is table of amd_location_part_override%rowtype ;
        fslMobRecs fslMobTab ;
        
		cursor fslMobcur is
			select spo_prime_part_no part_no,
				   loc_sid,
				   0,
				   null,
				   Amd_Defaults.INSERT_ACTION,
				   sysdate
				   from amd_sent_to_a2a asta, amd_spare_networks asn
				   where asta.spo_prime_part_no = asta.part_no
				   and asn.loc_type in ('MOB', 'FSL')
				   and asta.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.action_code != Amd_Defaults.DELETE_ACTION
                   and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	
        type reqRec is record (
            part_no amd_location_part_override.part_no%type,
            loc_sid amd_location_part_override.loc_sid%type,
            demand_level number
        ) ;
        type reqTab is table of reqRec ;
        reqRecs reqTab ;
                    
		cursor cur_req is
			select Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) part_no,
				   loc_sid,
				   sum(nvl(r.demand_level,0)) demand_level
				   from ramp r, amd_national_stock_items ansi, amd_sent_to_a2a asta, amd_spare_networks asn
				   where r.sc like 'C170008%'
				   and substr(r.sc, 8, 6) = asn.loc_id
				   and asn.loc_type in ('MOB', 'FSL')
				   and replace(r.current_stock_number, '-') = ansi.nsn
				   and ansi.prime_part_no = asta.part_no
				   and Amd_Location_Part_Override_Pkg.IsNumeric(ansi.nsn) = 'Y'
				   and ansi.action_code != Amd_Defaults.DELETE_ACTION
				   and asta.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.action_code != Amd_Defaults.DELETE_ACTION
                   and amd_utils.isPartRepairableYorN(ansi.prime_part_no) = 'Y'
				   group by  Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) , loc_sid
				   having sum(nvl(r.demand_level,0))  > 0 ;
	
		type array is table of tmp_amd_location_part_override%rowtype;
		l_data array;
		returnCode number ;
		cur_cnt NUMBER := 0 ;
		req_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 430,
				pKey1 => 'LoadFslMod',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			open fslMobCur ;
            fetch fslMobCur bulk collect into fslMobRecs ;
            close fslMobCur ;
	    	
            if fslMobRecs.first is not null then
                cur_cnt := fslMobRecs.count ;
                forall indx in fslMobRecs.first .. fslMobRecs.last
                   insert into tmp_amd_location_part_override values fslMobRecs(indx);
            end if ;                   
            
	
		exception when others then
            errorMsg(pSqlfunction => 'LoadFslMob',pTableName => 'tmp_amd_location_part_override',
                pError_location => 440) ;
            raise ;
        end ;
        
	    commit ;
        
        open cur_req ;
        fetch cur_req bulk collect into reqRecs ;
        close cur_req ;
        
		if reqRecs.first is not null then
            for indx in reqRecs.first .. reqRecs.last loop
    	
                begin
                    update tmp_amd_location_part_override
                        set	   tsl_override_qty = reqRecs(indx).demand_level
                        where part_no = reqRecs(indx).part_no
                                  and loc_sid = reqRecs(indx).loc_sid ;
                exception when others then
                    errorMsg(pSqlfunction => 'LoadFslMob', pTableName => 'tmp_amd_location_part_override',
                       pError_location => 450, pKey1 => reqRecs(indx).part_no, pKey2 => reqRecs(indx).loc_sid) ;
                       raise ;
                end ;
                req_cnt := req_cnt + 1 ;
            end loop ;
        end if ;            
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 460,
				pKey1 => 'LoadFslMod',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || cur_cnt,
				pKey4 => 'req_cnt=' || req_cnt) ;
        commit ;                
	exception when others then			  
		 ErrorMsg(pSqlfunction => 'LoadFslMob',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 470, pKey1 => 'cur_cnt=' || to_char(cur_cnt), pKey2 => 'req_cnt=' || to_char(req_cnt)) ;
		 raise ;	
	end loadFslMob ;
	
	
	procedure loadWhse(startStep in number := 1, endStep in number := 5) is
        type whseTab is table of tmp_amd_location_part_override%rowtype ;
        whseRecs whseTab ;
	
		cursor cursor_warehouse_parts is
			   select spo_prime_part_no part_no,
			   		  loc_sid,
					  0 tsl_override_qty,
					  null tsl_override_user,
					  amd_defaults.INSERT_ACTION action_code,
					  sysdate last_update_dt
				   from amd_sent_to_a2a asta, amd_spare_networks asn
				   where asta.spo_prime_part_no = asta.part_no
				   and asn.loc_id = amd_defaults.amd_warehouse_locid
				   and asta.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.spo_location is not null
                   and spo_prime_part_no is not null
                   and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y' ;
	
			 -- get all those whse where the rbl run had 0 value for and
			 --	1) sum all the tsls where FSL, MOB, UAB
			 --	2) from Total Spo Inventory, subtract out those from 1)
	
	
			-- tmp_amd_location_part_override is already by spo prime, no need to determine
		cursor cursor_peacetimeBasesSum IS
			  select part_no, sum(nvl(tsl_override_qty,0)) qty
			  	   from tmp_amd_location_part_override t, amd_spare_networks asn
				   where t.loc_sid = asn.loc_sid
				   and t.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.action_code != Amd_Defaults.DELETE_ACTION
				   and ( loc_type in ('MOB', 'FSL', 'UAB', 'COD')
				   	     or
						 loc_id in (Amd_Defaults.AMD_BASC_LOC_ID, Amd_Defaults.AMD_UK_LOC_ID,
                                    amd_defaults.AMD_AUS_LOC_ID )
					   )
				   and asn.spo_location is not null
                   and part_no is not null
				   group by part_no ;
		
		cursor cursor_wartimeRspSum is
			   select part_no, sum(nvl(rsp_level,0)) qty
			   from amd_rsp_sum
               where part_no is not null
			   group by part_no ;
	
		cursor cursor_peacetimeBO_Spo_Sum is
			   select spo_prime_part_no,  qty
			   from amd_backorder_spo_sum
               where spo_prime_part_no is not null
			   order by spo_prime_part_no ;
			   
				  -- get the whole list and the sum to spo prime
		cursor cursor_peacetimeSpoInv IS
			  select spo_prime_part_no part_no,
			  		 sum(nvl(spo_total_inventory,0)) qty
					  from amd_sent_to_a2a asta, amd_national_stock_items ansi
					  where asta.part_no = ansi.prime_part_no
					  and asta.action_code != Amd_Defaults.DELETE_ACTION
					  and ansi.action_code != Amd_Defaults.DELETE_ACTION
                      and spo_prime_part_no is not null
                      and amd_utils.isPartRepairableYorN(spo_prime_part_no) = 'Y'
					  group by spo_prime_part_no ;
	
		type partno_sum is table of number index by amd_spare_parts.part_no%type  ;
		-- arrays where index is nsi_sid, and the values are the sums
		partNoCandidates_sum partNo_sum ;
		partNoBases_sum partNo_sum ;
		partNoSpoInv_sum partNo_sum ;
		wareHouseLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE ;
		basesTsl_Rsp_Backorder_sum number ;
		sumOfSpoTotalInv number ;
		AtlantaWarehouseQty number ;
		returnCode NUMBER ;
		cur_cnt NUMBER := 0 ;
		baseSum_cnt NUMBER := 0 ;
		spoInv_cnt NUMBER := 0 ;
		rsp_cnt number := 0 ;
		spoSum_cnt number := 0 ;
        curStep number := 0 ;
			-- Calculation WareHouse TSLs
            procedure loadPeaceTimeBasesSum is
            begin
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 480,
        				pKey1 => 'loadPeaceTimeBasesSum',
        				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                        
			    -- load partNoBases_sum array where each partNo index has the sum for the bases
                open cursor_peacetimeBasesSum ;
                fetch cursor_peacetimeBasesSum bulk collect into partSumRecs ;
                close cursor_peacetimeBasesSum ;
                
                if partSumRecs.first is not null then
                    for indx in partSumRecs.first .. partSumRecs.last LOOP
                        partNoBases_sum(partSumRecs(indx).part_no) := partSumRecs(indx).qty ;
                        baseSum_cnt := baseSum_cnt + 1 ;
                    end loop ;
                end if ;                    
                
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 490,
        				pKey1 => 'loadPeaceTimeBasesSum',
        				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		    exception when others then
			    errorMsg(pSqlfunction => 'loadPeaceTimeBasesSum',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 500) ;
				   raise ;
            end loadPeaceTimeBasesSum ;
            
            procedure loadWarTimeRspSum is 
            begin
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 510,
        				pKey1 => 'loadWarTimeRspSum',
        				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

                open cursor_wartimeRspSum ;
                fetch cursor_wartimeRspSum bulk collect into partSumRecs ;
                close cursor_wartimeRspSum ;
                
                if partSumRecs.first is not null then                         
                    for indx in partSumRecs.first .. partSumRecs.last loop
                        begin
                             partNoBases_sum(partSumRecs(indx).part_no) := partNoBases_sum(partSumRecs(indx).part_no) + partSumRecs(indx).qty ;
                        exception when standard.no_data_found then
                             partNoBases_sum(partSumRecs(indx).part_no) := partSumRecs(indx).qty ;
                        end ;
                        rsp_cnt := rsp_cnt + 1 ;
                    end loop ;
                end if ;                    
                
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 520,
        				pKey1 => 'loadWarTimeRspSum',
        				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		    EXCEPTION WHEN OTHERS THEN
			    ErrorMsg(pSqlfunction => 'loadWarTimeRspSum', pTableName => 'tmp_amd_location_part_override',
				   pError_location => 530) ;
				   raise ;
            end loadWarTimeRspSum ;
	
            procedure loadPeaceTimeBO_Spo_Sum is 
            begin
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 540,
    				pKey1 => 'loadPeaceTimeBO_Spo_Sum',
    				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                    
                open cursor_peacetimeBO_Spo_Sum ;
                fetch cursor_peacetimeBO_Spo_Sum bulk collect into partSumRecs ;
                close cursor_peacetimeBO_Spo_Sum ;
                
                if partSumRecs.first is not null then 
                    for indx in partSumRecs.first .. partSumRecs.last loop
                        begin
                             partNoBases_sum(partSumRecs(indx).part_no) := partNoBases_sum(partSumRecs(indx).part_no) + partSumRecs(indx).qty ;
                        exception when standard.no_data_found then
                             partNoBases_sum(partSumRecs(indx).part_no) := partSumRecs(indx).qty ;
                        end ;
                        spoSum_cnt := spoSum_cnt + 1 ;
                    end loop ;
                end if ;                    
                
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 550,
        				pKey1 => 'loadPeaceTimeBO_Spo_Sum',
        				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		    exception when others then
			    errorMsg(pSqlfunction => 'loadPeaceTimeBO_Spo_Sum',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 560) ;
				   raise ;
	        end loadPeaceTimeBO_Spo_Sum ;
            
            procedure loadPeaceTimeSpoInv is 
                lineNo number := 0 ;
                part_no amd_spare_parts.part_no%type ;
            begin
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 570,
        				pKey1 => 'loadPeaceTimeSpoInv',
        				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    			 -- load partNoSpoInv_sum array where each partNo index has the total_spo_inventory

                open cursor_peacetimeSpoInv ;
                fetch cursor_peacetimeSpoInv bulk collect into partSumRecs ;
                close cursor_peacetimeSpoInv ;
                
                if partSumRecs.first is not null then                  
                    for indx in partSumRecs.first .. partSumRecs.last loop
                        part_no := partSumRecs(indx).part_no ;
                        if amd_utils.ISNUMBER(partSumRecs(indx).qty) then
                            lineNo := 1; partNoSpoInv_sum(partSumRecs(indx).part_no) := partSumRecs(indx).qty ;
                            lineNo := 2 ;spoInv_cnt := spoInv_cnt + 1 ;
                        else
                            lineNo := 3;
                            writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 580,
                                    pKey1 => 'loadPeaceTimeSpoInv',
                                    pKey2 => 'partSumRecs(indx).part_no=' || partSumRecs(indx).part_no,
                                    pKey3 => 'qty not numeric') ;                        
                        end if ;
                    end loop ;
                end if ;                    
                
                lineNo := 4 ;
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 590,
        				pKey1 => 'loadPeaceTimeSpoInv',
        				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		    exception when others then
			    errorMsg(pSqlfunction => 'loadPeaceTimeSpoInv', pTableName => 'tmp_amd_location_part_override',
				   pError_location => 600,pKey1 => to_char(lineNo),pKey2 => part_no) ;
				   raise ;
            end loadPeaceTimeSpoInv ;
            
            procedure loadWareHouseParts is
            begin
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 610,
        				pKey1 => 'loadWareHouseParts',
        				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    	--		wareHouseLocSid := amd_utils.GetLocSid(amd_defaults.AMD_WAREHOUSE_LOCID) ;
	
    			-- cycle thru each of the zero candidates
    			-- line up the partNo and do the necessary calculation.
    			-- per each partNo
    			-- 	   total_spo_inventory minus bases sum
    			-- 	   if result negative, make result zero
        
                open cursor_warehouse_parts ;
                fetch cursor_warehouse_parts bulk collect into whseRecs ;
                close cursor_warehouse_parts ;
                
                if whseRecs.first is not null then
                    for indx in whseRecs.first .. whseRecs.last loop
                        begin
                            begin
                                 basesTsl_Rsp_Backorder_sum := partNoBases_sum(whseRecs(indx).part_no) ;
                            exception when no_data_found then
                                 basesTsl_Rsp_Backorder_sum := 0 ;
                            end ;
            
                            begin
                                 sumOfSpoTotalInv := partNoSpoInv_sum(whseRecs(indx).part_no) ;
                            exception when no_data_found then
                                 sumOfSpoTotalInv := 0 ;
                            end ;
            
                            AtlantaWarehouseQty := sumOfSpoTotalInv - basesTsl_Rsp_Backorder_sum ;
                            if (AtlantaWarehouseQty < 0) then
                               AtlantaWarehouseQty := 0 ;
                            END IF ;
                            insert into tmp_amd_location_part_override
                                (
                                  part_no,
                                  loc_sid,
                                  tsl_override_qty,
                                  tsl_override_user,
                                  action_code,
                                  last_update_dt
                                )
                                values
                                (
                                  whseRecs(indx).part_no,
                                  whseRecs(indx).loc_sid,
                                  AtlantaWarehouseQty,
                                  null,
                                  Amd_Defaults.INSERT_ACTION,
                                  sysdate
                                ) ;
                               /*
                                UPDATE tmp_amd_location_part_override
                                    SET tsl_override_AtlantaWarehouseQty = AtlantaWarehouseQty
                                    WHERE part_no = rec.part_no
                                    AND loc_sid = wareHouseLocSid ;
                                */
                        exception when others then
                            errorMsg(pSqlfunction => 'LoadWhse',pTableName => 'tmp_amd_location_part_override',
                           pError_location => 620, pKey1 => 'partNo: ' || whseRecs(indx).part_no) ;
                           raise ;
                        end ;
                        cur_cnt := cur_cnt + 1 ;
                    end loop ;
                end if ;                    
        		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 630,
        				pKey1 => 'loadWareHouseParts',
        				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                commit ;                        
		    exception when others then
			    errorMsg(pSqlfunction => 'loadWareHouseParts',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 640) ;
				   raise ;
            end loadWareHouseParts ;
            
            
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 650,
				pKey1 => 'LoadWhse',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
            
		begin
    
            for i in startStep..endStep loop
                curStep := i ;            
                case i      
                    when 1 then loadPeaceTimeBasesSum ;            
                    when 2 then loadWarTimeRspSum;                    
                    when 3 then loadPeaceTimeBO_Spo_Sum ;            
                    when 4 then loadPeaceTimeSpoInv ;	
    	            when 5 then loadWareHouseParts ;
                end case ;
            end loop ;
	
		exception when others then
            errorMsg(pSqlfunction => 'LoadWhse',pTableName => 'tmp_amd_location_part_override',
                pError_location => 660) ;
            raise ;
		end ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 670,
				pKey1 => 'LoadWhse',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || to_char(cur_cnt),
				pKey4 => 'baseSum_cnt=' || to_char(baseSum_cnt),
				pData => 'spoInv_cnt=' || to_char(spoInv_cnt) || ' rsp_cnt=' || to_char(rsp_cnt) || ' spoSum_cnt=' || to_char(spoSum_cnt)) ;
		commit ;
	exception when others then
		errorMsg(pSqlfunction 	  	  => 'LoadWhse',pTableName => 'tmp_amd_location_part_override',
	       pError_location => 680,
           pKey1 => 'curStep=' || curStep,
           pkey2 => 'cur_cnt=' || to_char(cur_cnt),
           pKey3 => 'baseSum_cnt=' || to_char(baseSum_cnt),
           pKey4 => 'spoInv_cnt=' || to_char(spoInv_cnt) ) ;
	   raise ;
	end loadWhse ;
	
	
	function getFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE IS
		cursor cur( pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE ) IS
			select apl.*
				from amd_planner_logons apl, amd_planners ap, amd_national_stock_items ansi
				where ansi.nsi_sid = pNsiSid
				and amd_Preferred_Pkg.GetPreferredValue(ansi.planner_code_cleaned, ansi.planner_code) = ap.planner_code
				and ap.planner_code = apl.planner_code
				and ap.action_code != Amd_Defaults.DELETE_ACTION
				and apl.action_code != Amd_Defaults.DELETE_ACTION
				order by apl.planner_code, data_source, logon_id ;
		 retLogonId amd_planner_logons%rowtype := null ;
	begin
		 if not cur%isopen
		 then
		 	open cur(pNsiSid) ;
		 END IF ;
		 fetch cur into retLogonId ;
		 if cur%notfound then
		 	retLogonId.logon_id := Amd_Defaults.GetLogonId(amd_utils.GETNSN(amd_utils.GETPARTNO(pNsiSid))) ;
		 end if ;
		 close cur ;
		 return retLogonId.logon_id ;
	exception when others then
		errorMsg(pSqlfunction => 'GetFirstLogonIdForPart',pTableName => 'amd_planner_logons',
	   pError_location => 690) ;
	   raise ;
	end getFirstLogonIdForPart ;
	
	procedure loadOverrideUsers IS
        type overrideUserRec is record (
            part_no tmp_amd_location_part_override.part_no%type,
            nsi_sid amd_national_stock_items.nsi_sid%type,
            nsn amd_national_stock_items.nsn%type
        ) ;
        type overrideUserTab is table of overrideUserRec ;
        overrideUserRecs overrideUserTab  ;
        
		cursor overrideUserscur is
			 select part_no, nsi_sid, nsn
			 from tmp_amd_location_part_override talpo, amd_national_stock_items ansi
			 where talpo.part_no = ansi.prime_part_no and
			 	   talpo.action_code != Amd_Defaults.DELETE_ACTION and
			 	   ansi.action_code != Amd_Defaults.DELETE_ACTION
			 order by nsi_sid;
		lastNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE := -9993 ;
		-- TYPE partNo_logonId_tab IS TABLE OF amd_planner_logons.logon_id%TYPE INDEX BY amd_spare_parts.part_no%TYPE  ;
		-- partNo_logonId partNo_logonId_tab ;
		-- rowPartNo amd_spare_parts.part_no%TYPE  ;
		-- defaultUser amd_location_part_override.tsl_override_user%TYPE := Amd_Defaults.GetParamValue('override_user_default');
		tslOverrideUser AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE ;
		returnCode NUMBER ;
		cur_cnt NUMBER := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 700,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
         open overrideUserscur ;
         fetch overrideUserscur bulk collect into overrideUserRecs ;
         close overrideUserscur ;
         
         if overrideUserRecs.first is not null then			
             for indx in overrideUserRecs.first .. overrideUserRecs.last loop
                begin
                     if (lastNsiSid != overrideUserRecs(indx).nsi_sid) then
                        -- partNo_logonId(rec.part_no) := nvl(GetFirstLogonIdForPart(rec.nsi_sid), amd_defaults.GetLogonId(rec.nsn) ) ;
                        tslOverrideUser := NVL( GetFirstLogonIdForPart(overrideUserRecs(indx).nsi_sid), Amd_Defaults.GetLogonId(overrideUserRecs(indx).nsn) ) ;
                        update tmp_amd_location_part_override
                           set 	tsl_override_user = tslOverrideUser
                           where	part_no = overrideUserRecs(indx).part_no ;
                     end if ;
                     lastNsiSid := overrideUserRecs(indx).nsi_sid ;
                exception when others then
                        errorMsg(pSqlfunction => 'LoadOverrideUsers',pTableName => 'tmp_amd_location_part_override',
                       pError_location => 710,pKey1	=> 'nsiSid: ' || overrideUserRecs(indx).nsi_sid,pKey2 => 'partNo: ' || overrideUserRecs(indx).part_no) ;
                       raise ;
                end ;
                cur_cnt := cur_cnt + 1 ;
             end loop ;
        end if ;             
         
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 720,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || to_char(cur_cnt)) ;
		commit ;
	exception when others then
        errorMsg(pSqlfunction => 'LoadOverrideUsers',pTableName => 'tmp_amd_location_part_override',
            pError_location => 730, pKey1 => 'cur_cnt=' || to_char(cur_cnt) ) ;
        raise ;
	end loadOverrideUsers ;
	
	procedure processTsl(tsl IN tslCur) IS
		tslOverrideUser TMP_A2A_LOC_PART_OVERRIDE.OVERRIDE_USER%TYPE ;
		delete_cnt number := 0 ;
		update_cnt number := 0 ;
		insert_cnt number := 0 ;
		rec_cnt number := 0 ;
		rec tslRec ;
		tslRecs tslTab ;		
		procedure countTran is
		begin
			 if rec.action_code = amd_defaults.INSERT_ACTION then
			 	insert_cnt := insert_cnt + 1 ;
			elsif rec.action_code = amd_defaults.UPDATE_ACTION then
				update_cnt := update_cnt + 1 ;
			else
				delete_cnt := delete_cnt + 1 ;
			end if ;
		end countTran ;
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 740,
				pKey1 => 'processTsl',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
         fetch tsl bulk collect into tslRecs ;
         close tsl ;                
	
         if tslRecs.first is not null then
             for indx in tslRecs.first .. tslRecs.last
             loop
                 rec_cnt := rec_cnt + 1 ;
                 
                 begin
                    tslOverrideUser := NVL(GetFirstLogonIdForPart(tslRecs(indx).nsi_sid), Amd_Defaults.GetLogonId(tslRecs(indx).nsn) ) ;
                    if insertedTmpA2ALPO (
                              tslRecs(indx).spo_prime_part_no,
                              tslRecs(indx).spo_location,
                              OVERRIDE_TYPE,
                              tslRecs(indx).override_quantity,
                              OVERRIDE_REASON,
                              tslOverrideUser,
                              sysdate,
                              tslRecs(indx).action_code,
                              sysdate)	then
                        countTran ;
                    end if ;
                exception when others then
                    errorMsg(pSqlfunction => 'processTsl',pTableName => 'tmp_amd_location_part_override',
                       pError_location => 750,pKey1 => 'spo_prime_part: ' || tslRecs(indx).spo_prime_part_no,
                        pKey2 => 'action_code: ' || tslRecs(indx).action_code, pKey3 => 'spo_location: ' || tslRecs(indx).spo_location,
                       pKey4 => 'insert_cnt:' || to_char(insert_cnt) || ' delete_cnt:' || to_char(delete_cnt), 
                       pComments => 'update_cnt: ' || to_char(update_cnt) || ' rec_cnt=' || to_char(rec_cnt)) ;

                       raise ;
                end ;
    			 
             end loop ;
        end if ;             
		 
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 760,
				pKey1 => 'processTsl',
				pKey2 => 'rec_cnt=' || to_char(rec_cnt),
				pKey3 => 'insert_cnt=' || to_char(insert_cnt),
				pKey4 => 'delete_cnt=' || to_char(delete_cnt), 
				pData => 'update_cnt=' || to_char(update_cnt),
				pComments => 'processTsl ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    commit ;
	exception when others then
		errorMsg(pSqlfunction => 'processTsl',pTableName => 'tmp_a2a_loc_part_override',
	   	   pError_location => 770,pKey1 => 'rec_cnt=' || to_char(rec_cnt), pKey2 => 'insert_cnt=' || to_char(insert_cnt),
           pKey3 => 'delete_cnt=' || to_char(delete_cnt), pKey4 => 'update_cnt=' || to_char(update_cnt)) ;
	   	   raise ;
	end processTsl ;
	
	procedure loadZeroTslA2AByDate(pDoAllA2A in boolean, 
			  from_dt in date, to_dt in date, pSpolocation in varchar2) is
			
	begin
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 780,
				pKey1 => 'LoadZeroTslA2AByDate', 
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' ||  to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A) || ' pSpoLocation=' || pSpoLocation,
				pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		loadZeroTslA2A(pDoAllA2A, pSpoLocation, from_dt, to_dt) ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 790,
				pKey1 => 'LoadZeroTslA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	exception when others then
		errorMsg(pSqlfunction => 'loadZeroTslA2AByDate',pTableName => 'tmp_a2a_loc_part_override',
	   pError_location => 800) ;
	   raise ;
	end loadZeroTslA2AByDate ;
	
	procedure  loadZeroTslA2A(pDoAllA2A boolean, pSpoLocation varchar2,from_dt in date := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   IS
		
		tsl tslCur ;
		rc number ;
		
		procedure openTestData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 810,
	 		pKey1 => 'getTestData' ) ;
			commit ;

			   open tsl for
			   select distinct sent.spo_prime_part_no,
    			   sent.action_code action_code,
    			   sysdate,
    			   pSpoLocation spo_location,
    			   amd_utils.getNsn(sent.spo_prime_part_no) nsn,
    			   amd_utils.getNsiSidFromPartno(sent.spo_prime_part_no) nsi_sid,
    			   0 override_AtlantaWarehouseQty
			   from  amd_sent_to_a2a sent, amd_test_parts testParts
			   where sent.part_no = sent.spo_prime_part_no
               and sent.action_code <> amd_defaults.getDELETE_ACTION
			   and not exists (
					 select null 
					 from tmp_a2a_loc_part_override
					 where part_no = sent.spo_prime_part_no
					 and site_location = pSpoLocation
                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE) 
			   and sent.spo_prime_part_no = testParts.PART_NO ; 
		end openTestData ;
		
		procedure getAllData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 820,
	 		pKey1 => 'getAllData' ) ;
			commit ;

			   open tsl for
			   select distinct sent.spo_prime_part_no,
    			   sent.action_code action_code,
    			   sysdate,
    			   pSpoLocation spo_location,
    			   amd_utils.getNsn(spo_prime_part_no),
    			   amd_utils.getNsiSidFromPartNo(spo_prime_part_no) nsi_sid,
    			   0 override_AtlantaWarehouseQty
			   from  amd_sent_to_a2a sent
			   where  sent.part_no = sent.spo_prime_part_no
               and sent.action_code <> amd_defaults.getDELETE_ACTION
			   and not exists (
					 select null 
					 from tmp_a2a_loc_part_override
					 where part_no = sent.spo_prime_part_no
					 and site_location = pSpoLocation
                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE) ; 
                      
			   
		end getAllData ;
		
		procedure getDataByLastUpdateDt is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 830,
	 		pKey1 => 'getDataByLastUpdateDt' ) ;
			commit ;
			open tsl for
			   select distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   amd_utils.getNsn(sent.spo_prime_part_no) nsn,
			   amd_utils.getNsiSidFromPartNo(sent.spo_prime_part_no) nsi_sid,
			   0 override_AtlantaWarehouseQty
			   from  amd_sent_to_a2a sent
			   where sent.part_no = sent.spo_prime_part_no
			   and sent.action_code != Amd_Defaults.getDELETE_ACTION			   
			   and not exists (
					 select null 
					 from tmp_a2a_loc_part_override
					 where part_no = sent.spo_prime_part_no
					 and site_location = pSpoLocation
                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE) 
			   and  exists (select null
			   			    from amd_location_part_override
							where part_no = sent.spo_prime_part_no
							and (amd_utils.GetSpoLocation(loc_sid) = pSpoLocation 
								 or pSpoLocation in (Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_UAB_SPO_LOCATION, 
								 				 Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_COD_SPO_LOCATION) )
							and trunc(last_update_dt) between trunc(from_dt) and trunc(to_dt) ) ;  
		end getDataByLastUpdateDt ;
		
		procedure getDataByTranDtAndBatchTime is
		begin
				-- and then transaction_date >= amd_batch_jobs.start_time
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 840,
	 		pKey1 => 'getDataByTranDtAndBatchTime' ) ;
			commit ;
			   OPEN tsl FOR
				   SELECT distinct sent.spo_prime_part_no,
				   sent.action_code action_code,
				   sysdate,
				   pSpoLocation spo_location,
				   ansi.nsn,
				   ansi.nsi_sid,
				   0 override_AtlantaWarehouseQty
				   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, 
				      amd_sent_to_a2a sent, amd_spare_parts parts
				   where ansi.prime_part_no = sent.spo_prime_part_no
				   and sent.part_no = sent.spo_prime_part_no
				   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION
				   and parts.part_no = sent.spo_prime_part_no
				   and not exists (
						 select null 
						 from tmp_a2a_loc_part_override
						 where part_no = sent.spo_prime_part_no
						 and site_location = pspolocation
                         and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                           
				   and parts.action_code != amd_defaults.getDELETE_ACTION
				   and  exists (select null
				   			    from amd_location_part_override
								where part_no = sent.spo_prime_part_no
								and (amd_utils.GetSpoLocation(loc_sid) = pSpoLocation 
									 or pSpoLocation in (Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_UAB_SPO_LOCATION, 
									 				 Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_COD_SPO_LOCATION) )
								and (trunc(last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
                                    or trunc(sent.TRANSACTION_DATE) >= trunc(amd_batch_pkg.GETLASTSTARTTIME)) ) ;  
		end getDataByTranDtAndBatchTime ;		
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 850,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A),
				pKey4 => 'pSpoLocation=' || pSpoLocation,
				pData => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pComments => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY') 
					  || ' useTestData=' || amd_utils.boolean2Varchar2(useTestData) ) ;
	    COMMIT ;
		
		-- pDoAllA2A has the highest priority
		IF pDoAllA2A THEN
		   IF useTestData THEN
		   	  openTestData ;
			ELSE
			  getAllData ;
			END IF ;
		ELSE
			-- then by date range
			IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
						getDataByLastUpdateDt ;
			ELSIF useTestData THEN
				  openTestData ;
			ELSE
				getDataByTranDtAndBatchTime ;
			END IF ;
		END IF ;
		
		processTsl(tsl) ;
		
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 860,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pSpoLocation=' || pSpoLocation) ;
	    COMMIT ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	  	  => 'LoadZeroTslA2A',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 870) ;
		RAISE ;

	END LoadZeroTslA2A ;
	
    PROCEDURE LoadTmpAmdLocPartOverride( startStep in number := 1, endStep in number := 7) is
        curStep number := 0 ;	
    BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 880,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 Mta_Truncate_Table('tmp_amd_location_part_override','reuse storage');
         Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;      
         COMMIT ;
         for i in startStep..endStep loop
            curStep := i ;
             case i
                when 1 then LoadFslMob ;
                when 2 then LoadUk ;
                when 3 then LoadAUS ;
                when 4 then LoadBasc ;
                when 5 then LoadCAN ;
                when 6 then LoadWhse ;
                when 7 then LoadOverrideUsers ;
             end case ;
        end loop ;
         
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 890,
                pKey1 => 'LoadTmpAmdLocPartOverride',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        commit ;                 
    exception when others then
        ErrorMsg(
           pSqlfunction            => 'LoadTmpAmdLocPartOverride',
           pTableName              => 'tmp_amd_location_part_override',
           pError_location => 900,
           pKey1 => curStep) ;
        RAISE ;

    END LoadTmpAmdLocPartOverride;
    
    PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
    BEGIN
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 910,
                pKey1 => 'LoadZeroTslA2A',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pData => 'usesTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
                pComments => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
            -- do Inserts/Deletes only, i.e. not initial load
        commit ;
        loadZeroTslA2APartsWithNoTsls(doAllA2A => doAllA2A, useTestData => useTestData) ;
        loadZeroTslA2A4DelSpoPrimParts(doAllA2A => doAllA2A, useTestData => useTestData) ;
        loadRspZeroTslA2A(doAllA2A => doAllA2A, useTestData => useTestData) ;
        LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_COD_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
        LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_UAB_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
        loadZeroTslA2A( doAllA2A, amd_location_part_override_pkg.THE_WAREHOUSE, from_dt, to_dt, useTestData) ;
    
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 920,
                pKey1 => 'LoadZeroTslA2A',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'from_dt=' ||  TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pData =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
        ErrorMsg(
           pSqlfunction     => 'LoadZeroTslA2A',
       pTableName              => 'tmp_amd_location_part_override',
       pError_location => 930) ;
        RAISE ;

    END LoadZeroTslA2A ;
    
    PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
        returnCode NUMBER ;
        doAllA2A BOOLEAN := TRUE ;
        cnt NUMBER := 0 ;
        lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
        rc NUMBER ;
        dataByDate locPartOverrideCur ;
    BEGIN
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 940,
                pKey1 => 'loadA2AByDate',
                pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
                pKey3 => 'to_dt='  || to_char(to_dt,'MM/DD/YYYY'),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
         Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
         OPEN dataByDate FOR
              SELECT alpo.part_no,
                     spo_location AS site_location,
                    OVERRIDE_TYPE AS override_type,
                    tsl_override_qty AS override_quantity,
                    OVERRIDE_REASON AS override_reason,
                    tsl_override_user,
                    SYSDATE AS begin_date,
                    NULL AS end_date,
                    alpo.action_code AS action_code,
                    SYSDATE AS last_update_dt
             FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn
             WHERE alpo.loc_sid = asn.loc_sid
                    AND alpo.action_code != Amd_Defaults.DELETE_ACTION
                   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
                   AND alpo.part_no IN 
                          (SELECT DISTINCT spo_prime_part_no 
                        FROM AMD_SENT_TO_A2A 
                        WHERE action_code != Amd_Defaults.DELETE_ACTION) ;
         processLocPartOverride(dataByDate) ;
         -- Xzero LoadZeroTslA2A( doAllA2A, from_dt, to_dt ) ; 
    
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 950,
                pKey1 => 'loadA2AByDate',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
        ErrorMsg(
           pSqlfunction     => 'LoadA2AByDate',
       pTableName              => 'tmp_amd_location_part_override',
       pError_location => 960) ;
        RAISE ;

    END loadA2AByDate ;
    
    PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) IS
        cnt NUMBER := 0 ;
        lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
        rec locPartOverrideRec ;
        rc number ;
        locPartOverrideRecs locPartOverrideTab ;
    BEGIN
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 970,
                pKey1 => 'processLocPartOverride',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
         fetch locPartOverride bulk collect into locPartOverrideRecs ;
         close locPartOverride ;
         
         if locPartOverrideRecs.first is not null then       
            for indx in locPartOverrideRecs.first .. locPartOverrideRecs.last
             LOOP
                      lpo.part_no := locPartOverrideRecs(indx).part_no ;
                     lpo.site_location := locPartOverrideRecs(indx).site_location ;
                     lpo.override_type := locPartOverrideRecs(indx).override_type ;
                     lpo.override_quantity := locPartOverrideRecs(indx).override_quantity ;
                     lpo.override_reason := locPartOverrideRecs(indx).override_reason ;
                     lpo.override_user := locPartOverrideRecs(indx).tsl_override_user ;
                     lpo.begin_date := locPartOverrideRecs(indx).begin_date ;
                     lpo.end_date := locPartOverrideRecs(indx).end_date ;
                     lpo.action_code := locPartOverrideRecs(indx).action_code ;
                     lpo.last_update_dt := locPartOverrideRecs(indx).last_update_dt ;
                      IF insertedTmpA2ALPO(lpo) THEN
                          cnt := cnt + 1 ;
                     ELSE
                       Amd_Utils.debugMsg(pMsg => 'Part/site_location was not loaded to tmp_a2a_loc_part_override',
                             pPackage => 'amd_location_part_override_pkg.processLocPartOverride',
                          pLocation => 222,
                          pMsg2 =>locPartOverrideRecs(indx).part_no, 
                          pMsg4 => locPartOverrideRecs(indx).site_location) ;
                     END IF ;         
             END LOOP ;
         end if ;                  
         writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 980,
                pKey1 => 'processLocPartOverride',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                 pKey3 => 'cnt=' || cnt) ;
         COMMIT ;
    exception when others then
        ErrorMsg(pSqlfunction => 'processLocPartOverride',pTableName => 'tmp_a2a_loc_part_override',
               pError_location => 990, pKey1 => 'cnt=' || to_char(cnt)) ;
        RAISE ;
    END processLocPartOverride ;
    
    PROCEDURE LoadAllA2A( useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
        
        overrides locPartOverrideCur ;
        
        procedure getTestData is
        begin
              writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1000,
             pKey1 => 'getTestData' ) ;
            commit ;
             OPEN overrides FOR
                  SELECT alpo.part_no,
                         spo_location AS site_location,
                        OVERRIDE_TYPE AS override_type,
                        case
                            when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
                                 0
                            else
                                tsl_override_qty
                        end AS override_quantity,
                        OVERRIDE_REASON AS override_reason,
                        tsl_override_user,
                        SYSDATE AS begin_date,
                        NULL AS end_date,
                        case sent.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getDELETE_ACTION -- The part is not longer valid
                         else
                              case alpo.action_code
                                   when amd_defaults.getDELETE_ACTION then
                                         amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                                  else
                                        alpo.action_code
                             end
                        end AS action_code,
                        SYSDATE AS last_update_dt
                 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
                 WHERE alpo.loc_sid = asn.loc_sid
                       AND alpo.part_no = sent.part_no
                       and sent.SPO_PRIME_PART_NO is not null
                       and sent.PART_NO = sent.SPO_PRIME_PART_NO 
                       AND alpo.part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
                union
                select distinct rsp.part_no,
                rsp_location,
                override_type,
                case 
                     when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
                           0
                     when override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE and rsp_level > 0 then 
                           rsp_level - 1                           
                     else
                          rsp_level
                end override_quantity,
                OVERRIDE_REASON as override_reason,
                Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
                sysdate as begin_date,
                null as end_date,
                case sent.action_code
                     when amd_defaults.getDELETE_ACTION then
                           amd_defaults.getDELETE_ACTION -- The part is not longer valid
                     else
                          case rsp.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                             else
                                    rsp.action_code
                        end                    
                end AS action_code,
                sysdate as last_update_dt
                from amd_rsp_sum rsp, amd_sent_to_a2a sent, amd_spare_networks nwks
                where rsp.part_no = sent.part_no
                and sent.part_no = sent.spo_prime_part_no
                and sent.SPO_PRIME_PART_NO is not null
                and rsp.part_no in (select part_no from amd_test_parts)
                and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
                and nwks.mob is not null ;                            
        end getTestData ;
        
        procedure getDataByLastUpdateDt is
        begin
              writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1010,
             pKey1 => 'getDataByLastUpdateDt' ) ;
            commit ;
            OPEN overrides FOR
              SELECT alpo.part_no,
                     spo_location AS site_location,
                    OVERRIDE_TYPE AS override_type,
                    case
                        when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
                             0
                        else
                            tsl_override_qty
                    end AS override_quantity,
                    OVERRIDE_REASON AS override_reason,
                    tsl_override_user,
                    SYSDATE AS begin_date,
                    NULL AS end_date,
                    case sent.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getDELETE_ACTION -- The part is not longer valid
                         else
                              case alpo.action_code
                                   when amd_defaults.getDELETE_ACTION then
                                         amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                                  else
                                        alpo.action_code
                             end
                    end AS action_code,
                    SYSDATE AS last_update_dt
             FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
             WHERE alpo.loc_sid = asn.loc_sid
                   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
                   AND alpo.part_no = sent.part_no
                   and sent.SPO_PRIME_PART_NO is not null
                   and sent.part_no = sent.spo_prime_part_no 
            union
            select distinct rsp.part_no,
            rsp_location,
                override_type,
                case 
                     when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
                           0
                     when override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE and rsp_level > 0 then 
                           rsp_level - 1                           
                     else
                          rsp_level
                end override_quantity,
            OVERRIDE_REASON as override_reason,
            Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
            sysdate as begin_date,
            null as end_date,
            case sent.action_code
                 when amd_defaults.getDELETE_ACTION then
                       amd_defaults.getDELETE_ACTION -- The part is not longer valid
                 else
                      case rsp.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                         else
                                rsp.action_code
                    end                    
            end AS action_code,
            sysdate as last_update_dt
            from amd_rsp_sum rsp, amd_sent_to_a2a sent, amd_spare_networks nwks
            where trunc(rsp.last_update_dt) between trunc(from_dt) and trunc(to_dt) 
            and rsp.part_no = sent.part_no
            and sent.part_no = sent.spo_prime_part_no
            and sent.SPO_PRIME_PART_NO is not null                        
            and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
            and nwks.mob is not null ;
        end getDataByLastUpdateDt ;

        procedure getAllData is
        begin
              writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1020,
             pKey1 => 'getAllData' ) ;
            commit ;
            OPEN overrides FOR
              SELECT sent.spo_prime_part_no,
                     spo_location AS site_location,
                    OVERRIDE_TYPE AS override_type,
                    case
                        when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
                             0
                        else
                            tsl_override_qty
                    end AS override_quantity,
                    OVERRIDE_REASON AS override_reason,
                    tsl_override_user,
                    SYSDATE AS begin_date,
                    NULL AS end_date,
                    case sent.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getDELETE_ACTION -- The part is not longer valid
                         else
                              case alpo.action_code
                                   when amd_defaults.getDELETE_ACTION then
                                         amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                                  else
                                        alpo.action_code
                             end
                    end AS action_code,
                    SYSDATE AS last_update_dt
             FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
             WHERE alpo.loc_sid = asn.loc_sid
                    AND alpo.part_no = sent.part_no 
                    and sent.SPO_PRIME_PART_NO is not null
                   and sent.spo_prime_part_no = sent.part_no 
            union
            select distinct sent.spo_prime_part_no,
            rsp_location,
                override_type,
                case 
                     when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
                           0
                     when override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE and rsp_level > 0 then
                           rsp_level - 1                           
                     else
                          rsp_level
                end override_quantity,
            OVERRIDE_REASON as override_reason,
            Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
            sysdate as begin_date,
            null as end_date,
            case sent.action_code
                 when amd_defaults.getDELETE_ACTION then
                       amd_defaults.getDELETE_ACTION -- The part is not longer valid
                 else
                      case rsp.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                         else
                                rsp.action_code
                    end                    
            end AS action_code,
            sysdate as last_update_dt
            from amd_rsp_sum rsp, 
            amd_sent_to_a2a sent,
            amd_spare_networks nwks
            where  rsp.part_no = sent.part_no
            and sent.spo_prime_part_no = sent.part_no 
            and sent.SPO_PRIME_PART_NO is not null
            and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
            and nwks.mob is not null ;
        end getAllData ;

    BEGIN
         writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1030,
                 pKey1 => 'LoadAllA2A',
                pKey2 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
                pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey4 => 'to_dt='  || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
         Mta_Truncate_Table('tmp_a2a_loc_part_override','reuse storage');
         a2a_pkg.setSendAllData(true) ;
         IF useTestData THEN
            getTestData ;
        ELSE
            IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
                getDataByLastUpdateDt ;
            ELSE
                 getAllData ; 
            END IF ;
        END IF ;

        processLocPartOverride(overrides) ;

        -- Xzero loadZeroTslA2A(doAllA2A => TRUE, from_dt => from_dt, to_dt => to_dt, useTestData => useTestData) ;
        
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1040,
                 pKey1 => 'LoadAllA2A',
                pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pData => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(
           pSqlfunction             => 'LoadAllA2A',
           pTableName              => 'tmp_a2a_loc_part_override',
           pError_location => 1050,
             pKey1              => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
           pKey2              => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
           pKey3                => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData)) ;
        RAISE ;
    END LoadAllA2A ;
    
    PROCEDURE LoadInitial IS
         returnCode NUMBER ;
    BEGIN
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1060,
                 pKey1 => 'LoadInitial',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
         
         LoadTmpAmdLocPartOverride ;
          Mta_Truncate_Table('amd_location_part_override','reuse storage');
         COMMIT ;
         INSERT INTO AMD_LOCATION_PART_OVERRIDE
             SELECT * FROM TMP_AMD_LOCATION_PART_OVERRIDE where tsl_override_qty <> 0 ; -- Xzero
         COMMIT ;
         LoadAllA2A ;
         dbms_output.put_line('LoadInitial ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'LoadInitial', pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1070 ) ;
        RAISE ;
    END LoadInitial ;
    
    PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
              tsl tslCur ;
              
              procedure getTestData is 
              begin
                  writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1080,
                 pKey1 => 'getTestData' ) ;
                commit ;
               OPEN tsl FOR
                SELECT spo_prime_part_no,
                sent.action_code action_code, 
                transaction_date, 
                loc_id spo_location,
                items.nsn,
                nsi_sid,
                0 override_quantity 
                FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items, 
                       ( 
                       SELECT loc_id FROM AMD_SPARE_NETWORKS n 
                       WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
                       OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
                                          amd_location_part_leadtime_pkg.UK_LOCATION, amd_defaults.AMD_AUS_LOC_ID ) 
                       ) spo_locations, amd_test_parts testParts 
                where sent.part_no not in (select distinct part_no from amd_location_part_override where action_code <> 'D')
                and not exists (
                     select null 
                     from tmp_a2a_loc_part_override
                     where part_no = spo_prime_part_no
                     and site_location = spo_locations.loc_id
                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                       
                AND sent.part_no = testParts.PART_NO
                and sent.part_no = sent.spo_prime_part_no
                AND spo_prime_part_no = items.prime_part_no 
                and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                                   from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;                
              end getTestData ;
              
              procedure getAllData is
              begin
                  writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1090,
                 pKey1 => 'getAllData' ) ;
                commit ;
                   OPEN tsl FOR
                SELECT spo_prime_part_no,
                sent.action_code action_code, 
                transaction_date, 
                loc_id spo_location,
                nsn,
                nsi_sid,
                0 override_quantity 
                FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
                       ( 
                       SELECT loc_id FROM AMD_SPARE_NETWORKS n 
                       WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
                       OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
                                          amd_location_part_leadtime_pkg.UK_LOCATION, amd_defaults.AMD_AUS_LOC_ID ) 
                       ) spo_locations 
                where part_no not in (select distinct part_no from amd_location_part_override where action_code <> 'D')
                and not exists (
                     select null 
                     from tmp_a2a_loc_part_override
                     where part_no = spo_prime_part_no
                     and site_location = spo_locations.loc_id
                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                       
                and sent.part_no = sent.spo_prime_part_no
                AND spo_prime_part_no = items.prime_part_no 
                and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                     from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;                 
              end getAllData ;
              
              procedure getDataByTranDtAndBatchTime is
              begin
                  writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1100,
                 pKey1 => 'getDataByTranDtAndBatchTime' ) ;
                commit ;
                
                 OPEN tsl FOR
                    SELECT spo_prime_part_no,
                    sent.action_code action_code, 
                    transaction_date, 
                    loc_id spo_location,
                    nsn,
                    nsi_sid,
                    0 override_quantity 
                    FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
                           ( 
                           SELECT loc_id FROM AMD_SPARE_NETWORKS n 
                           WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
                           OR loc_id IN ('EY1746', 'EY8780') 
                           ) spo_locations 
                    WHERE part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D') 
                    AND not exists (
                         select null 
                         from tmp_a2a_loc_part_override
                         where part_no = spo_prime_part_no
                         and site_location = spo_locations.loc_id
                         and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                           
                    AND spo_prime_part_no = items.prime_part_no
                    and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no)
                    and sent.part_no = sent.spo_prime_part_no
                    and sent.ACTION_CODE <> amd_defaults.getDELETE_ACTION 
                    AND (TRUNC(transaction_date) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) 
                    or trunc(last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime) ) ;
              end getDataByTranDtAndBatchTime ;
              
    BEGIN
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1110,
                 pKey1 => 'loadZeroTslA2APartsWithNoTsls',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        COMMIT ;
        IF doAllA2A THEN
           IF useTestData THEN
                  getTestData ;
           ELSE
                  getAllData ;
           END IF ;
        ELSE
            IF useTestData THEN
               getTestData ;
            ELSE
                getDataByTranDtAndBatchTime ;
            END IF ;
        END IF ;
        
            
        processTsl(tsl) ;
    
        writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 1120,
                 pKey1 => 'loadZeroTslA2APartsWithNoTsls',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        COMMIT ;
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'loadZeroTslA2APartsWithNoTsls',pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1130 ) ;
        RAISE ;
    END loadZeroTslA2APartsWithNoTsls ;
    
    procedure sendZeroTslsForSpoPrimePart(spo_prime_part_no in amd_sent_to_a2a.part_no%type) is
        rspTsl tslCur ;
        nsn amd_spare_parts.nsn%type := amd_utils.getNsn(spo_prime_part_no) ;
        nsi_sid amd_nsi_parts.nsi_sid%type := amd_utils.getNsiSidFromPartNo(spo_prime_part_no) ;
        spoPrimePartNo amd_sent_to_a2a.SPO_PRIME_PART_NO%type := spo_prime_part_no ;
        
        procedure getAllBases is
        begin
            -- skip any that already have deletes with a 0 a2a tran in tmp_a2a_loc_part_override
            open rspTsl for
                SELECT spoPrimePartNo, 
                       Amd_Defaults.getDELETE_ACTION action_code , 
                       SYSDATE, 
                        rsp_location,
                        nsn,
                        nsi_sid,
                        0 override_quantity   
                FROM (select distinct mob || '_RSP' rsp_location from amd_spare_networks where mob is not null) bases
                where not exists (SELECT null 
                                  FROM TMP_A2A_LOC_PART_OVERRIDE
                                  WHERE part_no = spoPrimePartNo
                                     AND site_location = rsp_location
                                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE                                      
                                     and override_quantity = 0
                                     and action_code = amd_defaults.getDELETE_ACTION)
                union
                SELECT spoPrimePartNo, 
                       Amd_Defaults.getDELETE_ACTION action_code , 
                       SYSDATE, 
                        spo_location,
                        nsn,
                        nsi_sid,
                        0 override_quantity
                from (select distinct spo_location, loc_sid from amd_spare_networks where spo_location is not null) bases   
                where not exists (SELECT null 
                                  FROM TMP_A2A_LOC_PART_OVERRIDE
                                  WHERE part_no = spoPrimePartNo
                                     AND site_location = spo_location
                                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE                                     
                                     and override_quantity = 0
                                     and action_code = amd_defaults.getDELETE_ACTION) ;
        end getAllBases ;
        
        procedure getAllBasesNotSent is
        begin
            open rspTsl for
                SELECT spoPrimePartNo, 
                       Amd_Defaults.getINSERT_ACTION action_code , 
                       SYSDATE, 
                        rsp_location,
                        nsn,
                        nsi_sid,
                        0 override_quantity   
                FROM (select distinct mob || '_RSP' rsp_location from amd_spare_networks where mob is not null) bases
                where
                -- get only the spoPrimePartNo/site_location that do not have an active non-zero quantity
                not exists (select null 
                                  from tmp_a2a_loc_part_override
                                  where part_no = spoprimepartno
                                     AND site_location = rsp_location
                                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE                                      
                                     and action_code <> amd_defaults.getDELETE_ACTION
                                     and (override_quantity is not null and override_quantity > 0) )
                -- and get only the spoPrimePartNo/rsp_locations that do not have an active rsp_level                                       
                and not exists (select null
                                from amd_rsp_sum
                                where part_no = spoPrimePartNo
                                and rsp_location = bases.rsp_location
                                and action_code <> amd_defaults.getDELETE_ACTION
                                and (rsp_level is not null and rsp_level > 0) )        
                union
                SELECT spoPrimePartNo, 
                       Amd_Defaults.getINSERT_ACTION action_code , 
                       SYSDATE, 
                        spo_location,
                        nsn,
                        nsi_sid,
                        0 override_quantity
                from (select distinct spo_location from amd_spare_networks where spo_location is not null) bases   
                where 
                -- get only the spoPrimePartNo/site_location that do not have an active non-zero quantity
                not exists (select null 
                                  from tmp_a2a_loc_part_override
                                  where part_no = spoprimepartno
                                     and site_location = spo_location
                                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE                                      
                                     and action_code <> amd_defaults.getDELETE_ACTION
                                     and (override_quantity is not null and override_quantity > 0) 
                                     )
                -- and get only the spoPrimePartNo/rsp_locations that do not have an active rsp_level                                       
                and not exists (select null
                                from amd_location_part_override ov,
                                amd_spare_networks net
                                where part_no = spoPrimePartNo
                                and net.SPO_LOCATION = bases.spo_location
                                and ov.loc_sid = net.loc_sid
                                and ov.action_code <> amd_defaults.getDELETE_ACTION
                                and (tsl_override_qty is not null and tsl_override_qty > 0) ) ;
        end getAllBasesNotSent ;
        
    begin
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1140,
                 pKey1 => 'sendZeroTslsForSpoPrimePart',
                pKey2 => 'spo_prime_part_no=' || spo_prime_part_no,
                pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        -- the part should exist in the amd_sent_to_a2a tables
        -- if it is not in the amd_sent_to_a2a_table skip this code
        if a2a_pkg.isPartSent(spo_prime_part_no) then
            
            if amd_utils.isSpoPrimePart(spo_prime_part_no) then
                -- the part is still a valid spo prime part no
                -- so just sent zeros for thoses bases  that are not in tmp_a2a_loc_part_override
                getAllBasesNotSent ;
            else
                -- the part is not a valid spo prime part any more 
                -- so make sure DELETES get sent with 0's for all the bases for this part
                getAllBases ;
            end if ;
        
            -- load all this data to tmp_a2a_loc_part_override
            processTsl(tsl => rspTsl) ;
                                      
        end if ;
        
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1150,
                 pKey1 => 'sendZeroTslsForSpoPrimePart',
                pKey2 => 'spo_prime_part_no=' || spo_prime_part_no,
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
    end sendZeroTslsForSpoPrimePart ;
    
    PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false ) IS 
              rspTsl tslCur ;
              
              procedure getTestData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1160,
                 pKey1 => 'getTestData' ) ;
                commit ;
               -- send all the test data and do NOT filter on the last_update_dt
               OPEN rspTsl FOR
                     SELECT DISTINCT spo_prime_part_no, 
                           Amd_Defaults.INSERT_ACTION action_code , 
                           SYSDATE, 
                           mob,
                           nsn,
                           nsi_sid,
                           0 override_quantity   
                    FROM 
                         (
                          SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity
                         from (SELECT  DISTINCT spo_prime_part_no
                                FROM AMD_SENT_TO_A2A 
                               where part_no = spo_prime_part_no 
                               and action_code <> amd_defaults.getDelete_ACTION) primes,
                         AMD_SPARE_NETWORKS net
                         where mob is not null
                         AND not exists (
                                 select null 
                                 from tmp_a2a_loc_part_override
                                 where part_no = spo_prime_part_no
                                 and site_location = mob || '_RSP'
                                 and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                                  
                         -- and get only the spoPrimePartNo/rsp_locations that do not have an active rsp_level
                         and not exists (select null
                                    from amd_rsp_sum
                                    where part_no = spo_prime_part_no
                                    and rsp_location = mob || '_RSP'
                                    and action_code <> amd_defaults.getDELETE_ACTION
                                    and (rsp_level is not null and rsp_level > 0) )                                                                     
                                  
                     )  tsl,
                     AMD_NATIONAL_STOCK_ITEMS items 
                     where spo_prime_part_no = items.prime_part_no
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no)                 
                     and spo_prime_part_no in (select part_no from amd_test_parts)
                     AND items.action_code <> amd_defaults.getDelete_ACTION
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;
              end getTestData ;

              procedure getAllData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1170,
                 pKey1 => 'getAllData' ) ;
                commit ;
               OPEN rspTsl FOR
                     SELECT DISTINCT spo_prime_part_no, 
                           tsl.action_code , 
                           SYSDATE, 
                           mob,
                           nsn,
                           nsi_sid,
                           0 override_quantity   
                    FROM 
                         (
                          SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.action_code
                         from (SELECT  DISTINCT spo_prime_part_no, action_code
                               FROM AMD_SENT_TO_A2A
                               where part_no = spo_prime_part_no) primes,
                              AMD_SPARE_NETWORKS net
                         where mob is not null
                         AND not exists (
                                 select null 
                                 from tmp_a2a_loc_part_override
                                 where part_no = spo_prime_part_no
                                 and site_location = mob || '_RSP'
                                 and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                                   
                         -- and get only the spoPrimePartNo/rsp_locations that do not have an active rsp_level
                         and not exists (select null
                                    from amd_rsp_sum
                                    where part_no = spo_prime_part_no
                                    and rsp_location = mob || '_RSP'
                                    and action_code <> amd_defaults.getDELETE_ACTION
                                    and (rsp_level is not null and rsp_level > 0) )                                                                     
                                  
                     )  tsl,
                     AMD_NATIONAL_STOCK_ITEMS items 
                     where spo_prime_part_no = items.prime_part_no
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                          from amd_national_stock_items where prime_part_no = spo_prime_part_no)                     
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                                                from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;                     
              end getAllData ;

              procedure getDataByLastUpdateDt is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1180,
                 pKey1 => 'getDataByLastUpdateDt' ) ;
                commit ;
                  -- send all data whose last_update_dt >= amd_batch_pkg.getLastStartTime - ie all the 
               -- data that has been processed by the diff for the lastest batch job  
                   OPEN rspTsl FOR
                     SELECT DISTINCT tsl.spo_prime_part_no, 
                           tsl.action_code action_code , 
                           SYSDATE, 
                           mob,
                           items.nsn,
                           nsi_sid,
                           0 override_quantity   
                    FROM 
                         (
                              SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.last_update_dt last_update_dt, primes.action_code action_code
                             from (SELECT  DISTINCT spo_prime_part_no, transaction_date last_update_dt, action_code
                                   FROM AMD_SENT_TO_A2A 
                                   where part_no = spo_prime_part_no 
                                   and action_code <> amd_defaults.getDELETE_ACTION) primes,
                             AMD_SPARE_NETWORKS net
                             where mob is not null
                             AND not exists (
                                     select null 
                                     from tmp_a2a_loc_part_override
                                     where part_no = spo_prime_part_no
                                     and site_location = mob || '_RSP'
                                     and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                                       
                            -- and get only the spoPrimePartNo/rsp_locations that do not have an active rsp_level
                            and not exists (select null
                                    from amd_rsp_sum
                                    where part_no = spo_prime_part_no
                                    and rsp_location = mob || '_RSP'
                                    and action_code <> amd_defaults.getDELETE_ACTION
                                    and (rsp_level is not null and rsp_level > 0) )                                                                     
                                  
                          )  tsl,
                          AMD_NATIONAL_STOCK_ITEMS items,
                         amd_spare_parts parts
                         where tsl.spo_prime_part_no = items.prime_part_no
                         and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                                                     from amd_national_stock_items where prime_part_no = tsl.spo_prime_part_no)
                          and tsl.spo_prime_part_no = parts.part_no
                         and items.action_code <> amd_defaults.getDELETE_ACTION
                         and parts.action_code <> amd_defaults.getDELETE_ACTION                    
                          and (trunc(tsl.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
                              or trunc(items.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
                             or trunc(parts.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
                              ) ;
              end getDataByLastUpdateDt ;
                                          
    BEGIN
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1190,
                 pKey1 => 'loadRspZeroTslA2A',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
       if useTestData then
             getTestData ;
       else
              if doAllA2A then
                 getAllData ;
           else
                  getDataByLastUpdateDt ;
            END IF ;
        end if ;
        
        processTsl(tsl => rspTsl) ;
        
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'loadRspZeroTslA2A',pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1200 ) ;
        RAISE ;
    END loadRspZeroTslA2A;
    
    PROCEDURE deleteRspTslA2A is 
              rspTsl tslCur ;
              
              procedure getPrimeChangedData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1210,
                 pKey1 => 'getTestData' ) ;
                commit ;
               -- send all the test data and do NOT filter on the last_update_dt
               OPEN rspTsl FOR
                     SELECT DISTINCT spo_prime_part_no, 
                           Amd_Defaults.getDELETE_ACTION action_code , 
                           SYSDATE, 
                           mob,
                           nsn,
                           nsi_sid,
                           0 override_quantity   
                    FROM 
                         (
                          SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity
                         from (SELECT  DISTINCT part_no spo_prime_part_no
                                FROM AMD_test_parts ) primes, 
                         AMD_SPARE_NETWORKS net
                         where mob is not null
                     )  tsl,
                     AMD_NATIONAL_STOCK_ITEMS items 
                     where spo_prime_part_no = items.prime_part_no
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no)                 
                     and spo_prime_part_no in (select part_no from amd_test_parts)
                     AND items.action_code <> amd_defaults.getDelete_ACTION
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;
              end getPrimeChangedData ;


                                          
    BEGIN
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1220,
                 pKey1 => 'deleteRspTslA2A',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
        getPrimeChangedData ;           
        processTsl(tsl => rspTsl) ;
        
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'deleteRspTslA2A',pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1230 ) ;
        RAISE ;
    END deleteRspTslA2A;
                         
    
    PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
              tsl tslCur ;
              
              procedure getTestData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1240,
                 pKey1 => 'getTestData' ) ;
                commit ;
                 OPEN tsl FOR
                     SELECT DISTINCT sent.spo_prime_part_no,
                         sent.action_code action_code,
                        sent.transaction_date, 
                        net.SPO_LOCATION spo_location, 
                        i.nsn,
                        i.nsi_sid,
                        0 override_AtlantaWarehouseQty
                    FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i,
                    amd_test_parts testParts 
                    WHERE o.action_code = Amd_Defaults.DELETE_ACTION
                    AND not exists (
                             select null 
                             from tmp_a2a_loc_part_override
                             where part_no = sent.spo_prime_part_no
                             and site_location = net.spo_location
                             and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                               
                    AND sent.spo_prime_part_no = testParts.PART_NO
                    and sent.spo_prime_part_no = sent.part_no 
                    AND o.loc_sid = net.LOC_SID
                    AND o.part_no = sent.spo_prime_part_no
                    AND o.part_no = i.PRIME_PART_NO ;
              end getTestData ;
              
              procedure getAllData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1250,
                 pKey1 => 'getAllData' ) ;
                commit ;
                 OPEN tsl FOR
                     SELECT DISTINCT sent.spo_prime_part_no,
                        sent.action_code action_code,
                        sent.transaction_date, 
                        net.SPO_LOCATION spo_location, 
                        i.nsn,
                        i.nsi_sid,
                        0 override_AtlantaWarehouseQty
                    FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
                    WHERE o.action_code = Amd_Defaults.DELETE_ACTION
                    AND not exists (
                             select null 
                             from tmp_a2a_loc_part_override
                             where part_no = sent.spo_prime_part_no
                             and site_location = net.spo_location 
                             and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                              
                    AND o.loc_sid = net.LOC_SID
                    AND o.part_no = sent.spo_prime_part_no
                    AND o.part_no = i.PRIME_PART_NO 
                    and sent.spo_prime_part_no = sent.part_no ; 
              end getAllData ;

              procedure getDataByTranDtAndBatchTime is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1260,
                 pKey1 => 'getDataByTranDtAndBatchTime' ) ;
                commit ;
                 OPEN tsl FOR
                     SELECT DISTINCT sent.spo_prime_part_no, 
                        sent.action_code action_code, 
                        sent.transaction_date, 
                        net.SPO_LOCATION spo_location, 
                        i.nsn,
                        i.nsi_sid,
                        0 override_AtlantaWarehouseQty
                    FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
                    WHERE o.action_code = Amd_Defaults.DELETE_ACTION
                    AND not exists (
                             select null 
                             from tmp_a2a_loc_part_override
                             where part_no = sent.spo_prime_part_no
                             and site_location = net.spo_location
                             and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                             
                    AND o.loc_sid = net.LOC_SID
                    AND o.part_no = sent.spo_prime_part_no
                    AND o.part_no = i.PRIME_PART_NO
                    and sent.spo_prime_part_no = sent.part_no 
                    AND (TRUNC(sent.TRANSACTION_DATE) >= TRUNC(Amd_Batch_Pkg.getLastStartTime)
                    or trunc(o.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
                    or trunc(i.LAST_UPDATE_DT) >= trunc(amd_batch_pkg.getLastStartTime) ) ; 
              end getDataByTranDtAndBatchTime ;
                            
    BEGIN
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1270,
                 pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'useTestData=' ||  Amd_Utils.boolean2Varchar2(useTestData),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
         
         IF useTestData THEN
             getTestData ;
        elsif doAllA2A THEN
             getAllData ;
        else
               getDataByTranDtAndBatchTime ;
        END IF ;
        
        processTsl(tsl) ;
    
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1280,
                 pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        COMMIT ;
    
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'loadZeroTslA2A4DelSpoPrimParts',pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1290 ) ;
        RAISE ;
    END loadZeroTslA2A4DelSpoPrimParts ;
    
    PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
              tsl tslCur ;
              
              procedure getTestData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1300,
                 pKey1 => 'getTestData' ) ;
                commit ;
             OPEN tsl FOR
                SELECT 
                    spo_prime_part_no,
                    spoPrimes.action_code,
                    spoPrimes.transaction_date,
                    spo_location,
                    items.nsn,
                    items.nsi_sid,
                    override_quantity
                FROM (
                    SELECT sent.spo_prime_part_no,
                        THE_WAREHOUSE spo_location,
                        SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
                        sent.action_code action_code,
                        SYSDATE transaction_date
                    FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
                    WHERE
                    sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
                    AND not exists (
                             select null 
                             from tmp_a2a_loc_part_override
                             where part_no = sent.spo_prime_part_no
                             and site_location = THE_WAREHOUSE
                             and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                               
                    AND spo_prime_part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
                    AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
                    AND sent.part_no = p.part_no
                    and sent.spo_prime_part_no = sent.part_no 
                    AND p.nsn = i.NSN
                    GROUP BY sent.spo_prime_part_no
                    ) spoPrimes, 
                    AMD_NATIONAL_STOCK_ITEMS items
                WHERE spo_prime_part_no = items.PRIME_PART_NO
                and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                     from amd_national_stock_items where prime_part_no = spo_prime_part_no)    ;
              end getTestData ;
              
              procedure getAllValidSpoData is
              begin
                  writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1310,
                 pKey1 => 'getAllValidSpoData' ) ;
                commit ;
                OPEN tsl FOR
                SELECT 
                    spo_prime_part_no,
                    spoPrimes.action_code,
                    spoPrimes.transaction_date,
                    spo_location,
                    items.nsn,
                    items.nsi_sid,
                    override_quantity
                FROM (
                    SELECT sent.spo_prime_part_no,
                        THE_WAREHOUSE spo_location,
                        SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
                        sent.action_code action_code,
                        SYSDATE transaction_date
                    FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
                    WHERE
                    sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION -- spo data is valid if  sent.action_code <> delete_action
                    AND not exists (
                             select null 
                             from tmp_a2a_loc_part_override
                             where part_no = sent.spo_prime_part_no
                             and site_location = THE_WAREHOUSE
                             and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE)                               
                    AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
                    AND sent.part_no = p.part_no
                    and sent.spo_prime_part_no = sent.part_no 
                    AND p.nsn = i.NSN
                    GROUP BY sent.spo_prime_part_no
                    ) spoPrimes, 
                    AMD_NATIONAL_STOCK_ITEMS items
                WHERE spo_prime_part_no = items.PRIME_PART_NO 
                and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                     from amd_national_stock_items where prime_part_no = spo_prime_part_no)    ;
              end getAllValidSpoData ;
                        
    BEGIN
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1320,
                 pKey1 => 'loadTslA2AWarehouseParts',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    
        IF useTestData THEN
           getTestData ;
         ELSE
           getAllValidSpoData ;
         END IF ;
          
         processTsl(tsl) ;
    
        writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1330,
                 pKey1 => 'loadTslA2AWarehouseParts',
                pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
                pKey3 =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'loadTslA2AWarehouseParts',pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1340 ) ;
        RAISE ;
    END loadTslA2AWarehouseParts ;
    
    FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 IS
    BEGIN
         IF isInTmpA2A(part_no, site_location) THEN
             RETURN 'Y' ;
         ELSE
             RETURN 'N' ;
         END IF ; 
    END isInTmpA2AYorN ;
    
    FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN IS
             thePartNo TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE ;
             rc NUMBER ;
    BEGIN
         SELECT part_no INTO thePartNo
         FROM TMP_A2A_LOC_PART_OVERRIDE
         WHERE part_no = isInTmpA2A.part_no
         AND site_location = isInTmpA2A.site_location
         and override_type = amd_location_part_override_pkg.OVERRIDE_TYPE ; 
         
         RETURN TRUE ;
    EXCEPTION
             WHEN standard.NO_DATA_FOUND THEN
                   RETURN FALSE ;
             WHEN OTHERS THEN
                    ErrorMsg(
                       pSqlfunction             => 'isInTmpA2A',
                   pTableName              => 'tmp_a2a_loc_part_override',
                   pError_location => 1350,
                   pKey1              => part_no,
                      pKey2              => site_location) ;
                   RAISE ;
    END isInTmpA2A ;
    -- added 11/7/05 dse
    FUNCTION getInsertCnt RETURN NUMBER IS 
    BEGIN
         RETURN insertCnt ;
    END getInsertCnt ;
    
    FUNCTION getUpdateCnt RETURN NUMBER IS
    BEGIN
         RETURN updateCnt ;
    END getUpdateCnt ;
    
    FUNCTION getDeleteCnt RETURN NUMBER IS
    BEGIN
         RETURN deleteCnt ;
    END getDeleteCnt ;
    
    FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 IS
    BEGIN
         RETURN OVERRIDE_TYPE ;
    END getOVERRIDE_TYPE ;
    
    FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 IS
    BEGIN
         RETURN OVERRIDE_REASON ;
    END getOVERRIDE_REASON ;
    
    FUNCTION getBULKLIMIT RETURN NUMBER IS
    BEGIN
         RETURN BULKLIMIT ;
    END getBULKLIMIT ;
    
    FUNCTION getCOMMITAFTER RETURN NUMBER IS
    BEGIN
         RETURN COMMITAFTER ;
    END getCOMMITAFTER ;
    
    FUNCTION getSUCCESS RETURN NUMBER IS
    BEGIN
         RETURN SUCCESS ;
    END getSUCCESS ;
    
    FUNCTION getFAILURE RETURN NUMBER IS
    BEGIN
         RETURN FAILURE ;
    END getFAILURE ;
    
    FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 IS
    BEGIN
         RETURN THE_WAREHOUSE ;
    END getTHE_WAREHOUSE ;

    procedure version is
    begin
         writeMsg(pTableName => 'amd_location_part_override_pkg', 
                 pError_location => 1360, pKey1 => 'amd_location_part_override_pkg', pKey2 => '$Revision:   1.91  $') ;
         dbms_output.put_line('amd_location_part_override_pkg: $Revision:   1.91  $') ;
    end version ;
    
    
    function isTmpA2AOkay return boolean is
             result varchar2(1) ;
    begin
        select 'Y' into result
        from dual
        where exists (select null 
                        from tmp_a2a_loc_part_override
                      where action_code <> amd_defaults.getDELETE_ACTION
                      group by site_location, override_type
                      having count(part_no) <> (select count(*) 
                                                   from amd_sent_to_a2a 
                                                where part_no = spo_prime_part_no 
                                                       and action_code <> amd_defaults.getDELETE_ACTION)
                                                ) ;
        return false ;
    exception when standard.no_data_found then
        return true ;    
    end isTmpA2AOkay ;
    
    function isTmpA2AOkayYorN return varchar2 is
    begin
         if isTmpA2AOkay then
             return 'Y' ;
         end if ;
         
         return 'N' ;
         
    end isTmpA2AOkayYorN ;
    
    procedure loadZeroRspTsls is
        
        cnt number := 0 ;
        
        cursor primes is
            select distinct part_no 
            from amd_location_part_override ov
            where ov.last_update_dt >= amd_batch_pkg.GETLASTSTARTTIME
            and ov.action_code <> 'D'
            union
            select distinct part_no 
            from amd_rsp_sum 
            where last_update_dt >= amd_batch_pkg.getLastStartTime 
            and action_code <> amd_defaults.getDELETE_ACTION ;
        
        begin
            writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1370,
                     pKey1 => 'loadZeroTsls',
                    pKey2 =>  'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                    
            
            for rec in primes loop
                amd_location_part_override_pkg.SENDZEROTSLSFORSPOPRIMEPART(rec.part_no) ;
                cnt := cnt + 1 ;
            end loop ;
            
            writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1380,
                     pKey1 => 'loadZeroTsls',
                    pKey2 =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                    pKey3 => 'cnt=' || to_char(cnt)) ;
            commit ;                    
         end loadZeroRspTsls ;
    
        procedure checkForDeletedSpoPrimeParts is
            cnt number ;
            cursor partsToDelete is
            select 
            amd_utils.GETSPOLOCATION(loc_sid) location,
            part_no,
            'TSL Fixed' override_type,
            tsl_override_qty quantity,
            'Fixed TSL Load' override_reason,
            tsl_override_user override_user,
            last_update_dt begin_date
            from amd_location_part_override
            where action_code <> amd_defaults.getDELETE_ACTION
            and part_no in (select spo_prime_part_no
                            from amd_sent_to_a2a
                            where part_no = spo_prime_part_no
                            and action_code = amd_defaults.getDELETE_ACTION)
            union
            select
            rsp_location location,
            part_no,
            'TSL Fixed' override_type,
            rsp_level quantity,
            'Fixed TSL Load' override_reason,
            amd_location_part_override_pkg.GETFIRSTLOGONIDFORPART(amd_utils.GETNSISIDFROMPARTNO(part_no)) override_user,
            last_update_dt begin_date
            from amd_rsp_sum
            where action_code <> amd_defaults.getDELETE_ACTION
            and part_no in (select spo_prime_part_no
                            from amd_sent_to_a2a
                            where part_no = spo_prime_part_no
                            and action_code = amd_defaults.getDELETE_ACTION) 
            union
            select                            
            spo_location,
            part_no,
            override_type,
            tsl_override_qty,
            'Fixed TSL Load' override_reason,
            tsl_override_user,
            last_update_dt begin_date
            from amd_locpart_overid_consumables
            where action_code <> amd_defaults.getDELETE_ACTION
            and part_no in (select spo_prime_part_no
                            from amd_sent_to_a2a
                            where part_no = spo_prime_part_no
                            and action_code = amd_defaults.getDELETE_ACTION) ; 
        begin
            writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1390,
                     pKey1 => 'checkForDeletedSpoPrimeParts',
                    pKey2 =>  'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                    
            for rec in partsToDelete loop
                if insertedTmpA2ALPO (
                  pPartNo => rec.part_no,
                  pBaseName => rec.location,
                  pOverrideType => rec.override_type,
                  pTslOverrideQty => rec.quantity,    
                  pOverrideReason => rec.override_reason,
                  pTslOverrideUser => rec.override_user,
                  pBeginDate => sysdate,
                  pActionCode => amd_defaults.DELETE_ACTION,
                  pLastUpdateDt => sysdate) then
                
                    update amd_location_part_override
                    set action_code = amd_defaults.DELETE_ACTION,
                    last_update_dt = sysdate
                    where part_no = rec.part_no
                    and action_code <> amd_defaults.DELETE_ACTION ;
                    
                    update amd_rsp_sum
                    set action_code = amd_defaults.DELETE_ACTION,
                    last_update_dt = sysdate
                    where part_no = rec.part_no
                    and action_code <> amd_defaults.DELETE_ACTION ;
                    
                    cnt := cnt + 1 ;
                            
                end if ;           
                
            end loop ;             
            writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1400,
                     pKey1 => 'checkForDeletedSpoPrimeParts',
                    pKey2 =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                    pKey3 => 'cnt=' || cnt) ;
        end checkForDeletedSpoPrimeParts ;

        function ignoreStLouisYorN return varchar2 is
        begin
            if ignoreStLouis then
                return 'Y' ;
            else
                return 'N' ;
            end if ;
        end ignoreStLouisYorN ;

        procedure loadRspTslA2A is
            overrides locPartOverrideCur ;
        begin
            delete from tmp_a2a_loc_part_override ov where ov.SITE_LOCATION like '%_RSP' ;
            commit ;
            
            open overrides for
                select distinct sent.spo_prime_part_no,
                rsp_location,
                override_type,
                case 
                     when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
                           0
                     when override_type <> amd_location_part_override_pkg.OVERRIDE_TYPE and rsp_level > 0 then
                           rsp_level - 1                           
                     else
                          rsp_level
                end override_quantity,
                OVERRIDE_REASON as override_reason,
                Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
                sysdate as begin_date,
                null as end_date,
                case sent.action_code
                     when amd_defaults.getDELETE_ACTION then
                           amd_defaults.getDELETE_ACTION -- The part is not longer valid
                     else
                          case rsp.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                             else
                                    rsp.action_code
                        end                    
                end AS action_code,
                sysdate as last_update_dt
                from amd_rsp_sum rsp, 
                amd_sent_to_a2a sent,
                amd_spare_networks nwks
                where  rsp.part_no = sent.part_no
                and sent.spo_prime_part_no = sent.part_no 
                and sent.SPO_PRIME_PART_NO is not null
                and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
                and nwks.mob is not null ;

            processLocPartOverride(overrides) ;            
            
            -- XZero loadRspZeroTslA2A(doAllA2A => true, useTestData => false) ;
            commit ;
            
        end loadRspTslA2A ;            

    
BEGIN
    
      <<getParams>>
      DECLARE
       param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
        
       function getIgnoreStLouis return boolean is
            ignoreStLouis varchar2(1) ;
        begin
            ignoreStLouis := trim(amd_defaults.getParamValue('ignoreStLouis')) ;
            if ignoreStLouis is null then
                return false ;
            else
                if ignoreStLouis = 'Y' then
                    return true ;
                else
                    return false ;
                end if ; 
            end if ;
        end getIgnoreStLouis ;
        
        
      begin
          
          BEGIN
             SELECT param_value INTO param FROM AMD_PARAM_CHANGES WHERE param_key = 'debugLocPartOverride' ;
             debug := (param = '1');
          EXCEPTION WHEN OTHERS THEN
             debug := false ;
          end ;
          
          Amd_Location_Part_Override_Pkg.ignoreStLouis := getIgnoreStLouis() ;
      END getParams ;

        
END Amd_Location_Part_Override_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG;

CREATE PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG FOR AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_WRITER_ROLE;


