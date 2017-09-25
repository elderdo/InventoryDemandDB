SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PARAMETER_V;

/* Formatted on 2009/07/08 17:25 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_parameter_v (name,
                                                        description,
                                                        parameter_type,
                                                        value,
                                                        last_modified
                                                       )
as
   select "NAME", "DESCRIPTION", "PARAMETER_TYPE", "VALUE", last_modified
     from spoc17v2.v_parameter@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PARAMETER_V;

CREATE PUBLIC SYNONYM SPO_PARAMETER_V FOR AMD_OWNER.SPO_PARAMETER_V;


GRANT SELECT ON AMD_OWNER.SPO_PARAMETER_V TO AMD_READER_ROLE;

