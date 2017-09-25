SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_OVERRIDE_V;

/* Formatted on 2009/07/14 14:00 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_lp_override_v (part,
                                                          location,
                                                          override_type,
                                                          quantity,
                                                          override_reason,
                                                          override_user,
                                                          begin_date,
                                                          end_date,
                                                          last_modified
                                                         )
as
   select   "PART", "LOCATION", "OVERRIDE_TYPE", "QUANTITY",
            "OVERRIDE_REASON", "OVERRIDE_USER", "BEGIN_DATE", "END_DATE",
            last_modified
       from spoc17v2.v_lp_override@stl_escm_link
   order by location, part, override_type;


DROP PUBLIC SYNONYM SPO_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM SPO_LP_OVERRIDE_V FOR AMD_OWNER.SPO_LP_OVERRIDE_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_OVERRIDE_V TO AMD_READER_ROLE;

