SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_USER_PART_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_user_part_v (spo_user,
                                                      part,
                                                      last_modified
                                                     )
as
   select TO_CHAR (TO_NUMBER (spousers.logon_id)) spo_user,
          parts.part_no part, parts.last_update_dt last_modified
     from amd_spare_parts parts,
          amd_national_stock_items items,
          amd_planner_logons_v spousers,
          amd_preferred_v pref
    where parts.is_spo_part = 'Y'
      and parts.nsn = items.nsn
      and items.action_code <> 'D'
      and parts.part_no = pref.part_no
      and pref.planner_code = spousers.planner_code;


DROP PUBLIC SYNONYM X_USER_PART_V;

CREATE PUBLIC SYNONYM X_USER_PART_V FOR AMD_OWNER.X_USER_PART_V;


GRANT SELECT ON AMD_OWNER.X_USER_PART_V TO AMD_READER_ROLE;

