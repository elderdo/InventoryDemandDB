SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_PLANNER_LOGONS_V;

/* Formatted on 2008/11/05 09:12 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_planner_logons_v (planner_code,
                                                             logon_id,
                                                             data_source,
                                                             default_ind,
                                                             last_update_dt
                                                            )
AS
   SELECT planner_code, logon_id, data_source, default_ind, last_update_dt
     FROM amd_planner_logons
    WHERE action_code <> 'D';


DROP PUBLIC SYNONYM AMD_PLANNER_LOGONS_V;

CREATE PUBLIC SYNONYM AMD_PLANNER_LOGONS_V FOR AMD_OWNER.AMD_PLANNER_LOGONS_V;


GRANT SELECT ON AMD_OWNER.AMD_PLANNER_LOGONS_V TO AMD_READER_ROLE;


