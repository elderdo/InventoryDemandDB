SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_CONSUMABLE_PARTS_V;

/* Formatted on 2008/09/22 23:47 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_consumable_parts_v (part_no,
                                                               action_code,
                                                               last_update_dt
                                                              )
AS
   SELECT parts.part_no, parts.action_code, parts.last_update_dt
     FROM amd_spare_parts parts
    WHERE parts.is_consumable = 'Y';


DROP PUBLIC SYNONYM AMD_CONSUMABLE_PARTS_V;

CREATE PUBLIC SYNONYM AMD_CONSUMABLE_PARTS_V FOR AMD_OWNER.AMD_CONSUMABLE_PARTS_V;


GRANT SELECT ON AMD_OWNER.AMD_CONSUMABLE_PARTS_V TO AMD_READER_ROLE;


