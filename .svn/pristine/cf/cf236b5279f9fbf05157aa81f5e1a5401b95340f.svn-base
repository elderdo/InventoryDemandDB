SET DEFINE OFF;
DROP PUBLIC SYNONYM TMP1;

CREATE PUBLIC SYNONYM TMP1 FOR AMD_OWNER.TMP1;


DROP MATERIALIZED VIEW AMD_OWNER.TMP1;
CREATE MATERIALIZED VIEW AMD_OWNER.TMP1 
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
START WITH TO_DATE('21-Apr-2009 14:34:40','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48   
WITH ROWID
AS 
/* Formatted on 2009/04/21 14:05 (Formatter Plus v4.8.8) */
select qty_due, TRIM (returned_voucher) returned_voucher, status,
       TRIM (tcn) tcn, TRIM (from_segregation_code) from_sc,
       TRIM (to_segregation_code) to_sc, from_datetime,
       TRIM (temp_out_id) temp_out_id, TRIM (from_part) from_part,
       est_return_date
  from tmp1$merged@dgoldlb
 where returned_voucher is null and status = 'O' and tcn in ('LNI', 'LBR');

COMMENT ON MATERIALIZED VIEW AMD_OWNER.TMP1 IS 'snapshot table for snapshot AMD_OWNER.TMP1';

GRANT SELECT ON AMD_OWNER.TMP1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.TMP1 TO AMD_WRITER_ROLE;

