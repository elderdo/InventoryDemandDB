SET DEFINE OFF;
DROP PUBLIC SYNONYM LVLS;

CREATE PUBLIC SYNONYM LVLS FOR AMD_OWNER.LVLS;


DROP MATERIALIZED VIEW AMD_OWNER.LVLS;
CREATE MATERIALIZED VIEW AMD_OWNER.LVLS 
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
START WITH TO_DATE('20-Apr-2009 15:53:23','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48     
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:37 (Formatter Plus v4.8.8) */
select TRIM (niin) niin, TRIM (sran) sran,
       replace (SUBSTR (TRIM (current_stock_number), 1, 16), '-', '') nsn,
       TRIM (lvl_document_number) lvl_document_number, document_datetime,
       SUBSTR (TRIM (current_stock_number), 1, 16) current_stock_number,
       TRIM (compatibility_code) compatibility_code,
       to_date (date_lvl_loaded, 'yyddd') date_lvl_loaded, reorder_point,
       economic_order_qty, approved_lvl_qty
  from lvls@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.LVLS IS 'snapshot table for snapshot AMD_OWNER.LVLS';

CREATE INDEX AMD_OWNER.LVLS_NK01 ON AMD_OWNER.LVLS
(NSN)
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

CREATE UNIQUE INDEX AMD_OWNER.LVLS_PK ON AMD_OWNER.LVLS
(NIIN, SRAN, DOCUMENT_DATETIME)
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

GRANT SELECT ON AMD_OWNER.LVLS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.LVLS TO AMD_WRITER_ROLE;

