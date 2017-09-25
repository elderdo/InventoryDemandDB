SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_REPAIRABLE_PARTS_V;

/* Formatted on 2008/09/24 10:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_repairable_parts_v (part_no,
                                                               action_code,
                                                               last_update_dt
                                                              )
AS
   SELECT parts.part_no, parts.action_code, parts.last_update_dt
     FROM amd_spare_parts parts, amd_nsi_parts nsi
    WHERE parts.is_repairable = 'Y';


DROP PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V;

CREATE PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V FOR AMD_OWNER.AMD_REPAIRABLE_PARTS_V;


GRANT SELECT ON AMD_OWNER.AMD_REPAIRABLE_PARTS_V TO AMD_READER_ROLE;


