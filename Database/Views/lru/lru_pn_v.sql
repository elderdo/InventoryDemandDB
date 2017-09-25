DROP VIEW AMD_OWNER.LRU_PN_V;

/* Formatted on 4/5/2012 11:21:17 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.LRU_PN_V
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
     SELECT lru_breakdown."PART_NO",
            lru_breakdown."MASTER_LCN",
            lru_breakdown."LCN",
            lru_breakdown."PCCN",
            lru_breakdown."PLISN",
            lru_breakdown."QPA",
            lru_breakdown."INDENTURE",
            lru_breakdown."SLIC_SMR",
            lru_breakdown."SLIC_WUC",
            lru_breakdown."TOCC",
            lru_breakdown."SLIC_CAGE",
            lru_breakdown."SLIC_NOUN",
            lru_breakdown.gold_noun,
            lru_breakdown."USABLE_FROM",
            lru_breakdown."USABLE_TO",
            lru_breakdown.ims,
            lru_breakdown.aac,
            lru_breakdown.sos,
            lru_breakdown.nsn,
            lru_breakdown."LAST_UPDATE_DT"
       FROM amd_owner.lru_breakdown
      WHERE master_lcn = lcn
   ORDER BY master_lcn, part_no;


DROP PUBLIC SYNONYM LRU_PN_V;

CREATE OR REPLACE PUBLIC SYNONYM LRU_PN_V FOR AMD_OWNER.LRU_PN_V;


GRANT SELECT ON AMD_OWNER.LRU_PN_V TO AMD_READER_ROLE;
