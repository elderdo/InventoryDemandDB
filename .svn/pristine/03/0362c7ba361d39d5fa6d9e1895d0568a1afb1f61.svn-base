DROP VIEW AMD_OWNER.SRU_PN_V;

/* Formatted on 6/19/2012 12:45:18 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SRU_PN_V
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
             AND SUBSTR (slic_smr, 1, 3) = 'PAF'
             AND SUBSTR (slic_smr, 4, 1) <> 'Z'
             AND SUBSTR (slic_smr, 5, 1) <> 'Z')
            OR (    slic_smr IS NULL
                AND SUBSTR (cat1_smr, 1, 3) = 'PAF'
                AND SUBSTR (cat1_smr, 4, 1) <> 'Z'
                AND SUBSTR (slic_smr, 5, 1) <> 'Z')
   ORDER BY master_lcn, lcn, part_no;


DROP PUBLIC SYNONYM SRU_PN_V;

CREATE OR REPLACE PUBLIC SYNONYM SRU_PN_V FOR AMD_OWNER.SRU_PN_V;


GRANT SELECT ON AMD_OWNER.SRU_PN_V TO AMD_READER_ROLE;
