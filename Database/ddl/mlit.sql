SET DEFINE OFF;
DROP PUBLIC SYNONYM MLIT;

CREATE PUBLIC SYNONYM MLIT FOR AMD_OWNER.MLIT;


DROP MATERIALIZED VIEW AMD_OWNER.MLIT;
CREATE MATERIALIZED VIEW AMD_OWNER.MLIT 
TABLESPACE AMD_INDEX
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
USING INDEX
            TABLESPACE AMD_INDEX
            PCTFREE    10
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          64K
                        MINEXTENTS       1
                        MAXEXTENTS       UNLIMITED
                        PCTINCREASE      0
                        FREELISTS        1
                        FREELIST GROUPS  1
                        BUFFER_POOL      DEFAULT
                       )
REFRESH COMPLETE
START WITH TO_DATE('20-Apr-2009 16:00:19','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:40 (Formatter Plus v4.8.8) */
select TRIM (document_id) document_id, TRIM (customer) customer,
       TRIM (mils_activity) mils_activity,
       TRIM (mils_ownership_code) mils_ownership_code,
       TRIM (mils_profile) mils_profile, TRIM (in_tran_from) in_tran_from,
       TRIM (in_tran_to) in_tran_to, TRIM (in_tran_type) in_tran_type,
       TRIM (part) part, TRIM (abbr_part) abbr_part, create_date, ship_date,
       receipt_date, start_date_time, create_qty, ship_qty, receipt_qty,
       mils_condition, status_ind
  from mlit$merged@dgoldlb
 where TRIM (part) != TRIM (abbr_part) and status_ind = 'I'
    or TRIM (abbr_part) is null and status_ind = 'I';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.MLIT IS 'snapshot table for snapshot AMD_OWNER.MLIT';

CREATE UNIQUE INDEX AMD_OWNER.MLITP1 ON AMD_OWNER.MLIT
(DOCUMENT_ID)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.MLIT TO AMD_DATALOAD;

GRANT SELECT ON AMD_OWNER.MLIT TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.MLIT TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.MLIT TO WIR_AMD_IF_ROLE;

