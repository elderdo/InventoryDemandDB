SET DEFINE OFF;
DROP PUBLIC SYNONYM VENN;

CREATE PUBLIC SYNONYM VENN FOR AMD_OWNER.VENN;


DROP MATERIALIZED VIEW AMD_OWNER.VENN;
CREATE MATERIALIZED VIEW AMD_OWNER.VENN 
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
START WITH TO_DATE('20-Apr-2009 16:17:05','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:51 (Formatter Plus v4.8.8) */
select TRIM (vendor_code) vendor_code, TRIM (vendor_name) vendor_name,
       TRIM (cage_code) cage_code, TRIM (user_ref1) user_ref1
  from venn$merged@dgoldlb
 where cage_code is not null;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.VENN IS 'snapshot table for snapshot AMD_OWNER.venn';

CREATE UNIQUE INDEX AMD_OWNER.VENNP1 ON AMD_OWNER.VENN
(VENDOR_CODE)
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

CREATE INDEX AMD_OWNER.VENN_CAGE_INDEX ON AMD_OWNER.VENN
(CAGE_CODE)
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

GRANT SELECT ON AMD_OWNER.VENN TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.VENN TO AMD_WRITER_ROLE;

