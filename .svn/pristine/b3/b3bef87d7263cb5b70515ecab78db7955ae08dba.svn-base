SET DEFINE OFF;
DROP PUBLIC SYNONYM MILS;

CREATE PUBLIC SYNONYM MILS FOR AMD_OWNER.MILS;


DROP MATERIALIZED VIEW AMD_OWNER.MILS;
CREATE MATERIALIZED VIEW AMD_OWNER.MILS 
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
START WITH TO_DATE('20-Apr-2009 16:01:34','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:39 (Formatter Plus v4.8.8) */
select TRIM (mils_id) mils_id, TRIM (rec_types) rec_types, created_datetime,
       TRIM (status_line) status_line, TRIM (part) part,
       TRIM (default_name) default_name
  from mils@dgoldlb
 where default_name = 'A0E';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.MILS IS 'snapshot table for snapshot AMD_OWNER.MILS';

CREATE UNIQUE INDEX AMD_OWNER.MILSP1 ON AMD_OWNER.MILS
(MILS_ID)
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

GRANT SELECT ON AMD_OWNER.MILS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.MILS TO AMD_WRITER_ROLE;

