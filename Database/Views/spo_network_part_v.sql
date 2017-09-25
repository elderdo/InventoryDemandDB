SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_NETWORK_PART_V;

/* Formatted on 2009/07/08 17:22 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_network_part_v (network,
                                                           part,
                                                           last_modified
                                                          )
as
   select "NETWORK", "PART", last_modified
     from spoc17v2.v_network_part@stl_escm_link;


DROP PUBLIC SYNONYM SPO_NETWORK_PART_V;

CREATE PUBLIC SYNONYM SPO_NETWORK_PART_V FOR AMD_OWNER.SPO_NETWORK_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_NETWORK_PART_V TO AMD_READER_ROLE;

