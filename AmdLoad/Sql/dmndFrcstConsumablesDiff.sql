-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run dmndFrcstConsumablesDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready dmndFrcstConsumables.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE UNLIMITED

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



prompt rows in amd_dmnd_frcst_consumables
select count(*) from amd_dmnd_frcst_consumables where action_code <> 'D' ;

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT nsn,
               sran,
               period,
               ROUND (demand_forecast, 4) demand_forecast,
               duplicate
          FROM tmp_amd_dmnd_frcst_consumables
      ORDER BY nsn, sran, period;

   CURSOR deleteRecs
   IS
      SELECT nsn,
             sran,
             period,
             demand_forecast,
             duplicate
        FROM amd_dmnd_frcst_consumables cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM tmp_amd_dmnd_frcst_consumables
                          WHERE     nsn = cur.nsn
                                AND sran = cur.sran
                                AND period = cur.period)
             AND action_code <> 'D';

   updateCnt      NUMBER := 0;
   updateErrCnt   NUMBER := 0;
   insertCnt      NUMBER := 0;
   insertErrCnt   NUMBER := 0;
   deleteCnt      NUMBER := 0;
   deleteErrCnt   NUMBER := 0;
   diffError      BOOLEAN := FALSE;
   newCnt         NUMBER := 0;


   FUNCTION isDiff (newRec newRecs%ROWTYPE)
      RETURN BOOLEAN
   IS
      CURSOR curRecs (
         pNsn       amd_dmnd_frcst_consumables.nsn%TYPE,
         pSran      amd_dmnd_frcst_consumables.sran%TYPE,
         pPeriod    amd_dmnd_frcst_consumables.period%TYPE)
      IS
           SELECT nsn,
                  sran,
                  period,
                  ROUND (demand_forecast, 4) demand_forecast,
                  duplicate
             FROM amd_dmnd_frcst_consumables
            WHERE     action_code != 'D'
                  AND nsn = pNsn
                  AND sran = pSran
                  AND period = pPeriod
         ORDER BY nsn;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.nsn, newRec.sran, newRec.period)
      LOOP
         result :=
            amd_utils.isDiff (newRec.demand_forecast, oldRec.demand_forecast);

         result :=
            result OR amd_utils.isDiff (newRec.duplicate, oldRec.duplicate);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:nsn='
            || newRec.nsn
            || ' sran='
            || newRec.sran
            || ' period='
            || newRec.period
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (pNsn       amd_dmnd_frcst_consumables.nsn%TYPE,
                      pSran      amd_dmnd_frcst_consumables.sran%TYPE,
                      pPeriod    amd_dmnd_frcst_consumables.period%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_dmnd_frcst_consumables
          WHERE     nsn = pNsn
                AND sran = pSran
                AND period = pPeriod
                AND action_code <> 'D';
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
      RETURN amd_demand.doDmndFrcstConsumablesDiff (rec.nsn,
                                                    rec.sran,
                                                    rec.period,
                                                    rec.demand_forecast,
                                                    rec.duplicate,
                                                    'A');
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_demand.doDmndFrcstConsumablesDiff (rec.nsn,
                                                    rec.sran,
                                                    rec.period,
                                                    rec.demand_forecast,
                                                    rec.duplicate,
                                                    'C');
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_demand.doDmndFrcstConsumablesDiff (rec.nsn,
                                                    rec.sran,
                                                    rec.period,
                                                    rec.demand_forecast,
                                                    rec.duplicate,
                                                    'D');
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.nsn, newRec.sran, newRec.period)
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

prompt rows inserted into amd_dmnd_frcst_consumables
select count(*) from amd_dmnd_frcst_consumables where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_dmnd_frcst_consumables
select count(*) from amd_dmnd_frcst_consumables where action_code = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_dmnd_frcst_consumables
select count(*) from amd_dmnd_frcst_consumables where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_dmnd_frcst_consumables
select count(*) from amd_dmnd_frcst_consumables where action_code <> 'D';

PROMPT end dmndFrcstConsumablesDiff.sql
EXIT :rc
