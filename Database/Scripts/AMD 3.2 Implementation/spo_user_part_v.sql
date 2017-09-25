SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_USER_PART_V;

/* Formatted on 2008/08/14 12:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_user_part_v (spo_user,
                                                        part,
                                                        TIMESTAMP
                                                       )
AS
   SELECT "SPO_USER", "PART", uparts."TIMESTAMP" TIMESTAMP
     FROM spoc17v2.v_user_part@stl_escm_link uparts,
          spoc17v2.v_part@stl_escm_link parts
    WHERE uparts.part = parts.NAME AND parts.end_date IS NULL;


DROP PUBLIC SYNONYM SPO_USER_PART_V;

CREATE PUBLIC SYNONYM SPO_USER_PART_V FOR AMD_OWNER.SPO_USER_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_USER_PART_V TO AMD_READER_ROLE;


