SET DEFINE OFF;
DROP PUBLIC SYNONYM CHGH;

CREATE PUBLIC SYNONYM CHGH FOR AMD_OWNER.CHGH;


DROP MATERIALIZED VIEW AMD_OWNER.CHGH;
CREATE MATERIALIZED VIEW AMD_OWNER.CHGH 
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
START WITH TO_DATE('20-Apr-2009 15:38:27','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:35 (Formatter Plus v4.8.8) */
select TRIM (chgh_id) chgh_id, key_value1, "TO", field, "FROM"
  from chgh@dgoldlb
 where field = 'NSN';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.CHGH IS 'snapshot table for snapshot AMD_OWNER.CHGH';

GRANT SELECT ON AMD_OWNER.CHGH TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.CHGH TO AMD_WRITER_ROLE;

