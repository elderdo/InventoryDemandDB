SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_USER_PART_V;

/* Formatted on 2009/07/08 17:29 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_user_part_v (spo_user,
                                                        part,
                                                        last_modified
                                                       )
as
   select "SPO_USER", "PART", uparts.last_modified last_modified
     from spoc17v2.v_user_part@stl_escm_link uparts,
          spoc17v2.v_part@stl_escm_link parts
    where uparts.part = parts.name and parts.end_date is null;


DROP PUBLIC SYNONYM SPO_USER_PART_V;

CREATE PUBLIC SYNONYM SPO_USER_PART_V FOR AMD_OWNER.SPO_USER_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_USER_PART_V TO AMD_READER_ROLE;

