-- vim ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run backorderDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready backorderDiff.sql
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



prompt rows in amd_backorder_sum
select count(*) from amd_backorder_sum where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT Amd_Utils.getSpoPrimePartNo (part_no) spo_prime_part_no,
               amd_utils.getSpoLocation (loc_sid) spo_location,
               SUM (quantity_due) sum_qty
          FROM tmp_amd_reqs
         WHERE amd_utils.getSpoLocation (loc_sid) IS NOT NULL
      GROUP BY Amd_Utils.getSpoPrimePartNo (part_no),
               amd_utils.getSpoLocation (loc_sid)
        HAVING amd_utils.getSpoPrimePartNo (part_no) IS NOT NULL
      ORDER BY Amd_Utils.getSpoPrimePartNo (part_no),
               amd_utils.getSpoLocation (loc_sid);

   CURSOR deleteRecs
   IS
      SELECT spo_prime_part_no, spo_location
        FROM amd_backorder_sum cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (  SELECT Amd_Utils.getSpoPrimePartNo (part_no)
                                             spo_prime_part_no,
                                          amd_utils.getSpoLocation (loc_sid)
                                             spo_location,
                                          SUM (quantity_due) sum_qty
                                     FROM tmp_amd_reqs
                                    WHERE amd_utils.getSpoLocation (loc_sid)
                                             IS NOT NULL
                                 GROUP BY Amd_Utils.getSpoPrimePartNo (
                                             part_no),
                                          amd_utils.getSpoLocation (loc_sid)
                                   HAVING amd_utils.getSpoPrimePartNo (
                                             part_no)
                                             IS NOT NULL) backOrderSum
                          WHERE     backOrderSum.spo_prime_part_no =
                                       cur.spo_prime_part_no
                                AND backOrderSum.spo_location =
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
         spoPrimePartNo    amd_backorder_sum.spo_prime_part_no%TYPE,
         spoLocation       amd_backorder_sum.spo_location%TYPE)
      IS
           SELECT *
             FROM amd_backorder_sum
            WHERE     action_code != 'D'
                  AND spo_prime_part_no = spoPrimePartNo
                  AND spo_location = spoLocation
         ORDER BY spo_prime_part_no, spo_location;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.spo_prime_part_no, newRec.spo_location)
      LOOP
         result := amd_utils.isDiff (newRec.sum_qty, oldRec.qty);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:spo_prime_part_no='
            || newRec.spo_prime_part_no
            || ' spo_location='
            || newRec.spo_location
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (
      spoPrimePartNo    amd_backorder_sum.spo_prime_part_no%TYPE,
      spoLocation       amd_backorder_sum.spo_location%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_backorder_sum
          WHERE     spo_prime_part_no = spoPrimePartNo
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
      RETURN amd_reqs_pkg.InsertRowBackorder (rec.spo_prime_part_no,
                                              rec.spo_location,
                                              rec.sum_qty);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_reqs_pkg.UpdateRowBackorder (rec.spo_prime_part_no,
                                              rec.spo_location,
                                              rec.sum_qty);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_reqs_pkg.DeleteRowBackorder (rec.spo_prime_part_no,
                                              rec.spo_location);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1 ;
      IF isInsert (newRec.spo_prime_part_no, newRec.spo_location)
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

prompt rows inserted into amd_backorder_sum
select count(*) from amd_backorder_sum where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_backorder_sum
select count(*) from amd_backorder_sum where action_code = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_backorder_sum
select count(*) from amd_backorder_sum where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_backorder_sum
select count(*) from amd_backorder_sum where action_code <> 'D' ;

PROMPT end backorderDiff.sql
EXIT :rc
