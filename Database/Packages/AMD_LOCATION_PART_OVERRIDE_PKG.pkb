CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Location_Part_Override_Pkg AS

 /*
      $Author:   zf297a  $
	$Revision:   1.106.1
        $Date:   23 Sep 2015
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pkb  $

        Rev 1.106.1 9/23/15 added START_LOC_ID
        
        Rev 1.106 9/21/15 added amd_defaults.getProgramId
        
        Rev 1.105 2/23/15 added amd_defaults.getStartLocId
        
        Rev 1.104 2/13/15 commented out spo references
/*   
/*      Rev 1.103   10 Jun 2009 13:29:38   zf297a
/*   Initialize variables tsl_override_type and override_reason using data in amd_spo_types_v.
/*   
/*      Rev 1.102   24 Feb 2009 11:44:08   zf297a
/*   Removed A2A code
/*   
/*      Rev 1.101   19 Feb 2009 10:08:24   zf297a
/*   Implemented get/set for loadFMSdata.  Also, get the loadFMSdata switch from the amd_param_changes tab;e and make the default for loadFMSdata 'N' 
/*   
/*   loadUk, loadCAN, and loadAUS will only run if loadFMSdata = 'Y'
/*   
/*      Rev 1.100   14 Feb 2009 16:07:56   zf297a
/*   Implemented the new interface for loadWhse - endStep only goes to 4 now.
/*
/*      Rev 1.99   14 Feb 2009 14:44:26   zf297a
/*   Removed a2a code.
/*
/*      Rev 1.98   14 Feb 2009 07:30:24   zf297a
/*   Fixed procedure insertAmdLocPartOverride by altering the IF statement prior to inserting to amd_location_part_override and removing the check of the action_code.  All that is needed is the check of the tsl_override_qty.
/*
/*      Rev 1.97   13 Feb 2009 16:00:20   zf297a
/*   Implemented get/set routines for counters.  Fixed insert's to tmp_amd_location_part_override for procedure insertTmpAmdLocPartOverride.  Added some additional counters to make it easier to do a query and check the values after executing the load to tmp_amd_location_part_override.  For example:
/*   select amd_location_part_override_pkg.getTmpInsertCnt from dual
/*
/*      Rev 1.96   24 Sep 2008 10:47:06   zf297a
/*   qualified spo_prime_part_no using amd_sent_to_a2a
/*
/*      Rev 1.95   12 Aug 2008 17:06:50   zf297a
/*   made procedure errorMsg an autonomous_transaction so that its commit is independent of the main transaction and it can record the error message.
/*
/*      Rev 1.94   12 Aug 2008 11:33:52   zf297a
/*   Fixed getFirstLogonIdForPart to hand the condition where no data is found and attempt to the default via the part_no.
/*
/*      Rev 1.93   09 Apr 2008 13:49:16   zf297a
/*   Eliminate sending records with zero quantity for FSL's, MOB's, Atlanta Warehouse, and all other inserts into tmp tables except for sending updates and deleted for the tmp_a2a table.
/*
/*      Rev 1.92   19 Mar 2008 00:02:54   zf297a
/*   Use the new TSL_OVERRIDE_TYPE.
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
/*   Changed LoadUk to LoadUkandAUS and added check for the AUS location id.  Fixed the query for stockFromWhse to use 'C17%CODAUSG' with a G at the end.
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
    PROGRAM_ID constant varchar2(30)  := amd_defaults.getProgramId ;
    PROGRAM_ID_LL constant number := length(PROGRAM_ID) ;
    START_LOC_ID constant number := amd_defaults.getStartLocId;


	type candiateRec is record (
		part_no amd_spare_parts.part_no%type,
		loc_sid amd_spare_networks.loc_sid%type
	) ;
	type candidateTab is table of candiateRec ;
	candidateRecs candidateTab ;

	type stockRec is record (
		part_no amd_spare_parts.part_no%type,
		tsl_override_qty number
	) ;
	type stockTab is table of stockRec ;
	stockRecs stockTab ;

	type partSumRec is record (
		part_no amd_spare_parts.part_no%type,
		qty number
	) ;
	type partSumTab is table of partSumRec ;
	partSumRecs partSumTab ;

	type fslMobTab is table of amd_location_part_override%rowtype ;
    
    loadFMSdata varchar2(1) := 'N' ;

	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_LOCATION_PART_OVERRIDE_PKG' ;

	gtZeroCnt NUMBER := 0 ;
	tmpInsertCnt NUMBER := 0 ;
	tmpUpdateCnt NUMBER := 0 ;
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
                 pragma autonomous_transaction ;
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
		commit ;
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

        pragma AUTONOMOUS_TRANSACTION ;

	    key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pComments ;
		error_location number ;
        load_no number ;

	BEGIN
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
      dbms_output.put_line('sqlcode(' || SQLCODE || ') sqlerrm(' ||SQLERRM|| ')' ) ;
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
			  tmpUpdateCnt := tmpUpdateCnt + 1 ;
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
        if pTslOverrideUser is null then
            dbms_output.put_line('pPartNo=' 
                || pPartNo 
                || ' ' || pLocSid 
                || ' ' || getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (pPartNo))) ;
        end if ;                            
        if pTslOverrideQty > 0   then
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
	     tmpInsertCnt := tmpInsertCnt + 1 ;
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
         if pTslOverrideQty > 0  then
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
	exception
		when dup_val_on_index then
			UpdateAmdLocPartOverride (pPartNo,
				pLocSid,
				pTslOverrideQty,
				pTslOverrideUser,
				pActionCode,
				sysdate ) ;

		when others then
			ErrorMsg(pSqlfunction => 'InsertAmdLocPartOverride',
				pTableName => 'amd_location_part_override',
				pError_location => 40) ;
			raise ;

	END InsertAmdLocPartOverride ;





	FUNCTION InsertRow(pPartNo amd_location_part_override.PART_NO%type,
		pLocSid amd_location_part_override.LOC_SID%type,
		pTslOverrideQty amd_location_part_override.TSL_OVERRIDE_QTY%type ,
		pTslOverrideUser amd_location_part_override.TSL_OVERRIDE_USER%type )
	return number is

	begin

	    InsertAmdLocPartOverride(pPartNo,
		pLocSid, pTslOverrideQty,
		pTslOverrideUser, Amd_Defaults.INSERT_ACTION,
		sysdate ) ;

		return success ;

	exception when others then
		errorMsg(pSqlfunction => 'insertAmd',
			pTableName => 'amd_location_part_override',
			pError_location => 170,
			pKey1 => pPartNo, pKey2 => pLocSid) ;
		raise ;
	end insertRow ;


	function updateRow(pPartNo amd_location_part_override.part_no%type,
		pLocSid amd_location_part_override.loc_sid%type,
		pTslOverrideQty	amd_location_part_override.tsl_override_qty%type ,
		pTslOverrideUser amd_location_part_override.tsl_override_user%type )
	return number is
	begin
		updateAmdLocPartOverride (pPartNo,
			pLocSid,
			pTslOverrideQty,
			pTslOverrideUser,
			Amd_Defaults.UPDATE_ACTION,
			sysdate ) ;
		 return success ;

	 exception when others then
		errorMsg(pSqlfunction => 'updateRow',
			pTableName => 'amd_location_part_override',
                	pError_location => 190,
			pKey1 => pPartNo, pKey2 => pLocSid) ;
		raise ;
	end updateRow ;



	function deleteRow(pPartNo amd_location_part_override.part_no%TYPE,
		pLocSid amd_location_part_override.loc_sid%type,
		pTslOverrideQty	amd_location_part_override.tsl_override_qty%type ,
		pTslOverrideUser amd_location_part_override.tsl_override_user%type )
	return number is
	begin
		updateAmdLocPartOverride (
			pPartNo,
			pLocSid,
			pTslOverrideQty,
			pTslOverrideUser,
			Amd_Defaults.DELETE_ACTION,
			sysdate ) ;
	  	return success ;

	 exception when others then
		errorMsg(pSqlfunction => 'DeleteRow',
			pTableName => 'amd_location_part_override',
			pError_location => 210,
			pKey1 => pPartNo, pKey2 => pLocSid) ;
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

		cursor spoPrimePartsForTheUK IS
			select spo_prime_part_no, loc_sid
			from amd_spare_parts parts, amd_spare_networks ntwks
			where parts.is_repairable = 'Y'
			and parts.is_spo_part = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and ntwks.loc_id = Amd_Defaults.AMD_UK_LOC_ID ;

		stockRecs stockTab ;

	 	cursor stockFromWhse IS
			select parts.spo_prime_part_no part_no,
				sum(nvl(stock_level, 0)) tsl_override_qty
			from whse w, amd_spare_parts parts
			where parts.part_no = parts.spo_prime_part_no
			and parts.is_spo_part = 'Y'
			and parts.is_repairable = 'Y'
			and w.part = parts.part_no
			and w.sc like PROGRAM_ID ||'%CODUKBG'
			group by spo_prime_part_no ;

		returnCode number ;

		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;

		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		candidateRecCnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 230,
			pKey1 => 'LoadUk',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		open stockFromWhse ;
		fetch stockFromWhse bulk collect into stockRecs ;
		close stockFromWhse ;

		if stockRecs.first is not null then
			for indx in stockRecs.first .. stockRecs.last loop
				<<saveQty>>
				begin
					if ( stockRecs(indx).part_no is not null ) then
						partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
					end if ;

				exception when others then
					errorMsg(pSqlfunction => 'LoadUk',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 240,
						pKey1 => 'partNo: ' || stockRecs(indx).part_no,
						pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
					raise ;
				end saveQty ;

				stock_cnt := stock_cnt + 1 ;
			end loop ;
		end if ;

		open spoPrimePartsForTheUK ;
		fetch spoPrimePartsForTheUK bulk collect into candidateRecs ;
		close spoPrimePartsForTheUK ;

		if candidateRecs.first is not null then
			for indx in candidateRecs.first .. candidateRecs.last loop

				tslOverrideQty := 0 ;
				<<tslQty>>
				begin
					tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
				exception when no_data_found then
					tslOverrideQty := 0 ;
				end tslQty ;

				if tslOverrideQty > 0 then
					gtZeroCnt := gtZeroCnt + 1 ;
				end if ;

				<<insertTemp>>
				begin
                    if (candidateRecs(indx).part_no = '008-877') then
                        dbms_output.put_line(getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (candidateRecs(indx).part_no))) ;
                    end if ;                            
					insertTmpAmdLocPartOverride(candidateRecs(indx).part_no,
						candidateRecs(indx).loc_sid,
						tslOverrideQty,
                        getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (candidateRecs(indx).part_no)),
						Amd_Defaults.INSERT_ACTION,
						sysdate) ;
				exception when others then
					errorMsg(pSqlfunction	=> 'LoadUk',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 250,
						pKey1 => 'partNo: ' || candidateRecs(indx).part_no,
						pKey2 => 'locSid: ' || candidateRecs(indx).loc_sid) ;
					raise ;
				end insertTemp ;

				candidateRecCnt := candidateRecCnt + 1 ;

			end loop ;
		end if ;


		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 260,
			pKey1 => 'LoadUk',
			pKey2 => 'ended at ' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),
			pKey3 => 'stock_cnt=' || stock_cnt,
			pKey4 => 'candidateRecCnt=' || candidateRecCnt ) ;
		commit ;
	exception when others then
		 errorMsg(pSqlfunction => 'LoadUk',
			pTableName => 'tmp_amd_location_part_override',
			pError_location => 270,
			pKey1 => 'stock_cnt=' || to_char(stock_cnt),
			pKey2 => 'candidateRecCnt=' || to_char(candidateRecCnt) ) ;
		raise ;
	end loadUk ;

	procedure loadAUS IS
   		cursor spoPrimePartsForAUS IS
			select spo_prime_part_no, loc_sid
			from amd_spare_parts parts, amd_spare_networks ntwks
			where parts.is_repairable = 'Y'
			and parts.is_spo_part = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and ntwks.loc_id = Amd_Defaults.AMD_AUS_LOC_ID ;


	 	cursor stockFromWhse is
			select spo_prime_part_no part_no,
				sum(nvl(stock_level, 0)) tsl_override_qty
			from whse w, amd_spare_parts parts
			where w.part = parts.part_no
			and parts.is_spo_part = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and parts.is_repairable = 'Y'
			and w.sc like PROGRAM_ID || '%CODAUSG'
			group by spo_prime_part_no ;

		returnCode NUMBER ;

		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;

		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		candidateRecCnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 280,
			pKey1 => 'LoadAUS',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		open stockFromWhse ;
		fetch stockFromWhse bulk collect into stockRecs ;
		close stockFromWhse ;

		if stockRecs.first is not null then
			for indx in stockRecs.first .. stockRecs.last loop
			        <<getQty>>
				begin
					if ( stockRecs(indx).part_no is not null ) then
						partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
					end if ;
				exception when others then
					ErrorMsg(pSqlfunction => 'LoadAUS',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 290,
						pKey1 => 'partNo: ' || stockRecs(indx).part_no,
						pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
					raise ;
				end getQty ;
				stock_cnt := stock_cnt + 1 ;
			end loop ;
		end if ;

		open spoPrimePartsForAUS ;
		fetch spoPrimePartsForAUS bulk collect into candidateRecs ;
		close spoPrimePartsForAUS ;

		if candidateRecs.first is not null then
			for indx in candidateRecs.first .. candidateRecs.last loop
				tslOverrideQty := 0 ;
				begin
					tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
				exception when no_data_found then
					tslOverrideQty := 0 ;
				end ;

				<<insertTmp>>
				begin
					insertTmpAmdLocPartOverride(candidateRecs(indx).part_no,
						candidateRecs(indx).loc_sid,
						tslOverrideQty,
                        getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (candidateRecs(indx).part_no)),
						Amd_Defaults.INSERT_ACTION,
						sysdate) ;
				exception when others then
					errorMsg(pSqlfunction => 'insertTmp',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 300,
						pKey1 => 'partNo: '|| candidateRecs(indx).part_no,
						pKey2 => 'locSid: '|| candidateRecs(indx).loc_sid) ;
					raise ;
				end insertTmp ;

				candidateRecCnt := candidateRecCnt + 1 ;
			end loop ;
		end if ;

		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 310,
			pKey1 => 'LoadAUS',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
			pKey3 => 'stock_cnt=' || stock_cnt,
			pKey4 => 'candidateRecCnt=' || candidateRecCnt ) ;
		commit ;
	exception when others then
		errorMsg(pSqlfunction => 'LoadAUS',
			pTableName => 'tmp_amd_location_part_override',
			pError_location => 320,
			pKey1 => 'stock_cnt=' || to_char(stock_cnt),
			pKey2 => 'candidateRecCnt=' || to_char(candidateRecCnt) ) ;
		raise ;
	end loadAUS ;

	procedure loadCAN IS -- added 10/11/2007 by dse

   		cursor spoPrimePartsForCAN IS
			select spo_prime_part_no, loc_sid
			from amd_spare_parts parts, amd_spare_networks ntwks
			where parts.is_repairable = 'Y'
			and parts.is_spo_part = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and ntwks.loc_id = Amd_Defaults.AMD_CAN_LOC_ID ;

	 	cursor stockFromWhse is
			select parts.spo_prime_part_no part_no,
				sum(nvl(stock_level, 0)) tsl_override_qty
			from whse w, amd_spare_parts parts
			where w.part = parts.part_no
			and parts.is_spo_part = 'Y'
			and parts.is_repairable = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and w.sc like PROGRAM_ID || '%CODCANG'
			group by parts.spo_prime_part_no ;

		returnCode NUMBER ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;

		tslOverrideQty amd_location_part_override.tsl_override_qty%type ;
		stock_cnt number := 0 ;
		candidateRecCnt number := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 330,
			pKey1 => 'LoadCAN',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		open stockFromWhse;
		fetch stockFromWhse bulk collect into stockRecs ;
		close stockFromWhse ;

		if stockRecs.first is not null then
			for indx in stockRecs.first .. stockRecs.last loop
				begin
					if ( stockRecs(indx).part_no is not null ) then
						partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
					end if ;
				exception when others then
					ErrorMsg(pSqlfunction => 'LoadCAN',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 340,
						pKey1 => 'partNo: ' || stockRecs(indx).part_no,
						pKey2 => 'qty: ' || stockRecs(indx).tsl_override_qty) ;
					raise ;
				end ;

				stock_cnt := stock_cnt + 1 ;
			end loop ;
		end if ;

		open spoPrimePartsForCAN ;
		fetch spoPrimePartsForCAN bulk collect into candidateRecs ;
		close spoPrimePartsForCAN ;

		if candidateRecs.first is not null then
			for indx in candidateRecs.first .. candidateRecs.last loop
				tslOverrideQty := 0 ;

				<<getTsl>>
				begin
					tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
				exception when no_data_found then
					tslOverrideQty := 0 ;
				end getTsl ;

				<<insertTmp>>
				begin
					insertTmpAmdLocPartOverride(candidateRecs(indx).part_no,
						candidateRecs(indx).loc_sid,
						tslOverrideQty,
                        getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (candidateRecs(indx).part_no)),
						Amd_Defaults.INSERT_ACTION,
						sysdate) ;
				exception when others then
					errorMsg(pSqlfunction => 'LoadCAN',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 350,
						pKey1 => 'partNo: '|| candidateRecs(indx).part_no,
						pKey2 => 'locSid: '|| candidateRecs(indx).loc_sid) ;
					raise ;
				end insertTmp ;

				candidateRecCnt := candidateRecCnt + 1 ;
			end loop ;
		end if ;

		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 360,
			pKey1 => 'LoadCAN',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
			pKey3 => 'stock_cnt=' || stock_cnt,
			pKey4 => 'candidateRecCnt=' || candidateRecCnt ) ;
		commit ;
	exception when others then
		errorMsg(pSqlfunction => 'LoadCAN',pTableName => 'tmp_amd_location_part_override',
			pError_location => 370,
			pKey1 => 'stock_cnt=' || to_char(stock_cnt),
			pKey2 => 'candidateRecCnt=' || to_char(candidateRecCnt) ) ;
		raise ;
	end loadCAN ;


	PROCEDURE LoadBasc IS
   		cursor spoPrimePartsForBASC IS
			select spo_prime_part_no, loc_sid
			from amd_spare_parts parts, amd_spare_networks ntwks
			where parts.is_repairable = 'Y'
			and parts.is_spo_part = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and ntwks.loc_id = Amd_Defaults.AMD_BASC_LOC_ID ;


	 	cursor stockFromWhse is
			select spo_prime_part_no part_no,
				sum(nvl(stock_level, 0)) tsl_override_qty
			from whse w, amd_spare_parts parts
			where w.part = parts.part_no
			and parts.is_spo_part = 'Y'
			and parts.is_repairable = 'Y'
			and parts.part_no = parts.spo_prime_part_no
			and sc = PROGRAM_ID || 'PCAG'
			group by spo_prime_part_no ;

		returnCode number ;
		type partNo_stock is table of number index by amd_spare_parts.part_no%type  ;
		partNo_stockLevel partNo_stock ;

		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		stock_cnt NUMBER := 0 ;
		candidateRecCnt NUMBER := 0 ;
	begin
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 380,
			pKey1 => 'LoadBasc',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		open stockFromWhse;
		fetch stockFromWhse bulk collect into stockRecs ;
		close stockFromWhse ;

		if stockRecs.first is not null then
			for indx in stockRecs.first .. stockRecs.last loop
				begin
					if ( stockRecs(indx).part_no is not null ) then
						partNo_stockLevel(stockRecs(indx).part_no) := stockRecs(indx).tsl_override_qty ;
					end if ;
				exception when others then
					errorMsg(pSqlfunction => 'LoadBasc',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 390,
						pKey1 => 'partNo: ' || stockRecs(indx).part_no,
						pKey2 => 'qty: '|| stockRecs(indx).tsl_override_qty) ;
					raise ;
				end ;

				stock_cnt := stock_cnt + 1 ;

			end loop ;
		end if ;

		open spoPrimePartsForBASC ;
		fetch spoPrimePartsForBASC bulk collect into candidateRecs ;
		close spoPrimePartsForBASC ;

		if candidateRecs.first is not null then
			for indx in candidateRecs.first .. candidateRecs.last loop
				tslOverrideQty := 0 ;

				<<getTslQty>>
				begin
					tslOverrideQty := partNo_stockLevel(candidateRecs(indx).part_no) ;
				exception when no_data_found then
					tslOverrideQty := 0 ;
				end getTslQty ;

				<<insertTmp>>
				begin
					insertTmpAmdLocPartOverride(candidateRecs(indx).part_no,
						candidateRecs(indx).loc_sid,
						tslOverrideQty,
                        getfirstlogonidforpart
                            (amd_utils.getnsisidfrompartno (candidateRecs(indx).part_no)),
						Amd_Defaults.INSERT_ACTION,
						sysdate) ;
				exception when others then
					ErrorMsg(pSqlfunction => 'LoadBasc',
						pTableName => 'tmp_amd_location_part_override',
						pError_location => 400,
						pKey1 => 'partNo: ' || candidateRecs(indx).part_no,
						pKey2 => 'locSid: ' || candidateRecs(indx).loc_sid) ;
					raise ;
				end insertTmp ;

				candidateRecCnt := candidateRecCnt + 1 ;
			end loop ;
		end if ;

		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 410,
			pKey1 => 'LoadBasc',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
			pKey3 => 'stock_cnt=' || stock_cnt,
			pKey4 => 'candidateRecCnt=' || candidateRecCnt) ;
		commit ;

	exception when others then
		errorMsg(pSqlfunction => 'LoadBasc',
			pTableName => 'tmp_amd_location_part_override',
			pError_location => 420,
			pKey1 => 'stock_cnt=' || to_char(stock_cnt),
			pKey2 => 'candidateRecCnt=' || to_char(candidateRecCnt)) ;
		raise ;
	end loadBasc ;


	procedure loadRampData IS

		rampRecs fslMobTab ;

		cursor rampData is
		select parts.spo_prime_part_no part_no,
			loc_sid,
			sum(nvl(r.demand_level,0)) demand_level,
			null,
			amd_defaults.INSERT_ACTION,
			sysdate
		from ramp r, amd_spare_parts parts, amd_spare_networks asn
		where r.sc like PROGRAM_ID || '0008%'
		and substr(r.sc, START_LOC_ID, 6) = asn.loc_id
		and asn.loc_type in ('MOB', 'FSL')
		and replace(r.current_stock_number, '-') = parts.nsn
		and parts.spo_prime_part_no = parts.part_no
		and parts.is_spo_part = 'Y'
		and parts.is_repairable = 'Y'
		and Amd_Location_Part_Override_Pkg.IsNumeric(parts.nsn) = 'Y'
		and asn.action_code != Amd_Defaults.DELETE_ACTION
		group by  spo_prime_part_no , loc_sid
		having sum(nvl(r.demand_level,0))  > 0 ;

		type array is table of tmp_amd_location_part_override%rowtype;
		l_data array;
		returnCode number ;
		cur_cnt NUMBER := 0 ;
		req_cnt NUMBER := 0 ;

	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 430,
			pKey1 => 'loadRampData',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;


		open rampData ;
		fetch rampData bulk collect into rampRecs ;
		close rampData ;

		if rampRecs.first is not null then
			forall indx in rampRecs.first .. rampRecs.last
				insert into tmp_amd_location_part_override values rampRecs(indx) ;

			tmpInsertCnt := tmpInsertCnt + rampRecs.count ;
		end if ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 460,
			pKey1 => 'loadRampData',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
			pKey3 => 'cur_cnt=' || cur_cnt,
			pKey4 => 'req_cnt=' || req_cnt) ;
        	commit ;
	exception when others then
		ErrorMsg(pSqlfunction => 'loadRampData',
			pTableName => 'tmp_amd_location_part_override',
			pError_location => 470,
			pKey1 => 'cur_cnt=' || to_char(cur_cnt),
			pKey2 => 'req_cnt=' || to_char(req_cnt)) ;
		 raise ;
	end loadRampData ;


	procedure loadWhse(startStep in number := 1, endStep in number := 4) is

        	type whseTab is table of tmp_amd_location_part_override%rowtype ;
	        whseRecs whseTab ;

		cursor cursor_warehouse_parts is
			select parts.spo_prime_part_no part_no,
				loc_sid,
				0 tsl_override_qty,
				null tsl_override_user,
				amd_defaults.INSERT_ACTION action_code,
				sysdate last_update_dt
			from amd_spare_parts parts, amd_spare_networks asn
			where parts.spo_prime_part_no = parts.part_no
			and parts.is_spo_part = 'Y'
			and parts.is_repairable = 'Y'
			and asn.loc_id = amd_defaults.amd_warehouse_locid
			and asn.action_code != Amd_Defaults.DELETE_ACTION
			and asn.spo_location is not null
			and spo_prime_part_no is not null ;

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
			from amd_spare_parts parts, amd_national_stock_items items
			where parts.part_no = parts.spo_prime_part_no
			and parts.is_spo_part = 'Y'
			and parts.is_repairable = 'Y'
			and parts.nsn = items.nsn
			and items.action_code <> 'D'
			and parts.spo_prime_part_no is not null
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
                insert_cnt number := 0 ;
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
                            if AtlantaWarehouseQty > 0 then
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
                                insert_cnt := insert_cnt + 1 ;
                                tmpInsertCnt := tmpInsertCnt + 1 ;
                            end if ;
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
                        pKey2 => 'insert_cnt=' || insert_cnt,
        				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
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
					-- don't need this to load zero tsl's when 5 then loadWareHouseParts ;
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
				pData => 'spoInv_cnt=' || to_char(spoInv_cnt)
					|| ' rsp_cnt=' || to_char(rsp_cnt)
					|| ' spoSum_cnt=' || to_char(spoSum_cnt)) ;
		commit ;
	exception when others then
		errorMsg(pSqlfunction => 'LoadWhse',pTableName => 'tmp_amd_location_part_override',
			pError_location => 680,
			pKey1 => 'curStep=' || curStep,
			pkey2 => 'cur_cnt=' || to_char(cur_cnt),
			pKey3 => 'baseSum_cnt=' || to_char(baseSum_cnt),
			pKey4 => 'spoInv_cnt=' || to_char(spoInv_cnt) ) ;
		raise ;
	end loadWhse ;


	function getFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE)
		RETURN AMD_PLANNER_LOGONS.logon_id%TYPE IS

		cursor cur( pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE ) IS
			select apl.*
			from amd_planner_logons apl, amd_planners ap, amd_national_stock_items ansi
			where ansi.nsi_sid = pNsiSid
			and amd_Preferred_Pkg.GetPreferredValue(ansi.planner_code_cleaned, ansi.planner_code)
					= ap.planner_code
			and ap.planner_code = apl.planner_code
			and ap.action_code != Amd_Defaults.DELETE_ACTION
			and apl.action_code != Amd_Defaults.DELETE_ACTION
			order by apl.planner_code, data_source, logon_id ;
		 retLogonId amd_planner_logons%rowtype := null ;

		procedure getLogonIdViaPart is
			part_no amd_spare_parts.part_no%type ;
		begin
			part_no := amd_utils.getPartNo(pNsiSid) ;
			if part_no is not null then
				if amd_utils.isPartConsumable(part_no) then
					retLogonId.logon_id := amd_defaults.CONSUMABLE_LOGON_ID ;
				elsif amd_utils.isPartRepairable(part_no) then
					retLogonId.logon_id := amd_defaults.REPAIRABLE_LOGON_ID ;
				end if ;
			end if ;
		exception
			when standard.no_data_found then
				null ; -- do nothing it cannot be found
			when others then
				errorMsg(pSqlfunction => 'getLogonIdViaPart',pTableName => 'amd_spare_parts',
					pError_location => 685) ;
			raise ;
		end getLogonIdViaPart ;


	begin
		if not cur%isopen then
			open cur(pNsiSid) ;
		end if ;
		fetch cur into retLogonId ;
		if cur%notfound then
			getLogonIdViaPart ;
		end if ;
		close cur ;
		return retLogonId.logon_id ;
	exception
		when standard.no_data_found then
			getLogonIdViaPart ;
			return retLogonId.logon_id ;
		when others then
			errorMsg(pSqlfunction => 'GetFirstLogonIdForPart',pTableName => 'amd_planner_logons',
				pError_location => 690) ;
			raise ;
	end getFirstLogonIdForPart ;

	procedure loadOverrideUsers IS
		type overrideUserRec is record (
			part_no tmp_amd_location_part_override.part_no%type,
            loc_sid tmp_amd_location_part_override.LOC_SID%type
		) ;

		type overrideUserTab is table of overrideUserRec ;
		overrideUserRecs overrideUserTab  ;

		cursor overrideUserscur is
			 select part_no, loc_sid
			 from tmp_amd_location_part_override 
			 where tsl_override_user is null ; 

		tslOverrideUser AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE ;
		cur_cnt NUMBER := 0 ;
        update_cnt number := 0 ;

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
                     -- if (lastNsiSid != overrideUserRecs(indx).nsi_sid) then
                        -- partNo_logonId(rec.part_no) := nvl(GetFirstLogonIdForPart(rec.nsi_sid), amd_defaults.GetLogonId(rec.nsn) ) ;
                        tslOverrideUser := getfirstlogonidforpart
                                            (amd_utils.getnsisidfrompartno (overrideUserRecs(indx).part_no)) ;
                        if tslOverrideUser is null then
                            dbms_output.put_line(overrideUserRecs(indx).part_no) ;
                            tslOverrideUser := 'SPO' ;
                        end if ;                            
                        update tmp_amd_location_part_override
                           set 	tsl_override_user = tslOverrideUser
                           where	part_no = overrideUserRecs(indx).part_no
                           and loc_sid = overrideUserRecs(indx).loc_sid ;
                        update_cnt := update_cnt + 1 ;                           
                exception when others then
                        errorMsg(pSqlfunction => 'LoadOverrideUsers',pTableName => 'tmp_amd_location_part_override',
                            pError_location => 710,
                            pKey1	=>  'loc_sid=' || overrideUserRecs(indx).loc_sid,
                            pKey2 => 'partNo=' || overrideUserRecs(indx).part_no) ;
                       raise ;
                end ;
                cur_cnt := cur_cnt + 1 ;
             end loop ;
        end if ;

		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 720,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || to_char(cur_cnt),
                pKey4 => 'update_cnt=' || to_char(update_cnt)) ;
		commit ;
	exception when others then
        errorMsg(pSqlfunction => 'LoadOverrideUsers',pTableName => 'tmp_amd_location_part_override',
            pError_location => 730, pKey1 => 'cur_cnt=' || to_char(cur_cnt) ) ;
        raise ;
	end loadOverrideUsers ;



    PROCEDURE LoadTmpAmdLocPartOverride( startStep in number := 1, endStep in number := 7) is
        curStep number := 0 ;
    BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 880,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		 Mta_Truncate_Table('tmp_amd_location_part_override','reuse storage');
         COMMIT ;
         for i in startStep..endStep loop
            curStep := i ;
             case i
                when 1 then loadRampData ;
                when 2 then 
                    if loadFMSdata = 'Y' then 
                        LoadUk ; 
                    end if ;
                when 3 then 
                    if loadFMSdata = 'Y' then 
                        LoadAUS ; 
                    end if ;
                when 4 then LoadBasc ;
                when 5 then 
                    if loadFMSdata = 'Y' then
                        LoadCAN ;
                    end if ;                        
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
         dbms_output.put_line('LoadInitial ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

    EXCEPTION WHEN OTHERS THEN
        ErrorMsg(pSqlfunction => 'LoadInitial', pTableName => 'tmp_amd_location_part_override',
                   pError_location => 1070 ) ;
        RAISE ;
    END LoadInitial ;

	-- added 02/13/09 dse
    function getGtZeroCnt return number is
    begin
	return gtZeroCnt ;
    end getGtZeroCnt ;
    procedure setGtZeroCnt(value in number) is
    begin
	gtZeroCnt := value ;
    end setGtZeroCnt ;

    function getTmpInsertCnt return number is
    begin
	return tmpInsertCnt ;
    end getTmpInsertCnt ;
    procedure setTmpInsertCnt(value in number) is
    begin
	tmpInsertCnt := value ;
    end setTmpInsertCnt ;

    function getTmpUpdateCnt return number is
    begin
	return tmpUpdateCnt ;
    end getTmpUpdateCnt ;
    procedure setTmpUpdateCnt(value in number) is
    begin
	tmpUpdateCnt := 0 ;
    end setTmpUpdateCnt ;

    -- added 11/7/05 dse
    FUNCTION getInsertCnt RETURN NUMBER IS
    BEGIN
         RETURN insertCnt ;
    END getInsertCnt ;
    procedure setInsertCnt(value in number) is
    begin
	insertCnt := value ;
    end setInsertCnt ;

    FUNCTION getUpdateCnt RETURN NUMBER IS
    BEGIN
         RETURN updateCnt ;
    END getUpdateCnt ;
    procedure setUpdateCnt(value in number) is
    begin
	updateCnt := value ;
    end setUpdateCnt ;

    FUNCTION getDeleteCnt RETURN NUMBER IS
    BEGIN
         RETURN deleteCnt ;
    END getDeleteCnt ;
    procedure setDeleteCnt(value in number) is
    begin
	deleteCnt := value ;
    end setDeleteCnt ;
/*
    FUNCTION getTSL_OVERRIDE_TYPE RETURN VARCHAR2 IS
    BEGIN
         RETURN TSL_OVERRIDE_TYPE ;
    END getTSL_OVERRIDE_TYPE ;

    FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 IS
    BEGIN
         RETURN OVERRIDE_REASON ;
    END getOVERRIDE_REASON ;
*/
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
                 pError_location => 1360, pKey1 => 'amd_location_part_override_pkg', pKey2 => '$Revision:   1.106.1  $') ;
         dbms_output.put_line('amd_location_part_override_pkg: $Revision:   1.106.1  $') ;
    end version ;

    function getVersion return varchar2 is
    begin
        return '$Revision:   1.106.1  $' ;
    end getVersion ;


        function ignoreStLouisYorN return varchar2 is
        begin
            if ignoreStLouis then
                return 'Y' ;
            else
                return 'N' ;
            end if ;
        end ignoreStLouisYorN ;

        procedure setDebug(switch in varchar2) is
        begin
            debug := upper(switch) in ('Y','T','YES','TRUE') ;
            if debug then
                dbms_output.ENABLE(100000) ;
            else
                dbms_output.DISABLE ;
            end if ;
        end setDebug ;

        function getDebugYorN return varchar2 is
        begin
            if debug then
                return 'Y' ;
            else
                return 'N' ;
            end if ;
        end getDebugYorN ;
        
        procedure setLoadFMSdata(value in varchar2) is
        begin
            loadFMSdata := value ;
        end setLoadFMSdata ;
        
        function getLoadFMSdata return varchar2 is
        begin
            return loadFMSdata ;
        end getLoadFMSdata ;                        


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
          
          begin
            loadFMSdata := amd_defaults.getParamValue('loadFMSdata') ;
          exception when others then
            loadFMSdata := 'N' ;
          end ;                                   

          Amd_Location_Part_Override_Pkg.ignoreStLouis := getIgnoreStLouis() ;
      END getParams ;

      <<getTypes>>
      begin
	    --select tsl_fixed_override into tsl_override_type from amd_spo_types_v ;
	    --select fixed_tsl_load_override_reason into override_reason from amd_spo_types_v ;
        null;
      end getTypes ;


END Amd_Location_Part_Override_Pkg ;
/