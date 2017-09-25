-- ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run usersDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready usersDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 100000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

prompt rows in amd_users
select count(*) from amd_users where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
      SELECT DISTINCT amd_load.getBemsId (employee_NO) bems_id,
                      stable_email,
                      last_name,
                      first_name
        FROM amd_use1, amd_people_all_v
       WHERE     employee_status = 'A'
             AND LENGTH (ims_designator_code) = 3
             AND amd_load.getBemsId (employee_no) = bems_id
      UNION
      SELECT amd_load.getBemsId (userid) bems_id,
             stable_email,
             last_name,
             first_name
        FROM uims, amd_people_all_v
       WHERE     LENGTH (designator_code) = 3
             AND amd_load.getBemsId (userid) = bems_id
      UNION
      SELECT bems_id,
             stable_email,
             last_name,
             first_name
        FROM amd_default_users_v
      ORDER BY bems_id;

   CURSOR deleteRecs
   IS
      SELECT bems_id
        FROM amd_users cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (SELECT DISTINCT
                                        amd_load.getBemsId (employee_NO)
                                           bems_id,
                                        stable_email,
                                        last_name,
                                        first_name
                                   FROM amd_use1, amd_people_all_v
                                  WHERE     employee_status = 'A'
                                        AND LENGTH (ims_designator_code) = 3
                                        AND amd_load.getBemsId (employee_no) =
                                               bems_id
                                 UNION
                                 SELECT amd_load.getBemsId (userid) bems_id,
                                        stable_email,
                                        last_name,
                                        first_name
                                   FROM uims, amd_people_all_v
                                  WHERE     LENGTH (designator_code) = 3
                                        AND amd_load.getBemsId (userid) =
                                               bems_id
                                 UNION
                                 SELECT bems_id,
                                        stable_email,
                                        last_name,
                                        first_name
                                   FROM amd_default_users_v) users
                          WHERE users.bems_id = cur.bems_id)
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
      CURSOR curRecs (bemsId amd_users.bems_id%TYPE)
      IS
           SELECT *
             FROM amd_users
            WHERE action_code != 'D' AND bems_id = bemsId
         ORDER BY bems_id;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec IN curRecs (newRec.bems_id)
      LOOP
         result := amd_utils.isDiff (newRec.stable_email, oldRec.stable_email);
         result :=
            result OR amd_utils.isDiff (newRec.last_name, oldRec.last_name);
         result :=
            result OR amd_utils.isDiff (newRec.first_name, oldRec.first_name);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
            'diff error:bems_id=' || newRec.bems_id || ' cnt=' || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (bemsId amd_users.bems_id%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_users
          WHERE bems_id = bemsId AND action_code <> 'D';
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
      RETURN amd_load.insertUsersRow (rec.bems_id,
                                      rec.stable_email,
                                      rec.last_name,
                                      rec.first_name);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_load.updateUsersRow (rec.bems_id,
                                      rec.stable_email,
                                      rec.last_name,
                                      rec.first_name);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_load.deleteUsersRow (rec.bems_id);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.bems_id)
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
   THEN DBMS_OUTPUT.put_line ('updateErrCnt=' || updateErrCnt); END IF;


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

prompt rows inserted into amd_users
select count(*) from amd_users where action_code = 'A' and trunc(last_update_dt) = trunc(sysdate);

prompt rows updated for amd_users
select count(*) from amd_users where action_code = 'C' and trunc(last_update_dt) = trunc(sysdate);

prompt rows deleted for amd_users
select count(*) from amd_users where action_code = 'D' and trunc(last_update_dt) = trunc(sysdate);

prompt rows in amd_users
select count(*) from amd_users where action_code <> 'D' ;

PROMPT end usersDiff.sql
EXIT :rc
