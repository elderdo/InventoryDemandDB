SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_SPO_PARTS_V;

/* Formatted on 2008/09/22 23:34 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_spo_parts_v (part_no,
                                                        prime_part_no,
                                                        part_type,
                                                        assignment_date,
                                                        spo_prime_part_no
                                                       )
AS
   SELECT parts.part_no, items.prime_part_no,
          CASE
             WHEN parts.is_consumable = 'Y'
                THEN 'Consumable'
             WHEN parts.is_repairable = 'Y'
                THEN 'Repairable'
          END part_type,
          nsi.assignment_date, parts.spo_prime_part_no
     FROM amd_spare_parts parts,
          amd_national_stock_items items,
          amd_nsi_parts nsi
    WHERE parts.is_spo_part = 'Y'
      AND items.action_code <> 'D'
      AND parts.nsn = items.nsn
      AND parts.part_no = nsi.part_no
      AND nsi.unassignment_date IS NULL
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM AMD_SPO_PARTS_V;

CREATE PUBLIC SYNONYM AMD_SPO_PARTS_V FOR AMD_OWNER.AMD_SPO_PARTS_V;


GRANT SELECT ON AMD_OWNER.AMD_SPO_PARTS_V TO AMD_READER_ROLE;


