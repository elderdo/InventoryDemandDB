DROP VIEW AMD_OWNER.PGOLD_RAMP_V;

/* Formatted on 7/9/2012 4:25:08 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_RAMP_V
(
   NSN,
   SC,
   SRAN,
   SERVICEABLE_BALANCE,
   DUE_IN_BALANCE,
   DUE_OUT_BALANCE,
   DIFM_BALANCE,
   DATE_PROCESSED,
   AVG_REPAIR_CYCLE_TIME,
   PERCENT_BASE_CONDEM,
   PERCENT_BASE_REPAIR,
   DAILY_DEMAND_RATE,
   CURRENT_STOCK_NUMBER,
   RETENTION_LEVEL,
   HPMSK_BALANCE,
   DEMAND_LEVEL,
   UNSERVICEABLE_BALANCE,
   SUSPENDED_IN_STOCK,
   WRM_BALANCE,
   WRM_LEVEL,
   REQUISITION_OBJECTIVE,
   HPMSK_LEVEL_QTY,
   SPRAM_LEVEL,
   SPRAM_BALANCE,
   DELETE_INDICATOR,
   TOTAL_INACCESSIBLE_QTY
)
AS
   SELECT TRIM (niin),
          TRIM (sc),
          SUBSTR (sc, 8, 6),
          serviceable_balance,
          due_in_balance,
          due_out_balance,
          difm_balance,
          date_processed,
          avg_repair_cycle_time,
          percent_base_condem,
          percent_base_repair,
          daily_demand_rate,
          SUBSTR (TRIM (current_stock_number), 1, 16),
          retention_level,
          hpmsk_balance,
          demand_level,
          unserviceable_balance,
          suspended_in_stock,
          wrm_balance,
          wrm_level,
          requisition_objective,
          hpmsk_level_qty,
          spram_level,
          spram_balance,
          TRIM (delete_indicator),
          total_inaccessible_qty
     FROM ramp@amd_pgoldlb_link
    WHERE delete_indicator IS NULL;


DROP PUBLIC SYNONYM PGOLD_RAMP_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_RAMP_V FOR AMD_OWNER.PGOLD_RAMP_V;


GRANT SELECT ON AMD_OWNER.PGOLD_RAMP_V TO AMD_READER_ROLE;
