SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_USERS_V;

/* Formatted on 2008/10/02 13:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_users_v (bems_id,
                                                    last_update_dt,
                                                    stable_email,
                                                    first_name,
                                                    last_name
                                                   )
AS
   SELECT bems_id, last_update_dt,
          REPLACE (stable_email, ' ', '') stable_email,
          TRIM (first_name) first_name, TRIM (last_name) last_name
     FROM amd_users
    WHERE action_code <> 'D'
   UNION
   SELECT mgr.bems_id, last_update_dt,
          REPLACE (people.stable_email, ' ', '') stable_email,
          TRIM (people.first_name) first_name,
          TRIM (people.last_name) last_name
     FROM amd_site_asset_mgr mgr, amd_people_all_v people
    WHERE mgr.action_code <> 'D'
      AND mgr.bems_id = people.bems_id
      AND NOT EXISTS (SELECT NULL
                        FROM amd_users users
                       WHERE mgr.bems_id = users.bems_id);


DROP PUBLIC SYNONYM AMD_USERS_V;

CREATE PUBLIC SYNONYM AMD_USERS_V FOR AMD_OWNER.AMD_USERS_V;


GRANT SELECT ON AMD_OWNER.AMD_USERS_V TO AMD_READER_ROLE;


