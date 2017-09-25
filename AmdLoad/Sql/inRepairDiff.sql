-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run inRepairDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready inRepairDiff.sql
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
          FROM tmp_amd_in_repair
      ORDER BY part_no, loc_sid, order_no;

   CURSOR deleteRecs
   IS
      SELECT part_no, loc_sid, order_no
        FROM amd_in_repair cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM tmp_amd_in_repair
                          WHERE     part_no = cur.part_no
                                AND loc_sid = cur.loc_sid
                                AND order_no = cur.order_no)
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
         partNo     VARCHAR2,
         locSid     amd_in_repair.loc_sid%TYPE,
         orderNo    amd_in_repair.order_no%TYPE)
      IS
           SELECT *
             FROM amd_in_repair
            WHERE     action_code != 'D'
                  AND part_no = partNo
                  AND loc_sid = locSid
                  AND order_no = orderNo
         ORDER BY part_no, loc_sid, order_no;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.part_no, newRec.loc_sid, newRec.order_no)
      LOOP
         result := amd_utils.isDiff (newRec.repair_qty, oldRec.repair_qty);
         result :=
               result
            OR amd_utils.isDiff (newRec.repair_date, oldRec.repair_date);
         result :=
               result
            OR amd_utils.isDiff (newRec.repair_need_date,
                                 oldRec.repair_need_date);
         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error: part_no '
            || newRec.part_no
            || ' loc_sid='
            || newRec.loc_sid
            || ' order_no'
            || newRec.order_no
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (partNo     amd_in_repair.part_no%TYPE,
                      locSid     amd_in_repair.loc_sid%TYPE,
                      orderNo    amd_in_repair.order_no%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_in_repair
          WHERE     part_no = partNo
                AND loc_sid = locSid
                AND order_no = orderNo
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
      RETURN amd_inventory.insertRow (rec.part_no,
                                      rec.loc_sid,
                                      rec.repair_date,
                                      rec.repair_qty,
                                      rec.order_no,
                                      rec.repair_need_date);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.updateRow (rec.part_no,
                                      rec.loc_sid,
                                      rec.repair_date,
                                      rec.repair_qty,
                                      rec.order_no,
                                      rec.repair_need_date);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.inRepairDeleteRow (rec.part_no,
                                              rec.loc_sid,
                                              rec.order_no);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1 ;
      IF isInsert (newRec.part_no, newRec.loc_sid, newRec.order_no)
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

PROMPT end inRepairDiff.sql
EXIT :rc
