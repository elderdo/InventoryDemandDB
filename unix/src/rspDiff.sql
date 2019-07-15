-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run rspDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready rspDiff.sql
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



prompt rows in amd_rsp 
select count(*) from amd_rsp where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT part_no,
               loc_sid,
               rsp_inv,
               rsp_level
          FROM tmp_amd_rsp
      ORDER BY part_no, loc_sid;

   CURSOR deleteRecs
   IS
      SELECT part_no, loc_sid
        FROM amd_rsp cur
       WHERE     NOT EXISTS
                    (SELECT NULL
                       FROM tmp_amd_rsp
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
      CURSOR curRecs (partNo    amd_rsp.part_no%TYPE,
                      locSid    amd_rsp.loc_sid%TYPE)
      IS
           SELECT *
             FROM amd_rsp
            WHERE action_code != 'D' AND part_no = partNo AND loc_sid = locSid
         ORDER BY part_no, loc_sid;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.part_no, newRec.loc_sid)
      LOOP
         result := amd_utils.isDiff (newRec.rsp_inv, oldRec.rsp_inv);
         result :=
            result OR amd_utils.isDiff (newRec.rsp_level, oldRec.rsp_level);

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

   FUNCTION isInsert (partNo    amd_rsp.part_no%TYPE,
                      locSid    amd_rsp.loc_sid%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_rsp
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
      RETURN amd_inventory.RspInsertRow (rec.part_no,
                                         rec.loc_sid,
                                         rec.rsp_inv,
                                         rec.rsp_level);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.RspUpdateRow (rec.part_no,
                                         rec.loc_sid,
                                         rec.rsp_inv,
                                         rec.rsp_level);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.RspDeleteRow (rec.part_no, rec.loc_sid);
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

prompt rows inserted into amd_rsp 
select count(*) from amd_rsp where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_rsp 
select count(*) from amd_rsp where action_code = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_rsp 
select count(*) from amd_rsp where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_rsp 
select count(*) from amd_rsp where action_code <> 'D';
