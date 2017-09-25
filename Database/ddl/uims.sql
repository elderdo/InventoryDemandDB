SET DEFINE OFF;
DROP PUBLIC SYNONYM UIMS;

CREATE PUBLIC SYNONYM UIMS FOR AMD_OWNER.UIMS;


DROP MATERIALIZED VIEW AMD_OWNER.UIMS;
CREATE MATERIALIZED VIEW AMD_OWNER.UIMS 
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
START WITH TO_DATE('20-Apr-2009 15:58:08','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:48 (Formatter Plus v4.8.8) */
select TRIM (userid) userid, designator_code, alt_ims_des_code_b,
       alt_es_des_code_b, alt_sup_des_code_b
  from uims@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.UIMS IS 'snapshot table for snapshot AMD_OWNER.UIMS';

CREATE INDEX AMD_OWNER.UIMS_NK01 ON AMD_OWNER.UIMS
(LENGTH("DESIGNATOR_CODE"))
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

CREATE UNIQUE INDEX AMD_OWNER.UIMS_PK ON AMD_OWNER.UIMS
(USERID, DESIGNATOR_CODE)
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

GRANT SELECT ON AMD_OWNER.UIMS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.UIMS TO AMD_WRITER_ROLE;

