-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run sparePartDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready sparePartDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');




prompt rows in amd_spare_parts 
select count(*) from amd_spare_parts where action_code <> 'D';

VARIABLE rc NUMBER

EXEC amd_spare_parts_pkg.setDebug('Y');


DECLARE
   CURSOR newRecs
   IS
        SELECT part_no,
               mfgr,
               mic mic_code_lowest,
               acquisition_advice_code,
               date_icp,
               disposal_cost,
               erc,
               icp_ind,
               nomenclature,
               order_lead_time,
               order_quantity,
               order_uom,
               scrap_value,
               serial_flag,
               shelf_life,
               unit_cost,
               unit_volume,
               nsn,
               smr_code,
               item_type,
               planner_code,
               nsn_type,
               prime_ind,
               mmac,
               unit_of_issue,
               mtbdr,
               qpei_weighted,
               condemn_avg_cleaned,
               criticality_cleaned,
               mtbdr_cleaned,
               mtbdr_computed,
               nrts_avg_cleaned,
               cost_to_repair_off_base_cleand,
               time_to_repair_off_base_cleand,
               order_lead_time_cleaned,
               planner_code_cleaned,
               rts_avg_cleaned,
               smr_code_cleaned,
               unit_cost_cleaned,
               condemn_avg,
               criticality,
               nrts_avg,
               rts_avg,
               cost_to_repair_off_base,
               time_to_repair_off_base,
               amc_demand,
               amc_demand_cleaned,
               wesm_indicator
          FROM tmp_amd_spare_parts
      ORDER BY part_no;

   CURSOR deleteRecs
   IS
      SELECT part_no,
             nomenclature,
             mfgr,
             action_code
        FROM amd_spare_parts parts
       WHERE     NOT EXISTS
                    (SELECT NULL
                       FROM tmp_amd_spare_parts
                      WHERE part_no = parts.part_no)
             AND action_code <> 'D';

   updateCnt      NUMBER := 0;
   updateErrCnt   NUMBER := 0;
   insertCnt      NUMBER := 0;
   insertErrCnt   NUMBER := 0;
   deleteCnt      NUMBER := 0;
   deleteErrCnt   NUMBER := 0;
   diffError      BOOLEAN := FALSE;
   newCnt         NUMBER := 0;
   debug          BOOLEAN := FALSE;



   FUNCTION isDiff (newRec newRecs%ROWTYPE)
      RETURN BOOLEAN
   IS
      CURSOR curSparePart (
         partNo    VARCHAR2)
      IS
         SELECT parts.part_no part_no,
                parts.mfgr mfgr,
                items.mic_code_lowest,
                parts.acquisition_advice_code,
                date_icp,
                disposal_cost,
                erc,
                icp_ind,
                nomenclature,
                order_lead_time,
                order_quantity,
                order_uom,
                scrap_value,
                serial_flag,
                shelf_life,
                unit_cost,
                unit_volume,
                parts.nsn,
                smr_code,
                item_type,
                planner_code,
                nsn_type,
                prime_ind,
                items.mmac,
                parts.unit_of_issue,
                mtbdr,
                qpei_weighted,
                condemn_avg_cleaned,
                criticality_cleaned,
                mtbdr_cleaned,
                mtbdr_computed,
                nrts_avg_cleaned,
                cost_to_repair_off_base_cleand,
                time_to_repair_off_base_cleand,
                order_lead_time_cleaned,
                planner_code_cleaned,
                rts_avg_cleaned,
                smr_code_cleaned,
                unit_cost_cleaned,
                condemn_avg,
                criticality,
                nrts_avg,
                rts_avg,
                cost_to_repair_off_base,
                time_to_repair_off_base,
                amc_demand,
                amc_demand_cleaned,
                wesm_indicator
           FROM amd_spare_parts parts,
                amd_national_stock_items items,
                amd_nsns nsns,
                amd_nsi_parts lnks
          WHERE     parts.action_code != 'D'
                AND parts.nsn = nsns.nsn
                AND nsns.nsi_sid = items.nsi_sid
                AND nsns.nsi_sid = lnks.nsi_sid
                AND parts.part_no = lnks.part_no
                AND lnks.unassignment_date IS NULL
                AND parts.part_no = partNo;

      result     BOOLEAN := FALSE;
      cnt        NUMBER := 0;
      fieldCnt   NUMBER := 0;

      FUNCTION isDiff (newValue VARCHAR2, oldValue VARCHAR2)
         RETURN BOOLEAN
      IS
         result   BOOLEAN;
      BEGIN
         fieldCnt := fieldCnt + 1;
         result := amd_utils.isDiff (oldValue, newValue);

         IF result AND debug
         THEN
            DBMS_OUTPUT.put_line (
                  'varchar: fieldCnt='
               || fieldCnt
               || ' old='
               || oldValue
               || ' new='
               || newValue);
         END IF;

         RETURN result;
      END isDiff;

      FUNCTION isDiff (newValue NUMBER, oldValue NUMBER)
         RETURN BOOLEAN
      IS
         result   BOOLEAN;
      BEGIN
         fieldCnt := fieldCnt + 1;
         result := amd_utils.isDiff (oldValue, newValue);

         IF result AND debug
         THEN
            DBMS_OUTPUT.put_line (
                  'varchar: fieldCnt='
               || fieldCnt
               || ' old='
               || oldValue
               || ' new='
               || newValue);
         END IF;

         RETURN result;
      END isDiff;

      FUNCTION isDiff (newValue DATE, oldValue DATE)
         RETURN BOOLEAN
      IS
         result   BOOLEAN;
      BEGIN
         fieldCnt := fieldCnt + 1;
         result := amd_utils.isDiff (oldValue, newValue);

         IF result AND debug
         THEN
            DBMS_OUTPUT.put_line (
                  'varchar: fieldCnt='
               || fieldCnt
               || ' old='
               || oldValue
               || ' new='
               || newValue);
         END IF;

         RETURN result;
      END isDiff;
   BEGIN
      FOR oldRec IN curSparePart (newRec.part_no)
      LOOP
         fieldCnt := 0;
         result :=
            isDiff (newRec.condemn_avg_cleaned, oldRec.condemn_avg_cleaned);
         result :=
               result
            OR isDiff (newRec.criticality_cleaned,
                       oldRec.criticality_cleaned);
         result :=
            result OR isDiff (newRec.mtbdr_cleaned, oldRec.mtbdr_cleaned);
         result :=
               result
            OR isDiff (newRec.nrts_avg_cleaned, oldRec.nrts_avg_cleaned);
         result :=
               result
            OR isDiff (newRec.cost_to_repair_off_base_cleand,
                       oldRec.cost_to_repair_off_base_cleand);
         result :=
               result
            OR isDiff (newRec.time_to_repair_off_base_cleand,
                       oldRec.time_to_repair_off_base_cleand);
         result :=
               result
            OR isDiff (newRec.order_lead_time_cleaned,
                       oldRec.order_lead_time_cleaned);
         result :=
               result
            OR isDiff (newRec.planner_code_cleaned,
                       oldRec.planner_code_cleaned);
         result :=
            result OR isDiff (newRec.rts_avg_cleaned, oldRec.rts_avg_cleaned);
         result :=
               result
            OR isDiff (newRec.smr_code_cleaned, oldRec.smr_code_cleaned);
         result :=
               result
            OR isDiff (newRec.unit_cost_cleaned, oldRec.unit_cost_cleaned);
         result :=
               result
            OR isDiff (newRec.amc_demand_cleaned, oldRec.amc_demand_cleaned);

         result := result OR isDiff (newRec.mfgr, oldRec.mfgr);
         result := result OR isDiff (newRec.date_icp, oldRec.date_icp);
         result :=
            result OR isDiff (newRec.disposal_cost, oldRec.disposal_cost);
         result := result OR isDiff (newRec.erc, oldRec.erc);
         result := result OR isDiff (newRec.icp_ind, oldRec.icp_ind);
         result := result OR isDiff (newRec.nomenclature, oldRec.nomenclature);
         result :=
            result OR isDiff (newRec.order_lead_time, oldRec.order_lead_time);
         result := result OR isDiff (newRec.order_uom, oldRec.order_uom);
         result := result OR isDiff (newRec.scrap_value, oldRec.scrap_value);
         result := result OR isDiff (newRec.serial_flag, oldRec.serial_flag);
         result := result OR isDiff (newRec.shelf_life, oldRec.shelf_life);
         result := result OR isDiff (newRec.unit_cost, oldRec.unit_cost);
         result := result OR isDiff (newRec.unit_volume, oldRec.unit_volume);
         result := result OR isDiff (newRec.prime_ind, oldRec.prime_ind);
         result :=
               result
            OR isDiff (newRec.acquisition_advice_code,
                       oldRec.acquisition_advice_code);
         result :=
            result OR isDiff (newRec.unit_of_issue, oldRec.unit_of_issue);
         result := result OR isDiff (newRec.nsn, oldRec.nsn);

         IF oldRec.prime_ind = 'Y'
         THEN
            result := result OR isDiff (newRec.mmac, oldRec.mmac);
            result :=
               result OR isDiff (newRec.qpei_weighted, oldRec.qpei_weighted);
            result := result OR isDiff (newRec.mtbdr, oldRec.mtbdr);
            result :=
                  result
               OR isDiff (newRec.mtbdr_computed, oldRec.mtbdr_computed);
            result :=
               result OR isDiff (newRec.condemn_avg, oldRec.condemn_avg);
            result :=
               result OR isDiff (newRec.criticality, oldRec.criticality);
            result := result OR isDiff (newRec.nrts_avg, oldRec.nrts_avg);
            result := result OR isDiff (newRec.rts_avg, oldRec.rts_avg);
            result :=
                  result
               OR isDiff (newRec.mic_code_lowest, oldRec.mic_code_lowest);
            result := result OR isDiff (newRec.item_type, oldRec.item_type);
            result :=
                  result
               OR isDiff (newRec.order_quantity, oldRec.order_quantity);
            result :=
               result OR isDiff (newRec.planner_code, oldRec.planner_code);
            result := result OR isDiff (newRec.smr_code, oldRec.smr_code);
            result := result OR isDiff (newRec.nsn_type, oldRec.nsn_type);
            result :=
                  result
               OR isDiff (newRec.cost_to_repair_off_base,
                          oldRec.cost_to_repair_off_base);
            result :=
                  result
               OR isDiff (newRec.time_to_repair_off_base,
                          oldRec.time_to_repair_off_base);
            result := result OR isDiff (newRec.amc_demand, oldRec.amc_demand);
            result :=
                  result
               OR isDiff (newRec.wesm_indicator, oldRec.wesm_indicator);
         END IF;

         cnt := cnt + 1;


         IF result AND debug
         THEN
            DBMS_OUTPUT.put_line ('part_no=' || newRec.part_no);
         END IF;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
            'diff error: part_no ' || newRec.part_no || ' cnt=' || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (partNo VARCHAR2)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_spare_parts
          WHERE part_no = partNo AND action_code <> 'D';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            result := TRUE;
      END;

      RETURN result;
   END isInsert;

   FUNCTION insertRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_spare_parts_pkg.insertRow (
                rec.part_no,
                rec.mfgr,
                rec.date_icp,
                rec.disposal_cost,
                rec.erc,
                rec.icp_ind,
                rec.nomenclature,
                rec.order_lead_time,
                rec.order_quantity,
                rec.order_uom,
                rec.prime_ind,
                rec.scrap_value,
                rec.serial_flag,
                rec.shelf_life,
                rec.unit_cost,
                rec.unit_volume,
                rec.nsn,
                rec.nsn_type,
                rec.item_type,
                rec.smr_code,
                rec.planner_code,
                rec.mic_code_lowest,
                rec.acquisition_advice_code,
                rec.mmac,
                rec.unit_of_issue,
                rec.mtbdr,
                rec.mtbdr_computed,
                rec.qpei_Weighted,
                rec.condemn_avg_cleaned,
                rec.criticality_cleaned,
                rec.mtbdr_cleaned,
                rec.nrts_avg_cleaned,
                rec.cost_to_repair_off_base_cleand,
                rec.time_to_repair_off_base_cleand,
                rec.order_lead_time_cleaned,
                rec.planner_code_cleaned,
                rec.rts_avg_cleaned,
                rec.smr_code_cleaned,
                rec.unit_cost_cleaned,
                rec.condemn_Avg,
                rec.criticality,
                rec.nrts_avg,
                rec.rts_avg,
                rec.cost_to_repair_off_base,
                rec.time_to_repair_off_base,
                rec.amc_demand,
                rec.amc_demand_cleaned,
                rec.wesm_indicator);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      IF debug
      THEN
         DBMS_OUTPUT.put_line (
            'part_no=' || rec.part_no || ' prime_ind=' || rec.prime_ind);
      END IF;

      RETURN amd_spare_parts_pkg.updateRow (
                rec.Part_no,
                rec.Mfgr,
                rec.Date_icp,
                rec.Disposal_cost,
                rec.Erc,
                rec.Icp_ind,
                rec.Nomenclature,
                rec.Order_lead_time,
                rec.Order_quantity,
                rec.Order_uom,
                rec.Prime_ind,
                rec.Scrap_value,
                rec.Serial_flag,
                rec.Shelf_life,
                rec.Unit_cost,
                rec.Unit_volume,
                rec.Nsn,
                rec.Nsn_type,
                rec.Item_type,
                rec.Smr_code,
                rec.Planner_code,
                rec.Mic_code_lowest,
                rec.Acquisition_advice_code,
                rec.Mmac,
                rec.unit_of_issue,
                rec.Mtbdr,
                rec.Mtbdr_computed,
                rec.Qpei_Weighted,
                rec.condemn_avg_cleaned,
                rec.criticality_cleaned,
                rec.mtbdr_cleaned,
                rec.nrts_avg_cleaned,
                rec.cost_to_repair_off_base_cleand,
                rec.time_to_repair_off_base_cleand,
                rec.order_lead_time_cleaned,
                rec.planner_code_cleaned,
                rec.rts_avg_cleaned,
                rec.smr_code_cleaned,
                rec.unit_cost_cleaned,
                rec.condemn_avg,
                rec.Criticality,
                rec.nrts_avg,
                rec.rts_avg,
                rec.cost_to_repair_off_base,
                rec.time_to_repair_off_base,
                rec.amc_demand,
                rec.amc_demand_cleaned,
                rec.wesm_indicator);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_spare_parts_pkg.deleteRow (rec.part_no,
                                            rec.nomenclature,
                                            rec.mfgr);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.part_no)
      THEN
         IF insertRow (newRec) = 0
         THEN
            insertCnt := insertCnt + 1;
         ELSE
            insertErrCnt := insertErrCnt + 1;
         END IF;
      ELSIF isDiff (newRec)
      THEN
         IF updateRow (newRec) = 0
         THEN
            updateCnt := updateCnt + 1;
         ELSE
            updateErrCnt := updateErrCnt + 1;
         END IF;
      END IF;
   END LOOP;

   FOR rec IN deleteRecs
   LOOP
      IF deleteRow (rec) = 0
      THEN
         deleteCnt := deleteCnt + 1;
      ELSE
         deleteErrCnt := deleteErrCnt + 1;
      END IF;
   END LOOP;

   DBMS_OUTPUT.put_line ('newCnt=' || newCnt);

   DBMS_OUTPUT.put_line ('insertCnt=' || insertCnt);

   IF insertErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('insertErrCnt=' || insertErrCnt);
   END IF;

   DBMS_OUTPUT.put_line ('updateCnt=' || updateCnt);

   IF updateErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('updateErrCnt=' || updateErrCnt);
   END IF;


   DBMS_OUTPUT.put_line ('deleteCnt=' || deleteCnt);

   IF deleteErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('deleteErrCnt=' || deleteErrCnt);
   END IF;

   IF insertErrCnt > 0 OR updateErrCnt > 0 OR deleteErrCnt > 0 OR diffError
   THEN
      :rc := 4;
   ELSE
      :rc := 0;
   END IF;
END;
/

prompt rows inserted into amd_spare_parts 
select count(*) from amd_spare_parts where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_spare_parts 
select count(*) from amd_spare_parts where action_code = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_spare_parts 
select count(*) from amd_spare_parts where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_spare_parts 
select count(*) from amd_spare_parts where action_code <> 'D'; 

PROMPT end sparePartDiff.sql
EXIT :rc
