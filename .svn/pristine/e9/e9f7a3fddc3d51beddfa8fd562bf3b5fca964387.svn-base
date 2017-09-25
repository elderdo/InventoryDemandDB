-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run onHandInvsSumDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready onHandInvsSumDiff.sql
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
        SELECT part_no,
               amd_utils.getSpoLocation (loc_sid) spo_location,
               SUM (inv_qty) qty_on_hand
          FROM tmp_amd_on_hand_invs
         WHERE     action_code != 'D'
               AND amd_utils.getSpoLocation (loc_sid) IS NOT NULL
      GROUP BY part_no, amd_utils.getSpoLocation (loc_sid)
      ORDER BY part_no, spo_location;

   CURSOR deleteRecs
   IS
      SELECT part_no, spo_location, qty_on_hand
        FROM amd_on_hand_invs_sum cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (  SELECT part_no,
                                          amd_utils.getSpoLocation (loc_sid)
                                             spo_location,
                                          SUM (inv_qty) qty_on_hand
                                     FROM tmp_amd_on_hand_invs
                                    WHERE     action_code != 'D'
                                          AND amd_utils.getSpoLocation (
                                                 loc_sid)
                                                 IS NOT NULL
                                 GROUP BY part_no,
                                          amd_utils.getSpoLocation (loc_sid))
                                onHandInvSum
                          WHERE     onHandInvSum.part_no = cur.part_no
                                AND onHandInvSum.spo_location =
                                       cur.spo_location)
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
         partNo         VARCHAR2,
         spoLocation    amd_on_hand_invs_sum.spo_location%TYPE)
      IS
           SELECT *
             FROM amd_on_hand_invs_sum
            WHERE     action_code != 'D'
                  AND part_no = partNo
                  AND spo_location = spoLocation
         ORDER BY part_no, spo_location;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.part_no, newRec.spo_location)
      LOOP
         result := amd_utils.isDiff (newRec.qty_on_hand, oldRec.qty_on_hand);
         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error: part_no '
            || newRec.part_no
            || ' spo_location='
            || newRec.spo_location
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (partNo         amd_on_hand_invs_sum.part_no%TYPE,
                      spoLocation    amd_on_hand_invs_sum.spo_location%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_on_hand_invs_sum
          WHERE     part_no = partNo
                AND spo_location = spoLocation
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
      RETURN amd_inventory.doOnHandInvsSumDiff (rec.part_no,
                                                rec.spo_location,
                                                rec.qty_on_hand,
                                                'A');
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.doOnHandInvsSumDiff (rec.Part_no,
                                                rec.spo_location,
                                                rec.qty_on_hand,
                                                'C');
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.doOnHandInvsSumDiff (rec.part_no,
                                                rec.spo_location,
                                                rec.qty_on_hand,
                                                'D');
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.part_no, newRec.spo_location)
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

PROMPT end onHandInvsSumDiff.sql
EXIT :rc
