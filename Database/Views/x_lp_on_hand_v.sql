SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ON_HAND_V;

/* Formatted on 2009/06/09 15:19 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_on_hand_v (location,
                                                       part,
                                                       on_hand_type,
                                                       quantity,
                                                       timestamp
                                                      )
as
   select spo_location location, invs.part_no part,
          general_on_hand on_hand_type, qty_on_hand quantity,
          invs.last_update_dt timestamp
     from amd_on_hand_invs_sum invs, amd_spare_parts parts, amd_spo_types_v
    where invs.action_code <> 'D'
      and invs.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
   union
   select site_location location, invs.part_no part,
          defective_on_hand on_hand_type, qty_on_hand quantity,
          invs.last_update_dt timestamp
     from amd_repair_invs_sum invs, amd_spare_parts parts, amd_spo_types_v
    where invs.action_code <> 'D'
      and invs.part_no = parts.part_no
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM X_LP_ON_HAND_V FOR AMD_OWNER.X_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_ON_HAND_V TO AMD_READER_ROLE;

