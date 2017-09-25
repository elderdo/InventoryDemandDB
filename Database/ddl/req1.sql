SET DEFINE OFF;
DROP PUBLIC SYNONYM REQ1;

CREATE PUBLIC SYNONYM REQ1 FOR AMD_OWNER.REQ1;


DROP MATERIALIZED VIEW AMD_OWNER.REQ1;
CREATE MATERIALIZED VIEW AMD_OWNER.REQ1 
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
/* Formatted on 2009/04/21 13:54 (Formatter Plus v4.8.8) */
select TRIM (request_id) request_id, created_on created_datetime,
       quantity_requested qty_requested, TRIM (prime_part_cage) prime,
       TRIM (nsn) nsn, status, allow_alternates allow_alts_yn,
       quantity_reserved qty_reserved,
       TRIM (select_from_part) select_from_part,
       TRIM (select_from_segregation_code) select_from_sc,
       quantity_canceled qty_canc, TRIM (mils_source_dic) mils_source_dic,
       quantity_due qty_due, quantity_issued qty_issued, need_date,
       request_priority
  from req1$merged@dgoldlb
 where status != 'X';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.REQ1 IS 'snapshot table for snapshot AMD_OWNER.REQ1';

GRANT SELECT ON AMD_OWNER.REQ1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.REQ1 TO AMD_WRITER_ROLE;

