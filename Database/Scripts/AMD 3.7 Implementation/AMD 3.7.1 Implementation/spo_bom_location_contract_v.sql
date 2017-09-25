SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V;

/* Formatted on 2009/03/31 16:09 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_bom_location_contract_v (location,
                                                                    bom,
                                                                    contract_type,
                                                                    customer_location,
                                                                    begin_date,
                                                                    end_date,
                                                                    quantity,
                                                                    timestamp
                                                                   )
as
   select location, bom, contract_type, customer_location, begin_date,
          end_date, quantity, timestamp
     from spoc17v2.v_bom_location_contract@stl_escm_link;


DROP PUBLIC SYNONYM SPO_BOM_LOCATION_CONTRACT_V;

CREATE PUBLIC SYNONYM SPO_BOM_LOCATION_CONTRACT_V FOR AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V;


GRANT SELECT ON AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V TO AMD_READER_ROLE;


