DROP VIEW AMD_OWNER.SLIC_HA_SHELF_LIFE_V;

/* Formatted on 7/9/2012 4:34:40 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HA_SHELF_LIFE_V
(
   PART_NO,
   MFGR,
   SMR_CODE,
   SHELF_LIFE,
   STORAGE_DAYS,
   UNIT_VOLUME
)
AS
   SELECT smr.part_no pa0rt_no,
          smr.mfgr,
          smr.smr_code,
          shlifeha shelf_life,
          storage_days,
          (ulengtha * uwidthha * uheighha) / 1728 unit_volume
     FROM pslms_ha@amd_pslms_link.boeingdb ha,
          amd_shelf_life_codes sl,
          amd_owner.slic_hg_smr_codes_v smr
    WHERE     ha.refnumha = smr.part_no
          AND ha.cagecdxh = smr.mfgr
          AND shlifeha = sl.sl_code(+);


DROP PUBLIC SYNONYM SLIC_HA_SHELF_LIFE_V;

CREATE OR REPLACE PUBLIC SYNONYM SLIC_HA_SHELF_LIFE_V FOR AMD_OWNER.SLIC_HA_SHELF_LIFE_V;


GRANT SELECT ON AMD_OWNER.SLIC_HA_SHELF_LIFE_V TO AMD_READER_ROLE;
