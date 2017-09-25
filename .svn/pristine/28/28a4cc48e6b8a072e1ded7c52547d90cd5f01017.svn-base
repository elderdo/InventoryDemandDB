SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;

/* Formatted on 2009/07/14 00:02 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_rsp_sum_repairables_v (part_no,
                                                                  rsp_location,
                                                                  qty_on_hand,
                                                                  rsp_level,
                                                                  action_code,
                                                                  last_update_dt,
                                                                  override_type
                                                                 )
as
   select   part_no, rsp_location, qty_on_hand, rsp_level, action_code,
            last_update_dt, override_type
       from amd_rsp_sum
      where override_type = (select tsl_fixed_override
                               from amd_spo_types_v)
   order by 1, 2;


DROP PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V;

CREATE PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V FOR AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;


GRANT SELECT ON AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V TO AMD_READER_ROLE;

