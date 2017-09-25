SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_LEAD_TIME_V;

/* Formatted on 2008/08/14 12:55 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_part_lead_time_v (part,
                                                             lead_time_type,
                                                             quantity,
                                                             VARIANCE,
                                                             TIMESTAMP
                                                            )
AS
   SELECT part, lead_time_type, quantity, VARIANCE, TIMESTAMP
     FROM spoc17v2.v_part_lead_time@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_LEAD_TIME_V;

CREATE PUBLIC SYNONYM SPO_PART_LEAD_TIME_V FOR AMD_OWNER.SPO_PART_LEAD_TIME_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_LEAD_TIME_V TO AMD_READER_ROLE;


