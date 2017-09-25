SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_USER_USER_TYPE_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_user_user_type_v (spo_user,
                                                           user_type,
                                                           data_source,
                                                           last_modified
                                                          )
as
   select distinct TO_CHAR (TO_NUMBER (logon_id)) spo_user,
                   'PLANNER' user_type, 'AMD_PLANNER_LOGONS_V' data_source,
                   last_update_dt
              from amd_planner_logons_v
   union
   select TO_CHAR (TO_NUMBER (bems_id)) spo_user, user_type,
          'AMD_USER_TYPE' data_source, last_update_dt
     from amd_user_type
    where action_code <> 'D'
   union
   select TO_CHAR (TO_NUMBER (bems_id)) spo_user, 'SYSTEM' user_type,
          'AMD_SITE_ASSET_MGR', last_update_dt
     from amd_site_asset_mgr
    where action_code <> 'D' and bems_id not in (select bems_id
                                                   from amd_user_type
                                                  where action_code <> 'D')
   union
   select TO_CHAR (TO_NUMBER (bems_id)) spo_user, 'ADMINISTRATOR' user_type,
          'AMD_SITE_ASSET_MGR', last_update_dt
     from amd_site_asset_mgr
    where action_code <> 'D' and bems_id not in (select bems_id
                                                   from amd_user_type
                                                  where action_code <> 'D')
   union
   select TO_CHAR (TO_NUMBER (bems_id)) spo_user, 'PLANNER' user_type,
          'AMD_SITE_ASSET_MGR', last_update_dt
     from amd_site_asset_mgr
    where action_code <> 'D' and bems_id not in (select bems_id
                                                   from amd_user_type
                                                  where action_code <> 'D');


DROP PUBLIC SYNONYM X_USER_USER_TYPE_V;

CREATE PUBLIC SYNONYM X_USER_USER_TYPE_V FOR AMD_OWNER.X_USER_USER_TYPE_V;


GRANT SELECT ON AMD_OWNER.X_USER_USER_TYPE_V TO AMD_OWNER_DEVELOPER;

GRANT SELECT ON AMD_OWNER.X_USER_USER_TYPE_V TO AMD_READER_ROLE;

