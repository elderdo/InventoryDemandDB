SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;

/* Formatted on 2008/03/19 11:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_rsp_sum_repairables_v (part_no,
                                                                  rsp_location,
                                                                  qty_on_hand,
                                                                  rsp_level,
                                                                  action_code,
                                                                  last_update_dt,
                                                                  override_type
                                                                 )
AS
   SELECT   part_no, rsp_location, qty_on_hand, rsp_level, action_code,
            last_update_dt, override_type
       FROM amd_rsp_sum
      WHERE override_type = 'TSL Fixed'
   ORDER BY 1, 2;


DROP PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V;

CREATE PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V FOR AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;


GRANT SELECT ON AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V TO AMD_READER_ROLE;


