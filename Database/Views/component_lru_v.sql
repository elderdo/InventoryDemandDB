DROP VIEW AMD_OWNER.COMPONENT_LRU_V;

/* Formatted on 4/5/2012 11:04:20 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.COMPONENT_LRU_V
(
   PART_NO,
   MASTER_LCN,
   LCN,
   PCCN,
   PLISN,
   QPA,
   INDENTURE,
   SLIC_SMR,
   SLIC_WUC,
   TOCC,
   SLIC_CAGE,
   SLIC_NOUN,
   GOLD_NOUN,
   USABLE_FROM,
   USABLE_TO,
   IMS,
   AAC,
   SOS,
   NSN,
   LAST_UPDATE_DT
)
AS
     SELECT part_no,
            master_lcn,
            lcn,
            pccn,
            plisn,
            qpa,
            indenture,
            slic_smr,
            slic_wuc,
            tocc,
            slic_cage,
            slic_noun,
            gold_noun,
            usable_from,
            usable_to,
            ims,
            aac,
            sos,
            nsn,
            last_update_dt
       FROM (SELECT brkdwn.*, cat1.smrc cat1_smr
               FROM amd_owner.lru_breakdown brkdwn, amd_owner.pgold_cat1_v cat1
              WHERE master_lcn <> lcn AND part_no = cat1.part(+))
      WHERE (    slic_smr IS NOT NULL
             AND SUBSTR (slic_smr, 1, 3) = 'PAO'
             AND SUBSTR (slic_smr, 6, 1) = 'T')
            OR (    slic_smr IS NULL
                AND SUBSTR (cat1_smr, 1, 3) = 'PAO'
                AND SUBSTR (cat1_smr, 6, 1) = 'T')
   ORDER BY master_lcn, lcn, part_no;


DROP PUBLIC SYNONYM COMPONENT_LRU_V;

CREATE OR REPLACE PUBLIC SYNONYM COMPONENT_LRU_V FOR AMD_OWNER.COMPONENT_LRU_V;


GRANT SELECT ON AMD_OWNER.COMPONENT_LRU_V TO AMD_READER_ROLE;

