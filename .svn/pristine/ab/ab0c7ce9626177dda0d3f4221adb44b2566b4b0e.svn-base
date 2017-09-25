SET DEFINE OFF;
DROP PUBLIC SYNONYM WHSE;

CREATE PUBLIC SYNONYM WHSE FOR AMD_OWNER.WHSE;


DROP MATERIALIZED VIEW AMD_OWNER.WHSE;
CREATE MATERIALIZED VIEW AMD_OWNER.WHSE 
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
START WITH TO_DATE('21-Apr-2009 12:02:11','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48   
WITH ROWID
AS 
/* Formatted on 2009/04/21 14:15 (Formatter Plus v4.8.8) */
select TRIM (segregation_code) sc, TRIM (part) part, TRIM (prime) prime,
       TRIM (user_ref3) user_ref3, created_on created_datetime,
       created_by created_userid, stock_level,
       case
          when reorder_point < 1 and reorder_point > 0
             then 0
-- Requirement from GOLD that AMD must comply to get data for SPO 3/11/2008
          else reorder_point
       end reorder_point,
       planner_code
  from whse$merged@dgoldlb
 where segregation_code like 'C17%CODUKBG'
    or segregation_code like 'C17%CODAUSG'
    or segregation_code like 'C17%CTLATLG'
    or segregation_code like 'C17%CODCANG';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.WHSE IS 'snapshot table for snapshot AMD_OWNER.WHSE';

CREATE INDEX AMD_OWNER.WHSE_PART ON AMD_OWNER.WHSE
(PART)
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

CREATE UNIQUE INDEX AMD_OWNER.WHSE_PART_SC ON AMD_OWNER.WHSE
(PART, SC)
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

CREATE INDEX AMD_OWNER.WHSE_SC ON AMD_OWNER.WHSE
(SC)
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

GRANT SELECT ON AMD_OWNER.WHSE TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.WHSE TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.WHSE TO WIR_AMD_IF_ROLE;

