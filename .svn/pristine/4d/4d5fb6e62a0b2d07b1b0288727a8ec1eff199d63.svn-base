SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V;

/* Formatted on 2009/07/08 17:23 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_override_reason_type_v (id,
                                                                   name,
                                                                   description
                                                                  )
as
   select "ID", "NAME", "DESCRIPTION"
     from spoc17v2.v_override_reason_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_OVERRIDE_REASON_TYPE_V;

CREATE PUBLIC SYNONYM SPO_OVERRIDE_REASON_TYPE_V FOR AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V TO AMD_READER_ROLE;

