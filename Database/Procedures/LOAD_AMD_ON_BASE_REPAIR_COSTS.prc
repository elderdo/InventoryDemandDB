CREATE OR REPLACE PROCEDURE AMD_OWNER.LOAD_AMD_ON_BASE_REPAIR_COSTS
IS
/* -----------------------------------------------------------
 * Program Name : AMD_OWNER.LOAD_AMD_ON_BASE_REPAIR_COSTS
 * Version      : 1.0
 * Author       : Bob Menk
 * Created Date : June 30, 2017
 * Purpose      : Load TMP_AMD_ON_BASE_REPAIR_COSTS from TMP_LCCOST
 *                Load AMD_ON_BASE_REPAIR_COSTS from TMP_AMD_ON_BASE_REPAIR_COSTS
 *
 * Comment      :
 *
 * -----------------------------------------------------------
 * Modify by    Mod. Date   Changes
 * ---------    ---------   ----------------------------------
 * Bob Menk     06/Jun/17   Created this procedure based on ins_amd_on_base_repair_costs.sql
 *                          when converting the Load Oracle RMADS interface to
 *                          Oracle to Oracle processing
 */

   v_pkg_proc_nm     VARCHAR2(30) := 'LOAD_AMD_ON_BASE_REPAIR_COSTS';
   v_rows_deleted    NUMBER := 0;
   v_rows_inserted   NUMBER := 0;
   v_rows_updated    NUMBER := 0;

BEGIN
   INSERT INTO TMP_AMD_ON_BASE_REPAIR_COSTS (PART_NO, AJCN, MHR, DW_LOAD_DT)
        SELECT PART_NO, AJCN, SUM (NVL (MANHOUR, 0)), SYSDATE
          FROM TMP_LCCOST
      GROUP BY PART_NO, AJCN;
      
   v_rows_inserted := SQL%ROWCOUNT;
   
   LOAD_BATCH_TBL_COUNTS ('TMP_AMD_ON_BASE_REPAIR_COSTS',
                          v_pkg_proc_nm,
                          -1,
                          v_rows_inserted,
                          v_rows_updated,
                          SYSDATE);
                          
   COMMIT;

   v_rows_inserted := 0;

   INSERT INTO AMD_ON_BASE_REPAIR_COSTS (PART_NO, ON_BASE_REPAIR_COST, DW_LOAD_DT)
        SELECT PART_NO, (SUM (MHR) / COUNT (*)) * 20, SYSDATE
          FROM TMP_AMD_ON_BASE_REPAIR_COSTS
      GROUP BY PART_NO;
      
   v_rows_inserted := SQL%ROWCOUNT;
   
   LOAD_BATCH_TBL_COUNTS ('AMD_ON_BASE_REPAIR_COSTS',
                          v_pkg_proc_nm,
                          -1,
                          v_rows_inserted,
                          v_rows_updated,
                          SYSDATE);

   COMMIT;
END LOAD_AMD_ON_BASE_REPAIR_COSTS;
/