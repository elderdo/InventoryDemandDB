/* Formatted on 1/25/2017 2:32:30 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_LOCS_LOAD_PKG
AS
    /*

       $Author:   Douglas S Elder
     $Revision:   1.9
         $Date:   25 Jan 2017
     $Workfile:   amd_part_locs_load_pkg.pks  $

      Rev 1.9   25 Jan 2017 reformatted code
      
      Rev 1.8   07 Dec 2011 Added function getVersion

      Rev 1.7   Jun 09 2006 12:12:08   zf297a
   added interface version

      Rev 1.6   Jun 13 2005 09:19:04   c970183
   Added PVCS keywords

*/



   -------------------------------------------------------------------
   --
   -- SCCSID: amd_part_locs_load_pkg.sql  1.1  Modified: 08/14/02 17:11:22
   --
   --  Date      By   History
   --  ----    --   -------
   --  10/10/01      ks  initial implementation
   --  12/11/01      dse  Added named param for amd_preferred_pkg.GetUnitCost(.....
   --  8/14/02    ks            change fsl query to be more efficient.
   --  6/01/05    ks  changes to support AMD 1.7.1 - change to RSP_ON_HAND, RSP_OBJECTIVE
   --     change rampData_rec to be whole record,
   --     mod to queries for bssm, eg. lock_sid use '0' instead of 0
   -------------------------------------------------------------------


   -- added ROR to previous part_locations, since table now combines old amd_repair_levels
   -- too, which had MOB, FSL, ROR. also adding each part to warehouse as part/loc list since
   -- child table amd_part_loc_time_periods may provide ROP/ROQ info for warehouse, especially
   -- for consumables.
   OFFBASE_LOCID   CONSTANT VARCHAR2 (30) := 'OFFBASE';
   COMMIT_AFTER    CONSTANT NUMBER := 10000;

   -- data fields match cursor and database field names
   -- wrm relates to rsp
   /*
   type rampData_rec is record (
       date_processed date,
     avg_repair_cycle_time number,
     percent_base_condem number,
     percent_base_repair number,
     wrm_level number,
     wrm_balance number );
   function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return rampData_rec;
   function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return rampData_rec;
   */

   FUNCTION GetRampData (pNsn      ramp.nsn%TYPE,
                         pLocId    amd_spare_networks.loc_id%TYPE)
      RETURN ramp%ROWTYPE;

   FUNCTION GetRampData (pNsn       ramp.nsn%TYPE,
                         pLocSid    amd_spare_networks.loc_sid%TYPE)
      RETURN ramp%ROWTYPE;

   PROCEDURE LoadAmdPartLocations;

   -- added 6/9/2006 by dse
   PROCEDURE version;

   -- added 12/7/2011 by dse
   FUNCTION getVersion
      RETURN VARCHAR2;
END AMD_PART_LOCS_LOAD_PKG;
/