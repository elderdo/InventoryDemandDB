SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_USER_USER_TYPE_V;

/* Formatted on 2009/01/27 13:15 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_user_user_type_v (spo_user,
                                                             user_type,
                                                             timestamp
                                                            )
as
   select "SPO_USER", "USER_TYPE", "TIMESTAMP"
     from spoc17v2.v_user_user_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_USER_USER_TYPE_V;

CREATE PUBLIC SYNONYM SPO_USER_USER_TYPE_V FOR AMD_OWNER.SPO_USER_USER_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_USER_USER_TYPE_V TO AMD_READER_ROLE;


