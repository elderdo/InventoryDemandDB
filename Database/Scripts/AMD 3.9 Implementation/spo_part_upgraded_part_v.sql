SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PART_UPGRADED_PART_V;

/* Formatted on 2009/07/08 17:27 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_part_upgraded_part_v (part,
                                                                 upgraded_part,
                                                                 last_modified
                                                                )
as
   select part, upgraded_part, last_modified
     from spoc17v2.v_part_upgraded_part@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V FOR AMD_OWNER.SPO_PART_UPGRADED_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_PART_UPGRADED_PART_V TO AMD_READER_ROLE;

