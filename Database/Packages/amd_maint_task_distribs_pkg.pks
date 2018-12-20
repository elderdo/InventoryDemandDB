DROP PACKAGE AMD_OWNER.AMD_MAINT_TASK_DISTRIBS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_maint_task_distribs_pkg
as
    /*

       $Author:   c970183  $
     $Revision:   1.6  $
         $Date:   Jun 13 2005 09:02:46  $
     $Workfile:   amd_maint_task_distribs_pkg.pks  $
	      $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_maint_task_distribs_pkg.pks-arc  $

      Rev 1.6   Jun 13 2005 09:02:46   c970183
   Added PVCS keywords
*/

	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/25/01		  ks			initial implementation
	   --  06/01/05		  ks			change reference to rampData
	   -------------------------------------------------------------------


   	    -- mob, fsl, ror only, no warehouse
	    -- previous amd RepairRate always defaulted. may be in error. need rereview.
		-- 		  actual and projected may be considered incorrect in this manner too
		--		  since defaults always used. kept consistent with previous load for now.
		-- repair rate requires 5,6 position smr for default from existing system.
		-- if no 6 position smr, no record currently created.

  	   	  -- actual and projected designations for mtd
  	   ACTUAL constant varchar2(1) := 'A';
  	   PROJECTED constant varchar2(1) := 'P';
	   COMMIT_AFTER constant number := 10000;
  	   	  -- loadMtd needs to run after amd_part_locs loading
  	   procedure loadAmdMtd;


end amd_maint_task_distribs_pkg;
 
/


DROP PUBLIC SYNONYM AMD_MAINT_TASK_DISTRIBS_PKG;

CREATE PUBLIC SYNONYM AMD_MAINT_TASK_DISTRIBS_PKG FOR AMD_OWNER.AMD_MAINT_TASK_DISTRIBS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_MAINT_TASK_DISTRIBS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_MAINT_TASK_DISTRIBS_PKG TO AMD_WRITER_ROLE;
