SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_MTBF_V;

/* Formatted on 2008/08/14 12:55 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_part_mtbf_v (part,
                                                        mtbf_type,
                                                        quantity,
                                                        TIMESTAMP
                                                       )
AS
   SELECT part, mtbf_type, quantity, TIMESTAMP
     FROM spoc17v2.v_part_mtbf@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_MTBF_V;

CREATE PUBLIC SYNONYM SPO_PART_MTBF_V FOR AMD_OWNER.SPO_PART_MTBF_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_MTBF_V TO AMD_READER_ROLE;


