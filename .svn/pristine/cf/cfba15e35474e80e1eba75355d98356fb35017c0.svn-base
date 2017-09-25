SET DEFINE OFF;
DROP PUBLIC SYNONYM PRC1;

CREATE PUBLIC SYNONYM PRC1 FOR AMD_OWNER.PRC1;


DROP MATERIALIZED VIEW AMD_OWNER.PRC1;
CREATE MATERIALIZED VIEW AMD_OWNER.PRC1 
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
START WITH TO_DATE('20-Apr-2009 15:54:28','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:45 (Formatter Plus v4.8.8) */
select TRIM (sc) sc, TRIM (part) part, cap_price, gfp_price
  from prc1$merged@dgoldlb
 where sc = 'DEF' and part not like '% ' and part not like ' %';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.PRC1 IS 'snapshot table for snapshot AMD_OWNER.PRC1';

CREATE INDEX AMD_OWNER.PRC1I2_NEW_IDX ON AMD_OWNER.PRC1
(PART)
LOGGING
TABLESPACE AMD_DATA
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

CREATE UNIQUE INDEX AMD_OWNER.PRC1P1 ON AMD_OWNER.PRC1
(SC, PART)
LOGGING
TABLESPACE AMD_DATA
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

GRANT SELECT ON AMD_OWNER.PRC1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.PRC1 TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.PRC1 TO WIR_AMD_IF_ROLE;

