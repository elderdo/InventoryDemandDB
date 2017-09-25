SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;

/* Formatted on 2009/03/31 16:10 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_bom_location_contract_v (base_name,
                                                                  quantity,
                                                                  begin_date,
                                                                  end_date
                                                                 )
as
   select   spo_location, count (aaa.tail_no), '06/14/1993', '12/31/4100'
       from amd_spare_networks asn, amd_ac_assigns aaa
      where asn.loc_sid = aaa.loc_sid and asn.loc_type = 'MOB'
   group by asn.spo_location
   union
   select   spo_location, 0, '06/14/1993', '12/31/4100'
       from amd_spare_networks asn
      where loc_type = 'FSL'
   group by spo_location;


DROP PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V;

CREATE PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V FOR AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;


GRANT SELECT ON AMD_OWNER.X_BOM_LOCATION_CONTRACT_V TO AMD_READER_ROLE;


