/* Formatted on 7/2/2016 11:32:43 PM (QP5 v5.256.13226.35538) */
-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run partFactorsDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready partFactorsDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 100000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



prompt rows in  amd_part_factors
select count(*) from amd_part_factors where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT tmp.part_no part_no,
               tmp.loc_sid loc_sid,
               tmp.pass_up_rate pass_up_rate,
               tmp.rts rts,
               tmp.cmdmd_rate cmdmd_rate,
               ansi.criticality_cleaned criticality_cleaned,
               ansi.criticality criticality,
               ansi.criticality_changed criticality_changed
          FROM tmp_amd_part_factors tmp,
               amd_national_stock_items ansi,
               amd_spare_parts asp
         WHERE     tmp.part_no = asp.part_no
               AND asp.nsn = ansi.nsn
               AND ansi.action_code != 'D'
               AND tmp.action_code != 'D'
               AND asp.action_code != 'D'
      ORDER BY tmp.part_no, tmp.loc_sid;

   CURSOR deleteRecs
   IS
      SELECT part_no, loc_sid
        FROM amd_part_factors cur
       WHERE     NOT EXISTS
                    (SELECT NULL
                       FROM tmp_amd_part_factors pf
                      WHERE part_no = cur.part_no AND loc_sid = cur.loc_sid)
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
      CURSOR curRecs (partNo    amd_part_factors.part_no%TYPE,
                      locSid    amd_part_factors.loc_sid%TYPE)
      IS
           SELECT part_no,
                  loc_sid,
                  pass_up_rate,
                  rts,
                  cmdmd_rate
             FROM amd_part_factors
            WHERE action_code != 'D' AND part_no = partNo AND loc_sid = locSid
         ORDER BY part_no;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.part_no, newRec.loc_sid)
      LOOP
         result := amd_utils.isDiff (newRec.pass_up_rate, oldRec.pass_up_rate);

         result := result OR amd_utils.isDiff (newRec.rts, oldRec.rts);

         result :=
            result OR amd_utils.isDiff (newRec.cmdmd_rate, oldRec.cmdmd_rate);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:part_no='
            || newRec.part_no
            || ' loc_sid='
            || newRec.loc_sid
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (partNo    amd_part_factors.part_no%TYPE,
                      locSid    amd_part_factors.loc_sid%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_part_factors
          WHERE part_no = partNo AND loc_sid = locSid AND action_code <> 'D';
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
      RETURN amd_part_factors_pkg.insertRow (rec.part_no,
                                             rec.loc_sid,
                                             rec.pass_up_rate,
                                             rec.rts,
                                             rec.cmdmd_rate,
                                             rec.criticality,
                                             rec.criticality_changed,
                                             rec.criticality_cleaned);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_part_factors_pkg.updateRow (rec.part_no,
                                             rec.loc_sid,
                                             rec.pass_up_rate,
                                             rec.rts,
                                             rec.cmdmd_rate,
                                             rec.criticality,
                                             rec.criticality_changed,
                                             rec.criticality_cleaned);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_part_factors_pkg.deleteRow (rec.part_no,
                                             rec.loc_sid);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;

      IF isInsert (newRec.part_no, newRec.loc_sid)
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

prompt rows inserted into  amd_part_factors
select count(*) from amd_part_factors where action_code =  'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_part_factors
select count(*) from amd_part_factors where action_code =  'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_part_factors
select count(*) from amd_part_factors where action_code =  'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_part_factors
select count(*) from amd_part_factors where action_code <>  'D';

PROMPT end partFactorsDiff.sql
EXIT :rc
