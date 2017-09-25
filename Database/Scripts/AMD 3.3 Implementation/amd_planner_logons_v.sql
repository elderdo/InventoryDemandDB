SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_PLANNER_LOGONS_V;

/* Formatted on 2008/10/02 13:17 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_planner_logons_v (planner_code,
                                                             logon_id,
                                                             data_source,
                                                             default_ind,
                                                             last_update_dt
                                                            )
AS
   SELECT planner_code, logon_id, data_source, default_ind, last_update_dt
     FROM amd_planner_logons
    WHERE action_code <> 'D'
   UNION
   SELECT planner_code, bems_id login_id, '4' data_source, NULL default_ind,
          last_update_dt
     FROM amd_site_asset_mgr mgr
    WHERE mgr.action_code <> 'D' AND NOT EXISTS (SELECT NULL
                                                   FROM amd_planner_logons a
                                                  WHERE bems_id = logon_id);


DROP PUBLIC SYNONYM AMD_PLANNER_LOGONS_V;

CREATE PUBLIC SYNONYM AMD_PLANNER_LOGONS_V FOR AMD_OWNER.AMD_PLANNER_LOGONS_V;


GRANT SELECT ON AMD_OWNER.AMD_PLANNER_LOGONS_V TO AMD_READER_ROLE;


