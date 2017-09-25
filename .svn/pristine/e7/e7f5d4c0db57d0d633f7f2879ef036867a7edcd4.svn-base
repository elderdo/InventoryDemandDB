SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_USERS_V;

/* Formatted on 2009/01/26 10:39 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_users_v (bems_id,
                                                    last_update_dt,
                                                    stable_email,
                                                    first_name,
                                                    last_name
                                                   )
as
   select bems_id, last_update_dt,
          replace (stable_email, ' ', '') stable_email,
          TRIM (first_name) first_name, TRIM (last_name) last_name
     from amd_users
    where action_code <> 'D'
   union
   select mgr.bems_id, last_update_dt,
          replace (people.stable_email, ' ', '') stable_email,
          TRIM (people.first_name) first_name,
          TRIM (people.last_name) last_name
     from amd_site_asset_mgr mgr, amd_people_all_v people
    where mgr.action_code <> 'D'
      and mgr.bems_id = people.bems_id
      and not exists (select null
                      from amd_users users
                      where mgr.bems_id = users.bems_id
                  and users.action_code <> 'D');


DROP PUBLIC SYNONYM AMD_USERS_V;

CREATE PUBLIC SYNONYM AMD_USERS_V FOR AMD_OWNER.AMD_USERS_V;


GRANT SELECT ON AMD_OWNER.AMD_USERS_V TO AMD_READER_ROLE;



