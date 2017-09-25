DROP VIEW AMD_OWNER.PGOLD_RSV1_V;

/* Formatted on 7/9/2012 4:25:14 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_RSV1_V
(
   RESERVE_ID,
   FORM_REQUIRED_YN,
   REMARK_MOVE_ONLY_YN,
   CREATED_DOCDATE,
   TO_SC,
   ITEM_ID,
   STATUS
)
AS
   SELECT TRIM (reserve_id),
          form_required_yn,
          remark_move_only_yn,
          created_docdate,
          TRIM (to_sc),
          TRIM (item_id),
          status
     FROM rsv1@amd_pgoldlb_link;


DROP PUBLIC SYNONYM PGOLD_RSV1_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_RSV1_V FOR AMD_OWNER.PGOLD_RSV1_V;


GRANT SELECT ON AMD_OWNER.PGOLD_RSV1_V TO AMD_READER_ROLE;
