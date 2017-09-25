SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_NETWORK_PART_V;

/* Formatted on 2009/03/31 16:04 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_network_part_v (network,
                                                           part,
                                                           timestamp
                                                          )
as
   select "NETWORK", "PART", "TIMESTAMP"
     from spoc17v2.v_network_part@stl_escm_link;


DROP PUBLIC SYNONYM SPO_NETWORK_PART_V;

CREATE PUBLIC SYNONYM SPO_NETWORK_PART_V FOR AMD_OWNER.SPO_NETWORK_PART_V;


GRANT SELECT ON AMD_OWNER.SPO_NETWORK_PART_V TO AMD_READER_ROLE;


