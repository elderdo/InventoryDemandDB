SET DEFINE OFF;
DROP PUBLIC SYNONYM RAMP;

CREATE PUBLIC SYNONYM RAMP FOR AMD_OWNER.RAMP;


DROP MATERIALIZED VIEW AMD_OWNER.RAMP;
CREATE MATERIALIZED VIEW AMD_OWNER.RAMP 
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
START WITH TO_DATE('21-Apr-2009 11:30:27','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48      
WITH ROWID
AS 
/* Formatted on 2009/04/21 11:03 (Formatter Plus v4.8.8) */
select TRIM (niin) nsn, TRIM (sc) sc, SUBSTR (sc, 8, 6) sran,
       serviceable_balance, due_in_balance, due_out_balance, difm_balance,
       date_processed, avg_repair_cycle_time, percent_base_condem,
       percent_base_repair, daily_demand_rate,
       SUBSTR (TRIM (current_stock_number), 1, 16) current_stock_number,
       retention_level, hpmsk_balance, demand_level, unserviceable_balance,
       suspended_in_stock, wrm_balance, wrm_level, requisition_objective,
       hpmsk_level_qty, spram_level, spram_balance,
       TRIM (delete_indicator) delete_indicator, total_inaccessible_qty
  from ramp@dgoldlb
 where delete_indicator is null;

COMMENT ON MATERIALIZED VIEW AMD_OWNER.RAMP IS 'snapshot table for snapshot AMD_OWNER.RAMP';

CREATE UNIQUE INDEX AMD_OWNER.RAMPP1 ON AMD_OWNER.RAMP
(NSN, SC)
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

CREATE INDEX AMD_OWNER.RAMP_CSN_SC ON AMD_OWNER.RAMP
(CURRENT_STOCK_NUMBER, SC)
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

CREATE INDEX AMD_OWNER.RAMP_FCN_CSN_SC ON AMD_OWNER.RAMP
(REPLACE("CURRENT_STOCK_NUMBER",'-'), SUBSTR("SC",8,6))
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

GRANT SELECT ON AMD_OWNER.RAMP TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.RAMP TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.RAMP TO WIR_AMD_IF_ROLE;

