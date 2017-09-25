SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_FLAG_V;

/* Formatted on 2009/05/11 13:33 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_flag_v (name,
                                                   description,
                                                   flag_type,
                                                   value,
                                                   timestamp
                                                  )
as
   select "NAME", "DESCRIPTION", "FLAG_TYPE", "VALUE", "TIMESTAMP"
     from spoc17v2.v_flag@stl_escm_link;


DROP PUBLIC SYNONYM SPO_FLAG_V;

CREATE PUBLIC SYNONYM SPO_FLAG_V FOR AMD_OWNER.SPO_FLAG_V;


GRANT SELECT ON AMD_OWNER.SPO_FLAG_V TO AMD_READER_ROLE;


