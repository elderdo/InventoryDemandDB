SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_UPGRADED_PART_V;

/* Formatted on 2008/08/14 12:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_part_upgraded_part_v (part,
                                                                 upgraded_part,
                                                                 TIMESTAMP
                                                                )
AS
   SELECT part, upgraded_part, TIMESTAMP
     FROM spoc17v2.v_part_upgraded_part@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V FOR AMD_OWNER.SPO_PART_UPGRADED_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_UPGRADED_PART_V TO AMD_READER_ROLE;


