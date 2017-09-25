-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run onOrderDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready onOrderDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 100000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE


VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT *
          FROM tmp_amd_on_order
      ORDER BY gold_order_number, order_date, loc_sid;

   CURSOR deleteRecs
   IS
      SELECT part_no,
             gold_order_number,
             order_date,
             loc_sid
        FROM amd_on_order cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM tmp_amd_on_order
                          WHERE     gold_order_number = cur.gold_order_number
                                AND order_date = cur.order_date
                                AND loc_sid = cur.loc_sid)
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
         goldOrderNumber    VARCHAR2,
         orderDate          DATE,
         locSid             NUMBER)
      IS
           SELECT *
             FROM amd_on_order
            WHERE     action_code != 'D'
                  AND gold_order_number = goldOrderNumber
                  AND order_date = orderDate
                  AND loc_sid = locSid
         ORDER BY gold_order_number, order_date, loc_sid;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec
         IN curRecs (newRec.gold_order_number,
                     newRec.order_date,
                     newRec.loc_sid)
      LOOP
         result := amd_utils.isDiff (newRec.part_no, oldRec.part_no);
         result :=
            result OR amd_utils.isDiff (newRec.order_qty, oldRec.order_qty);
         result :=
               result
            OR amd_utils.isDiff (newRec.sched_receipt_date,
                                 oldRec.sched_receipt_date);
         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error: gold_order_number '
            || newRec.gold_order_number
            || ' order_dat='
            || TO_DATE (newRec.order_date, 'MM/DD/YYYY')
            || ' loc_sid='
            || newRec.loc_sid
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (goldOrderNo    amd_on_order.gold_order_number%TYPE,
                      orderDate      amd_on_order.order_date%TYPE,
                      locSid         amd_on_order.loc_sid%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_on_order
          WHERE     gold_order_number = goldOrderNo
                AND order_date = orderDate
                AND loc_sid = locSid
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
      RETURN amd_inventory.insertOnOrderRow (rec.part_no,
                                             rec.loc_sid,
                                             rec.order_date,
                                             rec.order_qty,
                                             rec.gold_order_number,
                                             rec.sched_receipt_date);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.updateOnOrderRow (rec.Part_no,
                                             rec.loc_sid,
                                             rec.order_date,
                                             rec.order_qty,
                                             rec.gold_order_number,
                                             rec.sched_receipt_date);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.deleteRow (rec.part_no,
                                      rec.loc_sid,
                                      rec.gold_order_number,
                                      rec.order_date);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.gold_order_number,
                   newRec.order_date,
                   newRec.loc_sid)
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

PROMPT end onOrderDiff.sql
EXIT :rc
