DROP VIEW AMD_OWNER.COMPONENT_PART_V;

/* Formatted on 4/5/2012 11:05:04 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.COMPONENT_PART_V
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
   SELECT "PART_NO",
          "MASTER_LCN",
          "LCN",
          "PCCN",
          "PLISN",
          "QPA",
          "INDENTURE",
          "SLIC_SMR",
          "SLIC_WUC",
          "TOCC",
          "SLIC_CAGE",
          "SLIC_NOUN",
          gold_noun,
          "USABLE_FROM",
          "USABLE_TO",
          ims,
          aac,
          sos,
          nsn,
          "LAST_UPDATE_DT"
     FROM lru_breakdown
    WHERE master_lcn <> lcn
   MINUS
   (SELECT "PART_NO",
           "MASTER_LCN",
           "LCN",
           "PCCN",
           "PLISN",
           "QPA",
           "INDENTURE",
           "SLIC_SMR",
           "SLIC_WUC",
           "TOCC",
           "SLIC_CAGE",
           "SLIC_NOUN",
           gold_noun,
           "USABLE_FROM",
           "USABLE_TO",
           ims,
           aac,
           sos,
           nsn,
           "LAST_UPDATE_DT"
      FROM sru_pn_v
    UNION
    SELECT "PART_NO",
           "MASTER_LCN",
           "LCN",
           "PCCN",
           "PLISN",
           "QPA",
           "INDENTURE",
           "SLIC_SMR",
           "SLIC_WUC",
           "TOCC",
           "SLIC_CAGE",
           "SLIC_NOUN",
           gold_noun,
           "USABLE_FROM",
           "USABLE_TO",
           ims,
           aac,
           sos,
           nsn,
           "LAST_UPDATE_DT"
      FROM component_lru_v)
   ORDER BY master_lcn, lcn, part_no;


DROP PUBLIC SYNONYM COMPONENT_PART_V;

CREATE OR REPLACE PUBLIC SYNONYM COMPONENT_PART_V FOR AMD_OWNER.COMPONENT_PART_V;

GRANT SELECT ON AMD_OWNER.COMPONENT_PART_V TO AMD_READER_ROLE;

