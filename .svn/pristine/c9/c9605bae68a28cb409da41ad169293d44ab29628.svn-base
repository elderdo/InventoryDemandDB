SET DEFINE OFF;
DROP PUBLIC SYNONYM AMD_ISGP;

CREATE PUBLIC SYNONYM AMD_ISGP FOR AMD_OWNER.AMD_ISGP;


DROP MATERIALIZED VIEW AMD_OWNER.AMD_ISGP;
CREATE MATERIALIZED VIEW AMD_OWNER.AMD_ISGP 
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
START WITH TO_DATE('20-Apr-2009 15:41:33','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:27 (Formatter Plus v4.8.8) */
select TRIM (sc) sc, TRIM (part) part, TRIM (group_no) group_no, sequence_no,
       TRIM (group_priority) group_priority
  from isgp$merged@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.AMD_ISGP IS 'snapshot table for snapshot AMD_OWNER.AMD_ISGP';

CREATE UNIQUE INDEX AMD_OWNER.AMD_ISGP_PK ON AMD_OWNER.AMD_ISGP
(SC, PART, GROUP_NO)
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

GRANT SELECT ON AMD_OWNER.AMD_ISGP TO AMD_READER_ROLE;

GRANT DELETE, INSERT, UPDATE ON AMD_OWNER.AMD_ISGP TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_ISGP TO WIR_AMD_IF_ROLE;

