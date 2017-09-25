SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_DEFAULT_PLANNERS_V;

/* Formatted on 2008/07/09 15:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_default_planners_v (planner_code,
                                                               default_type,
                                                               effective_date
                                                              )
AS
   SELECT param_value, 'CONSUMABLE', effective_date
     FROM amd_param_changes
    WHERE param_key = 'consumable_planner_code'
      AND effective_date = (SELECT MAX (effective_date)
                              FROM amd_param_changes
                             WHERE param_key = 'consumable_planner_code')
   UNION
   SELECT param_value, 'REPAIRABLE', effective_date
     FROM amd_param_changes
    WHERE param_key = 'repairable_planner_code'
      AND effective_date = (SELECT MAX (effective_date)
                              FROM amd_param_changes
                             WHERE param_key = 'repairable_planner_code');


DROP PUBLIC SYNONYM AMD_DEFAULT_PLANNERS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_PLANNERS_V FOR AMD_OWNER.AMD_DEFAULT_PLANNERS_V;


GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_PLANNERS_V TO AMD_READER_ROLE;


