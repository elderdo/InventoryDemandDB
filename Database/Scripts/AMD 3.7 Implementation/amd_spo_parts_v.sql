SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_SPO_PARTS_V;

/* Formatted on 2009/02/06 12:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_spo_parts_v (part_no,
                                                        prime_part_no,
                                                        part_type,
                                                        assignment_date,
                                                        spo_prime_part_no
                                                       )
as
   select parts.part_no, items.prime_part_no,
          case
             when parts.is_consumable = 'Y'
                then 'Consumable'
             when parts.is_repairable = 'Y'
                then 'Repairable'
          end part_type,
          nsi.assignment_date, parts.spo_prime_part_no
     from amd_spare_parts parts,
          amd_national_stock_items items,
          amd_nsi_parts nsi
    where parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and items.action_code <> 'D'
      and parts.nsn = items.nsn
      and parts.part_no = nsi.part_no
      and nsi.unassignment_date is null;


DROP PUBLIC SYNONYM AMD_SPO_PARTS_V;

CREATE PUBLIC SYNONYM AMD_SPO_PARTS_V FOR AMD_OWNER.AMD_SPO_PARTS_V;


GRANT SELECT ON AMD_OWNER.AMD_SPO_PARTS_V TO AMD_READER_ROLE;

