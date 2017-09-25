SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_LEAD_TIME_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_part_lead_time_v (part,
                                                           lead_time_type,
                                                           quantity,
                                                           variance,
                                                           last_modified
                                                          )
as
   select pref.part_no part, new_buy_lead_time lead_time_type,
          pref.order_lead_time quantity, 0 variance,
          part_last_update_dt last_modified
     from amd_preferred_v pref, amd_spare_parts parts, amd_spo_types_v
    where pref.part_no = parts.part_no
      and parts.action_code <> 'D'
      and parts.is_spo_part = 'Y'
   union
   select pref.part_no part, repair_lead_time lead_time_type,
          pref.time_to_repair_off_base quantity, 0 variance,
          part_last_update_dt last_modified
     from amd_preferred_v pref, amd_spare_parts parts, amd_spo_types_v
    where pref.part_no = parts.part_no
      and parts.action_code <> 'D'
      and parts.is_repairable = 'Y'
      and parts.is_consumable = 'N'
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_LEAD_TIME_V;

CREATE PUBLIC SYNONYM X_PART_LEAD_TIME_V FOR AMD_OWNER.X_PART_LEAD_TIME_V;


GRANT SELECT ON AMD_OWNER.X_PART_LEAD_TIME_V TO AMD_READER_ROLE;

