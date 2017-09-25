SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V;

/* Formatted on 2008/03/19 11:56 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_rsp_sum_consumables_v (part_no,
                                                                  rsp_location,
                                                                  qty_on_hand,
                                                                  rsp_level,
                                                                  rop_or_roq,
                                                                  action_code,
                                                                  last_update_dt,
                                                                  override_type
                                                                 )
AS
   SELECT   part_no, rsp_location, qty_on_hand, rsp_level,
            rsp_level - 1 rop_or_roq, action_code, last_update_dt,
            override_type
       FROM amd_rsp_sum
      WHERE override_type = 'ROP Fixed'
   UNION
   SELECT   part_no, rsp_location, qty_on_hand, rsp_level,
            amd_defaults.getroq rop_or_roq, action_code, last_update_dt,
            amd_lp_override_consumabl_pkg.getroq_type
       FROM amd_rsp_sum
      WHERE override_type = 'ROP Fixed'
   ORDER BY 1, 2;


DROP PUBLIC SYNONYM AMD_RSP_SUM_CONSUMABLES_V;

CREATE PUBLIC SYNONYM AMD_RSP_SUM_CONSUMABLES_V FOR AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V;


GRANT SELECT ON AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V TO AMD_READER_ROLE;


