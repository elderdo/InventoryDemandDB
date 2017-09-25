SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;

/* Formatted on 2009/04/10 13:51 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_bom_location_contract_v (location,
                                                                  bom,
                                                                  contract,
                                                                  contract_type,
                                                                  customer_location,
                                                                  begin_date,
                                                                  end_date,
                                                                  quantity
                                                                 )
as
   select   loc_id, 'C17', 'C17', 'A', 'AF',
            to_date ('06/14/1993', 'MM/DD/YYYY'),
            to_date ('12/31/4100', 'MM/DD/YYYY'), count (aaa.tail_no)
       from amd_spare_networks asn, amd_ac_assigns aaa
      where asn.loc_sid = aaa.loc_sid
        and (    assignment_start < CURRENT_DATE
             and (assignment_end > CURRENT_DATE or assignment_end is null)
            )
        and asn.spo_location is not null
        and asn.loc_type = 'MOB'
   group by asn.loc_id;


DROP PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V;

CREATE PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V FOR AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;


GRANT SELECT ON AMD_OWNER.X_BOM_LOCATION_CONTRACT_V TO AMD_READER_ROLE;


