-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run backOrderSpoSumDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready backOrderSpoSumDiff.sql
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
        SELECT spo_prime_part_no, SUM (qty) qty
          FROM (  SELECT part_no, loc_sid, SUM (quantity_due) qty
                    FROM tmp_amd_reqs
                GROUP BY part_no, loc_sid
                ORDER BY part_no) reqs,
               amd_sent_to_a2a sent
         WHERE     reqs.part_no = sent.part_no
               AND sent.action_code <> 'D'
               AND amd_utils.getSpoLocation (reqs.loc_sid) IS NOT NULL
               AND sent.spo_prime_part_no IS NOT NULL
      GROUP BY spo_prime_part_no;

   CURSOR deleteRecs
   IS
      SELECT spo_prime_part_no
        FROM amd_backorder_spo_sum cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (  SELECT spo_prime_part_no, SUM (qty) qty
                                     FROM (  SELECT part_no,
                                                    loc_sid,
                                                    SUM (quantity_due) qty
                                               FROM tmp_amd_reqs
                                           GROUP BY part_no, loc_sid
                                           ORDER BY part_no) reqs,
                                          amd_sent_to_a2a sent
                                    WHERE     reqs.part_no = sent.part_no
                                          AND sent.action_code <> 'D'
                                          AND amd_utils.getSpoLocation (
                                                 reqs.loc_sid)
                                                 IS NOT NULL
                                          AND sent.spo_prime_part_no
                                                 IS NOT NULL
                                 GROUP BY spo_prime_part_no) backOrderSpoSum
                          WHERE backOrderSpoSum.spo_prime_part_no =
                                   cur.spo_prime_part_no)
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
         spoPrimePartNo    amd_backorder_spo_sum.spo_prime_part_no%TYPE)
      IS
           SELECT *
             FROM amd_backorder_spo_sum
            WHERE action_code != 'D' AND spo_prime_part_no = spoPrimePartNo
         ORDER BY spo_prime_part_no;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.spo_prime_part_no)
      LOOP
         result := amd_utils.isDiff (newRec.qty, oldRec.qty);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:spo_prime_part_no='
            || newRec.spo_prime_part_no
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (
      spoPrimePartNo    amd_backorder_spo_sum.spo_prime_part_no%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_backorder_spo_sum
          WHERE spo_prime_part_no = spoPrimePartNo AND action_code <> 'D';
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
      RETURN amd_reqs_pkg.InsertRowSpoSum (rec.spo_prime_part_no, rec.qty);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_reqs_pkg.UpdateRowSpoSum (rec.spo_prime_part_no, rec.qty);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_reqs_pkg.DeleteRowSpoSum (rec.spo_prime_part_no);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1 ;
      IF isInsert (newRec.spo_prime_part_no)
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

PROMPT end backOrderSpoSumDiff.sql
EXIT :rc
