SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_USER_PART_V;

/* Formatted on 2008/10/02 13:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_user_part_v (spo_user,
                                                      part,
                                                      TIMESTAMP
                                                     )
AS
   SELECT TO_CHAR (TO_NUMBER (spousers.logon_id)) spo_user,
          parts.part_no part, parts.last_update_dt TIMESTAMP
     FROM amd_spare_parts parts,
          amd_national_stock_items items,
          amd_planner_logons_v spousers,
          amd_preferred_v pref
    WHERE parts.is_spo_part = 'Y'
      AND parts.nsn = items.nsn
      AND items.action_code <> 'D'
      AND parts.part_no = pref.part_no
      AND pref.planner_code = spousers.planner_code;


DROP PUBLIC SYNONYM X_USER_PART_V;

CREATE PUBLIC SYNONYM X_USER_PART_V FOR AMD_OWNER.X_USER_PART_V;


GRANT SELECT ON AMD_OWNER.X_USER_PART_V TO AMD_READER_ROLE;


