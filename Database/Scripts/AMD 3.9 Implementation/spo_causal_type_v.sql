SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_CAUSAL_TYPE_V;

/* Formatted on 2009/09/15 13:47 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_causal_type_v (id,
                                                          name,
                                                          description,
                                                          last_modified
                                                         )
as
   select "ID", "NAME", "DESCRIPTION", last_modified
     from spoc17v2.v_causal_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM SPO_CAUSAL_TYPE_V FOR AMD_OWNER.SPO_CAUSAL_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_CAUSAL_TYPE_V TO AMD_READER_ROLE;


