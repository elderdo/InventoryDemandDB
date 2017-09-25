SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_DEFAULT_USERS_V;

/* Formatted on 2008/07/09 15:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_default_users_v (bems_id,
                                                            stable_email,
                                                            last_name,
                                                            first_name,
                                                            effective_date,
                                                            default_type
                                                           )
AS
   SELECT param_value, stable_email, last_name, first_name, effective_date,
          'CONSUMABLE'
     FROM amd_param_changes, amd_people_all_v
    WHERE param_key = 'consumable_logon_id'
      AND effective_date = (SELECT MAX (effective_date)
                              FROM amd_param_changes
                             WHERE param_key = 'consumable_logon_id')
      AND param_value = bems_id
   UNION
   SELECT param_value, stable_email, last_name, first_name, effective_date,
          'REPAIRABLE'
     FROM amd_param_changes, amd_people_all_v
    WHERE param_key = 'repairable_logon_id'
      AND effective_date = (SELECT MAX (effective_date)
                              FROM amd_param_changes
                             WHERE param_key = 'repairable_logon_id')
      AND param_value = bems_id;


DROP PUBLIC SYNONYM AMD_DEFAULT_USERS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_USERS_V FOR AMD_OWNER.AMD_DEFAULT_USERS_V;


GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_USERS_V TO AMD_READER_ROLE;


