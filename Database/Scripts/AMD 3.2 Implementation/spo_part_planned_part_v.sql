SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_PLANNED_PART_V;

/* Formatted on 2008/08/14 12:56 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_part_planned_part_v (part,
                                                                planned_part,
                                                                supersession_type,
                                                                begin_date,
                                                                end_date,
                                                                TIMESTAMP,
                                                                spo_user
                                                               )
AS
   SELECT part, planned_part, supersession_type, begin_date, end_date,
          TIMESTAMP, spo_user
     FROM spoc17v2.v_part_planned_part@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_PLANNED_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_PLANNED_PART_V FOR AMD_OWNER.SPO_PART_PLANNED_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_PLANNED_PART_V TO AMD_READER_ROLE;


