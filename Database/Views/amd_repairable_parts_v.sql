SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_REPAIRABLE_PARTS_V;

/* Formatted on 2008/08/14 12:48 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_repairable_parts_v (part_no)
AS
   SELECT parts.part_no
     FROM amd_spare_parts parts,
          amd_national_stock_items items,
          amd_preferred_v pref
    WHERE parts.nsn = items.nsn
      AND pref.part_no = parts.part_no
      AND parts.action_code <> 'D'
      AND items.action_code <> 'D'
      AND amd_utils.isrepairablesmrcodeyorn (pref.smr_code) = 'Y';


DROP PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V;

CREATE PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V FOR AMD_OWNER.AMD_REPAIRABLE_PARTS_V;


GRANT SELECT ON AMD_OWNER.AMD_REPAIRABLE_PARTS_V TO AMD_READER_ROLE;


