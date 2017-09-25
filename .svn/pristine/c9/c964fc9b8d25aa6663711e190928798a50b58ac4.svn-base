DROP VIEW AMD_OWNER.GOLDSA_REQ1_V;

/* Formatted on 2/21/2017 6:50:39 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.GOLDSA_REQ1_V
(
   REQUEST_ID,
   CREATED_DATETIME,
   QTY_REQUESTED,
   PRIME,
   NSN,
   STATUS,
   ALLOW_ALTS_YN,
   QTY_RESERVED,
   SELECT_FROM_PART,
   SELECT_FROM_SC,
   SELECT_FROM_LOC_ID,
   QTY_CANC,
   MILS_SOURCE_DIC,
   QTY_DUE,
   QTY_ISSUED,
   NEED_DATE,
   REQUEST_PRIORITY,
   PURPOSE_CODE
)
AS
   SELECT TRIM (request_id),
          r.created_datetime,
          qty_requested,
          TRIM (r.prime),
          TRIM (r.nsn),
          status,
          allow_alts_yn,
          qty_reserved,
          TRIM (select_from_part),
          TRIM (select_from_sc),
          CASE
             WHEN     LENGTH (TRIM (select_from_sc)) >=
                         amd_defaults.getStartLocId + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (select_from_sc),
                                            amd_defaults.getStartLocId,
                                            6))
             THEN
                SUBSTR (TRIM (select_from_sc), 8, 6)
             ELSE
                NULL
          END
             select_from_loc_id,
          qty_canc,
          TRIM (mils_source_dic),
          qty_due,
          qty_issued,
          need_date,
          request_priority,
          purpose_code
     FROM cat1@amd_goldsa_link c, req1@amd_goldsa_link r
    WHERE     c.part = r.select_from_part
          AND c.source_code = 'F77'
          AND r.select_from_sc = 'SATCAA0001C17G';


DROP PUBLIC SYNONYM GOLDSA_REQ1_V;

CREATE PUBLIC SYNONYM GOLDSA_REQ1_V FOR AMD_OWNER.GOLDSA_REQ1_V;


GRANT SELECT ON AMD_OWNER.GOLDSA_REQ1_V TO AMD_READER_ROLE;
