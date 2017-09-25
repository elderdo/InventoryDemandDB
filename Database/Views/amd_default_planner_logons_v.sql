SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V;

/* Formatted on 2008/07/09 15:55 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_default_planner_logons_v (planner_code,
                                                                     planner_code_effective_date,
                                                                     logon_id,
                                                                     logon_id_effective_date,
                                                                     data_source,
                                                                     default_type
                                                                    )
AS
   SELECT planner.planner_code, planner.effective_date, users.bems_id,
          users.effective_date, '3' data_source, users.default_type
     FROM amd_default_planners_v planner, amd_default_users_v users
    WHERE planner.default_type = users.default_type;


DROP PUBLIC SYNONYM AMD_DEFAULT_PLANNER_LOGONS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_PLANNER_LOGONS_V FOR AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V;


GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V TO AMD_READER_ROLE;


