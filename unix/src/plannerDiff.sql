-- vim: ff=unix:ts=2:sw=2=sts=2:et:
PROMPT run plannerDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready plannerDiff.sql
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




prompt rows in amd_planners 
select count(*) from amd_planners where action_code <> 'D' ;

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
      SELECT DISTINCT ims_designator_code planner_code
        FROM amd_use1
       WHERE     employee_status = 'A'
             AND SUBSTR (employee_no, 1, 1) IN ('1',
                                                '2',
                                                '3',
                                                '4',
                                                '5',
                                                '6',
                                                '7',
                                                '8',
                                                '9',
                                                '0')
             AND ims_designator_code IS NOT NULL
             AND LENGTH (ims_designator_code) = 3
      UNION
      SELECT uims.DESIGNATOR_CODE planner_code
        FROM uims
       WHERE LENGTH (designator_code) = 3
      UNION
      SELECT planner_code FROM amd_default_planners_v
      ORDER BY planner_code;

   CURSOR deleteRecs
   IS
      SELECT planner_code
        FROM amd_planners cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (SELECT DISTINCT
                                        ims_designator_code planner_code
                                   FROM amd_use1
                                  WHERE     employee_status = 'A'
                                        AND SUBSTR (employee_no, 1, 1) IN ('1',
                                                                           '2',
                                                                           '3',
                                                                           '4',
                                                                           '5',
                                                                           '6',
                                                                           '7',
                                                                           '8',
                                                                           '9',
                                                                           '0')
                                        AND ims_designator_code IS NOT NULL
                                        AND LENGTH (ims_designator_code) = 3
                                 UNION
                                 SELECT uims.DESIGNATOR_CODE planner_code
                                   FROM uims
                                  WHERE LENGTH (designator_code) = 3
                                 UNION
                                 SELECT planner_code
                                   FROM amd_default_planners_v) planners
                          WHERE planners.planner_code = cur.planner_code)
             AND action_code <> 'D';

   insertCnt      NUMBER := 0;
   insertErrCnt   NUMBER := 0;
   deleteCnt      NUMBER := 0;
   deleteErrCnt   NUMBER := 0;
   newCnt         NUMBER := 0;



   FUNCTION isInsert (plannerCode amd_planners.planner_code%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_planners
          WHERE planner_code = plannerCode AND action_code <> 'D';
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
      RETURN amd_load.InsertRow (rec.planner_code);
   END insertRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_load.deleteRow (rec.planner_code);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.planner_code)
      THEN
         IF insertRow (newRec) = 0
         THEN
            insertCnt := insertCnt + 1;
         ELSE
            insertErrCnt := insertErrCnt + 1;
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

   DBMS_OUTPUT.put_line ('deleteCnt=' || deleteCnt);

   IF deleteErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('deleteErrCnt=' || deleteErrCnt);
   END IF;

   IF insertErrCnt > 0 OR deleteErrCnt > 0
   THEN
      :rc := 4;
   ELSE
      :rc := 0;
   END IF;
END;
/

prompt rows inserted into amd_planners 
select count(*) from amd_planners where action_code = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM') ;

prompt rows deleted for amd_planners 
select count(*) from amd_planners where action_code = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM') ;

prompt rows in amd_planners 
select count(*) from amd_planners where action_code <> 'D';

PROMPT end plannerDiff.sql
EXIT :rc
