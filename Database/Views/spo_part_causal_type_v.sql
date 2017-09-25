SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;

/* Formatted on 2009/07/08 17:25 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_part_causal_type_v (part,
                                                               causal_type,
                                                               quantity,
                                                               last_modified
                                                              )
as
   select part, causal_type, quantity, last_modified
     from spoc17v2.v_part_causal_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_CAUSAL_V;

CREATE PUBLIC SYNONYM SPO_PART_CAUSAL_V FOR AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;

