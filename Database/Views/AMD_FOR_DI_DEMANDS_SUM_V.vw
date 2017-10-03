DROP VIEW AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V;

/* Formatted on 10/2/2017 4:58:44 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V
(
   DOC_NO,
   DOC_DATE,
   DOC_DATE_DEFAULTED,
   NSI_SID,
   LOC_SID,
   QUANTITY,
   ACTION_CODE,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT doc_no,
          doc_date,
          doc_date_defaulted,
          nsi_sid,
          CASE
             WHEN SUBSTR (doc_no, 1, 1) = 'M'
             THEN
                amd_utils.GetLocSid ('FB2065')
             WHEN SUBSTR (doc_no, 1, 3) IN ('C17', 'REQ')
             THEN
                amd_utils.GetLocSid ('EY1746')
             ELSE
                loc_sid
          END
             loc__sid,
          quantity,
          action_code,
          last_update_dt
     FROM amd_demands;


DROP PUBLIC SYNONYM AMD_FOR_DI_DEMANDS_SUM_V;

CREATE PUBLIC SYNONYM AMD_FOR_DI_DEMANDS_SUM_V FOR AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V;


GRANT SELECT ON AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V TO AMD_READER_ROLE;
