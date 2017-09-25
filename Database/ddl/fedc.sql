SET DEFINE OFF;
DROP PUBLIC SYNONYM FEDC;

CREATE PUBLIC SYNONYM FEDC FOR AMD_OWNER.FEDC;


DROP MATERIALIZED VIEW AMD_OWNER.FEDC;
CREATE MATERIALIZED VIEW AMD_OWNER.FEDC 
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
START WITH TO_DATE('20-Apr-2009 16:05:14','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:36 (Formatter Plus v4.8.8) */
select TRIM (part_number) part_number, TRIM (vendor_code) vendor_code,
       seq_number, gfp_price, TRIM (nsn) nsn
  from fedc@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.FEDC IS 'snapshot table for snapshot AMD_OWNER.FEDC';

CREATE UNIQUE INDEX AMD_OWNER.FEDCP1 ON AMD_OWNER.FEDC
(PART_NUMBER, VENDOR_CODE, SEQ_NUMBER)
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

GRANT SELECT ON AMD_OWNER.FEDC TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.FEDC TO AMD_WRITER_ROLE;

