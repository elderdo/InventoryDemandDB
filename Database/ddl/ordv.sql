SET DEFINE OFF;
DROP PUBLIC SYNONYM ORDV;

CREATE PUBLIC SYNONYM ORDV FOR AMD_OWNER.ORDV;


DROP MATERIALIZED VIEW AMD_OWNER.ORDV;
CREATE MATERIALIZED VIEW AMD_OWNER.ORDV 
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
START WITH TO_DATE('20-Apr-2009 15:51:38','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:42 (Formatter Plus v4.8.8) */
select TRIM (order_no) order_no, site_code, vendor_est_cost,
       vendor_est_ret_date
  from ordv@dgoldlb;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.ORDV IS 'snapshot table for snapshot AMD_OWNER.ORDV';

CREATE UNIQUE INDEX AMD_OWNER.ORDVP1 ON AMD_OWNER.ORDV
(ORDER_NO)
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

GRANT SELECT ON AMD_OWNER.ORDV TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.ORDV TO AMD_WRITER_ROLE;

