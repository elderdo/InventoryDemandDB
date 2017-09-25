SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_OVERRIDE_V;

/* Formatted on 2009/07/14 14:07 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_override_v (location,
                                                        part,
                                                        override_type,
                                                        quantity,
                                                        override_reason,
                                                        override_user,
                                                        begin_date,
                                                        end_date,
                                                        source,
                                                        last_modified
                                                       )
as
   select "LOCATION", "PART", "OVERRIDE_TYPE", "QUANTITY", "OVERRIDE_REASON",
          "OVERRIDE_USER", "BEGIN_DATE", "END_DATE", "SOURCE",
          "LAST_MODIFIED"
     from amd_lp_override_wk_v lpo
    where exists (
             select   null
                 from amd_lp_override_wk_v, amd_spo_types_v
                where location = lpo.location
                  and part = lpo.part
                  and override_type in
                         (rop_fixed_override,
                          roq_fixed_override,
                          tsl_fixed_override
                         )
             group by location, part
               having sum (quantity) <> 0);


DROP PUBLIC SYNONYM X_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM X_LP_OVERRIDE_V FOR AMD_OWNER.X_LP_OVERRIDE_V;


GRANT SELECT ON AMD_OWNER.X_LP_OVERRIDE_V TO AMD_READER_ROLE;

