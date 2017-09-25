SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;

/* Formatted on 2008/08/14 12:54 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_part_causal_type_v (part,
                                                               causal_type,
                                                               quantity,
                                                               TIMESTAMP
                                                              )
AS
   SELECT part, causal_type, quantity, TIMESTAMP
     FROM spoc17v2.v_part_causal_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM SPO_PART_CAUSAL_TYPE_V FOR AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;


