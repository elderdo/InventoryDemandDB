SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_V;

/* Formatted on 2009/07/08 17:09 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_confirmed_request_v (id,
                                                                name,
                                                                request_type,
                                                                last_modified
                                                               )
as
   select id, name, request_type, last_modified
     from spoc17v2.v_confirmed_request@stl_escm_link;


DROP PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V FOR AMD_OWNER.SPO_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.SPO_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;

