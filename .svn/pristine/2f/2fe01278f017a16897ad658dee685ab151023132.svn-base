SET DEFINE OFF;
DROP PUBLIC SYNONYM RSV1;

CREATE PUBLIC SYNONYM RSV1 FOR AMD_OWNER.RSV1;


DROP MATERIALIZED VIEW AMD_OWNER.RSV1;
CREATE MATERIALIZED VIEW AMD_OWNER.RSV1 
TABLESPACE AMD_DATA
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
START WITH TO_DATE('21-Apr-2009 14:12:28','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/21 13:56 (Formatter Plus v4.8.8) */
select TRIM (reserve_id), form_required form_required_yn,
       remark_move_only remark_move_only_yn, created_docdate,
       TRIM (to_segregation_code) to_sc, TRIM (item_id) item_id, status
  from rsv1$merged@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.RSV1 IS 'snapshot table for snapshot AMD_OWNER.RSV1';

CREATE INDEX AMD_OWNER.RSV1_FCN_TO_SC ON AMD_OWNER.RSV1
(SUBSTR("TO_SC",8,6))
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

GRANT SELECT ON AMD_OWNER.RSV1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.RSV1 TO AMD_WRITER_ROLE;

