-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run lpOverrideConsumablesDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready lpOverrideConsumablesDiff.sql
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



prompt rows in amd_locpart_overid_consumables 
select count(*) from amd_locpart_overid_consumables where action_code <> 'D' ;

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT *
          FROM tmp_locpart_overid_consumables
      ORDER BY part_no, spo_location, tsl_override_type;

   CURSOR deleteRecs
   IS
      SELECT part_no,
             spo_location,
             tsl_override_type,
             tsl_override_user,
             tsl_override_source,
             tsl_override_qty,
             loc_sid
        FROM amd_locpart_overid_consumables cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM tmp_locpart_overid_consumables
                          WHERE     part_no = cur.part_no
                                AND spo_location = cur.spo_location
                                AND tsl_override_type = cur.tsl_override_type)
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
         partNo             amd_locpart_overid_consumables.part_no%TYPE,
         spoLocation        amd_locpart_overid_consumables.spo_location%TYPE,
         tslOverrideType    amd_locpart_overid_consumables.tsl_override_type%TYPE)
      IS
           SELECT *
             FROM amd_locpart_overid_consumables
            WHERE     action_code != 'D'
                  AND part_no = partNo
                  AND spo_location = spoLocation
                  AND tsl_override_type = tslOverrideType
         ORDER BY part_no;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec
         IN curRecs (newRec.part_no,
                     newRec.spo_location,
                     newRec.tsl_override_type)
      LOOP
         result :=
            amd_utils.isDiff (newRec.tsl_override_qty,
                              oldRec.tsl_override_qty);
         result :=
               result
            OR amd_utils.isDiff (newRec.tsl_override_user,
                                 oldRec.tsl_override_user);
         result :=
               result
            OR amd_utils.isDiff (newRec.tsl_override_source,
                                 oldRec.tsl_override_source);

         result := result OR amd_utils.isDiff (newRec.loc_sid, oldRec.loc_sid);

         cnt := cnt + 1;

         IF cnt > 1
         THEN
            DBMS_OUTPUT.put_line (
                  'diff error:part_no='
               || newRec.part_no
               || ' spo_location='
               || newRec.spo_location
               || ' tsl_override_type='
               || newRec.tsl_override_type
               || ' cnt='
               || cnt);
            diffError := TRUE;
         END IF;
      END LOOP;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (
      partNo             amd_locpart_overid_consumables.part_no%TYPE,
      spoLocation        amd_locpart_overid_consumables.spo_location%TYPE,
      tslOverrideType    amd_locpart_overid_consumables.tsl_override_type%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_locpart_overid_consumables
          WHERE     part_no = partNo
                AND spo_location = spoLocation
                AND tsl_override_type = tslOverrideType
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
      RETURN amd_lp_override_consumabl_pkg.doLPOverrideConsumablesDiff (
                rec.part_no,
                rec.spo_location,
                rec.tsl_override_type,
                rec.tsl_override_user,
                rec.tsl_override_source,
                rec.tsl_override_qty,
                rec.loc_sid,
                'A');
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_lp_override_consumabl_pkg.doLPOverrideConsumablesDiff (
                rec.part_no,
                rec.spo_location,
                rec.tsl_override_type,
                rec.tsl_override_user,
                rec.tsl_override_source,
                rec.tsl_override_qty,
                rec.loc_sid,
                'C');
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_lp_override_consumabl_pkg.doLPOverrideConsumablesDiff (
                rec.part_no,
                rec.spo_location,
                rec.tsl_override_type,
                rec.tsl_override_user,
                rec.tsl_override_source,
                rec.tsl_override_qty,
                rec.loc_sid,
                'D');
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.part_no,
                   newRec.spo_location,
                   newRec.tsl_override_type)
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

prompt rows inserted into amd_locpart_overid_consumables 
select count(*) from amd_locpart_overid_consumables where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM') ;

prompt rows updated for amd_locpart_overid_consumables 
select count(*) from amd_locpart_overid_consumables where action_code = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM') ;

prompt rows deleted for amd_locpart_overid_consumables 
select count(*) from amd_locpart_overid_consumables where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM') ;

prompt rows in amd_locpart_overid_consumables 
select count(*) from amd_locpart_overid_consumables where action_code <> 'D';

PROMPT end lpOverrideConsumablesDiff.sql
EXIT :rc
