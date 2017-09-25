SET DEFINE OFF;
DROP PUBLIC SYNONYM CGVT;

CREATE PUBLIC SYNONYM CGVT FOR AMD_OWNER.CGVT;


DROP MATERIALIZED VIEW AMD_OWNER.CGVT;
CREATE MATERIALIZED VIEW AMD_OWNER.CGVT 
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
START WITH TO_DATE('20-Apr-2009 15:46:30','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48    
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:33 (Formatter Plus v4.8.8) */
select service_code, stock_number, isg_master_stock_number, isg_oou_code
  from cgvt@dgoldlb
 where stock_number is not null and isg_master_stock_number is not null;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.CGVT IS 'snapshot table for snapshot AMD_OWNER.CGVT';

GRANT SELECT ON AMD_OWNER.CGVT TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.CGVT TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.CGVT TO WIR_AMD_IF_ROLE;

