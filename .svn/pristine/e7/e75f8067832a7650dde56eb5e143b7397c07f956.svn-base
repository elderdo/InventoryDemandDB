SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_BACKORDER_V;

/* Formatted on 2009/07/08 15:49 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_backorder_v (location,
                                                         part,
                                                         backorder_type,
                                                         quantity,
                                                         last_modified
                                                        )
as
   select spo_location location, backorder.spo_prime_part_no part,
          general_backorder backorder_type, qty,
          backorder.last_update_dt last_modified
     from amd_backorder_sum backorder, amd_spare_parts parts, amd_spo_types_v
    where backorder.action_code <> 'D'
      and backorder.spo_prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM X_LP_BACKORDER_V FOR AMD_OWNER.X_LP_BACKORDER_V;


GRANT SELECT ON AMD_OWNER.X_LP_BACKORDER_V TO AMD_READER_ROLE;

