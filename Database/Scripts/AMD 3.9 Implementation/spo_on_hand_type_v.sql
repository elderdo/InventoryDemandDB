SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_ON_HAND_TYPE_V;

/* Formatted on 2009/07/08 17:23 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_on_hand_type_v (id,
                                                           name,
                                                           description,
                                                           last_modified
                                                          )
as
   select "ID", "NAME", "DESCRIPTION", last_modified
     from spoc17v2.v_on_hand_type@stl_escm_link;


DROP PUBLIC SYNONYM SPO_ON_HAND_TYPE_V;

CREATE PUBLIC SYNONYM SPO_ON_HAND_TYPE_V FOR AMD_OWNER.SPO_ON_HAND_TYPE_V;


GRANT SELECT ON AMD_OWNER.SPO_ON_HAND_TYPE_V TO AMD_READER_ROLE;

